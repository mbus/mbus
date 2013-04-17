##################################
# TSMC180 ARM/Artisan
# Author: zhiyoong
# Last Edited: March 03 2010
# Version 7.1 (setenv SW_SOC 7.1)
# Dumps rings & stripes for TSMC180
# ARM/Artisan std-cells with appropriate
# rings and stripes with top metal layer
# Usage power $top_metal $my_toplevel
###################################

proc power {top_metal my_toplevel} {
    
    # RINGS
    set ring_width 2
    set ring_spacing 1
    set ring_offset 1
    
    for {set i 3} {$i <= $top_metal} {incr i} {
	if {$i % 2 == 0} {
	    addRing -nets {VDD VSS} -type core_rings -around core \
		-layer_right METAL$i -layer_left METAL$i -layer_top METAL[expr $i-1] -layer_bottom METAL[expr $i-1] \
		-width_top ${ring_width} -width_bottom ${ring_width} -width_left ${ring_width} -width_right ${ring_width} \
		-spacing_top ${ring_spacing} -spacing_bottom ${ring_spacing} -spacing_right ${ring_spacing} -spacing_left ${ring_spacing} \
		-offset_right ${ring_offset} -offset_left ${ring_offset}
	} else {
	    addRing -nets {VDD VSS} -type core_rings -around core \
		-layer_right METAL[expr $i-1] -layer_left METAL[expr $i-1] -layer_top METAL$i -layer_bottom METAL$i \
		-width_top ${ring_width} -width_bottom ${ring_width} -width_left ${ring_width} -width_right ${ring_width} \
		-spacing_top ${ring_spacing} -spacing_bottom ${ring_spacing} -spacing_right ${ring_spacing} -spacing_left ${ring_spacing} \
		-offset_right ${ring_offset} -offset_left ${ring_offset}
	}
    }

    # STRIPES
    set stripe_width_v 1.320
    set stripe_width_h 1.320
    set cell_height 5.040
    set cell_width 40.260
    
    globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
    globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
    setAddStripeOption -remove_floating_stripe_over_block 0

    #STANDARD CELL STRIPES
    sroute -nets {VDD VSS} -corePinLayer 1 -noLayerChangeRoute -noBlockPins -noPadPins -noPadRings -verbose

    #POWER STRIPES
    for {set i 4} {$i <= $top_metal} {incr i 2} {
	addStripe -nets {VDD VSS} -direction vertical -layer METAL$i -width $stripe_width_v -start_from left\
	    -spacing [expr $cell_width+${stripe_width_v}] \
	    -set_to_set_distance [expr 2*${cell_width}] \
	    -xleft_offset ${cell_width}
    }
    for {set i 3} {$i <= $top_metal} {incr i 2} {
        addStripe -nets {VDD VSS} -direction horizontal -layer METAL${i} -width ${stripe_width_h} -start_from bottom \
	    -spacing [expr 3*${cell_height}-${stripe_width_h}] \
	    -set_to_set_distance [expr 6*${cell_height}] \
	    -ybottom_offset [expr 2.5*${cell_height}-0.5*${stripe_width_h}]
    }

    saveDesign ${my_toplevel}.power.enc
    puts "##################################" 
    puts "#Power Rings & Stripes Done" 
    puts "#Saved in ${my_toplevel}.power.enc"
    puts "##################################" 
}