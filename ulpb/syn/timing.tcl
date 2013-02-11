# Timing setup for synthesis

# Clock period
set clk_period 18
set clk_uncertainty 2
set clk_transition 2

#Create real clock if clock port is found
if {[sizeof_collection [get_ports CLK]] > 0} {
  set clk_name "CLK"
  set clk_port "CLK"
  #If no waveform is specified, 50% duty cycle is assumed
  create_clock -name $clk_name -period $clk_period [get_ports $clk_port] 
  set_drive 0 [get_clocks $clk_name] 
}
#If not real clock then create virtual clock
if {[sizeof_collection [get_ports CLK]] == 0} {
  set clk_name "vclk"
  create_clock -name $clk_name -period $clk_period 
}

set_clock_uncertainty $clk_uncertainty [get_clocks $clk_name]
#Propagated clock used for gated clocks only
#set_propagated_clock [get_clocks $clk_name]
set_clock_transition $clk_transition [get_clocks $clk_name]

set_operating_conditions "typical" -library "typical" 
set_wire_load_model -name "tsmc18_wl50" -library "typical" 
set_wire_load_mode "segmented" 

set typical_input_delay 0.100
set typical_output_delay 0.100
set typical_wire_load 0.010 
