#############################################################################################
## Author:         Yejoong Kim
## Last Modified:  August 23 2017
## Description:    Makefile for FLPv3L/FLPv3S verilog simulation
## 
## Usage:
##          make            // Pre-APR simulation
##          make vpd        // Pre-APR simulation with VPD dump
##          make syn        // Post-Synthesis simulation
##          make syn.vpd    // Post-Synthesis simulation with VPD dump
##          make apr        // Post-APR simulation
##          make apr.vpd    // Post-APR simulation with VPD dump
##
## <NOTE> You need to include the following path in your .cshrc file
##        /afs/eecs.umich.edu/vlsida/projects/m3_hdk/scripts/bin
##
############################################################################################# 

##################
## DUT and MBus ##
##################

LAYER   = FLP
TARGET  = FLPv3L

MBUS_VER = r04p2

#################
## Directories ##
#################

M3_HDK      = /afs/eecs.umich.edu/vlsida/projects/m3_hdk
M3_SDK      = /afs/eecs.umich.edu/vlsida/projects/m3_sdk
NET_DIR     = $(M3_HDK)/layer/$(LAYER)/$(TARGET)/verilog
SYN_DIR     = $(M3_HDK)/layer/$(LAYER)/$(TARGET)/synth
APR_DIR     = $(M3_HDK)/layer/$(LAYER)/$(TARGET)/apr
MBUSTB_DIR  = $(M3_HDK)/IP/mbus/$(MBUS_VER)/mbus_testbench

###############
## VCS Flags ##
###############
#-- NOTE: NTC and RECREM flags are required for tcbn90lpefbwp7t.v
VFLAGS_main =   +v2k +vc -sverilog +systemverilogext+sv +lint=all,noVCDE,noNS +warn=all -timescale=1ns/1ps +vcs+lic+wait \
                +multisource_int_delays +plusarg_save +overlap -full64 -Mupdate -line -debug +libext+.v+.vlib+.vh \
                +neg_tchk -sdfretain +sdfverbose
                #-cm line+cond+fsm+tgl -cm_hier $(TARGET).hier -cm_libs yv+celldefine \

VFLAGS        = $(VFLAGS_main) +define+SIM+DEBUG
VFLAGS_vcd    = $(VFLAGS_main) +define+SIM+DEBUG+VCD_DUMP
VFLAGS_vpd    = $(VFLAGS_main) +define+SIM+DEBUG+VPD_DUMP
VFLAGSsyn     = $(VFLAGS_main) +define+SIM+SYN+SDF+NTC+RECREM
VFLAGSsyn_vcd = $(VFLAGS_main) +define+SIM+SYN+SDF+NTC+RECREM+VCD_DUMP
VFLAGSsyn_vpd = $(VFLAGS_main) +define+SIM+SYN+SDF+NTC+RECREM+VPD_DUMP
VFLAGSapr     = $(VFLAGS_main) +define+SIM+APR+SDF+NTC+RECREM
VFLAGSapr_vcd = $(VFLAGS_main) +define+SIM+APR+SDF+NTC+RECREM+VCD_DUMP
VFLAGSapr_vpd = $(VFLAGS_main) +define+SIM+APR+SDF+NTC+RECREM+VPD_DUMP

##########################
## m3_genRptVcs Options ##
##########################
#-- List all the warnings/lint messages you can ignore

GENRPTVCS_FLAGS	=   -i2 VCDE \
					-i2 ZERO \
					-i2 OUDPE \
                    -i2 /afs/eecs.umich.edu/vlsida/projects/m3_hdk/IP/mbus/r04p2/mbus_testbench/mbus_snooper.v:CAWM-L \
                    -i2 /afs/eecs.umich.edu/vlsida/projects/m3_hdk/IP/mbus/r04p2/mbus_testbench/mbus_snooper.v:UI \
                    -i2 /afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3S/verilog/tcbn90lpefbwp7t.v:IWU \
                    -i2 /afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3S/verilog/ESD_PAD_TSMC90_rev1.v:UI \
                    -i2 /afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3S/verilog/m3_custom_tsmc90.v:UI \
                    -i3 UI:RX_BROADCAST \
                    -i3 IWNF:FE_UNCONNECTEDZ \
                    -i3 VNGS:FE_UNCONNECTEDZ \
                    -i3 IWU:FE_UNCONNECTEDZ \
                    -i3 TFIPC-L:\(OUTPUT\) \
                    -i2 NTCDNC \
                    -i2 SDFCOM_SWC \
                    -i2 SDFCOM_IWSBA \
                    -i3 SDFCOM_STCLOR:QDN90LP \
                    -i3 SDFCOM_TANE:QDN90LP \
                    -i3 SDFCOM_IANE:QDN90LP \
                    -i3 SDFCOM_IANE:PAD_ \
                    -i3 SDFCOM_IANE:CLK_GEN_ \
                    -i3 SDFCOM_UHICD:PAD_50x60_DO \

