#############################################################################################
##Author:         ZhiYoong Foo
##Last Modified:  Feb 25 2014
##Description:    Makefile for MBUS Example
############################################################################################# 

VV       = vcs

SIMV     = ./simv 

VFLAGS   = +v2k +vc -sverilog +lint=all,noVCDE,noOUDPE +warn=all,noOUDPE -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays +plusarg_save +overlap -full64 -Mupdate -line -debug +libext+.v+.vlib+.vh -lca +notimingcheck +define+SIM

VCSFLAGS =

all: .PHONY

clean:
	rm -rf ./simv ./simv* ./csrc ./ucli.key ./vcs.prof ./inter.vpd ./DVEfiles ./vcs.key ./*.log profileReport* simprofile*

mbus_example:
	$(VV) $(VFLAGS)$(VCSFLAGS) -l $@.log \
	./$@_test_def.v \
	./mbus_ctrl_wrapper.v \
	./mbus_ctrl.v \
	./mbus_wire_ctrl.v \
	./mbus_node.v \
	./mbus_swapper.v \
	./mbus_addr_rf.v \
	./mbus_int_ctrl.v \
	./mbus_regular_sleep_ctrl.v \
	./layer_ctrl.v \
	./ablk.v \
	./clkgen_def.v \
	./clkgen.v \
	./lc_header.v \
	./lc_mbc_iso.v \
	./mbc_header.v \
	./rf.v \
	./rstdtctr.v \
	./timer.v \
	./$@_def.v \
	./$@.v \
	./$@_test.v ; \
	$(SIMV)

.PHONY: mbus_example 
