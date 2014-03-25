set top_level rstdtctr

create_qtm_model $top_level
create_qtm_port { RESETn } -type output
save_qtm_model -output $top_level -format {lib db} -library_cell

exit