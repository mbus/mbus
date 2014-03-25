# common_tsmc18.tcl setup library files

# ARM std cell library for TSMC 180nm
# Set library paths
set search_path [list "." "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/synopsys/"]

set link_library "* typical.db"
set target_library "typical.db"

set hdlin_auto_save_templates true
set hdlout_internal_busses true
set verilogout_single_bit false
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
