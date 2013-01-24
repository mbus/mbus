STD_CELLS = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v
ULPB = ulpb_node32
CTRL = control
TESTBENCH = ulpb_node32_tb.v
ADDI_FILE = control.v
SIM_FILES = ${ULPB}.v ${ADDI_FILE}
SIM_SYNTH_FILES = ${ULPB}.nl.v ${ADDI_FILE}
#GOLDEN_RESULT = goldenbrick/goldenresult
#SIM_RESULT = testbench.txt
POST_SDF = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/primetime/pt_postprocessor.pl

synth_node:
	-cd syn; dc_shell -f ${ULPB}.tcl |tee ${ULPB}.dc.log
	-perl ${POST_SDF} -s syn/${ULPB}.dc.sdf -o ${ULPB}.dc.sdf
	-mv ${ULPB}.dc.sdf syn/

synth_ctrl:
	-cd syn; dc_shell -f ${CTRL}.tcl |tee ${CTRL}.dc.log
	-perl ${POST_SDF} -s syn/${CTRL}.dc.sdf -o ${CTRL}.dc.sdf
	-mv ${CTRL}.dc.sdf syn/

sim_synth:
	-cd syn; ncverilog ${TESTBENCH} ${SIM_SYNTH_FILES}
#	-cd perl; ./testbench_gen.pl synth
#	-diff ${GOLDEN_RESULT} syn/${SIM_RESULT}

sim:
	-cd verilog; ncverilog ${TESTBENCH} ${SIM_FILES}
#	-cd perl; ./testbench_gen.pl
#	-diff ${GOLDEN_RESULT} verilog/${SIM_RESULT}

clean:
	-cd verilog; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*; rm -f *.txt
	-cd syn; rm -f *.log; rm -f *.rpt; rm -f *.nl.v; rm -f *.sdf; rm -f *.svf; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*;
	-cd syn; rm -f *.syn; rm -f *.pvl; rm -f *.mr; rm -f *.txt; rm -f log;
#	-cd goldenbrick; find . ! -name "*.c" -delete

#c_compile:
#	-cd goldenbrick; gcc -Wall -ggdb -o goldenbrick goldenbrick.c
#	-goldenbrick/goldenbrick > ${GOLDEN_RESULT}

#int:
#	-cd syn; vcs +v2k +vc -Mupdate -line -full64 -I +memcbk -full64 ${TESTBENCH} ${SIM_SYNTH_FILES} -o int_simv -RI

