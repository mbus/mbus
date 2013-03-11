# Load common variables, artisan standard cells
# SHOULD ONLY DO APR! Tests!
source -verbose "./common.tcl"

# Set top level name
set top_level "ulpb_node32_ef"

# Read verilog files
read_verilog ../apr/${top_level}/${top_level}.apr.v
list_designs
current_design $top_level

# Read timing constrints
# Set clock names, ports
read_parasitic -pin_cap_included ../apr/${top_level}/${top_level}.spef
read_sdc ../apr/${top_level}/${top_level}.sdc
read_sdf ../apr/${top_level}/${top_level}.apr.sdf

set power_enable_analysis true
set power_ui_backward_compatibility true

read_vcd ../verilog/task0.vcd -strip_path tb_ulpb_node32/n2/
#read_vcd ../verilog/task1.vcd -strip_path tb_ulpb_node32/n2/
#read_vcd ../verilog/task2.vcd -strip_path tb_ulpb_node32/n2/
#read_vcd ../verilog/task3_1.vcd -strip_path tb_ulpb_node32/n2/
#read_vcd ../verilog/task3_2.vcd -strip_path tb_ulpb_node32/n2/
update_power

#Reporting
source -verbose "./reporting.tcl"

exit
