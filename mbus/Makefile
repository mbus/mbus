
date_o = $(shell date '+%m.%d.%y.%H.%M.%S')

tar_o = \
	verilog/mbus_addr_rf.v \
	verilog/mbus_ctrl.v \
	verilog/mbus_ctrl_layer_wrapper.v \
	verilog/mbus_ctrl_wrapper.v \
	verilog/mbus_ext_int.v \
	verilog/mbus_layer_wrapper.v \
	verilog/mbus_master_node.v \
	verilog/mbus_master_sleep_ctrl.v \
	verilog/mbus_node.v \
	verilog/mbus_regular_isolation.v \
	verilog/mbus_regular_sleep_ctrl.v \
	verilog/mbus_swapper.v \
	verilog/mbus_wire_ctrl.v \
	verilog/include/*

synth:
	-cd syn; make synth

simv:
	-cd verilog; make simv

dve:	
	-cd verilog; make dve

tar:	
	tar -cvf ./tar/mbus_O2A_$(date_o).v.tar $(tar_o)


clean:
	-cd verilog; make clean
	-cd syn; make clean
	-cd verilog; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*; rm -f *.txt
	-cd netlist; make clean
	-cd primetime; make clean

#int:
#	-cd syn; vcs +v2k +vc -Mupdate -line -full64 -I +memcbk -full64 ${TESTBENCH} ${SIM_SYNTH_FILES} -o int_simv -RI

.PHONY: tar