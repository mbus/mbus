set top_level mbus_addr_rf

create_qtm_model $top_level

create_qtm_port { RESETn RELEASE_ISO_FROM_SLEEP_CTRL ADDR_IN[3:0] ADDR_WR_EN ADDR_CLRn } -type input
create_qtm_port { ADDR_OUT[3:0] ADDR_VALID } -type output

set_qtm_port_load [get_qtm_ports  { RESETn RELEASE_ISO_FROM_SLEEP_CTRL ADDR_IN[3:0] ADDR_WR_EN ADDR_CLRn } ] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
