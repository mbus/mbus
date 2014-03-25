# Timing setup for synthesis

# Clock period
set mbus_clk_period 2500
set mbus_clk_uncertainty 1
set mbus_clk_transition 1

set mbus_clk_name "MBUS_CLK"
set mbus_clk_port "MBUS_CLK"
create_clock -name $mbus_clk_name -period $mbus_clk_period [get_ports CIN]

set_clock_uncertainty $mbus_clk_uncertainty [get_clocks $mbus_clk_name]
set_clock_transition $mbus_clk_transition [get_clocks $mbus_clk_name]

set lc_clk_period 2500
set lc_clk_uncertainty 1
set lc_clk_transition 1

set lc_clk_name "LC_CLK"
set lc_clk_port "LC_CLK"
#If no waveform is specified, 50% duty cycle is assumed
create_clock -name $lc_clk_name -period $lc_clk_period [get_pins clkgen_0/CLK_OUT] 

set_clock_uncertainty $lc_clk_uncertainty [get_clocks $lc_clk_name]
set_clock_transition $lc_clk_transition [get_clocks $lc_clk_name]

set_clock_groups -asynchronous -group $mbus_clk_name -group $lc_clk_name

set_wire_load_mode "segmented" 

set typical_input_delay 0.100
set typical_output_delay 0.100
set typical_wire_load 0.010 

