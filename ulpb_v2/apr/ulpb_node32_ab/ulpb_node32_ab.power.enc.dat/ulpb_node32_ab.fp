######################################################
#                                                    #
#  Cadence Design Systems                            #
#  FirstEncounter Floor Plan Information             #
#                                                    #
######################################################
# Created by First Encounter v08.10-s273_1 on Fri Mar  8 16:29:03 2013

Version: 8

Head Box: 0.0000 0.0000 175.0000 171.2800
IO Box: 0.0000 0.0000 175.0000 171.2800
Core Box: 10.5600 10.0800 165.0000 161.2800
UseStdUtil: false

######################################################
#  DesignRoutingHalo: <space> <bottomLayerName> <topLayerName>
######################################################

######################################################
#  Core Rows Parameters:                             #
######################################################
Row Spacing = 0.000000
Row SpacingType = 2
Row Flip = 1
Core Row Site: tsm3site 

##############################################################################
#  DefRow: <name> <site> <x> <y> <orient> <num_x> <num_y> <step_x> <step_y>  #
##############################################################################
DefRow: ROW_0 tsm3site 10.5600 10.0800 N 234 1 0.6600 0.0000
DefRow: ROW_1 tsm3site 10.5600 15.1200 FS 234 1 0.6600 0.0000
DefRow: ROW_2 tsm3site 10.5600 20.1600 N 234 1 0.6600 0.0000
DefRow: ROW_3 tsm3site 10.5600 25.2000 FS 234 1 0.6600 0.0000
DefRow: ROW_4 tsm3site 10.5600 30.2400 N 234 1 0.6600 0.0000
DefRow: ROW_5 tsm3site 10.5600 35.2800 FS 234 1 0.6600 0.0000
DefRow: ROW_6 tsm3site 10.5600 40.3200 N 234 1 0.6600 0.0000
DefRow: ROW_7 tsm3site 10.5600 45.3600 FS 234 1 0.6600 0.0000
DefRow: ROW_8 tsm3site 10.5600 50.4000 N 234 1 0.6600 0.0000
DefRow: ROW_9 tsm3site 10.5600 55.4400 FS 234 1 0.6600 0.0000
DefRow: ROW_10 tsm3site 10.5600 60.4800 N 234 1 0.6600 0.0000
DefRow: ROW_11 tsm3site 10.5600 65.5200 FS 234 1 0.6600 0.0000
DefRow: ROW_12 tsm3site 10.5600 70.5600 N 234 1 0.6600 0.0000
DefRow: ROW_13 tsm3site 10.5600 75.6000 FS 234 1 0.6600 0.0000
DefRow: ROW_14 tsm3site 10.5600 80.6400 N 234 1 0.6600 0.0000
DefRow: ROW_15 tsm3site 10.5600 85.6800 FS 234 1 0.6600 0.0000
DefRow: ROW_16 tsm3site 10.5600 90.7200 N 234 1 0.6600 0.0000
DefRow: ROW_17 tsm3site 10.5600 95.7600 FS 234 1 0.6600 0.0000
DefRow: ROW_18 tsm3site 10.5600 100.8000 N 234 1 0.6600 0.0000
DefRow: ROW_19 tsm3site 10.5600 105.8400 FS 234 1 0.6600 0.0000
DefRow: ROW_20 tsm3site 10.5600 110.8800 N 234 1 0.6600 0.0000
DefRow: ROW_21 tsm3site 10.5600 115.9200 FS 234 1 0.6600 0.0000
DefRow: ROW_22 tsm3site 10.5600 120.9600 N 234 1 0.6600 0.0000
DefRow: ROW_23 tsm3site 10.5600 126.0000 FS 234 1 0.6600 0.0000
DefRow: ROW_24 tsm3site 10.5600 131.0400 N 234 1 0.6600 0.0000
DefRow: ROW_25 tsm3site 10.5600 136.0800 FS 234 1 0.6600 0.0000
DefRow: ROW_26 tsm3site 10.5600 141.1200 N 234 1 0.6600 0.0000
DefRow: ROW_27 tsm3site 10.5600 146.1600 FS 234 1 0.6600 0.0000
DefRow: ROW_28 tsm3site 10.5600 151.2000 N 234 1 0.6600 0.0000
DefRow: ROW_29 tsm3site 10.5600 156.2400 FS 234 1 0.6600 0.0000

######################################################
#  Track: dir start number space layer_num layer1 ...#
######################################################
Track: X 0.3300 265 0.6600 1 5
Track: Y 1.4000 152 1.1200 1 5
Track: Y 0.2800 306 0.5600 1 4
Track: X 0.3300 265 0.6600 1 4
Track: X 0.3300 265 0.6600 1 3
Track: Y 0.2800 306 0.5600 1 3
Track: Y 0.2800 306 0.5600 1 2
Track: X 0.3300 265 0.6600 1 2
Track: X 0.3300 265 0.6600 1 1
Track: Y 0.2800 306 0.5600 1 1

