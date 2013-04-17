apr:
	cd ulpb_node32_ab ; \
	velocity -64 -nowin -init ulpb_node32_ab.tcl
	cd ulpb_node32_cd ; \
	velocity -64 -nowin -init ulpb_node32_cd.tcl
	cd ulpb_node32_ef ; \
	velocity -64 -nowin -init ulpb_node32_ef.tcl
	cd ulpb_ctrl_wrapper ; \
	velocity -64 -nowin -init ulpb_ctrl_wrapper.tcl

clean:
	rm -rf */*enc*; rm -rf */timingReports
	rm -f */*.spf; rm -f */*.spef; rm -f */*.lef; rm -f */*.gds; rm -f */*.apr*; rm -f */*.rpt; rm -f */*cts*; rm -rf */*rcdb*; rm -f */*.old; rm -f */*.sdc;