###################
## List of Files ##
###################

#-- List all the directories that have verilog files whose filename is same as its module name
SEARCH_DIRS	  =	-y $(NET_DIR)/ \
				-y $(NET_DIR)/mbus/ \
                -y $(MBUSTB_DIR) \
				-y ./ \

#-- List all the directories that have 'include' files (e.g, def files)
INCLUDE_DIRS  =	+incdir+$(NET_DIR)/ \
				+incdir+$(NET_DIR)/mbus/ \
                +incdir+$(MBUSTB_DIR) \
				+incdir+./ \

#-- List all the verilog files where verilog module names are not equal to its file name
VERILOG_FILES =	-v $(NET_DIR)/$(TARGET)_def.v \
                -v $(NET_DIR)/tcbn90lpefbwp7t.v \
				-v $(NET_DIR)/sc_x_hvt_tsmc90.v \
				-v $(NET_DIR)/ESD_PAD_TSMC90_rev1.v \
				-v $(NET_DIR)/m3_custom_tsmc90.v \
                -v $(NET_DIR)/QDN90LP1024KX8M128P8v2.v \
                -v $(NET_DIR)/TS1GE4096X32M8.v \

#-- Golden-brick
OUT_GOLD_FILE   =   $(TARGET).out.gold

#-- [SYN SIM] List all the directories that have testbenches (including MBus testbench files)
SEARCH_DIRS_SYN   = -y $(MBUSTB_DIR) \

#-- [SYN SIM] List all the directories that have 'include' files that is included in testbenches (including MBus testbench files)
INCLUDE_DIRS_SYN  = +incdir+$(NET_DIR) \
					+incdir+$(MBUSTB_DIR) \
                    +incdir+./ \

#-- [SYN SIM] List all the files required for building a complete 'TARGET' system
VERILOG_FILES_SYN =	-v $(NET_DIR)/tcbn90lpefbwp7t.v \
				    -v $(NET_DIR)/sc_x_hvt_tsmc90.v \
				    -v $(NET_DIR)/ESD_PAD_TSMC90_rev1.v \
				    -v $(NET_DIR)/m3_custom_tsmc90.v \
                    -v $(NET_DIR)/QDN90LP1024KX8M128P8v2.v \
                    -v $(NET_DIR)/TS1GE4096X32M8.v \
					-v $(SYN_DIR)/$(TARGET).nl.v \

#-- [SYN SIM] Golden-brick
OUT_GOLD_FILE_SYN   =   $(TARGET).syn.out.gold

#-- [APR SIM] List all the directories that have testbenches (including MBus testbench files)
SEARCH_DIRS_APR   = -y $(MBUSTB_DIR) \
					-y ./ \

#-- [APR SIM] List all the directories that have 'include' files that is included in testbenches (including MBus testbench files)
INCLUDE_DIRS_APR  = +incdir+$(MBUSTB_DIR) \
					+incdir+./ \

#-- [APR SIM] List all the files required for building a complete 'TARGET' system
VERILOG_FILES_APR =	-v $(NET_DIR)/tcbn90lpefbwp7t.v \
				    -v $(NET_DIR)/sc_x_hvt_tsmc90.v \
				    -v $(NET_DIR)/ESD_PAD_TSMC90_rev1.v \
				    -v $(NET_DIR)/m3_custom_tsmc90.v \
                    -v $(NET_DIR)/QDN90LP1024KX8M128P8v2.v \
                    -v $(NET_DIR)/TS1GE4096X32M8.v \
					-v $(APR_DIR)/$(TARGET).apr.sim.v \

#-- [APR SIM] Golden-brick
OUT_GOLD_FILE_APR   =   $(TARGET).apr.out.gold

######################
## Makefile Recipes ##
######################

VV      = vcs
SIMV    = ./simv -cm line+cond+fsm+tgl
URG     = urg -full64 -dir simv.vdb -report ./REPORTS/$(TARGET)/

all: $(TARGET)

