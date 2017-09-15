pt:
	pt_shell -f ulpb_node32_ab.tcl | tee ulpb_node32_ab.log
	pt_shell -f ulpb_node32_cd.tcl | tee ulpb_node32_cd.log
	pt_shell -f ulpb_node32_ef.tcl | tee ulpb_node32_ef.log
	pt_shell -f ulpb_ctrl_wrapper.tcl | tee ulpb_ctrl_wrapper.log

clean:
	rm -f *.log *.rpt
