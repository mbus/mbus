# 180um TSMC Artisan Library
# Set library paths
set ARTISAN "/afs/eecs.umich.edu/kits/.contrib/arm_mosis_tsmc_180/mm3_node/sc-x_2004q3v1/aci/sc/synopsys"
set SYNOPSYS [get_unix_variable SYNOPSYS]
set search_path [list "." $ARTISAN ${SYNOPSYS}/libraries/syn]
set link_library "* typical.db dw_foundation.sldb"
set target_library "typical.db"

# set_dont_use any *XL* cell
#set_dont_use { typical/*XLTR }

#Warning Suppression
suppress_message UID-401