######################################################
#  GCellGrid: dir start number space                 #
######################################################
GCellGrid: X 171.9300 2 3.0700
GCellGrid: X 0.3300 27 6.6000
GCellGrid: X 0.0000 2 0.3300
GCellGrid: Y 168.2800 2 3.0000
GCellGrid: Y 0.2800 31 5.6000
GCellGrid: Y 0.0000 2 0.2800

######################################################
#  SpareCell: cellName                               #
#  SpareInst: instName                               #
######################################################

######################################################
#  ScanGroup: groupName startPin stopPin             #
######################################################

######################################################
#  JtagCell:  leafCellName                           #
#  JtagInst:  <instName | HInstName>                 #
######################################################

######################################################################################
#  BlackBox: -cell <cell_name> { -size <x> <y> |  -area <um^2> | \                  #
#            -gatecount <count> <areapergate> <utilization> | \                     #
#            {-gateArea <gateAreaValue> [-macroArea <macroAreaValue>]} } \          #
#            [-minwidth <w> | -minheight <h> | -fixedwidh <w> | -fixedheight <h>] \ #
#            [-aspectratio <ratio>]                                                  #
#            [-boxList <nrConstraintBox>                                             #
#              ConstraintBox: <llx> <lly> <urx> <ury>                                #
#              ... ]                                                                 #
######################################################################################

#########################################################
#  PhysicalNet: <name> [-pwr|-gnd|-tiehi|-tielo]        #
#########################################################
PhysicalNet: VDD -pwr
PhysicalNet: VSS -gnd

#########################################################
#  PhysicalInstance: <name> <cell> <orient> <llx> <lly> #
#########################################################

#####################################################################
#  Group: <group_name> <nrHinst> [-isPhyHier]                       #
#    <inst_name>                                                    #
#    ...                                                            #
#####################################################################

#####################################################################
#  Fence:  <name> <llx> <lly> <urx> <ury> <nrConstraintBox>         #
#    ConstraintBox: <llx> <lly> <urx> <ury>                         #
#    ...                                                            #
#  Region: <name> <llx> <lly> <urx> <ury> <nrConstraintBox>         #
#    ConstraintBox: <llx> <lly> <urx> <ury>                         #
#    ...                                                            #
#  Guide:  <name> <llx> <lly> <urx> <ury> <nrConstraintBox>         #
#    ConstraintBox: <llx> <lly> <urx> <ury>                         #
#    ...                                                            #
#  SoftGuide: <name>                                                #
#    ...                                                            #
#####################################################################

###########################################################################
#  <Constraints>                                                          #
#     <Constraint  type="fence|guide|region|softguide"                    #
#                  readonly=1  name="blk_name">                           #
#       <Box llx=1 lly=2 urx=3 ury=4 /> ...                               #
#     </Constraint>                                                       #
#  </Constraints>                                                         #
###########################################################################
###########################################################################
#  <HierarchicalPartitions>                                               #
#     <NetGroup name="group_name" nets=val spacing=val isOptOrder=val isAltLayer=val isPffGroup=val > #
#         <Net name="net_name" /> ...                                     #
#     </NetGroup>                                                         #
#     <Partition name="ptn_name"  hinst="name"                            #
#         coreToLeft=fval coreToRight=fval coreToTop=fval coreToBottom=fval   #
#         pinSpacingNorth=val pinSpacingWest=val pinSpacingSouth=val      #
#         pinSpacingEast=val  blockedLayers=xval >       #
#         <TrackHalfPitch Horizontal=val Vertical=val />                  #
#         <SpacingHalo left=10.0 right=11.0 top=11.0 bottom=11.0 />       #
#         <Clone hinst="hinst_name" orient=R0|R90|... />                  #
#         <PinLayer side="N|W|S|E" Metal1=yes Metal2=yes ... />           #
#         <RowSize cellHeight=1.0 railWidth=1.0 />                        #
#         <RoutingHalo sideSize=11.0 bottomLayer=M1 topLayer=M2  />       #
#         <SpacingHalo left=11.0 right=11.0 top=11.0 bottom=11.0 />       #
#     </Partition>                                                        #
#     <CellPinGroup name="group_name" cell="cell_name"                    #
#                       pins=nr spacing=val isOptOrder=1 isAltLayer=1 >   #
#         <GroupFTerm name="term_name" /> ...                             #
#     </CellPinGroup>                                                     #
#     <PartitionPinBlockage layerMap=x llx=1 lly=2 urx=3 ury=4 name="n" />#
#     <PinGuide name="name" boxes=num cell="name" >                       #
#        <Box llx=11.0 lly=22.0 urx=33.0 ury=44.0 layer=id /> ...         #
#     </PinGuide>                                                         #
#     <CellPtnCut name="name" cuts=Num >                                  #
#        <Box llx=11.0 lly=22.0 urx=33.0 ury=44.0 /> ...                  #
#     </CellPtnCut>                                                       #
#  </HierarchicalPartitions>                                              #
###########################################################################
<HierarchicalPartitions>
    <Partition name="ulpb_node32_ab" hinst="" coreToLeft=0.0000 coreToRight=0.0000 coreToTop=0.0000 coreToBottom=0.0000 pinSpacingNorth=2 pinSpacingWest=2 pinSpacingSouth=2 pinSpacingEast=2 blockedLayers=0x1f >
	<PinLayer side="N" Metal2=yes Metal4=yes />
	<PinLayer side="W" Metal3=yes Metal5=yes />
	<PinLayer side="S" Metal2=yes Metal4=yes />
	<PinLayer side="E" Metal3=yes Metal5=yes />
    </Partition>
