# Naming rules for consistent tool interface
# Translation of script: namingrules.dc

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
