# Link the design
link

# Set maximum fanout of gates
set_max_fanout 4 $top_level 

# Configure the clock network
set_fix_hold [all_clocks] 
set_dont_touch_network $clk_port

# Set delays: Input, Output
set_driving_cell -lib_cell INVX2 [all_inputs]
set_input_delay $typical_input_delay [all_inputs] -clock $clk_name 
remove_input_delay -clock $clk_name [find port $clk_port]
set_output_delay $typical_output_delay [all_outputs] -clock $clk_name 

# Set loading of outputs 
set_load $typical_wire_load [all_outputs]
# Set loading of DIN and CLKOUT (Needs to be going to pads)
# This means PAD + bonding wire + PAD + input cap + (maybe socket)
# Roughly set to 2pF
set_load 2 {DOUT CLKOUT}

# Set clock
set_ideal_network $clk_name 

# Verify the design
check_design

# Uniquify repeated modules
uniquify
