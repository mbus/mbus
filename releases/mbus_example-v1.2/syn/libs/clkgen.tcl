set top_level clkgen

create_qtm_model $top_level

create_qtm_port { CLK_RING_ENn CLK_GATE CLK_TUNE[3:0] } -type input
create_qtm_port { CLK_OUT } -type output

set_qtm_port_load [get_qtm_ports  { CLK_RING_ENn CLK_GATE CLK_TUNE[3:0] } ] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
