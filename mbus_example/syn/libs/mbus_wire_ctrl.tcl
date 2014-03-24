set top_level mbus_wire_ctrl

create_qtm_model $top_level

create_qtm_port { RESETn DIN CLKIN DOUT_FROM_BUS CLKOUT_FROM_BUS RELEASE_ISO_FROM_SLEEP_CTRL EXTERNAL_INT } -type input
create_qtm_port { DOUT CLKOUT } -type output

set_qtm_port_load [get_qtm_ports  { RESETn DIN CLKIN DOUT_FROM_BUS CLKOUT_FROM_BUS RELEASE_ISO_FROM_SLEEP_CTRL EXTERNAL_INT }] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit