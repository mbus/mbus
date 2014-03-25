set top_level rf

create_qtm_model $top_level

create_qtm_port { RESETn ISOLATE DATA_IN[18:0] ADDRESS_IN[3:0]} -type input

create_qtm_port { clk_tune[3:0] timer_resetn timer_en timer_roi timer_sat[7:0] rf2lc_mbus_reply_address_timer[7:0] ablk_pg ablk_resetn ablk_en ablk_config_0[3:0] ablk_config_1[3:0] } -type output

set_qtm_port_load [get_qtm_ports  { RESETn ISOLATE DATA_IN[18:0] ADDRESS_IN[3:0] } ] -value 0.005

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
