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
VCS = SW_VCS=2011.03 vcs +v2k +vc -Mupdate -line -full64
INTFLAGS = -I +memcbk
VFLAGSnl  = +v2k +vc -sverilog +lint=all,noVCDE +warn=all -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays +plusarg_save +overlap -full64 -Mupdate -line -debug -cc gcc +libext+.v+.vlib+.vh +prof +neg_tchk +memopt -negdelay


all:    simv
#	./simv | tee program.out

##### 
# Modify starting here
#####

TESTBENCH = tb_ulpb_node32.v
SYNFILES = ulpb_node32_ab.nl.v ulpb_node32_cd.nl.v ulpb_node32_ef.nl.v ulpb_ctrl_wrapper.nl.v

#two_bit_pred.vg:	tut_mod.v tut_synth.tcl
#	dc_shell-t -f tut_synth.tcl | tee synth.out


.PHONY: dve syn_simv

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(VFLAGSnl) $(TESTBENCH) $(SYNFILES) -o syn_simv -R | tee syn_program.out 

syn_dve:	$(SYNFILES) $(TESTBENCH)
	$(VCS) +memcbk $(TESTBENCH) $(SYNFILES) -o dve -R -gui

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out \
	  syn_simv syn_simv.daidir syn_program.out \
	  int_simv int_simv.daidir syn_int_simv syn_int_simv.daidir \
	  DVEfiles\
          dve *.vpd *.vcd *.dump ucli.key *.txt vcs.prof .restart* .synopsys* .saveDVE*

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out DVEfiles/
