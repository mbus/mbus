# MBus Release 04p2g

## Directory Structure

This release of MBus contains the following directories. 
The term "layer" and "node" are used interchangeably here. 
(e.g., master-layer = master-node, member-layer = member-node)

    * doc: MBus-protocol-releated documents; 
      made mostly by Pat, Ye-Sheng, Yoonmyung...
    * source: All verilog source files are here.
    * master: Verilog files required for a master-layer implementation. 
      This contains only soft-links pointing at original files in `source` 
      directory.
    * member: Verilog files required for a member-layer implementation. 
      This contains only soft-links pointing at original files in `source` 
      directory.
    * mbus_testbench: Verilog files for top-level verilog simulations. 
      These are not intended to be used for a real chip implementation. 
      Instead, you can use these files to make up a dummy layer (either 
      master-layer or member-layer) and use it to control or interact with 
      your DUT layer. This does not include the Layer Controller; Your testbench 
      is expected to behave as the Layer Controller.
    * sample: A sample member-layer implementation is here. It does not contain all 
      files used for the full chip implementation, but it has everything related to 
      the MBus portion.
    * scripts
        - createNewLayer: This script copies MBus verilog files in a user-specified 
          location, and does in-place editing using a given layer name.
        - genRF: This script generates a structural verilog file for MBus Register 
          File. It also does some useful and handy jobs.


## Layer Name Convention and the Included Scripts

Verilog file names in this repository starts with either `LNAME` or `lname`. Also,
verilog modules and some compiler directives also start with `LNAME` or `lname`.
These must be replaced with a real layer name. Conventionally, `LNAME` is replaced
with the upper-case layer name, while `lname` is replaced with the lower-case layer
name. For example, if your layer name is `FLPv3L` (Flash layer version 3 Large),
`LNAME` could be replaced with `FLPv3L`, and `lname` is replaced with `flpv3l`.
(Note that the `v` character is always lower-case). Usually a layer name consists
of three upper-case letters (e.g., FLP), followed by a version (e.g., v3), followed
by a sub-version letter (e.g., L). This is our policy at the University of Michigan;
other parties may do differently. However, note that the included scripts,
`createNewLayer` and `genRF`, are built based on this policy.


### `createNewLayer`

Usage: `createNewLayer [LAYER_NAME]`

This script copies necessary MBus verilog files into your working directory and
replaces `LNAME` and `lname` prefixes in Verilog file names, modules, etc,
with a given layer name.

Before running the script, you need to edit the script itself. Open `createNewLayer`
using a text editor, then find `$LNAME_dir` and `$mbus_dir`. Change the content of
these variables as follows:

`$LNAME_dir`: Absolute path where the top-level verilog is located
`$mbus_dir` : Absolute path of `mbus` directory under `$LNAME_dir`

Also, locate the line "\[INFO\] Select technology..." in the script. You need to add
your technology option in this section. For example, if you use TSMC 65nm, then you
should add the following lines in proper locations:

`print "  7. TSMC 65nm \n"`
`elsif ($tech_id == 7) { $postfix = "tsmc65"; }`

After that, you need to make lname_mbus_member_ctrl.tsmc65.v file. See "Verilog Files"
section below for how to.

Once everything is done, you can run `createNewLayer`, it will copy the MBus Verilog 
files into the specified directories (`$LNAME_dir` and `mbus_dir`) and make appropriate
changes.

Note that, LNAME_def.sample.v and mbus/lname_mbus_isolation.bh.v are provided for
reference purpose only, and these should not be used for a chip implementation.
You need to make your own LNAME_def.v and mbus/lname_mbus_isolation.v file by yourself.
And these files are not overwritten by `createNewLayer` script. See the provided
FLPv3L_def.v and mbus/flpv3l_mbus_isolation.v files in `sample` directory.


### `genRF`

Usage: `genRF genRF.conf`

This script generates a structure verilog for MBus Register File. Makefile and input
configuration files are usually located in `genRF` directory under the top-level
directory (top-level directory indicates the one specified in `$LNAME_dir` in
`createNewLayer`)

The best way to make the input configuration file is modifying the provided sample
file. See sample/FLPv3L/genRF/genRF.conf. This is the input configuration file used
for the sample layer.

There should be detailed comments in the provided genRF.conf, but the most important
variables would be `TOP_LEVEL_VERILOG_FILE` and `TOP_DEF_VERILOG_FILE` since this
script will **directly** modify the files specified in these variables. More specifically,
any lines between a line containing `//---- genRF Beginning of ...` and another line
containing `//---- genRF End of ...` will be replaced by the script. See the sample
genRF.conf and FLPv3L.v, FLPv3L_def.v files in `sample` directory.

The register description in this genRF.conf files has PROPERTY section, which you
specify one of `W/R`, `R`, or `LC`. `W/R`(write/read) and `R`(read-only) are the most
common type of registers, and they will be included in the generated structure verilog.
`LC` is for registers which share the same power/clock domains with the Layer Controller,
and they will be included in a separate behaviral verilog file. Pleae note that, usually,
you do not need `LC` registers.

Following files are generated once you run this script.

    * LNAME_RF.h: C/C++ Header file
    * RegFile.log: MBus Register File information
    * lname_rf.tcl: PrimeTime script for QTM generation
    * lname_rf.v: MBus Register File structural verilog. This is to be instantiated 
      in your top-level verilog.


## Verilog Files

This is a brief description of the verilog files in `member` directory.

    * include: Contains required functions/compiler directives for MBus implementation.
    * LNAME_def.v: Compiler directives for the top-level (your DUT)
    * lname_layer_ctrl.v: Layer Controller behavioral verilog
    * lname_mbus_isolation.v: MBus isolation module. This is for reference only. You need
      to make a structural verilog of MBus isolation in your directory by yourself. See
      the description of `createNewLayer` script above.
    * lname_mbus_member_ctrl.xxx.v: Structural verilog of MBus Member Control module.
      'XXX' represents the technology selection. You need to prepare a new one if you
      can't find your technology here. Just copy one of the file and rename it properly,
      and then replace all the standard cell instantiations and related pin names,
      following your standard cell library convention.
    * lname_mbus_member_ctrl.v: Behavioral verilog of MBus Member Control module. This
      is for reference only, and this should not be used for a chip implementation.
    * lname_mbus_node.v: MBus Node behavioral verilog
    * lname_mbus_swapper.v: MBus Swapper behavioral verilog


## Contact

Please forward any question to Yejoong Kim [yejoong@umich.edu]

Last Updated on September 21, 2017.
