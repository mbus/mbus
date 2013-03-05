# TCL script for Design Compiler

# Load common variables, artisan standard cells
source -verbose "common.tcl"

# Set top level name
set top_level "ulpb_ctrl_wrapper"

# Read verilog files
read_verilog "../verilog/ulpb_ctrl.v ../verilog/ulpb_swapper.v ../verilog/ulpb_node32.v ../verilog/ulpb_ctrl_wrapper.v"
analyze -format verilog "../verilog/ulpb_ctrl.v ../verilog/ulpb_swapper.v ../verilog/ulpb_node32.v ../verilog/ulpb_ctrl_wrapper.v"
elaborate $top_level 
#current_design $top_level

list_designs

# Read timing constrints
# Set clock names, ports
source -verbose "ulpb_ctrl_timing.tcl"
set_clock_sense -logical_stop_propagation [get_clocks CLK_EXT]

# Read common settings
source -verbose "ulpb_node_common_settings.tcl"

# Synthesize the design
#compile -map_effort medium
compile_ultra

# Rename modules, signals according to the naming rules
# Used for tool exchange
source -verbose "namingrules.tcl"

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${current_design}.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${top_level}.dc.sdf"
#Write SDC file
write_sdc "${current_design}.sdc"

# Generate report file
set maxpaths 20
set rpt_file "${current_design}.dc.rpt"

check_design > $rpt_file
report_area  >> ${rpt_file}
report_power -hier -analysis_effort medium >> ${rpt_file}
report_power -verbose >> ${rpt_file}
report_power -net -include_input_power
report_design >> ${rpt_file}
report_cell >> ${rpt_file}
report_port -verbose >> ${rpt_file}
report_compile_options >> ${rpt_file}
report_constraint -all_violators -verbose >> ${rpt_file}
report_timing -path full -delay max -max_paths $maxpaths -nworst 100 >> ${rpt_file}

#Exit dc_shell
quit
