
synth:
	-cd syn; make synth

simv:
	-cd verilog; make simv

dve:	
	-cd verilog; make dve


clean:
	-cd verilog; make clean
	-cd syn; make clean
	-cd verilog; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*; rm -f *.txt
	-cd netlist; make clean

#int:
#	-cd syn; vcs +v2k +vc -Mupdate -line -full64 -I +memcbk -full64 ${TESTBENCH} ${SIM_SYNTH_FILES} -o int_simv -RI

