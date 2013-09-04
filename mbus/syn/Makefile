
MBUS_n0 = mbus_node_n0
MBUS_n1 = mbus_node_n1
MBUS_n2 = mbus_node_n2
MBUS_n3 = mbus_node_n3
CTRL = mbus_ctrl_wrapper

POST_SDF = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/primetime/pt_postprocessor.pl

synth:
	make synth_node;
	make synth_ctrl_wrapper;

synth_node:
	dc_shell -f ${MBUS_n0}.tcl | tee ${MBUS_n0}.dc.log
	-perl ${POST_SDF} -s ${MBUS_n0}.pt.sdf -o ${MBUS_n0}.dc.sdf
	dc_shell -f ${MBUS_n1}.tcl | tee ${MBUS_n1}.dc.log
	-perl ${POST_SDF} -s ${MBUS_n1}.pt.sdf -o ${MBUS_n1}.dc.sdf
	dc_shell -f ${MBUS_n2}.tcl | tee ${MBUS_n2}.dc.log
	-perl ${POST_SDF} -s ${MBUS_n2}.pt.sdf -o ${MBUS_n2}.dc.sdf
	dc_shell -f ${MBUS_n3}.tcl | tee ${MBUS_n3}.dc.log
	-perl ${POST_SDF} -s ${MBUS_n3}.pt.sdf -o ${MBUS_n3}.dc.sdf

synth_ctrl_wrapper:
	dc_shell -f ${CTRL}.tcl | tee ${CTRL}.dc.log
	-perl ${POST_SDF} -s ${CTRL}.pt.sdf -o ${CTRL}.dc.sdf

mbus_addr_rf:
	dc_shell -f $@.tcl | tee $@.dc.log
	-perl ${POST_SDF} -s $@.pt.sdf -o $@.dc.sdf

mbus_regular_sleep_ctrl:
	dc_shell -f $@.tcl | tee $@.dc.log
	-perl ${POST_SDF} -s $@.pt.sdf -o $@.dc.sdf

clean:
	rm -f *.log; rm -f *.rpt; rm -f *.nl.v; rm -f *.sdf; rm -f *.svf; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*;
	rm -f *.pvl *.syn *.mr *.sdc
	rm -rf alib*
