# Generate report file
set maxpaths 20

check_design > $rpt_file
#Ungroup Hierarchy and report area & cell
ungroup -all
report_area  >> ${rpt_file}
report_cell >> ${rpt_file}
report_power -analysis_effort high -verbose >> ${rpt_file}
report_power -net -include_input_nets -nworst 10 >> ${rpt_file}
report_design >> ${rpt_file}
report_port -verbose >> ${rpt_file}
report_compile_options >> ${rpt_file}
report_constraint -all_violators -verbose >> ${rpt_file}
report_timing -path full -delay max -max_paths $maxpaths -nworst 100 >> ${rpt_file}
