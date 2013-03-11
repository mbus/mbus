##################################
# TSMC180 ARM/Artisan
# Author: zhiyoong
# Last Edited: March 03 2010
# Version 7.1 (setenv SW_SOC 7.1)
# Cleans Up
# Filler Cells Insertion
# Obstruction Removal
# Outputs: .lef
#          .apr.v
#          .apr.pg.v
#          .apr.phy.v
#          .apr.phy.pg.v
#          .cap
#          .spf
#          .spef
#          .sdf
#          .apr.v.cdl
#          .apr.pg.v.cdl
#          .gds
# Usage cleanup $top_metal $my_toplevel
###################################

proc cleanup {top_metal my_toplevel apr_root} {
    
    deleteObstruction -all
    checkPlace
    
    #ADD FILLER
    addFiller -cell FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER
    globalNetConnect VDD -type pgpin -pin VDD -inst {*FILLER} -module {}
    globalNetConnect VSS -type pgpin -pin VSS -inst {*FILLER} -module {}
    applyGlobalNets
    
    saveDesign ${my_toplevel}.final.enc
    
    deleteObstruction -all

    #OUTPUT LEF
    set dbgLefDefOutVersion 5.5
    lefout ${my_toplevel}.lef -stripePin -PGpinLayers 1 2 3 4 5 6

    #OUTPUT VERILOG
    saveNetlist -excludeLeafCell ${my_toplevel}.apr.v
    saveNetlist -excludeLeafCell -includePowerGround ${my_toplevel}.apr.pg.v
    saveNetlist -excludeLeafCell -includePhysicalInst ${my_toplevel}.apr.phy.v
    saveNetlist -excludeLeafCell -includePhysicalInst -includePowerGround ${my_toplevel}.apr.phy.pg.v

    #OUTPUT CDL
#    exec perl ${apr_root}/common/lvs2cdl.pl $my_toplevel &

    #OUTPUT GDS
    streamOut ${my_toplevel}.gds -mapFile ../common/tsmc18.map

    # Generate SDF
    setExtractRCMode -engine detail -relative_c_th 0.01 -total_c_th 0.01 -reduce 0.0 -rcdb tap.db \
	-specialNet true -useLEFCap true -useLEFResistance true
    extractRC -outfile ${my_toplevel}.cap
    rcOut -spf ${my_toplevel}.spf
    rcOut -spef ${my_toplevel}.spef
    write_sdc ${my_toplevel}.sdc

    setUseDefaultDelayLimit 10000
    delayCal -sdf ${my_toplevel}.apr.sdf

    # Run Geometry and Connection checks
    verifyGeometry -reportAllCells -viaOverlap -report ${my_toplevel}.geom.rpt
    fixMinCutVia

    # Meant for power vias that are just too small
    verifyConnectivity -type all -noAntenna -report ${my_toplevel}.conn.rpt
    timeDesign -postRoute
    reportPower

    setAnalysisMode -checkType hold
    report_timing -check_type skew
    
    puts "##################################" 
    puts "#Cleanup Done" 
    puts "#Saved in ${my_toplevel}.final.enc"
    puts "##################################" 
}