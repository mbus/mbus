# TCL script for Design Compiler

# Load common variables, artisan standard cells
source -verbose "common.tcl"

# Set top level name
set top_level "ulpb_node32"

# Read verilog files
read_verilog "../verilog/ulpb_node32.v ../verilog/ulpb_swapper.v"
analyze -format verilog "../verilog/ulpb_node32.v ../verilog/ulpb_swapper.v"
elaborate $top_level -param "ADDRESS=8'hcd"
#current_design $top_level

list_designs

# Read timing constrints
# Set clock names, ports
source -verbose "ulpb_node_timing.tcl"

# Register retiming
#set_balance_registers

# Link the design
link

# Set maximum fanout of gates
set_max_fanout 5 $top_level 

# Configure the clock network
set_fix_hold [all_clocks] 
set_dont_touch_network $clk_port 

# Set delays: Input, Output
set_driving_cell -lib_cell INVX2TR [all_inputs]
#set_driving_cell -lib_cell INVX2TR [all_inputs] -library typical
set_input_delay $typical_input_delay [all_inputs] -clock $clk_name 
remove_input_delay -clock $clk_name [find port $clk_port]
set_output_delay $typical_output_delay [all_outputs] -clock $clk_name 

# Set loading of outputs 
set_load $typical_wire_load [all_outputs] 

# Verify the design
check_design

# Uniquify repeated modules
uniquify

# Synthesize the design
#compile -map_effort medium
compile -map_effort medium

# Rename modules, signals according to the naming rules
# Used for tool exchange
source -verbose "namingrules.tcl"

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${current_design}.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${current_design}.dc.sdf"

# Generate report file
set maxpaths 20
set rpt_file "${current_design}.dc.rpt"

check_design > $rpt_file
report_area  >> ${rpt_file}
report_power -hier -analysis_effort medium >> ${rpt_file}
report_design >> ${rpt_file}
report_cell >> ${rpt_file}
report_port -verbose >> ${rpt_file}
report_compile_options >> ${rpt_file}
report_constraint -all_violators -verbose >> ${rpt_file}
report_timing -path full -delay max -max_paths $maxpaths -nworst 100 >> ${rpt_file}

#Exit dc_shell
quit
