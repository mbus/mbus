# common.tcl setup library files

# TSMC180 Library
# Set library paths
#set search_path [list "." "/afs/eecs.umich.edu/kits/.contrib/arm_mosis_tsmc_180/LIT/sc-x_2004q3v1/aci/sc/synopsys/" "/afs/eecs.umich.edu/vlsida/projects/LIT/syn/NAND_FLASH_CTRL/"]
set search_path [list "." "/afs/eecs.umich.edu/kits/.contrib/arm_mosis_tsmc_180/LIT/sc-x_2004q3v1/aci/sc/synopsys/"]

#set target_library "typical.db slow.db fast.db NAND_BUF.db"
#set link_library [concat * typical.db slow.db fast.db NAND_BUF.db]
set target_library "typical.db slow.db fast.db"
set link_library [concat * typical.db slow.db fast.db]
# set target_library "typical.db"
# set link_library [concat * typical.db]

set hdlin_auto_save_templates true
set hdlout_internal_busses true
set verilogout_single_bit false
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}

#NO LOW LEAK OR CLOCK CELLS!
#set_dont_use typical/*XL
#set_dont_use typical/CLK*

#GET RID OF ASSIGN STATEMENTS
#set compile_fix_multiple_port_nets true
#NO TRISTATES!
#set verilogout_no_tri true