</HierarchicalPartitions>

######################################################
#  Instance: <name> <orient> <llx> <lly>             #
######################################################

#################################################################
#  Block: <name> <orient> [<llx> <lly>]                         #
#         [<haloLeftMargin>  <haloBottomMargin>                 #
#          <haloRightMargin> <haloTopMargin> <haloFromInstBox>] #
#         [<IsInstDefCovered> <IsInstPreplaced>]                #
#                                                               #
#  Block with INT_MAX loc is for recording the halo block with  #
#  non-prePlaced status                                         #
#################################################################

######################################################
#  BlockLayerObstruct: <name> <layerX> ...           #
######################################################

######################################################
#  FeedthroughBuffer: <instName>                     #
######################################################

#################################################################
#  <PlacementBlockages>                                         #
#     <Blockage name="blk_name" type="hard|soft|partial">       #
#       <Attr density=1.2 inst="inst_name" pushdown=yes />      #
#       <Box llx=1 lly=2 urx=3 ury=4 /> ...                     #
#     </Blockage>                                               #
#  </PlacementBlockages>                                        #
#################################################################

###########################################################################
#  <RouteBlockages>                                                       #
#     <Blockage name="blk_name" type="User|RouteGuide|PtnCut|WideWire">   #
#       <Attr spacing=1.2 drw=1.2 inst="name" pushdown=yes fills=yes />   #
#       <Layer type="route|cut|masterslice" id=layerNo />                 #
#       <Box llx=1 lly=2 urx=3 ury=4 /> ...                               #
#       <Poly points=nr x0=1 y0=1 x1=2 y2=2 ...  />                       #
#     </Blockage>                                                         #
#  </RouteBlockages>                                                      #
###########################################################################

######################################################
#  PrerouteAsObstruct: <layer_treated_as_obstruct>   #
######################################################
PrerouteAsObstruct: 0x3

######################################################
#  NetWeight: <net_name> <weight (in integer)>       #
######################################################

#################################################################
#  SprFile: <file_name>                                         #
#################################################################
SprFile: ulpb_node32_ab.fp.spr

#########################################################################################
#  IOPin: <pinName> <x> <y> <side> <layerId> <width> <depth> {placed|fixed|cover|-} <nrBox> \ #
#         [-special] [-clock] [[-spacing <value>] | [-drw <value>]]                     #
#    PinBox: <llx> <lly> <urx> <ury> [-lyr <layerId>] \                                 #
#            [[-spacing <value>] | [-drw <value>]]                                      #
#    PinPoly: <nrPt> <x1> <y1> <x2> <y2> ...<xn> <yn> [-lyr <layerId>] \                #
#             [[-spacing <value>] | [-drw <value>]]                                     #
#    PinAntenna: <pinName> <ANTENNAPIN*> <value> LAYER <layer>                          #
#########################################################################################

##########################################################################
#  <IOPins>                                                              #
#    <Pin name="pin_name" type="clock|power|ground|analog"               #
#         status="covered|fixed|placed" is_special=1 >                   #
#      <Port>                                                            #
#        <Pref x=1 y=2 side="N|S|W|E|U|D" width=w depth=d />             #
#        <Via name="via_name" x=1 y=2 /> ...                             #
#        <Layer id=id spacing=1.2 drw=1.2>                               #
#          <Box llx=1 lly=2 urx=3 ury=4 /> ...                           #
#          <Poly points=nr x0=1 y0=1 x1=2 y2=2 ...           />          #
#        </Layer> ...                                                    #
#      </Port>  ...                                                      #
#    </Pin> ...                                                          #
#  </IOPins>                                                             #
##########################################################################

#####################################################################
#  <Property>                                                       #
#     <obj_type name="inst_name" >                                  #
#       <prop name="name" type=type_name value=val />               #
#       <Attr name="name" type=type_name value=val />               #
#     </obj_type>                                                   #
#  </Property>                                                      #
#  where:                                                           #
#       type is data type: Box, String, Int, PTR, Loc, double, Bits #
#       obj_type are: inst, Design, instTerm, Bump, cell, net       #
#####################################################################
<Properties>
  <Design name="ulpb_node32_ab">
	<prop name="CUT_ROWS" type=Int value=0 />
  </Design>
</Properties>

###########################################################$############################################################################################
#  GlobalNetConnection: <net_name> {-pin|-inst|-net} <base_name_pattern> -type {pgpin|net|tiehi|tielo} {-all|-module <name>|-region <box>} [-override] #
########################################################################################################################################################
GlobalNetConnection: VDD -pin VDD -inst * -type pgpin -module {}
GlobalNetConnection: VSS -pin VSS -inst * -type pgpin -module {}

################################################################################
#  NetProperties: <net_name> [-special] [-def_prop {int|dbl|str} <value>]...   #
################################################################################
