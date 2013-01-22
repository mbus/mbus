# common.tcl setup library files

# 180um IBM Artisan Library
# Set library paths
set ARTISAN "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/synopsys"
set SYNOPSYS [get_unix_variable SYNOPSYS]
set search_path [list "." $ARTISAN ${SYNOPSYS}/libraries/syn]
set link_library "* typical.db dw_foundation.sldb"
set target_library "typical.db"

# set_dont_use any *XL* cell
set_dont_use { typical/*XLTR }
