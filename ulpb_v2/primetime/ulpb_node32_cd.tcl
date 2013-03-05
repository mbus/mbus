# Load common variables, artisan standard cells
source -verbose "./common.tcl"

# Set top level name
set top_level "ulpb_node32_cd"

# Read verilog files
read_verilog ../netlist/${top_level}.nl.v
list_designs
current_design $top_level

# Read timing constrints
# Set clock names, ports
read_sdc ../syn/${top_level}.sdc
read_sdf ../syn/${top_level}.dc.sdf

set power_enable_analysis true
set power_ui_backward_compatibility true

#read_vcd -time {0 20 50 -1} ../waves.vcd
read_vcd ../netlist/tb_ulpb_node32.vcd -strip_path tb_ulpb_node32/n1/

update_power

estimate_clock_network_power typical/BUFX2

update_power

#create_power_waveforms -output foo -format out

report_power -verbose -include_estimated_clock_network  > "${top_level}.power.rpt"
report_power -clocks CLKIN  > "${top_level}.power.rpt"
report_power -cell -clocks CLKIN  > "${top_level}.power.rpt"

#exit
