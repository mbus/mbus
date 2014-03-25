set top_level ablk

create_qtm_model $top_level

create_qtm_port { ABLK_PG ABLK_RESETn ABLK_EN ABLK_CONFIG_0[3:0] ABLK_CONFIG_1[3:0] } -type input
create_qtm_port {  } -type output

set_qtm_port_load [get_qtm_ports { ABLK_PG ABLK_RESETn ABLK_EN ABLK_CONFIG_0[3:0] ABLK_CONFIG_1[3:0] } ] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
