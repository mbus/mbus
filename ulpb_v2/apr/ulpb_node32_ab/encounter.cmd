#######################################################
#                                                     #
#  Encounter Command Logging File                     #
#  Created on Fri Mar  8 16:29:00 2013                #
#                                                     #
#######################################################

#@(#)CDS: First Encounter v08.10-s273_1 (64bit) 06/16/2009 02:26 (Linux 2.6)
#@(#)CDS: NanoRoute v08.10-s155 NR090610-1622/USR60-UB (database version 2.30, 78.1.1) {superthreading v1.11}
#@(#)CDS: CeltIC v08.12-s254_1 (64bit) 06/11/2009 13:50:30 (Linux 2.6.9-67.0.10.ELsmp)
#@(#)CDS: CTE v08.10-s204_1 (64bit) Jun 10 2009 13:59:07 (Linux 2.6.9-67.0.10.ELsmp)
#@(#)CDS: CPE v08.12-s010

getMultiCpuLicense 12
setMultiCpuUsage -numThreads 12
loadConfig ./ulpb_node32_ab.conf
setCteReport
floorPlan -r 1.0 0.75 10 10 10 10
setFlipping s
redraw
fit
addRing -nets {VDD VSS} -type core_rings -around core -layer_right METAL2 -layer_left METAL2 -layer_top METAL3 -layer_bottom METAL3 -width_top 2 -width_bottom 2 -width_left 2 -width_right 2 -spacing_top 1 -spacing_bottom 1 -spacing_right 1 -spacing_left 1 -offset_right 1 -offset_left 1
addRing -nets {VDD VSS} -type core_rings -around core -layer_right METAL4 -layer_left METAL4 -layer_top METAL3 -layer_bottom METAL3 -width_top 2 -width_bottom 2 -width_left 2 -width_right 2 -spacing_top 1 -spacing_bottom 1 -spacing_right 1 -spacing_left 1 -offset_right 1 -offset_left 1
addRing -nets {VDD VSS} -type core_rings -around core -layer_right METAL4 -layer_left METAL4 -layer_top METAL5 -layer_bottom METAL5 -width_top 2 -width_bottom 2 -width_left 2 -width_right 2 -spacing_top 1 -spacing_bottom 1 -spacing_right 1 -spacing_left 1 -offset_right 1 -offset_left 1
globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
setAddStripeOption -remove_floating_stripe_over_block 0
sroute -nets {VDD VSS} -corePinLayer 1 -noLayerChangeRoute -noBlockPins -noPadPins -noPadRings -verbose
addStripe -nets {VDD VSS} -direction vertical -layer METAL4 -width 1.320 -start_from left -spacing 41.58 -set_to_set_distance 80.52 -xleft_offset 40.260
addStripe -nets {VDD VSS} -direction horizontal -layer METAL3 -width 1.320 -start_from bottom -spacing 13.8 -set_to_set_distance 30.24 -ybottom_offset 11.94
addStripe -nets {VDD VSS} -direction horizontal -layer METAL5 -width 1.320 -start_from bottom -spacing 13.8 -set_to_set_distance 30.24 -ybottom_offset 11.94
saveDesign ulpb_node32_ab.power.enc
setPrerouteAsObs {1 2}
loadIoFile ulpb_node32_ab.io
timeDesign -prePlace
setPlaceMode -congEffort high -maxRouteLayer 5 -placeIoPins false
placeDesign
timeDesign -preCTS
optDesign -preCTS
timeDesign -preCTS
congOpt -nrIterInCongOpt 20
globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
applyGlobalNets
saveDesign ulpb_node32_ab.placed.enc
loadTimingCon ../../syn/ulpb_node32_ab.sdc
setCTSMode -bottomPreferredLayer 1 -topPreferredLayer 3 -leafBottomPreferredLayer 1 -leafTopPreferredLayer 3
createClockTreeSpec -output ulpb_node32_ab.cts -bufFootprint clkbuf -invFootprint clkinv
specifyClockTree -clkfile ulpb_node32_ab.cts
ckSynthesis -rguide cts.rguide -report report.ctsrpt -macromodel report.ctsmdl -fix_added_buffers -forceReconvergent
timeDesign -postCTS
optDesign -postCTS -hold
globalNetConnect VDD -type pgpin -pin VDD -inst CLK* -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst CLK* -module {}
applyGlobalNets
saveDesign ulpb_node32_ab.clk.enc
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
setNanoRouteMode -routeTopRoutingLayer 5
setNanoRouteMode -routeBottomRoutingLayer 2
globalDetailRoute
timeDesign -postRoute
optDesign -postRoute -hold
timeDesign -postRoute
saveDesign ulpb_node32_ab.routed.enc
report_timing -check_type setup -path_type full_clock -nworst 20 > timingReports/${my_toplevel}.rpt.setup
setAnalysisMode -checkType hold
report_timing -check_type hold -path_type full_clock -nworst 20 > timingReports/${my_toplevel}.rpt.hold
deleteObstruction -all
checkPlace
addFiller -cell FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER
globalNetConnect VDD -type pgpin -pin VDD -inst *FILLER -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst *FILLER -module {}
applyGlobalNets
saveDesign ulpb_node32_ab.final.enc
deleteObstruction -all
lefOut ulpb_node32_ab.lef -stripePin -PGpinLayers 1 2 3 4 5 6
saveNetlist -excludeLeafCell ulpb_node32_ab.apr.v
saveNetlist -excludeLeafCell -includePowerGround ulpb_node32_ab.apr.pg.v
saveNetlist -excludeLeafCell -includePhysicalInst ulpb_node32_ab.apr.phy.v
saveNetlist -excludeLeafCell -includePhysicalInst -includePowerGround ulpb_node32_ab.apr.phy.pg.v
streamOut ulpb_node32_ab.gds -mapFile ../common/tsmc18.map
setExtractRCMode -engine detail -relative_c_th 0.01 -total_c_th 0.01 -reduce 0.0 -rcdb tap.db -specialNet true -useLEFCap true -useLEFResistance true
extractRC -outfile ulpb_node32_ab.cap
rcOut -spf ulpb_node32_ab.spf
rcOut -spef ulpb_node32_ab.spef
setUseDefaultDelayLimit 10000
delayCal -sdf ulpb_node32_ab.apr.sdf
verifyGeometry -reportAllCells -viaOverlap -report ulpb_node32_ab.geom.rpt
fixMinCutVia
verifyConnectivity -type all -noAntenna -report ulpb_node32_ab.conn.rpt
timeDesign -postRoute
all_op_conds
all_op_conds
get_analysis_view default_view_hold -constraint_mode
setAnalysisMode -checkType hold
report_timing -check_type skew
