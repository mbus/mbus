##################################
# TSMC180 ARM/Artisan
# Author: zhiyoong
# Last Edited: March 03 2010
# Version 7.1 (setenv SW_SOC 7.1)
# Places Cells
# Usage place $my_toplevel
###################################

proc place_cells {top_metal my_toplevel} {
    
    setPrerouteAsObs {1 2}
    loadIoFile ${my_toplevel}.io
    timeDesign -prePlace
    setPlaceMode -congEffort high -maxRouteLayer ${top_metal} -placeIoPins false
    placeDesign
    timeDesign -preCTS
    optDesign -preCTS
    timeDesign -preCTS
    congOpt -nrIterInCongOpt 20
    
    globalNetConnect VDD -type pgpin -pin VDD -inst {*} -module {}
    globalNetConnect VSS -type pgpin -pin VSS -inst {*} -module {}
    applyGlobalNets
    
    saveDesign ${my_toplevel}.placed.enc
    puts "##################################" 
    puts "#Placement Done" 
    puts "#Saved in ${my_toplevel}.placed.enc"
    puts "##################################" 
}