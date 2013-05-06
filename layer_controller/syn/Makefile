
POST_SDF = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/primetime/pt_postprocessor.pl

synth:
	dc_shell -f layer_ctrl.tcl |tee layer_ctrl.dc.log
	-perl ${POST_SDF} -s layer_ctrl.pt.sdf -o layer_ctrl.dc.sdf

clean:
	rm -f *.log; rm -f *.rpt; rm -f *.nl.v; rm -f *.sdf; rm -f *.svf; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*;
	rm -f *.pvl *.syn *.mr *.sdc
	rm -rf alib*
