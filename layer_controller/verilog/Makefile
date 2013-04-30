# make          <- runs simv (after compiling simv if needed)
# make simv     <- compile simv if needed (but do not run)
# make int      <- runs int_simv interactively (after compiling it if needed)
# make syn      <- runs syn_simv (after synthesizing if needed then 
#                                 compiling synsimv if needed)
# make syn_int  <- runs syn_int_simv interactively (much like make syn)
# make clean    <- remove files created during compilations (but not synthesis)
# make nuke     <- remove all files created during compilation and synthesis
#
# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be 
# similar to the information in those scripts but that seems hard to avoid.
#

# added "SW_VCS=2011.03 and "-full64" option -- awdeorio fall 2011
VCS = SW_VCS=2011.03 vcs +v2k +vc -sverilog +lint=all,noVCDE +warn=all -Mupdate -line -full64 -cm line+cond+fsm+tgl
SYNVCS = SW_VCS=2011.03 vcs +v2k +vc -Mupdate -line -full64 +v2k +vc -sverilog +lint=all,noVCDE +warn=all -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays +plusarg_save +overlap -full64 -Mupdate -line -debug -cc gcc +libext+.v+.vlib+.vh +prof +neg_tchk +memopt -negdelay +define+SYN
APRVCS = SW_VCS=2011.03 vcs +v2k +vc -Mupdate -line -full64 +v2k +vc -sverilog +lint=all,noVCDE +warn=all -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays +plusarg_save +overlap -full64 -Mupdate -line -debug -cc gcc +libext+.v+.vlib+.vh +prof +neg_tchk +memopt -negdelay +define+APR
VCSFLAGS =
INTFLAGS = -I +memcbk

all:    simv

##### 
# Modify starting here
#####

TESTBENCH = tb_layer_ctrl.v
SIMFILES = 	mbus_addr_rf.v \
			mbus_swapper.v \
			mbus_ext_int.v \
			mbus_wire_ctrl.v \
			mbus_clk_sim.v \
			mbus_regular_isolation.v \
			mbus_regular_sleep_ctrl.v \
			mbus_ctrl.v \
			mbus_master_sleep_ctrl.v \
			mbus_node.v \
			mbus_ctrl_wrapper.v \
			mbus_layer_wrapper.v \
			mbus_ctrl_layer_wrapper.v \
			mem_ctrl.v \
			layer_ctrl_isolation.v \
			rf_ctrl.v \
			int_action_rom.v \
			layer_ctrl.v \
			layer_wrapper.v

SYNFILES = 	../syn/mbus_node32_ab.nl.v \
		../syn/mbus_node32_cd.nl.v \
		../syn/mbus_node32_ef.nl.v \
		../syn/mbus_ctrl_wrapper.nl.v
APRFILES = 	../apr/mbus_node32_ab/mbus_node32_ab.apr.v \
		../apr/mbus_node32_cd/mbus_node32_cd.apr.v \
		../apr/mbus_node32_ef/mbus_node32_ef.apr.v \
		../apr/mbus_ctrl_wrapper/mbus_ctrl_wrapper.apr.v

#####
# Should be no need to modify after here
#####
simv:		$(SIMFILES) $(TESTBENCH)
		$(VCS) $(VCSFLAGS) $(TESTBENCH) $(SIMFILES) -o simv -cm line+cond+fsm+tgl -R | tee program.out
		urg -dir simv.vdb -report ./REPORTS

syn_simv:	$(SIMFILES) $(TESTBENCH)
		$(SYNVCS) $(VCSFLAGS) $(TESTBENCH) $(SYNFILES) -o syn_simv -cm line+cond+fsm+tgl -R | tee syn_program.out
		urg -dir syn_simv.vdb -report ./REPORTS

apr_simv:	$(APRFILES) $(TESTBENCH)
		$(APRVCS) $(VCSFLAGS) $(TESTBENCH) $(APRFILES) -o apr_simv -cm line+cond+fsm+tgl -R | tee apr_program.out
		urg -dir apr_simv.vdb -report ./REPORTS

# updated interactive debugger "DVE", using the latest version of VCS
# awdeorio fall 2011
dve:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) $(VCSFLAGS) +memcbk $(TESTBENCH) $(SIMFILES) -o dve -R -gui

.PHONY: simv syn_simv apr_simv dve

clean:	
	rm -rvf *simv *.daidir csrc vcs.key program.out \
	syn_simv syn_simv.daidir *program.out \
	int_simv int_simv.daidir syn_int_simv syn_int_simv.daidir \
	DVEfiles\
        dve *.vpd *.vcd *.dump ucli.key *.vdb REPORTS .saveDVEfiles .restart* .synopsys_dve* cm.log *.prof \
	INCA_libs waves.shm irun* nclaunch* ncverilog* result*.txt .nclaunch* .simvision log*

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out DVEfiles/
