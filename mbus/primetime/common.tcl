# common.tcl setup library files

# TSMC180 Library
# Set library paths
set search_path [list "." "/afs/eecs.umich.edu/kits/.contrib/arm_mosis_tsmc_180/LIT/sc-x_2004q3v1/aci/sc/synopsys/"]

set target_library "typical.db"
set link_library [concat * typical.db]

set hdlin_auto_save_templates true
set hdlout_internal_busses true
set verilogout_single_bit false
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}

