
# Register retiming
#set_balance_registers

# Link the design
link

# Set maximum fanout of gates
set_max_fanout 5 $top_level 

# Configure the clock network
set_fix_hold [all_clocks] 
set_dont_touch_network $clk_port 

# Set delays: Input, Output
set_driving_cell -lib_cell INVX2 [all_inputs]
#set_driving_cell -lib_cell INVX2TR [all_inputs] -library typical
set_input_delay $typical_input_delay [all_inputs] -clock $clk_name 
remove_input_delay -clock $clk_name [find port $clk_port]
set_output_delay $typical_output_delay [all_outputs] -clock $clk_name 

# Set loading of outputs 
set_load $typical_wire_load [all_outputs] 

# Set clock
set_ideal_network $clk_name 

# Verify the design
check_design

# Uniquify repeated modules
uniquify

