#####################################################################
# TCL script for Design Compiler used to synthesize MBUS's layer_ctrl
# 
# 
# Last Modified Date: May 23 2013
# Last Modified By: ZhiYoong Foo <zhiyoong@umich.edu>
# Update Log:
# May 23 2013
# First Added
#####################################################################


#####################################################################
# Set Vars
#####################################################################

# Set top level name
set top_level "layer_ctrl"

# Set Library
set SYNOPSYS [get_unix_variable SYNOPSYS]
set search_path [list "." ${SYNOPSYS}/libraries/syn]
set synthetic_library "standard.sldb dw_foundation.sldb"
set target_library "gtech.db"
set link_library [concat "*" $target_library $synthetic_library]

# Set Clock
set clk_port "CLK"
set clk_period 2500
set clk_uncertainty 1
set clk_transition 1

set typical_input_delay 0.100
set typical_output_delay 0.100
set typical_output_load 0.010 

#Set layer_ctrl parameters
set LC_RF_DATA_WIDTH 24
set LC_RF_ADDR_WIDTH 6
set LC_RF_DEPTH 64
set LC_MEM_ADDR_WIDTH 12
set LC_MEM_DATA_WIDTH 32
set LC_MEM_DEPTH 1024
set LC_INT_DEPTH 4
#####################################################################
# Synthesize
#####################################################################

# Read verilog files
read_verilog "../verilog/layer_ctrl.v" 
analyze -format verilog "../verilog/layer_ctrl.v"
elaborate layer_ctrl -param 	"LC_RF_DATA_WIDTH = $LC_RF_DATA_WIDTH, \
					 LC_RF_ADDR_WIDTH = $LC_RF_ADDR_WIDTH, \
					 LC_RF_DEPTH = $LC_RF_DEPTH, \
					 LC_MEM_ADDR_WIDTH = $LC_MEM_ADDR_WIDTH, \
					 LC_MEM_DATA_WIDTH = $LC_MEM_DATA_WIDTH, \
					 LC_MEM_DEPTH = $LC_MEM_DEPTH, \
					 LC_INT_DEPTH = $LC_INT_DEPTH \
					"
# Timing setup for synthesis
create_clock -name $clk_port -period $clk_period [get_ports $clk_port] 
set_drive 0 [get_clocks $clk_port] 
set_clock_uncertainty $clk_uncertainty [get_clocks $clk_port]
set_clock_transition $clk_transition [get_clocks $clk_port]

# Link the design
link

# Set maximum fanout of gates
set_max_fanout 4 $top_level

# Configure the clock network
set_fix_hold [all_clocks] 

# Set Input Output Constraints
set_input_delay $typical_input_delay [all_inputs] -clock $clk_port 
remove_input_delay -clock $clk_port [find port $clk_port]
set_output_delay $typical_output_delay [all_outputs] -clock $clk_port 
set_load $typical_output_load [all_outputs]

# Verify the design
check_design

# Uniquify repeated modules
uniquify

# Synthesize the design
compile_ultra 

# Rename modules, signals according to the naming rules
# Used for tool exchange

define_name_rules asic_port_rules -type port \
				  -allowed {a-z A-Z 0-9 _ () []} \
				  -max_length 255 \
				  -reserved_words [list "always" "and" "assign" "begin" "buf" "bufif0" "bufif1" "case" "casex" "casez" "cmos" "deassign" "default" "defparam" "disable" "edge" "else" "end" "endcase" "endfunction" "endmodule" "endprimitive" "endspecify" "endtable" "endtask" "event" "for" "force" "forever" "fork" "function" "highz0" "highz1" "if" "initial" "inout" "input" "integer" "join" "large" "macromodule" "medium" "module" "nand" "negedge" "nmos" "nor" "not" "notif0" "notif1" "or" "output" "pmos" "posedge" "primitive" "pull0" "pull1" "pulldown" "pullup" "rcmos" "reg" "release" "repeat" "rnmos" "rpmos" "rtran" "rtranif0" "rtranif1" "scalered" "small" "specify" "specparam" "strong0" "strong1" "supply0" "supply1" "table" "task" "time" "tran" "tranif0" "tranif1" "tri" "tri0" "tri1" "triand" "trior" "vectored" "wait" "wand" "weak0" "weak1" "while" "wire" "wor" "xnor" "xor" "abs" "access" "after" "alias" "all" "and" "architecture" "array" "assert" "attribute" "begin" "block" "body" "buffer" "bus" "case" "component" "configuration" "constant" "disconnect" "downto" "else" "elsif" "end" "entity" "exit" "file" "for" "function" "generate" "generic" "guarded" "if" "in" "inout" "is" "label" "library" "linkage" "loop" "map" "mod" "nand" "new" "next" "nor" "not" "null" "of" "on" "open" "or" "others" "out" "package" "port" "procedure" "process" "range" "record" "register" "rem" "report" "return" "select" "severity" "signal" "subtype" "then" "to" "transport" "type" "units" "until" "use" "variable" "wait" "when" "while" "with" "xor"] \
				  -case_insensitive \
				  -first_restricted {_ 0-9} \
				  -last_restricted {_} \
				  -replacement_char {_} \

