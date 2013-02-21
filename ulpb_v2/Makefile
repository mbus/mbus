STD_CELLS = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v
ULPB = ulpb_node32
CTRL = ulpb_ctrl 
SWAPPER = ulpb_swapper
TESTBENCH = tb_ulpb_node32.v

VERILOG_SRC = ${ULPB}.v ${CTRL}.v ${SWAPPER}.v

NETLISTS = ${ULPB}_ab.nl.v ${ULPB}_cd.nl.v ${ULPB}_ef.nl.v ${CTRL}.nl.v ${STD_CELLS}

POST_SDF = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/primetime/pt_postprocessor.pl

VCS = SW_VCS=2011.03 vcs +v2k +vc -Mupdate -line -full64
INTFLAGS = -I +memcbk

synth_node:
	-cd syn; dc_shell -f ${ULPB}.tcl |tee ${ULPB}.dc.log
	-perl ${POST_SDF} -s syn/${ULPB}.dc.sdf -o netlist/${ULPB}.dc.sdf

synth_ctrl:
	-cd syn; dc_shell -f ${CTRL}.tcl |tee ${CTRL}.dc.log
	-perl ${POST_SDF} -s syn/${CTRL}.dc.sdf -o netlist/${CTRL}.dc.sdf

syn_simv:	$(NETLISTS) $(TESTBENCH)
	-cd syn; $(VCS) $(TESTBENCH) $(NETLISTS) -o syn_simv -R | tee syn_program.out 

simv:	$(VERILOG_SRC) $(TESTBENCH)
	-cd verilog; $(VCS) $(TESTBENCH) $(VERILOG_SRC)	-o simv -R | tee program.out

dve:	$(VERILOG_SRC) $(TESTBENCH) 
	-cd verilog; $(VCS) +memcbk $(TESTBENCH) $(VERILOG_SRC) -o dve -R -gui


clean:
	-cd verilog; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*; rm -f *.txt
	-cd syn; rm -f *.log; rm -f *.rpt; rm -f *.nl.v; rm -f *.sdf; rm -f *.svf; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*;
	-cd syn; rm -f *.syn; rm -f *.pvl; rm -f *.mr; rm -f *.txt; rm -f log;

#int:
#	-cd syn; vcs +v2k +vc -Mupdate -line -full64 -I +memcbk -full64 ${TESTBENCH} ${SIM_SYNTH_FILES} -o int_simv -RI

