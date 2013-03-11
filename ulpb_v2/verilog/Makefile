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
SYNVCS = SW_VCS=2011.03 vcs +v2k +vc -sverilog +lint=all,noVCDE +warn=all -Mupdate -line -full64 -cm line+cond+fsm+tgl
APRVCS = SW_VCS=2011.03 vcs +v2k +vc -sverilog +lint=all,noVCDE +warn=all -Mupdate -line -full64 -cm line+cond+fsm+tgl
VCSFLAGS =
INTFLAGS = -I +memcbk

all:    simv

##### 
# Modify starting here
#####

TESTBENCH = tb_ulpb_node32.v
SIMFILES = ulpb_node32.v ulpb_ctrl.v ulpb_swapper.v ulpb_ctrl_wrapper.v
SYNFILES = 	../syn/ulpb_node32_ab.dc.v \
		../syn/ulpb_node32_cd.dc.v \
		../syn/ulpb_node32_ef.dc.v \
		../syn/ulpb_ctrl_wrapper.dc.v
APRFILES = 	../apr/ulpb_node32_ab/ulpb_node32_ab.apr.v \
		../apr/ulpb_node32_cd/ulpb_node32_cd.apr.v \
		../apr/ulpb_node32_ef/ulpb_node32_ef.apr.v \
		../apr/ulpb_ctrl_wrapper/ulpb_ctrl_wrapper.apr.v

#####
# Should be no need to modify after here
#####
simv:		$(SIMFILES) $(TESTBENCH)
		$(VCS) $(VCSFLAGS) $(TESTBENCH) $(SIMFILES) -o simv -cm line+cond+fsm+tgl -R | tee program.out
		urg -dir simv.vdb -report ./REPORTS

syn_simv:	$(SIMFILES) $(TESTBENCH)
		$(SYNVCS) $(VCSFLAGS) $(TESTBENCH) $(SYNFILES) -o syn_simv -cm line+cond+fsm+tgl -R | tee syn_program.out
		urg -dir simv.vdb -report ./REPORTS

apr_simv:	$(APRFILES) $(TESTBENCH)
		$(APRVCS) $(VCSFLAGS) $(TESTBENCH) $(APRFILES) -o apr_simv -cm line+cond+fsm+tgl -R | tee apr_program.out
		urg -dir simv.vdb -report ./REPORTS

# updated interactive debugger "DVE", using the latest version of VCS
# awdeorio fall 2011
dve:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) +memcbk $(TESTBENCH) $(SIMFILES) -o dve -R -gui

.PHONY: simv dve

clean:	
	rm -rvf simv *.daidir csrc vcs.key program.out \
	syn_simv syn_simv.daidir syn_program.out \
	int_simv int_simv.daidir syn_int_simv syn_int_simv.daidir \
	DVEfiles\
        dve *.vpd *.vcd *.dump ucli.key *.vdb REPORTS .saveDVEfiles .restart* .synopsys_dve*

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out DVEfiles/
