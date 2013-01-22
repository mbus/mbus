STD_CELLS = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v
#TESTBENCH = test_mult.v
#SIM_FILES = mult.v
#SIM_SYNTH_FILES = mult.nl.v
#GOLDEN_RESULT = goldenbrick/goldenresult
#SIM_RESULT = testbench.txt
TCL_NAME = ulpb
POST_SDF = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/primetime/pt_postprocessor.pl

synth:
	-cd syn; dc_shell -f ${TCL_NAME}.tcl |tee ${TCL_NAME}.dc.log
	-perl ${POST_SDF} -s syn/${TCL_NAME}.dc.sdf -o ${TCL_NAME}.dc.sdf
	-mv ${TCL_NAME}.dc.sdf syn/

#sim_synth:
#	-cd perl; ./testbench_gen.pl synth
#	-cd syn; ncverilog ${TESTBENCH} ${SIM_SYNTH_FILES}
#	-diff ${GOLDEN_RESULT} syn/${SIM_RESULT}

#sim:
#	-cd perl; ./testbench_gen.pl
#	-cd verilog; ncverilog ${TESTBENCH} ${SIM_FILES}
#	-diff ${GOLDEN_RESULT} verilog/${SIM_RESULT}

clean:
	-cd verilog; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm
	-cd syn; find . ! -name "*.tcl" -delete
#	-cd goldenbrick; find . ! -name "*.c" -delete

#c_compile:
#	-cd goldenbrick; gcc -Wall -ggdb -o goldenbrick goldenbrick.c
#	-goldenbrick/goldenbrick > ${GOLDEN_RESULT}

#int:
#	-cd syn; vcs +v2k +vc -Mupdate -line -full64 -I +memcbk -full64 ${TESTBENCH} ${SIM_SYNTH_FILES} -o int_simv -RI

