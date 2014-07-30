set top_level lc_header

create_qtm_model $top_level

create_qtm_port { SLEEP } -type input

set_qtm_port_load [get_qtm_ports  { SLEEP } ] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
