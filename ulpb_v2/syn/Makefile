
ULPB = ulpb_node32
CTRL = ulpb_ctrl

POST_SDF = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/primetime/pt_postprocessor.pl

#STD_CELLS = /afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v

synth:
	dc_shell -f ${ULPB}.tcl |tee ${ULPB}.dc.log
	-perl ${POST_SDF} -s ${ULPB}.dc.sdf -o ../netlist/${ULPB}.dc.sdf
	dc_shell -f ${CTRL}.tcl |tee ${CTRL}.dc.log
	-perl ${POST_SDF} -s ${CTRL}.dc.sdf -o ../netlist/${CTRL}.dc.sdf
	mv *.nl.v ../netlist

clean:
	rm -f *.log; rm -f *.rpt; rm -f *.nl.v; rm -f *.sdf; rm -f *.svf; rm -f *.key; rm -rf INCA_libs; rm -rf *.log; rm -rf waves.shm; rm -rf .nclaunch*; rm -rf .simvision*;
	rm -f *.pvl *.syn *.mr
