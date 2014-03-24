set top_level mbus_regular_sleep_ctrl

create_qtm_model $top_level

create_qtm_port { MBUS_CLKIN RESETn SLEEP_REQ } -type input
create_qtm_port { MBC_SLEEP MBC_SLEEP_B MBC_ISOLATE MBC_ISOLATE_B MBC_CLK_EN MBC_CLK_EN_B MBC_RESET MBC_RESET_B } -type output

set_qtm_port_load [get_qtm_ports  { MBUS_CLKIN RESETn SLEEP_REQ } ] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
