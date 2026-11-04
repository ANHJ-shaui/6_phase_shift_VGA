library verilog;
use verilog.vl_types.all;
entity EG_PHY_BANKREF is
    generic(
        INR             : string  := "OFF";
        LVDS            : string  := "OFF";
        VOD             : string  := "350m";
        VCM             : string  := "1.2";
        INR_STDBY       : string  := "DISABLE";
        LVDS_STDBY      : string  := "DISABLE";
        DIFFRESISTOR    : string  := "NONE"
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INR : constant is 1;
    attribute mti_svvh_generic_type of LVDS : constant is 1;
    attribute mti_svvh_generic_type of VOD : constant is 1;
    attribute mti_svvh_generic_type of VCM : constant is 1;
    attribute mti_svvh_generic_type of INR_STDBY : constant is 1;
    attribute mti_svvh_generic_type of LVDS_STDBY : constant is 1;
    attribute mti_svvh_generic_type of DIFFRESISTOR : constant is 1;
end EG_PHY_BANKREF;
