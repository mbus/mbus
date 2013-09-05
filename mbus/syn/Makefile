#Makefile for MBUS synthesis

POST_SDF = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/primetime/pt_postprocessor.pl

RUN_SYN = dc_shell -f $@.tcl | tee $@.dc.log
RUN_POST = -perl ${POST_SDF} -s $@.pt.sdf -o $@.dc.sdf


all:
	make mbus_node_n0;
	make mbus_node_n1;
	make mbus_node_n2;
	make mbus_node_n3;
	make mbus_ctrl_wrapper;
	make mbus_addr_rf;
	make mbus_regular_sleep_ctrl;
	make mbus_wire_ctrl;
	make mbus_int_ctrl;
	make mbus_regular_isolation;


mbus_node_n0:
	${RUN_SYN}
	${RUN_POST}

mbus_node_n1:
	${RUN_SYN}
	${RUN_POST}

mbus_node_n2:
	${RUN_SYN}
	${RUN_POST}

mbus_node_n3:
	${RUN_SYN}
	${RUN_POST}

mbus_ctrl_wrapper:
	${RUN_SYN}
	${RUN_POST}

mbus_addr_rf:
	${RUN_SYN}
	${RUN_POST}

mbus_regular_sleep_ctrl:
	${RUN_SYN}
	${RUN_POST}

mbus_wire_ctrl:
	${RUN_SYN}
	${RUN_POST}

mbus_int_ctrl:
	${RUN_SYN}
	${RUN_POST}

mbus_regular_isolation:
	${RUN_SYN}
	${RUN_POST}

clean:
	rm -f *.log; rm -f *.rpt; rm -f *.nl.v; rm -f *.sdf; rm -f *.svf; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*;
	rm -f *.pvl *.syn *.mr *.sdc
	rm -rf alib*
