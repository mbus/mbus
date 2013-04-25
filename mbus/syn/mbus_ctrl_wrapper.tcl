# TCL script for Design Compiler

# Load common variables, artisan standard cells
source -verbose "common.tcl"

# Set top level name
set top_level "mbus_ctrl_wrapper"

# Read verilog files
read_verilog "../verilog/mbus_ctrl.v ../verilog/mbus_swapper.v ../verilog/mbus_node.v ../verilog/mbus_ctrl_wrapper.v"
analyze -format verilog "../verilog/mbus_ctrl.v ../verilog/mbus_swapper.v ../verilog/mbus_node.v ../verilog/mbus_ctrl_wrapper.v"
elaborate $top_level  -param "ADDRESS=20'haaaa0"
current_design $top_level

list_designs

# Read timing constrints
# Set clock names, ports
source -verbose "mbus_ctrl_wrapper_timing.tcl"
set_clock_sense -logical_stop_propagation [get_clocks CLK_EXT]

# Read common settings
source -verbose "mbus_node_common_settings.tcl"

# Synthesize the design
#compile -map_effort medium
compile_ultra 
#compile_ultra -gate_clock

# Rename modules, signals according to the naming rules
# Used for tool exchange
source -verbose "namingrules.tcl"

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${top_level}.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${top_level}.pt.sdf"
#Write SDC file
write_sdc "${current_design}.sdc"

#Reporting
set rpt_file "${top_level}.dc.rpt"
source -verbose "common_report.tcl"

#Exit dc_shell
quit
