#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
静态一致性检查：模块端口声明 <-> 例化连接 <-> .adc 引脚约束

在把工程丢进 TD 之前，先把"名字对不上"这类错误找出来。
TD 里这类问题要等到实现阶段才报（例如 vga_hs 找不到引脚），来回一轮很慢。

用法：
    python check_ports.py [src目录]      # 默认当前目录
"""
import re
import sys
from pathlib import Path

SRC = Path(sys.argv[1] if len(sys.argv) > 1 else ".")


def strip_comments(text):
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    text = re.sub(r"//[^\n]*", " ", text)
    return text


def match_paren(txt, i):
    """i 指向 '('，返回与之配平的 ')' 的下标；找不到返回 -1"""
    depth = 0
    while i < len(txt):
        if txt[i] == "(":
            depth += 1
        elif txt[i] == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def skip_params(txt, i):
    """跳过紧跟在 module 名之后的 #( ... ) 参数表，返回其后的起始位置

    这一条是必须的：key_debounce / freq_counter / wave_capture / wave_ram / xy_scope
    都是 `module xxx #(parameter ...) ( 端口 )` 的写法。若直接从 module 名往后找
    第一个 '('，命中的会是参数表的括号，端口表就被误当成"没有端口"。
    """
    j = i
    while j < len(txt) and txt[j] in " \t\r\n":
        j += 1
    if j < len(txt) and txt[j] == "#":
        k = txt.find("(", j)
        if k < 0:
            return i
        e = match_paren(txt, k)
        return e + 1 if e > 0 else i
    return i


def split_top(body):
    """按顶层逗号切分（忽略括号内的逗号）"""
    parts, buf, dep = [], "", 0
    for ch in body:
        if ch in "([":
            dep += 1
        elif ch in ")]":
            dep -= 1
        if ch == "," and dep == 0:
            parts.append(buf)
            buf = ""
        else:
            buf += ch
    parts.append(buf)
    return parts


TYPE_KW = {"wire", "reg", "signed", "unsigned", "logic", "tri", "var"}

# ---------- 1. 解析所有模块的端口 ----------
modules = {}   # name -> {"ports": {name: (dir, width)}, "file": Path}
for vf in sorted(SRC.glob("*.v")):
    txt = strip_comments(vf.read_text(encoding="utf-8", errors="ignore"))
    for m in re.finditer(r"\bmodule\s+(\w+)", txt):
        name = m.group(1)
        start = skip_params(txt, m.end())          # 先跳过 #(parameter ...)
        i = txt.find("(", start)
        if i < 0:
            continue
        j = match_paren(txt, i)
        if j < 0:
            continue
        ports, cur_dir, cur_w = {}, None, 1
        for p in split_top(txt[i + 1:j]):
            p = p.strip()
            if not p:
                continue
            md = re.search(r"\b(input|output|inout)\b", p)
            if md:
                cur_dir = md.group(1)
                mw = re.search(r"\[\s*([^:\]]+)\s*:\s*([^\]]+)\s*\]", p)
                if mw:
                    try:
                        cur_w = abs(int(eval(mw.group(1), {}, {})) - int(eval(mw.group(2), {}, {}))) + 1
                    except Exception:
                        cur_w = 1
                else:
                    cur_w = 1
                tail = re.sub(r"\[[^\]]*\]", " ", p[md.end():])
            elif cur_dir:
                tail = re.sub(r"\[[^\]]*\]", " ", p)
            else:
                continue
            for nm in re.findall(r"\b([A-Za-z_]\w*)\b", tail):
                if nm in TYPE_KW:
                    continue
                ports[nm] = (cur_dir, cur_w)
        modules[name] = {"ports": ports, "file": vf}

print("== 已解析模块 ==")
for k, v in modules.items():
    print(f"  {k:16s} {len(v['ports']):2d} ports  ({v['file'].name})")

# ---------- 2. 检查例化 ----------
problems = []
print("\n== 例化端口检查 ==")
for vf in sorted(SRC.glob("*.v")):
    txt = strip_comments(vf.read_text(encoding="utf-8", errors="ignore"))
    for m in re.finditer(r"\b(\w+)\s*#?\s*(?:\([^;]*?\)\s*)?(\w+)\s*\(", txt):
        mod, inst = m.group(1), m.group(2)
        if mod not in modules:
            continue
        i = m.end() - 1                 # 正则末尾吞掉的就是连接列表的 '('
        if i < 0 or txt[i] != "(":
            continue
        j = match_paren(txt, i)
        if j < 0:
            continue
        body = txt[i + 1:j]
        conns = re.findall(r"\.(\w+)\s*\(", body)
        if not conns:
            continue
        declared = set(modules[mod]["ports"].keys())
        missing = [c for c in conns if c not in declared]
        if missing:
            problems.append(f"{vf.name}: 例化 {mod} {inst} 用了模块里不存在的端口 {missing}")
        else:
            n_unconn = len(declared) - len(conns)
            tag = "" if n_unconn == 0 else f"  [{n_unconn} 个端口未连接]"
            print(f"  OK  {vf.name:20s} {mod} {inst}  ({len(conns)}/{len(declared)}){tag}")

# ---------- 3. 顶层端口 vs .adc 约束 ----------
print("\n== 约束 vs 顶层端口 ==")
top = "adda_direct"
if top in modules:
    tports = set(modules[top]["ports"].keys())
    adc = SRC / (top + ".adc")
    if adc.exists():
        atxt = strip_comments(adc.read_text(encoding="utf-8", errors="ignore"))
        pins = [p.strip() for p in re.findall(r"set_pin_assignment\s*\{\s*([^}]+?)\s*\}", atxt)]
        bad, seen = [], set()
        for p in pins:
            base = re.sub(r"\[\d+\]$", "", p)
            seen.add(base)
            if base not in tports:
                bad.append(p)
        if bad:
            problems.append(f".adc 约束了顶层不存在的信号: {bad}")
        else:
            print(f"  OK  {len(pins)} 条引脚约束全部能在顶层端口里找到")
        unconstrained = sorted(tports - seen)
        if unconstrained:
            print(f"  [提示] 顶层有、但约束未分配引脚的端口: {unconstrained}")
else:
    print(f"  找不到顶层模块 {top}")

# ---------- 汇总 ----------
print("\n== 结果 ==")
if problems:
    for p in problems:
        print("  [错误] " + p)
    sys.exit(1)
print("  全部通过")
