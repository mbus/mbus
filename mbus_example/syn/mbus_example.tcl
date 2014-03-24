# TCL script for Design Compiler

# Load common variables, artisan standard cells
source -verbose "./common_tsmc18.tcl"

#Load all the hand-written netlist fake libraries
set search_path [concat $search_path "./libs"]
set link_library [concat $link_library \
		      ablk_lib.db \
		      clkgen_lib.db \
		      lc_header_lib.db \
		      lc_mbc_iso_lib.db \
		      mbc_header_lib.db \
		      mbus_addr_rf_lib.db \
		      mbus_int_ctrl_lib.db \
		      mbus_regular_sleep_ctrl_lib.db \
		      mbus_wire_ctrl_lib.db \
		      rf_lib.db \
		      rstdtctr_lib.db \
		     ]
set target_library [concat $target_library]

# Set top level name
set top_level "mbus_example"

# Read verilog files
read_verilog "  ../../mbus/verilog/mbus_swapper.v \
		../../mbus/verilog/mbus_node.v \
		../../layer_controller/verilog/layer_ctrl.v \
		../verilog/mbus_example_def.v \
		../verilog/mbus_example_test_def.v \
		../verilog/timer.v \
		../verilog/mbus_example.v \
		"

analyze -format verilog "	../../mbus/verilog/mbus_swapper.v \
				../../mbus/verilog/mbus_node.v \
				../../layer_controller/verilog/layer_ctrl.v \
				../verilog/mbus_example_def.v \
				../verilog/mbus_example_test_def.v \
				../verilog/timer.v \
				../verilog/mbus_example.v \
			"

current_design $top_level

list_designs

# Read timing constrints
# Set clock names, ports
source -verbose "./mbus_example_timing.tcl"

# Link the design
link

# Set maximum fanout of gates
set_max_fanout 4 $top_level 

# Configure the clock network
set_dont_touch_network $mbus_clk_port
set_dont_touch_network $lc_clk_port

# Don't do anything with all the following
# Does not have outputs, will get optimized away
set_dont_touch ablk_0
set_dont_touch clkgen_0
set_dont_touch lc_header_0
set_dont_touch mbc_header_0

# Verify the design
check_design

# Uniquify repeated modules
uniquify

# Synthesize the design
set compile_no_new_cells_at_top_level true
compile_ultra -no_boundary_optimization -no_autoungroup

# Rename modules, signals according to the naming rules
# Used for tool exchange
source -verbose "./namingrules.tcl"

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${top_level}.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${top_level}.pt.sdf"
#Write SDC file
write_sdc "${current_design}.sdc"

#Reporting
set rpt_file "${top_level}.dc.rpt"
# Generate report file
set maxpaths 20
check_design > $rpt_file
#Ungroup Hierarchy and report area & cell
ungroup -all
report_area  >> ${rpt_file}
report_cell >> ${rpt_file}
report_power -analysis_effort high -verbose >> ${rpt_file}
report_power -net -include_input_nets -nworst 10 >> ${rpt_file}
report_design >> ${rpt_file}
report_port -verbose >> ${rpt_file}
report_compile_options >> ${rpt_file}
report_constraint -all_violators -verbose >> ${rpt_file}
report_timing -path full -delay max -max_paths $maxpaths -nworst 100 >> ${rpt_file}

#Exit dc_shell
quit
