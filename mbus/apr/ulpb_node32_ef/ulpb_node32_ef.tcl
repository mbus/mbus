##################################
# TSMC180 ARM/ARTISAN
# Author: zhiyoong
# Last Edited: March 08 2013
# Velocity (SW_SOC 8.1)
###################################

#My Varaibles
set my_toplevel ulpb_node32_ef
set top_metal 5

# Multi-Core
getMultiCpuLicense 12
setMultiCpuUsage -numThreads 12

# Allow manual footprint declarations in conf file
set dbgGPSAutoCellFunction 0

loadConfig ./${my_toplevel}.conf
setCteReport

# Floorplan
floorPlan -r 1.0 0.75 10 10 10 10
setFlipping s
redraw
fit

###################################
# POWER
###################################
source ../common/power.tcl
power ${top_metal} ${my_toplevel}

###################################
# PLACE
###################################
source ../common/place_cells.tcl
place_cells ${top_metal} ${my_toplevel}

###################################
# CLOCK
###################################
source ../common/clock_syn.tcl
#clock_syn ${my_toplevel} ${syn_root}
clock_syn ${my_toplevel} blah

###################################
# ROUTE
###################################
source ../common/route.tcl
route ${top_metal} ${my_toplevel}

###################################
# REPORTS
###################################
report_timing -check_type setup -path_type full_clock -nworst 20 > timingReports/${my_toplevel}.rpt.setup
setAnalysisMode -checkType hold
report_timing -check_type hold -path_type full_clock -nworst 20 > timingReports/${my_toplevel}.rpt.hold

###################################
# CLEAN UP!
###################################
source ../common/cleanup.tcl
cleanup ${top_metal} ${my_toplevel} blah

exit