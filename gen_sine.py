import math

N = 512          # 点数：从 256 改成 512
AMP = 1500       # 幅度
OFFSET = 2048    # 中值（12位无符号，范围0~4095）

with open('sine.mem', 'w') as f:
    for i in range(N):
        val = int(OFFSET + AMP * math.sin(2 * math.pi * i / N))
        if val < 0:
            val = 0
        if val > 4095:
            val = 4095
        f.write(f"{val:03x}\n")