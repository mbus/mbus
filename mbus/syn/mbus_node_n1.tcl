# TCL script for Design Compiler

# Load common variables, artisan standard cells
source -verbose "common.tcl"

# Set top level name
set top_level "mbus_node"

# Read verilog files
read_verilog "../verilog/mbus_node.v ../verilog/mbus_swapper.v"
analyze -format verilog "../verilog/mbus_node.v ../verilog/mbus_swapper.v"
elaborate $top_level -param "ADDRESS=20'hbbbb1"
current_design $top_level

list_designs

# Read timing constrints
# Set clock names, ports
source -verbose "mbus_node_timing.tcl"

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
write -hierarchy -format verilog -output "${top_level}_n1.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${top_level}_n1.pt.sdf"
#Write SDC file
write_sdc "${top_level}_n1.sdc"

#Reporting
set rpt_file "${top_level}_n1.dc.rpt"
source -verbose "common_report.tcl"

#Exit dc_shell
quit
