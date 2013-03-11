##################################
# TSMC180 ARM/Artisan
# Author: zhiyoong
# Last Edited: March 03 2010
# Version 7.1 (setenv SW_SOC 7.1)
# Routes Signal nets
# Usage route $top_metal $my_toplevel
###################################

proc route {top_metal my_toplevel} {

    setNanoRouteMode -quiet -routeWithTimingDriven true
    setNanoRouteMode -quiet -routeTdrEffort 2
    setNanoRouteMode -quiet -routeSiEffort med
    setNanoRouteMode -quiet -routeSelectedNetOnly false
    setNanoRouteMode -quiet -routeWithSiDriven true
    setNanoRouteMode -quiet -routeWithSiPostRouteFix true
    setNanoRouteMode -quiet -drouteEndIteration 25
    setNanoRouteMode -quiet -drouteOnGridOnly none
    setNanoRouteMode -quiet -routeMergeSpecialWire true
    setNanoRouteMode -quiet -drouteAutoStop false
    setNanoRouteMode -quiet -droutePostRouteSwapVia false
    setNanoRouteMode -quiet -drouteUseMultiCutViaEffort low
    setNanoRouteMode -routeTopRoutingLayer ${top_metal}
    setNanoRouteMode -routeBottomRoutingLayer 2
    globalDetailRoute
    timeDesign -postRoute
    optDesign -postRoute -hold
    timeDesign -postRoute
    saveDesign ${my_toplevel}.routed.enc
    puts "##################################" 
    puts "#Routing Signals Done" 
    puts "#Saved in ${my_toplevel}.routed.enc"
    puts "##################################" 
}