# TCL script for Design Compiler

# Load common variables, artisan standard cells
source -verbose "common.tcl"

# Set top level name
set top_level "layer_ctrl"

# Read verilog files
read_verilog "../verilog/layer_ctrl.v" 
analyze -format verilog "../verilog/layer_ctrl.v"
current_design $top_level

list_designs

# Read timing constrints
# Set clock names, ports
source -verbose "layer_ctrl_timing.tcl"

# Link the design
link

# Set maximum fanout of gates
set_max_fanout 4 $top_level 

# Configure the clock network
set_fix_hold [all_clocks] 
set_dont_touch_network $clk_port

# Set delays: Input, Output
set_driving_cell -lib_cell INVX2 [all_inputs]
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
compile_ultra 

# Rename modules, signals according to the naming rules
# Used for tool exchange
source -verbose "namingrules.tcl"

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${top_level}.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${top_level}.pt.sdf"
#Write SDC file
write_sdc "${top_level}.sdc"

#Reporting
set rpt_file "${top_level}.dc.rpt"
source -verbose "common_report.tcl"

#Exit dc_shell
quit
