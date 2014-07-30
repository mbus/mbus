set top_level lc_mbc_iso

create_qtm_model $top_level

create_qtm_port { MBC_ISOLATE ADDROUT_uniso[31:0] DATAOUT_uniso[31:0] PENDOUT_uniso REQOUT_uniso PRIORITYOUT_uniso ACKOUT_uniso RESPOUT_uniso LRC_SLEEP_uniso LRC_RESET_uniso LRC_ISOLATE_uniso SLEEP_REQ_uniso } -type input
create_qtm_port { ADDROUT[31:0] DATAOUT[31:0] PENDOUT REQOUT PRIORITYOUT ACKOUT RESPOUT LRC_SLEEP LRC_RESET LRC_ISOLATE SLEEP_REQ } -type output

set_qtm_port_load [get_qtm_ports  { MBC_ISOLATE ADDROUT_uniso[31:0] DATAOUT_uniso[31:0] PENDOUT_uniso REQOUT_uniso PRIORITYOUT_uniso ACKOUT_uniso RESPOUT_uniso LRC_SLEEP_uniso LRC_RESET_uniso LRC_ISOLATE_uniso SLEEP_REQ_uniso }] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