define_name_rules asic_cell_rules -type cell \
				  -allowed {a-z A-Z 0-9 _} \
				  -max_length 255 \
				  -reserved_words [list "always" "and" "assign" "begin" "buf" "bufif0" "bufif1" "case" "casex" "casez" "cmos" "deassign" "default" "defparam" "disable" "edge" "else" "end" "endcase" "endfunction" "endmodule" "endprimitive" "endspecify" "endtable" "endtask" "event" "for" "force" "forever" "fork" "function" "highz0" "highz1" "if" "initial" "inout" "input" "integer" "join" "large" "macromodule" "medium" "module" "nand" "negedge" "nmos" "nor" "not" "notif0" "notif1" "or" "output" "pmos" "posedge" "primitive" "pull0" "pull1" "pulldown" "pullup" "rcmos" "reg" "release" "repeat" "rnmos" "rpmos" "rtran" "rtranif0" "rtranif1" "scalered" "small" "specify" "specparam" "strong0" "strong1" "supply0" "supply1" "table" "task" "time" "tran" "tranif0" "tranif1" "tri" "tri0" "tri1" "triand" "trior" "vectored" "wait" "wand" "weak0" "weak1" "while" "wire" "wor" "xnor" "xor" "abs" "access" "after" "alias" "all" "and" "architecture" "array" "assert" "attribute" "begin" "block" "body" "buffer" "bus" "case" "component" "configuration" "constant" "disconnect" "downto" "else" "elsif" "end" "entity" "exit" "file" "for" "function" "generate" "generic" "guarded" "if" "in" "inout" "is" "label" "library" "linkage" "loop" "map" "mod" "nand" "new" "next" "nor" "not" "null" "of" "on" "open" "or" "others" "out" "package" "port" "procedure" "process" "range" "record" "register" "rem" "report" "return" "select" "severity" "signal" "subtype" "then" "to" "transport" "type" "units" "until" "use" "variable" "wait" "when" "while" "with" "xor"] \
				  -case_insensitive \
				  -first_restricted {_ 0-9} \
				  -last_restricted {_} \
				  -map { {{"*cell*","U"},{"*-return","RET"}} } \
				  -replacement_char {_}

define_name_rules asic_net_rules -type net \
                                 -allowed {a-z A-Z 0-9 _[]} \
				 -max_length 255 \
				 -reserved_words [list "always" "and" "assign" "begin" "buf" "bufif0" "bufif1" "case" "casex" "casez" "cmos" "deassign" "default" "defparam" "disable" "edge" "else" "end" "endcase" "endfunction" "endmodule" "endprimitive" "endspecify" "endtable" "endtask" "event" "for" "force" "forever" "fork" "function" "highz0" "highz1" "if" "initial" "inout" "input" "integer" "join" "large" "macromodule" "medium" "module" "nand" "negedge" "nmos" "nor" "not" "notif0" "notif1" "or" "output" "pmos" "posedge" "primitive" "pull0" "pull1" "pulldown" "pullup" "rcmos" "reg" "release" "repeat" "rnmos" "rpmos" "rtran" "rtranif0" "rtranif1" "scalered" "small" "specify" "specparam" "strong0" "strong1" "supply0" "supply1" "table" "task" "time" "tran" "tranif0" "tranif1" "tri" "tri0" "tri1" "triand" "trior" "vectored" "wait" "wand" "weak0" "weak1" "while" "wire" "wor" "xnor" "xor" "abs" "access" "after" "alias" "all" "and" "architecture" "array" "assert" "attribute" "begin" "block" "body" "buffer" "bus" "case" "component" "configuration" "constant" "disconnect" "downto" "else" "elsif" "end" "entity" "exit" "file" "for" "function" "generate" "generic" "guarded" "if" "in" "inout" "is" "label" "library" "linkage" "loop" "map" "mod" "nand" "new" "next" "nor" "not" "null" "of" "on" "open" "or" "others" "out" "package" "port" "procedure" "process" "range" "record" "register" "rem" "report" "return" "select" "severity" "signal" "subtype" "then" "to" "transport" "type" "units" "until" "use" "variable" "wait" "when" "while" "with" "xor"] \
				 -case_insensitive \
				 -check_internal_net_name \
				 -first_restricted {_ 0-9} \
				 -last_restricted {_} \
				 -replacement_char {_} \
				 -check_bus_indexing \
				 -remove_irregular_port_bus \
				 -remove_irregular_net_bus \
				 -flatten_multi_dimension_busses \
				 -equal_ports_nets \
				 -inout_ports_equal_nets

# NOTE: The exact syntax of the -map option is important, without the
# spaces and curly-brackets in this exact place, -map may not work
define_name_rules asic_clean_name -map { {{"__", "_"},{"_$", ""}} }

change_names -rules asic_port_rules -verbose -hierarchy
change_names -rules asic_cell_rules -verbose -hierarchy
change_names -rules asic_net_rules -verbose -hierarchy
change_names -rules asic_clean_name -verbose -hierarchy

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${top_level}.nl.v"

# Generate Standard Delay Format (SDF) file
write_sdf -context verilog "${top_level}.pt.sdf"
#Write SDC file
write_sdc "${top_level}.sdc"

# Reporting
set rpt_file "${top_level}.dc.rpt"
set maxpaths 20

check_design > $rpt_file
#Ungroup Hierarchy and report area & cell
ungroup -all
report_area >> ${rpt_file}
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
