set top_level mbus_int_ctrl

create_qtm_model $top_level

create_qtm_port { CLKIN RESETn MBC_ISOLATE SC_CLR_BUSY MBUS_CLR_BUSY REQ_INT MBC_SLEEP LRC_SLEEP CLR_EXT_INT } -type input
create_qtm_port { EXTERNAL_INT_TO_WIRE EXTERNAL_INT_TO_BUS } -type output

set_qtm_port_load [get_qtm_ports  { CLKIN RESETn MBC_ISOLATE SC_CLR_BUSY MBUS_CLR_BUSY REQ_INT MBC_SLEEP LRC_SLEEP CLR_EXT_INT }] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit