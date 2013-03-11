##################################
# TSMC180 ARM/Artisan
# Author: zhiyoong
# Last Edited: March 03 2010
# Version 7.1 (setenv SW_SOC 7.1)
# Synthesizes clock
# Usage clock $my_toplevel
###################################

proc clock_syn {my_toplevel syn_root} {
#    loadTimingCon ${syn_root}/${my_toplevel}/${my_toplevel}.sdc
    loadTimingCon ../../syn/${my_toplevel}.sdc
    setCTSMode -bottomPreferredLayer 1 -topPreferredLayer 3 -leafBottomPreferredLayer 1 -leafTopPreferredLayer 3
    createClockTreeSpec -output ${my_toplevel}.cts -bufFootprint clkbuf -invFootprint clkinv
    specifyClockTree -clkfile ${my_toplevel}.cts
    ckSynthesis -rguide cts.rguide -report report.ctsrpt -macromodel report.ctsmdl -fix_added_buffers -forceReconvergent
    timeDesign -postCTS
    optDesign -postCTS -hold
    
    globalNetConnect VDD -type pgpin -pin {VDD} -inst {CLK*} -module {} 
    globalNetConnect VSS -type pgpin -pin {VSS} -inst {CLK*} -module {}
    applyGlobalNets
    
    saveDesign ${my_toplevel}.clk.enc
    puts "##################################" 
    puts "#Syhthesizing Clock Done"
    puts "#Saved in ${my_toplevel}.clk.enc"
    puts "##################################" 
}
