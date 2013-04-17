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

# Read common settings
source -verbose "ulpb_node_common_settings.tcl"

# Synthesize the design
#compile -map_effort medium
compile_ultra 
#compile_ultra -gate_clock

# Rename modules, signals according to the naming rules
# Used for tool exchange
source -verbose "namingrules.tcl"

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${current_design}.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${current_design}.pt.sdf"
#Write SDC file
write_sdc "${current_design}.sdc"

#Reporting
source -verbose "common_report.tcl"

#Exit dc_shell
quit