clean:
	rm -rf ./simv ./simv* ./csrc ./ucli.key ./vcs.prof ./inter.vpd ./DVEfiles ./vcs.key ./*.log REPORTS/*

compile:
	$(VV) $(VFLAGS) -l $(TARGET).log $(VERILOG_FILES) $(SEARCH_DIRS) $(INCLUDE_DIRS) ./$(TARGET)_test.v

compile.vcd:
	$(VV) $(VFLAGS_vcd) -l $(TARGET).log $(VERILOG_FILES) $(SEARCH_DIRS) $(INCLUDE_DIRS) ./$(TARGET)_test.v

compile.vpd:
	$(VV) $(VFLAGS_vpd) -l $(TARGET).log $(VERILOG_FILES) $(SEARCH_DIRS) $(INCLUDE_DIRS) ./$(TARGET)_test.v

compile.syn:
	$(VV) $(VFLAGSsyn) -l $(TARGET).syn.log $(VERILOG_FILES_APR) $(SEARCH_DIRS_APR) $(INCLUDE_DIRS_APR) ./$(TARGET)_test.v

compile.syn.vcd:
	$(VV) $(VFLAGSsyn_vcd) -l $(TARGET).syn.log $(VERILOG_FILES_APR) $(SEARCH_DIRS_APR) $(INCLUDE_DIRS_APR) ./$(TARGET)_test.v

compile.syn.vpd:
	$(VV) $(VFLAGSsyn_vpd) -l $(TARGET).syn.log $(VERILOG_FILES_APR) $(SEARCH_DIRS_APR) $(INCLUDE_DIRS_APR) ./$(TARGET)_test.v

compile.apr:
	$(VV) $(VFLAGSapr) -l $(TARGET).apr.log $(VERILOG_FILES_APR) $(SEARCH_DIRS_APR) $(INCLUDE_DIRS_APR) ./$(TARGET)_test.v

compile.apr.vcd:
	$(VV) $(VFLAGSapr_vcd) -l $(TARGET).apr.log $(VERILOG_FILES_APR) $(SEARCH_DIRS_APR) $(INCLUDE_DIRS_APR) ./$(TARGET)_test.v

compile.apr.vpd:
	$(VV) $(VFLAGSapr_vpd) -l $(TARGET).apr.log $(VERILOG_FILES_APR) $(SEARCH_DIRS_APR) $(INCLUDE_DIRS_APR) ./$(TARGET)_test.v

run: 
	$(SIMV) | tee $(TARGET).out

run.syn: 
	$(SIMV) | tee $(TARGET).syn.out

run.apr: 
	$(SIMV) | tee $(TARGET).apr.out

gui: 
	$(SIMV) -gui &

report:
	@ m3_genRptVcs -i $(TARGET).log -o $(TARGET).vcs.rpt $(GENRPTVCS_FLAGS)
	@ echo "";
	@ echo "[INFO] --- VCS Report ...";
	@ echo "";
	@ cat $(TARGET).vcs.rpt
	@ echo "";
	@ echo "[INFO] --- End of VCS Report ...";
#	$(URG)

report.syn:
	@ m3_genRptVcs -i $(TARGET).syn.log -o $(TARGET).syn.vcs.rpt $(GENRPTVCS_FLAGS)
	@ echo "";
	@ echo "[INFO] --- VCS Report ...";
	@ echo "";
	@ cat $(TARGET).syn.vcs.rpt
	@ echo "";
	@ echo "[INFO] --- End of VCS Report ...";
#	$(URG)

report.apr:
	@ m3_genRptVcs -i $(TARGET).apr.log -o $(TARGET).apr.vcs.rpt $(GENRPTVCS_FLAGS)
	@ echo "";
	@ echo "[INFO] --- VCS Report ...";
	@ echo "";
	@ cat $(TARGET).apr.vcs.rpt
	@ echo "";
	@ echo "[INFO] --- End of VCS Report ...";
#	$(URG)

conv: vcd2vpd_conv

check:
	@ gvim -d $(OUT_GOLD_FILE) $(TARGET).out

check.syn:
	@ gvim -d $(OUT_GOLD_FILE_SYN) $(TARGET).syn.out

check.apr:
	@ gvim -d $(OUT_GOLD_FILE_APR) $(TARGET).apr.out

vcd2vpd_conv:
	@ vcd2vpd $(TARGET).vcd $(TARGET).vpd
	@ rm -f $(TARGET).vcd

$(TARGET): compile run report

$(TARGET).vcd: compile.vcd run report conv

$(TARGET).vpd: compile.vpd run report

$(TARGET).syn: compile.syn run.syn report.syn

$(TARGET).syn.vcd: compile.syn.vcd run.syn report.syn conv

$(TARGET).syn.vpd: compile.syn.vpd run.syn report.syn

$(TARGET).apr: compile.apr run.apr report.apr

$(TARGET).apr.vcd: compile.apr.vcd run.apr report.apr conv

$(TARGET).apr.vpd: compile.apr.vpd run.apr report.apr

vcd: $(TARGET).vcd

vpd: $(TARGET).vpd

syn: $(TARGET).syn

syn.vcd: $(TARGET).syn.vcd

syn.vpd: $(TARGET).syn.vpd

apr: $(TARGET).apr

apr.vcd: $(TARGET).apr.vcd

apr.vpd: $(TARGET).apr.vpd

.PHONY:   $(TARGET) $(TARGET).vcd $(TARGET).vpd $(TARGET).syn $(TARGET).syn.vcd $(TARGET).syn.vpd $(TARGET).apr $(TARGET).apr.vcd $(TARGET).apr.vpd compile compile.vcd compile.vpd compile.syn compile.syn.vcd compile.syn.vpd compile.apr compile.apr.vcd compile.apr.vpd run run.syn run.apr report report.syn report.apr check check.syn check.apr conv
