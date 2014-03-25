PT      =pt_shell

all: ablk clkgen lc_header lc_mbc_iso mbc_header mbus_addr_rf mbus_int_ctrl mbus_regular_sleep_ctrl mbus_wire_ctrl rf rstdtctr

ablk:
	$(PT) -f $@.tcl | tee $@.log

clkgen:
	$(PT) -f $@.tcl | tee $@.log

lc_header:
	$(PT) -f $@.tcl | tee $@.log

lc_mbc_iso:
	$(PT) -f $@.tcl | tee $@.log

mbc_header:
	$(PT) -f $@.tcl | tee $@.log

mbus_addr_rf:
	$(PT) -f $@.tcl | tee $@.log

mbus_int_ctrl:
	$(PT) -f $@.tcl | tee $@.log

mbus_regular_sleep_ctrl:
	$(PT) -f $@.tcl | tee $@.log

mbus_wire_ctrl:
	$(PT) -f $@.tcl | tee $@.log

rf:
	$(PT) -f $@.tcl | tee $@.log

rstdtctr:
	$(PT) -f $@.tcl | tee $@.log

clean: 
	rm -rf *.lib *.log *.db

.PHONY: ablk clkgen lc_header lc_mbc_iso mbc_header mbus_addr_rf mbus_int_ctrl mbus_regular_sleep_ctrl mbus_wire_ctrl rf rstdtctr
