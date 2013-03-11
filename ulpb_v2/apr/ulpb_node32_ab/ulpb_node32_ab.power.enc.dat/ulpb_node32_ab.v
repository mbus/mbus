module ulpb_node32_ab (
	CLKIN, 
	RESETn, 
	DIN, 
	CLKOUT, 
	DOUT, 
	TX_ADDR, 
	TX_DATA, 
	TX_PEND, 
	TX_REQ, 
	PRIORITY, 
	TX_ACK, 
	RX_ADDR, 
	RX_DATA, 
	RX_REQ, 
	RX_ACK, 
	RX_FAIL, 
	RX_PEND, 
	TX_FAIL, 
	TX_SUCC, 
	TX_RESP_ACK);
   input CLKIN;
   input RESETn;
   input DIN;
   output CLKOUT;
   output DOUT;
   input [7:0] TX_ADDR;
   input [31:0] TX_DATA;
   input TX_PEND;
   input TX_REQ;
   input PRIORITY;
   output TX_ACK;
   output [7:0] RX_ADDR;
   output [31:0] RX_DATA;
   output RX_REQ;
   input RX_ACK;
   output RX_FAIL;
   output RX_PEND;
   output TX_FAIL;
   output TX_SUCC;
   input TX_RESP_ACK;

   // Internal wires
   wire n990;
   wire n991;
   wire n992;
   wire n993;
   wire n994;
   wire n995;
   wire n996;
   wire n997;
   wire n998;
   wire n999;
   wire n1000;
   wire n1001;
   wire n1002;
   wire n1003;
   wire n1004;
   wire n1005;
   wire n1006;
   wire n1007;
   wire n1008;
   wire n1009;
   wire n1010;
   wire n1011;
   wire n1012;
   wire n1013;
   wire n1014;
   wire n1015;
   wire n1016;
   wire n1017;
   wire n1018;
   wire n1019;
   wire n1020;
   wire n1021;
   wire n1022;
   wire n1023;
   wire n1024;
   wire n1025;
   wire n1026;
   wire BUS_INT;
   wire BUS_INT_RSTn;
   wire out_reg_pos;
   wire tx_underflow;
   wire ctrl_bit_buf;
   wire out_reg_neg;
   wire \mode_neg[1] ;
   wire N754;
   wire swapper0_negp_int;
   wire swapper0_nege_negp_clk_5;
   wire swapper0_nege_negp_clk_3;
   wire swapper0_nege_negp_clk_1;
   wire swapper0_pose_negp_clk_4;
   wire swapper0_pose_negp_clk_2;
   wire swapper0_pose_negp_clk_0;
   wire n11;
   wire n12;
   wire n14;
   wire n16;
   wire n18;
   wire n20;
   wire n22;
   wire n24;
   wire n26;
   wire n28;
   wire n30;
   wire n32;
   wire n34;
   wire n36;
   wire n38;
   wire n40;
   wire n42;
   wire n44;
   wire n46;
   wire n48;
   wire n50;
   wire n52;
   wire n54;
   wire n56;
   wire n58;
   wire n60;
   wire n62;
   wire n64;
   wire n66;
   wire n68;
   wire n70;
   wire n72;
   wire n74;
   wire n76;
   wire n78;
   wire n79;
   wire n81;
   wire n82;
   wire n83;
   wire n84;
   wire n86;
   wire n88;
   wire n90;
   wire n92;
   wire n94;
   wire n96;
   wire n98;
   wire n100;
   wire n102;
   wire n104;
   wire n106;
   wire n108;
   wire n110;
   wire n112;
   wire n114;
   wire n116;
   wire n118;
   wire n120;
   wire n122;
   wire n124;
   wire n126;
   wire n128;
   wire n130;
   wire n132;
   wire n134;
   wire n136;
   wire n138;
   wire n140;
   wire n142;
   wire n144;
   wire n146;
   wire n148;
   wire n150;
   wire n152;
   wire n153;
   wire n154;
   wire n155;
   wire n156;
   wire n157;
   wire n158;
   wire n159;
   wire n160;
   wire n161;
   wire n162;
   wire n163;
   wire n164;
   wire n165;
   wire n166;
   wire n167;
   wire n168;
   wire n169;
   wire n170;
   wire n171;
   wire n172;
   wire n173;
   wire n174;
   wire n175;
   wire n176;
   wire n177;
   wire n178;
   wire n179;
   wire n180;
   wire n181;
   wire n182;
   wire n183;
   wire n184;
   wire n185;
   wire n187;
   wire n189;
   wire n191;
   wire n193;
   wire n195;
   wire n197;
   wire n199;
   wire n201;
   wire n202;
   wire n203;
   wire n204;
   wire n205;
   wire n207;
   wire n209;
   wire n210;
   wire n211;
   wire n212;
   wire n213;
   wire n214;
   wire n216;
   wire n217;
   wire n218;
   wire n219;
   wire n220;
   wire n221;
   wire n223;
   wire n224;
   wire n225;
   wire n226;
   wire n227;
   wire n229;
   wire n248;
   wire n254;
   wire n260;
   wire n262;
   wire n308;
   wire n309;
   wire n312;
   wire n451;
   wire n518;
   wire n520;
   wire n521;
   wire n522;
   wire n523;
   wire n524;
   wire n525;
   wire n526;
   wire n529;
   wire n583;
   wire n623;
   wire n625;
   wire n627;
   wire n628;
   wire n629;
   wire n630;
   wire n631;
   wire n632;
   wire n633;
   wire n634;
   wire n635;
   wire n636;
   wire n637;
   wire n638;
   wire n639;
   wire n640;
   wire n641;
   wire n642;
   wire n643;
   wire n644;
   wire n645;
   wire n646;
   wire n647;
   wire n648;
   wire n649;
   wire n650;
   wire n651;
   wire n652;
   wire n653;
   wire n654;
   wire n655;
   wire n656;
   wire n657;
   wire n658;
   wire n659;
   wire n660;
   wire n661;
   wire n662;
   wire n663;
   wire n664;
   wire n665;
   wire n666;
   wire n667;
   wire n668;
   wire n669;
   wire n670;
   wire n671;
   wire n672;
   wire n673;
   wire n674;
   wire n675;
   wire n676;
   wire n677;
   wire n678;
   wire n679;
   wire n680;
   wire n717;
   wire n718;
   wire n719;
   wire n720;
   wire n721;
   wire n722;
   wire n723;
   wire n725;
   wire n726;
   wire n727;
   wire n728;
   wire n730;
   wire n731;
   wire n732;
   wire n733;
   wire n734;
   wire n735;
   wire n736;
   wire n737;
   wire n738;
   wire n739;
   wire n740;
   wire n741;
   wire n742;
   wire n743;
   wire n744;
   wire n745;
   wire n746;
   wire n747;
   wire n748;
   wire n749;
   wire n750;
   wire n751;
   wire n752;
   wire n753;
   wire n7540;
   wire n755;
   wire n756;
   wire n757;
   wire n758;
   wire n759;
   wire n760;
   wire n761;
   wire n762;
   wire n763;
   wire n764;
   wire n765;
   wire n766;
   wire n767;
   wire n768;
   wire n769;
   wire n770;
   wire n771;
   wire n772;
   wire n773;
   wire n774;
   wire n775;
   wire n776;
   wire n777;
   wire n778;
   wire n779;
   wire n780;
   wire n781;
   wire n782;
   wire n783;
   wire n784;
   wire n785;
   wire n786;
   wire n787;
   wire n788;
   wire n789;
   wire n790;
   wire n791;
   wire n792;
   wire n793;
   wire n794;
   wire n795;
   wire n796;
   wire n797;
   wire n798;
   wire n799;
   wire n800;
   wire n801;
   wire n802;
   wire n803;
   wire n804;
   wire n805;
   wire n806;
   wire n807;
   wire n808;
   wire n809;
   wire n810;
   wire n811;
   wire n812;
   wire n813;
   wire n814;
   wire n815;
   wire n816;
   wire n817;
   wire n818;
   wire n819;
   wire n820;
   wire n821;
   wire n822;
   wire n823;
   wire n824;
   wire n825;
   wire n826;
   wire n827;
   wire n828;
   wire n829;
   wire n830;
   wire n831;
   wire n832;
   wire n833;
   wire n834;
   wire n835;
   wire n836;
   wire n837;
   wire n838;
   wire n839;
   wire n840;
   wire n841;
   wire n842;
   wire n843;
   wire n844;
   wire n845;
   wire n846;
   wire n847;
   wire n848;
   wire n849;
   wire n850;
   wire n851;
   wire n852;
   wire n853;
   wire n854;
   wire n855;
   wire n856;
   wire n857;
   wire n858;
   wire n859;
   wire n860;
   wire n861;
   wire n862;
   wire n863;
   wire n864;
   wire n865;
   wire n866;
   wire n867;
   wire n868;
   wire n869;
   wire n870;
   wire n871;
   wire n872;
   wire n873;
   wire n874;
   wire n875;
   wire n876;
   wire n877;
   wire n878;
   wire n879;
   wire n880;
   wire n881;
   wire n882;
   wire n883;
   wire n884;
   wire n885;
   wire n886;
   wire n887;
   wire n888;
   wire n889;
   wire n890;
   wire n891;
   wire n892;
   wire n893;
   wire n894;
   wire n895;
   wire n896;
   wire n897;
   wire n898;
   wire n899;
   wire n900;
   wire n901;
   wire n902;
   wire n903;
   wire n904;
   wire n905;
   wire n906;
   wire n907;
   wire n908;
   wire n909;
   wire n910;
   wire n911;
   wire n912;
   wire n913;
   wire n914;
   wire n915;
   wire n916;
   wire n917;
   wire n918;
   wire n919;
   wire n920;
   wire n921;
   wire n922;
   wire n923;
   wire n924;
   wire n925;
   wire n926;
   wire n927;
   wire n928;
   wire n929;
   wire n930;
   wire n931;
   wire n932;
   wire n933;
   wire n934;
   wire n935;
   wire n936;
   wire n937;
   wire n938;
   wire n939;
   wire n940;
   wire n941;
   wire n942;
   wire n943;
   wire n944;
   wire n945;
   wire n946;
   wire n947;
   wire n948;
   wire n949;
   wire n950;
   wire n951;
   wire n952;
   wire n953;
   wire n954;
   wire n955;
   wire n956;
   wire n957;
   wire n958;
   wire n959;
   wire n960;
   wire n961;
   wire n962;
   wire n963;
   wire n964;
   wire n965;
   wire n966;
   wire n967;
   wire n968;
   wire n969;
   wire n970;
   wire n971;
   wire n972;
   wire n973;
   wire n974;
   wire n975;
   wire n976;
   wire n977;
   wire n978;
   wire n979;
   wire n980;
   wire n981;
   wire n982;
   wire n983;
   wire n984;
   wire n985;
   wire n986;
   wire n987;
   wire n988;
   wire [7:0] ADDR;
   wire [4:0] bit_position;
   wire [31:0] DATA;
   wire [3:2] bus_state;
   wire [1:0] mode;
   wire [33:4] rx_data_buf;
   wire [3:0] bus_state_neg;

   DFFNSXL \mode_neg_reg[0]  (.SN(n767), 
	.QN(n719), 
	.D(n202), 
	.CKN(CLKIN));
   DFFSX1 \rx_data_buf_reg[13]  (.SN(n767), 
	.QN(n749), 
	.D(n124), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[3]  (.SN(n763), 
	.QN(n748), 
	.D(n144), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[0]  (.SN(n766), 
	.QN(RX_ADDR[0]), 
	.Q(n746), 
	.D(n199), 
	.CK(CLKIN));
   DFFSX1 \mode_reg[1]  (.SN(n761), 
	.QN(n254), 
	.Q(mode[1]), 
	.D(n623), 
	.CK(CLKIN));
   DFFSX1 req_interrupt_reg (.SN(n765), 
	.QN(n745), 
	.Q(n260), 
	.D(n217), 
	.CK(CLKIN));
   DFFSX1 \bit_position_reg[1]  (.SN(n764), 
	.QN(n744), 
	.Q(bit_position[1]), 
	.D(n212), 
	.CK(CLKIN));
   DFFSX1 \bit_position_reg[4]  (.SN(n766), 
	.QN(bit_position[4]), 
	.Q(n742), 
	.D(n205), 
	.CK(CLKIN));
   DFFNRX1 \bus_state_neg_reg[1]  (.RN(n761), 
	.QN(n308), 
	.Q(n741), 
	.D(N754), 
	.CKN(CLKIN));
   DFFSXL RX_FAIL_reg (.SN(n767), 
	.QN(n1024), 
	.D(n79), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[2]  (.SN(n767), 
	.QN(n740), 
	.D(n146), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[12]  (.SN(n766), 
	.QN(n739), 
	.D(n126), 
	.CK(CLKIN));
   DFFSX1 RX_REQ_reg (.SN(n763), 
	.QN(RX_REQ), 
	.Q(n738), 
	.D(n214), 
	.CK(CLKIN));
   DFFSX1 \bit_position_reg[0]  (.SN(n762), 
	.QN(n733), 
	.Q(bit_position[0]), 
	.D(n220), 
	.CK(CLKIN));
   DFFSX1 \bit_position_reg[2]  (.SN(n766), 
	.QN(n732), 
	.Q(bit_position[2]), 
	.D(n209), 
	.CK(CLKIN));
   DFFSX1 \bus_state_reg[3]  (.SN(n766), 
	.QN(bus_state[3]), 
	.Q(n731), 
	.D(n204), 
	.CK(CLKIN));
   DFFNSXL swapper0_nege_negp_clk_5_reg (.SN(n227), 
	.QN(swapper0_nege_negp_clk_5), 
	.D(n223), 
	.CKN(n750));
   DFFNSXL swapper0_nege_negp_clk_1_reg (.SN(n227), 
	.QN(swapper0_nege_negp_clk_1), 
	.Q(n226), 
	.D(n229), 
	.CKN(n750));
   DFFNSXL swapper0_nege_negp_clk_3_reg (.SN(n227), 
	.QN(swapper0_nege_negp_clk_3), 
	.Q(n224), 
	.D(n225), 
	.CKN(n750));
   DFFSXL swapper0_pose_negp_clk_0_reg (.SN(n227), 
	.QN(swapper0_pose_negp_clk_0), 
	.Q(n229), 
	.D(1'b0), 
	.CK(n750));
   DFFSXL swapper0_pose_negp_clk_2_reg (.SN(n227), 
	.QN(swapper0_pose_negp_clk_2), 
	.Q(n225), 
	.D(n226), 
	.CK(n750));
   DFFSXL swapper0_pose_negp_clk_4_reg (.SN(n227), 
	.QN(swapper0_pose_negp_clk_4), 
	.Q(n223), 
	.D(n224), 
	.CK(n750));
   DFFSXL BUS_INT_RSTn_reg (.SN(n761), 
	.Q(BUS_INT_RSTn), 
	.D(n312), 
	.CK(CLKIN));
   DFFSXL TX_SUCC_reg (.SN(n81), 
	.QN(n1026), 
	.D(n82), 
	.CK(CLKIN));
   DFFSXL TX_FAIL_reg (.SN(n81), 
	.QN(n1025), 
	.D(n451), 
	.CK(CLKIN));
   DFFSXL \rx_data_buf_reg[33]  (.SN(n761), 
	.QN(rx_data_buf[33]), 
	.D(n84), 
	.CK(CLKIN));
   DFFSXL TX_ACK_reg (.SN(n766), 
	.QN(n991), 
	.D(n11), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[3]  (.SN(n765), 
	.QN(n1020), 
	.D(n64), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[2]  (.SN(n764), 
	.QN(n1021), 
	.D(n58), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[1]  (.SN(n761), 
	.QN(n1022), 
	.D(n36), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[13]  (.SN(n765), 
	.QN(n1010), 
	.D(n22), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[12]  (.SN(n766), 
	.QN(n1011), 
	.D(n20), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[11]  (.SN(n767), 
	.QN(n1012), 
	.D(n18), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[10]  (.SN(n761), 
	.QN(n1013), 
	.D(n16), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[0]  (.SN(n765), 
	.QN(n1023), 
	.D(n14), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[9]  (.SN(n765), 
	.QN(n1014), 
	.D(n76), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[8]  (.SN(n764), 
	.QN(n1015), 
	.D(n74), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[7]  (.SN(n766), 
	.QN(n1016), 
	.D(n72), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[6]  (.SN(n763), 
	.QN(n1017), 
	.D(n70), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[5]  (.SN(n766), 
	.QN(n1018), 
	.D(n68), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[4]  (.SN(n763), 
	.QN(n1019), 
	.D(n66), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[31]  (.SN(n762), 
	.QN(n992), 
	.D(n62), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[30]  (.SN(n766), 
	.QN(n993), 
	.D(n60), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[29]  (.SN(n766), 
	.QN(n994), 
	.D(n56), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[28]  (.SN(n767), 
	.QN(n995), 
	.D(n54), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[27]  (.SN(n761), 
	.QN(n996), 
	.D(n52), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[26]  (.SN(n765), 
	.QN(n997), 
	.D(n50), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[25]  (.SN(n764), 
	.QN(n998), 
	.D(n48), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[24]  (.SN(n766), 
	.QN(n999), 
	.D(n46), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[23]  (.SN(n764), 
	.QN(n1000), 
	.D(n44), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[22]  (.SN(n766), 
	.QN(n1001), 
	.D(n42), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[21]  (.SN(n763), 
	.QN(n1002), 
	.D(n40), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[20]  (.SN(n762), 
	.QN(n1003), 
	.D(n38), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[19]  (.SN(n766), 
	.QN(n1004), 
	.D(n34), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[18]  (.SN(n766), 
	.QN(n1005), 
	.D(n32), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[17]  (.SN(n767), 
	.QN(n1006), 
	.D(n30), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[16]  (.SN(n761), 
	.QN(n1007), 
	.D(n28), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[15]  (.SN(n765), 
	.QN(n1008), 
	.D(n26), 
	.CK(CLKIN));
   DFFSXL \RX_DATA_reg[14]  (.SN(n764), 
	.QN(n1009), 
	.D(n24), 
	.CK(CLKIN));
   DFFSXL \rx_data_buf_reg[0]  (.SN(n764), 
	.Q(n676), 
	.D(n150), 
	.CK(CLKIN));
   DFFSXL \rx_data_buf_reg[1]  (.SN(n765), 
	.Q(n674), 
	.D(n148), 
	.CK(CLKIN));
   DFFSXL \rx_data_buf_reg[32]  (.SN(n762), 
	.Q(n675), 
	.D(n86), 
	.CK(CLKIN));
   DFFSXL RX_PEND_reg (.SN(n766), 
	.Q(n677), 
	.D(n12), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[6]  (.SN(n766), 
	.QN(rx_data_buf[6]), 
	.D(n138), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[7]  (.SN(n761), 
	.QN(rx_data_buf[7]), 
	.D(n136), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[8]  (.SN(n766), 
	.QN(rx_data_buf[8]), 
	.D(n134), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[16]  (.SN(n763), 
	.QN(rx_data_buf[16]), 
	.D(n118), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[17]  (.SN(n763), 
	.QN(rx_data_buf[17]), 
	.D(n116), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[18]  (.SN(n762), 
	.QN(rx_data_buf[18]), 
	.D(n114), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[19]  (.SN(n765), 
	.QN(rx_data_buf[19]), 
	.D(n112), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[20]  (.SN(n764), 
	.QN(rx_data_buf[20]), 
	.D(n110), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[21]  (.SN(n767), 
	.QN(rx_data_buf[21]), 
	.D(n108), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[22]  (.SN(n761), 
	.QN(rx_data_buf[22]), 
	.D(n106), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[23]  (.SN(n766), 
	.QN(rx_data_buf[23]), 
	.D(n104), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[24]  (.SN(n766), 
	.QN(rx_data_buf[24]), 
	.D(n102), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[25]  (.SN(n763), 
	.QN(rx_data_buf[25]), 
	.D(n100), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[26]  (.SN(n762), 
	.QN(rx_data_buf[26]), 
	.D(n98), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[27]  (.SN(n766), 
	.QN(rx_data_buf[27]), 
	.D(n96), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[28]  (.SN(n763), 
	.QN(rx_data_buf[28]), 
	.D(n94), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[29]  (.SN(n762), 
	.QN(rx_data_buf[29]), 
	.D(n92), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[30]  (.SN(n766), 
	.QN(rx_data_buf[30]), 
	.D(n90), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[9]  (.SN(n761), 
	.QN(rx_data_buf[9]), 
	.D(n132), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[31]  (.SN(n766), 
	.QN(rx_data_buf[31]), 
	.D(n88), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[4]  (.SN(n765), 
	.QN(rx_data_buf[4]), 
	.D(n142), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[14]  (.SN(n767), 
	.QN(rx_data_buf[14]), 
	.D(n122), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[5]  (.SN(n762), 
	.QN(rx_data_buf[5]), 
	.D(n140), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[15]  (.SN(n763), 
	.QN(rx_data_buf[15]), 
	.D(n120), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[10]  (.SN(n766), 
	.QN(rx_data_buf[10]), 
	.D(n130), 
	.CK(CLKIN));
   DFFSX1 \rx_data_buf_reg[11]  (.SN(n764), 
	.QN(rx_data_buf[11]), 
	.D(n128), 
	.CK(CLKIN));
   DFFSXL ctrl_bit_buf_reg (.SN(n766), 
	.QN(ctrl_bit_buf), 
	.D(n83), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[7]  (.SN(RESETn), 
	.QN(RX_ADDR[7]), 
	.D(n185), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[2]  (.SN(n762), 
	.QN(RX_ADDR[2]), 
	.D(n195), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[4]  (.SN(n765), 
	.QN(RX_ADDR[4]), 
	.D(n191), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[6]  (.SN(RESETn), 
	.QN(RX_ADDR[6]), 
	.D(n187), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[5]  (.SN(RESETn), 
	.QN(RX_ADDR[5]), 
	.D(n189), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[1]  (.SN(n764), 
	.QN(RX_ADDR[1]), 
	.D(n197), 
	.CK(CLKIN));
   DFFSX1 \RX_ADDR_reg[3]  (.SN(n767), 
	.QN(RX_ADDR[3]), 
	.D(n193), 
	.CK(CLKIN));
   DFFSXL out_reg_pos_reg (.SN(n766), 
	.QN(out_reg_pos), 
	.D(n78), 
	.CK(CLKIN));
   DFFSXL tx_underflow_reg (.SN(n766), 
	.QN(tx_underflow), 
	.D(n152), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[17]  (.SN(n764), 
	.QN(DATA[17]), 
	.D(n634), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[9]  (.SN(n763), 
	.QN(DATA[9]), 
	.D(n652), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[11]  (.SN(n762), 
	.QN(DATA[11]), 
	.D(n644), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[21]  (.SN(n766), 
	.QN(DATA[21]), 
	.D(n646), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[13]  (.SN(RESETn), 
	.QN(DATA[13]), 
	.D(n656), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[31]  (.SN(RESETn), 
	.QN(DATA[31]), 
	.D(n648), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[30]  (.SN(RESETn), 
	.QN(DATA[30]), 
	.D(n666), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[29]  (.SN(n763), 
	.QN(DATA[29]), 
	.D(n665), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[28]  (.SN(n767), 
	.QN(DATA[28]), 
	.D(n664), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[23]  (.SN(n765), 
	.QN(DATA[23]), 
	.D(n663), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[22]  (.SN(n761), 
	.QN(DATA[22]), 
	.D(n658), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[20]  (.SN(n762), 
	.QN(DATA[20]), 
	.D(n657), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[15]  (.SN(RESETn), 
	.QN(DATA[15]), 
	.D(n655), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[14]  (.SN(RESETn), 
	.QN(DATA[14]), 
	.D(n650), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[12]  (.SN(n766), 
	.QN(DATA[12]), 
	.D(n649), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[3]  (.SN(n766), 
	.QN(DATA[3]), 
	.D(n647), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[2]  (.SN(n766), 
	.QN(DATA[2]), 
	.D(n638), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[1]  (.SN(n767), 
	.QN(DATA[1]), 
	.D(n637), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[0]  (.SN(n767), 
	.QN(DATA[0]), 
	.D(n636), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[7]  (.SN(n761), 
	.QN(ADDR[7]), 
	.D(n635), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[4]  (.SN(n765), 
	.QN(ADDR[4]), 
	.D(n633), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[3]  (.SN(n764), 
	.QN(ADDR[3]), 
	.D(n630), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[0]  (.SN(n766), 
	.QN(ADDR[0]), 
	.D(n629), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[25]  (.SN(n763), 
	.QN(DATA[25]), 
	.D(n627), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[5]  (.SN(n763), 
	.QN(DATA[5]), 
	.D(n660), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[27]  (.SN(n762), 
	.QN(DATA[27]), 
	.D(n640), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[26]  (.SN(n762), 
	.QN(DATA[26]), 
	.D(n662), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[24]  (.SN(n766), 
	.QN(DATA[24]), 
	.D(n661), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[19]  (.SN(n766), 
	.QN(DATA[19]), 
	.D(n659), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[18]  (.SN(n767), 
	.QN(DATA[18]), 
	.D(n654), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[16]  (.SN(RESETn), 
	.QN(DATA[16]), 
	.D(n653), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[10]  (.SN(n766), 
	.QN(DATA[10]), 
	.D(n651), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[8]  (.SN(n767), 
	.QN(DATA[8]), 
	.D(n645), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[7]  (.SN(n761), 
	.QN(DATA[7]), 
	.D(n643), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[6]  (.SN(n765), 
	.QN(DATA[6]), 
	.D(n642), 
	.CK(CLKIN));
   DFFSXL \DATA_reg[4]  (.SN(n766), 
	.QN(DATA[4]), 
	.D(n641), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[6]  (.SN(n764), 
	.QN(ADDR[6]), 
	.D(n639), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[5]  (.SN(n766), 
	.QN(ADDR[5]), 
	.D(n632), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[2]  (.SN(n763), 
	.QN(ADDR[2]), 
	.D(n631), 
	.CK(CLKIN));
   DFFSXL \ADDR_reg[1]  (.SN(n762), 
	.QN(ADDR[1]), 
	.D(n628), 
	.CK(CLKIN));
   DFFSX1 \mode_reg[0]  (.SN(n761), 
	.QN(mode[0]), 
	.Q(n202), 
	.D(n201), 
	.CK(CLKIN));
   DFFSX1 \bus_state_reg[2]  (.SN(n765), 
	.QN(bus_state[2]), 
	.Q(n734), 
	.D(n211), 
	.CK(CLKIN));
   DFFNSXL out_reg_neg_reg (.SN(n761), 
	.Q(out_reg_neg), 
	.D(n583), 
	.CKN(CLKIN));
   DFFNSX1 \bus_state_neg_reg[2]  (.SN(n763), 
	.QN(bus_state_neg[2]), 
	.D(n210), 
	.CKN(CLKIN));
   DFFNSX1 \bus_state_neg_reg[0]  (.SN(n762), 
	.QN(bus_state_neg[0]), 
	.D(n216), 
	.CKN(CLKIN));
   DFFNSX1 \bus_state_neg_reg[3]  (.SN(n766), 
	.QN(bus_state_neg[3]), 
	.D(n203), 
	.CKN(CLKIN));
   INVX1 U259 (.Y(n309), 
	.A(CLKIN));
   OAI21X4 U692 (.Y(CLKOUT), 
	.B0(n309), 
	.A1(n529), 
	.A0(BUS_INT));
   NAND2X1 U628 (.Y(n625), 
	.B(n766), 
	.A(CLKIN));
   INVX1 U237 (.Y(n227), 
	.A(n625));
   DFFNSX1 \mode_neg_reg[1]  (.SN(n766), 
	.Q(\mode_neg[1] ), 
	.D(mode[1]), 
	.CKN(CLKIN));
   DFFSX4 swapper0_INT_FLAG_reg (.SN(n221), 
	.QN(BUS_INT), 
	.Q(n312), 
	.D(1'b0), 
	.CK(swapper0_negp_int));
   DFFSXL \bus_state_reg[1]  (.SN(RESETn), 
	.QN(n717), 
	.D(n213), 
	.CK(CLKIN));
   DFFSXL \bus_state_reg[0]  (.SN(n762), 
	.QN(n743), 
	.Q(n248), 
	.D(n219), 
	.CK(CLKIN));
   DFFSXL tx_pend_reg (.SN(n764), 
	.QN(n747), 
	.Q(n262), 
	.D(n667), 
	.CK(CLKIN));
   DFFSX1 \bit_position_reg[3]  (.SN(n766), 
	.QN(bit_position[3]), 
	.Q(n730), 
	.D(n207), 
	.CK(CLKIN));
   DLY3X1 U695 (.Y(n627), 
	.A(n178));
   DLY3X1 U696 (.Y(n628), 
	.A(n525));
   DLY3X1 U697 (.Y(n629), 
	.A(n526));
   DLY3X1 U698 (.Y(n630), 
	.A(n523));
   DLY3X1 U699 (.Y(n631), 
	.A(n524));
   DLY3X1 U700 (.Y(n632), 
	.A(n521));
   DLY3X1 U701 (.Y(n633), 
	.A(n522));
   DLY3X1 U702 (.Y(n634), 
	.A(n170));
   DLY3X1 U703 (.Y(n635), 
	.A(n518));
   DLY3X1 U704 (.Y(n636), 
	.A(n153));
   DLY3X1 U705 (.Y(n637), 
	.A(n154));
   DLY3X1 U706 (.Y(n638), 
	.A(n155));
   DLY3X1 U707 (.Y(n639), 
	.A(n520));
   DLY3X1 U708 (.Y(n640), 
	.A(n180));
   DLY3X1 U709 (.Y(n641), 
	.A(n157));
   DLY3X1 U710 (.Y(n642), 
	.A(n159));
   DLY3X1 U711 (.Y(n643), 
	.A(n160));
   DLY3X1 U712 (.Y(n644), 
	.A(n164));
   DLY3X1 U713 (.Y(n645), 
	.A(n161));
   DLY3X1 U714 (.Y(n646), 
	.A(n174));
   DLY3X1 U715 (.Y(n647), 
	.A(n156));
   DLY3X1 U716 (.Y(n648), 
	.A(n184));
   DLY3X1 U717 (.Y(n649), 
	.A(n165));
   DLY3X1 U718 (.Y(n650), 
	.A(n167));
   DLY3X1 U719 (.Y(n651), 
	.A(n163));
   DLY3X1 U720 (.Y(n652), 
	.A(n162));
   DLY3X1 U721 (.Y(n653), 
	.A(n169));
   DLY3X1 U722 (.Y(n654), 
	.A(n171));
   DLY3X1 U723 (.Y(n655), 
	.A(n168));
   DLY3X1 U724 (.Y(n656), 
	.A(n166));
   DLY3X1 U725 (.Y(n657), 
	.A(n173));
   DLY3X1 U726 (.Y(n658), 
	.A(n175));
   DLY3X1 U727 (.Y(n659), 
	.A(n172));
   DLY3X1 U728 (.Y(n660), 
	.A(n158));
   DLY3X1 U729 (.Y(n661), 
	.A(n177));
   DLY3X1 U730 (.Y(n662), 
	.A(n179));
   DLY3X1 U731 (.Y(n663), 
	.A(n176));
   DLY3X1 U732 (.Y(n664), 
	.A(n181));
   DLY3X1 U733 (.Y(n665), 
	.A(n182));
   DLY3X1 U734 (.Y(n666), 
	.A(n183));
   DLY3X1 U735 (.Y(n667), 
	.A(n218));
   NAND3X1 U736 (.Y(n668), 
	.C(n939), 
	.B(n312), 
	.A(n938));
   AOI21X1 U737 (.Y(n737), 
	.B0(n668), 
	.A1(n950), 
	.A0(n937));
   OAI31X1 U738 (.Y(n669), 
	.B0(n929), 
	.A2(n942), 
	.A1(n941), 
	.A0(n953));
   NOR2X1 U739 (.Y(n670), 
	.B(n854), 
	.A(n961));
   AOI21X1 U740 (.Y(n671), 
	.B0(n669), 
	.A1(n260), 
	.A0(n670));
   AOI211X1 U741 (.Y(n672), 
	.C0(n930), 
	.B0(n671), 
	.A1(n260), 
	.A0(n856));
   NOR2X1 U742 (.Y(n451), 
	.B(n1025), 
	.A(n672));
   INVX1 U743 (.Y(n673), 
	.A(n909));
   AOI211X1 U744 (.Y(n204), 
	.C0(BUS_INT), 
	.B0(n910), 
	.A1(n673), 
	.A0(n725));
   BUFX3 U745 (.Y(n678), 
	.A(n730));
   BUFX3 U746 (.Y(n679), 
	.A(n743));
   AOI222X1 U747 (.Y(n12), 
	.C1(n312), 
	.C0(n970), 
	.B1(n971), 
	.B0(RX_PEND), 
	.A1(BUS_INT), 
	.A0(RX_PEND));
   AOI22XL U748 (.Y(n176), 
	.B1(TX_DATA[23]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[23]));
   AOI22XL U749 (.Y(n161), 
	.B1(TX_DATA[8]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[8]));
   AOI22XL U750 (.Y(n158), 
	.B1(TX_DATA[5]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[5]));
   AOI22XL U751 (.Y(n177), 
	.B1(TX_DATA[24]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[24]));
   AOI22XL U752 (.Y(n160), 
	.B1(TX_DATA[7]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[7]));
   AOI22XL U753 (.Y(n156), 
	.B1(TX_DATA[3]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[3]));
   AOI22XL U754 (.Y(n166), 
	.B1(TX_DATA[13]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[13]));
   AOI22XL U755 (.Y(n157), 
	.B1(TX_DATA[4]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[4]));
   AOI22XL U756 (.Y(n182), 
	.B1(TX_DATA[29]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[29]));
   AOI22XL U757 (.Y(n175), 
	.B1(TX_DATA[22]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[22]));
   AOI22XL U758 (.Y(n153), 
	.B1(TX_DATA[0]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[0]));
   AOI22XL U759 (.Y(n159), 
	.B1(TX_DATA[6]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[6]));
   AOI22XL U760 (.Y(n155), 
	.B1(TX_DATA[2]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[2]));
   AOI22XL U761 (.Y(n178), 
	.B1(TX_DATA[25]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[25]));
   AOI22XL U762 (.Y(n170), 
	.B1(TX_DATA[17]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[17]));
   AOI22XL U763 (.Y(n179), 
	.B1(TX_DATA[26]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[26]));
   AOI22XL U764 (.Y(n174), 
	.B1(TX_DATA[21]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[21]));
   AOI22XL U765 (.Y(n171), 
	.B1(TX_DATA[18]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[18]));
   AOI22XL U766 (.Y(n180), 
	.B1(TX_DATA[27]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[27]));
   AOI22XL U767 (.Y(n164), 
	.B1(TX_DATA[11]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[11]));
   AOI22XL U768 (.Y(n165), 
	.B1(TX_DATA[12]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[12]));
   AOI22XL U769 (.Y(n184), 
	.B1(TX_DATA[31]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[31]));
   AOI22XL U770 (.Y(n154), 
	.B1(TX_DATA[1]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[1]));
   AOI22XL U771 (.Y(n162), 
	.B1(TX_DATA[9]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[9]));
   AOI22XL U772 (.Y(n183), 
	.B1(TX_DATA[30]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[30]));
   AOI22XL U773 (.Y(n181), 
	.B1(TX_DATA[28]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[28]));
   AOI22XL U774 (.Y(n169), 
	.B1(TX_DATA[16]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[16]));
   AOI22XL U775 (.Y(n167), 
	.B1(TX_DATA[14]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[14]));
   AOI22XL U776 (.Y(n168), 
	.B1(TX_DATA[15]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[15]));
   AOI22XL U777 (.Y(n163), 
	.B1(TX_DATA[10]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[10]));
   AOI22XL U778 (.Y(n173), 
	.B1(TX_DATA[20]), 
	.B0(n751), 
	.A1(n753), 
	.A0(DATA[20]));
   AOI22XL U779 (.Y(n172), 
	.B1(TX_DATA[19]), 
	.B0(n752), 
	.A1(n753), 
	.A0(DATA[19]));
   OAI22XL U780 (.Y(n218), 
	.B1(n876), 
	.B0(TX_PEND), 
	.A1(n747), 
	.A0(n975));
   CLKBUFX8 U781 (.Y(n753), 
	.A(n928));
   CLKBUFX8 U782 (.Y(n7540), 
	.A(n940));
   CLKBUFX8 U783 (.Y(n757), 
	.A(n967));
   CLKINVX8 U784 (.Y(n680), 
	.A(n735));
   AOI22XL U785 (.Y(n79), 
	.B1(n1024), 
	.B0(n948), 
	.A1(n949), 
	.A0(n312));
   AOI22XL U786 (.Y(n522), 
	.B1(TX_ADDR[4]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[4]));
   AOI22XL U787 (.Y(n526), 
	.B1(TX_ADDR[0]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[0]));
   AOI22XL U788 (.Y(n525), 
	.B1(TX_ADDR[1]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[1]));
   AOI22XL U789 (.Y(n523), 
	.B1(TX_ADDR[3]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[3]));
   AOI22XL U790 (.Y(n518), 
	.B1(TX_ADDR[7]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[7]));
   AOI22XL U791 (.Y(n524), 
	.B1(TX_ADDR[2]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[2]));
   AOI22XL U792 (.Y(n520), 
	.B1(TX_ADDR[6]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[6]));
   AOI22XL U793 (.Y(n521), 
	.B1(TX_ADDR[5]), 
	.B0(n975), 
	.A1(n808), 
	.A0(ADDR[5]));
   AOI211XL U794 (.Y(n11), 
	.C0(n975), 
	.B0(n976), 
	.A1(n991), 
	.A0(TX_REQ));
   CLKBUFX2 U795 (.Y(n727), 
	.A(bus_state[2]));
   CLKBUFX2 U796 (.Y(n726), 
	.A(bit_position[4]));
   CLKBUFX2 U797 (.Y(n725), 
	.A(bus_state[3]));
   CLKBUFX2 U798 (.Y(n728), 
	.A(n717));
   CLKBUFX1 U799 (.Y(TX_ACK), 
	.A(n991));
   CLKBUFX1 U800 (.Y(RX_DATA[31]), 
	.A(n992));
   CLKBUFX1 U801 (.Y(RX_DATA[30]), 
	.A(n993));
   CLKBUFX1 U802 (.Y(RX_DATA[29]), 
	.A(n994));
   CLKBUFX1 U803 (.Y(RX_DATA[28]), 
	.A(n995));
   CLKBUFX1 U804 (.Y(RX_DATA[27]), 
	.A(n996));
   CLKBUFX1 U805 (.Y(RX_DATA[26]), 
	.A(n997));
   CLKBUFX1 U806 (.Y(RX_DATA[25]), 
	.A(n998));
   CLKBUFX1 U807 (.Y(RX_DATA[24]), 
	.A(n999));
   CLKBUFX1 U808 (.Y(RX_DATA[23]), 
	.A(n1000));
   CLKBUFX1 U809 (.Y(RX_DATA[22]), 
	.A(n1001));
   CLKBUFX1 U810 (.Y(RX_DATA[21]), 
	.A(n1002));
   CLKBUFX1 U811 (.Y(RX_DATA[20]), 
	.A(n1003));
   CLKBUFX1 U812 (.Y(RX_DATA[19]), 
	.A(n1004));
   CLKBUFX1 U813 (.Y(RX_DATA[18]), 
	.A(n1005));
   CLKBUFX1 U814 (.Y(RX_DATA[17]), 
	.A(n1006));
   CLKBUFX1 U815 (.Y(RX_DATA[16]), 
	.A(n1007));
   CLKBUFX1 U816 (.Y(RX_DATA[15]), 
	.A(n1008));
   CLKBUFX1 U817 (.Y(RX_DATA[14]), 
	.A(n1009));
   CLKBUFX1 U818 (.Y(RX_DATA[13]), 
	.A(n1010));
   CLKBUFX1 U819 (.Y(RX_DATA[12]), 
	.A(n1011));
   CLKBUFX1 U820 (.Y(RX_DATA[11]), 
	.A(n1012));
   CLKBUFX1 U821 (.Y(RX_DATA[10]), 
	.A(n1013));
   CLKBUFX1 U822 (.Y(RX_DATA[9]), 
	.A(n1014));
   CLKBUFX1 U823 (.Y(RX_DATA[8]), 
	.A(n1015));
   CLKBUFX1 U824 (.Y(RX_DATA[7]), 
	.A(n1016));
   CLKBUFX1 U825 (.Y(RX_DATA[6]), 
	.A(n1017));
   CLKBUFX1 U826 (.Y(RX_DATA[5]), 
	.A(n1018));
   CLKBUFX1 U827 (.Y(RX_DATA[4]), 
	.A(n1019));
   CLKBUFX1 U828 (.Y(RX_DATA[3]), 
	.A(n1020));
   CLKBUFX1 U829 (.Y(RX_DATA[2]), 
	.A(n1021));
   CLKBUFX1 U830 (.Y(RX_DATA[1]), 
	.A(n1022));
   CLKBUFX1 U831 (.Y(RX_DATA[0]), 
	.A(n1023));
   CLKBUFX1 U832 (.Y(RX_FAIL), 
	.A(n1024));
   CLKBUFX1 U833 (.Y(TX_FAIL), 
	.A(n1025));
   CLKBUFX1 U834 (.Y(TX_SUCC), 
	.A(n1026));
   NOR3X2 U835 (.Y(n828), 
	.C(n732), 
	.B(n742), 
	.A(bit_position[3]));
   NOR3X2 U836 (.Y(n830), 
	.C(n678), 
	.B(n732), 
	.A(n726));
   NOR2X2 U837 (.Y(n889), 
	.B(n728), 
	.A(n727));
   NOR3X2 U838 (.Y(n831), 
	.C(n742), 
	.B(bit_position[3]), 
	.A(bit_position[2]));
   NOR3X4 U839 (.Y(n922), 
	.C(n950), 
	.B(n938), 
	.A(BUS_INT));
   OAI221XL U840 (.Y(n220), 
	.C0(n986), 
	.B1(n987), 
	.B0(n733), 
	.A1(n988), 
	.A0(bit_position[0]));
   OAI211X1 U841 (.Y(n212), 
	.C0(n985), 
	.B0(n986), 
	.A1(n744), 
	.A0(n987));
   NOR3X2 U842 (.Y(n987), 
	.C(n919), 
	.B(n898), 
	.A(BUS_INT));
   OAI21X1 U843 (.Y(n986), 
	.B0(n312), 
	.A1(n978), 
	.A0(n979));
   INVX1 U844 (.Y(n718), 
	.A(n717));
   INVX1 U845 (.Y(n720), 
	.A(n719));
   INVX1 U846 (.Y(n721), 
	.A(n676));
   INVX1 U847 (.Y(n722), 
	.A(n674));
   INVX1 U848 (.Y(n723), 
	.A(n675));
   INVX1 U849 (.Y(RX_PEND), 
	.A(n677));
   NOR2X2 U850 (.Y(n983), 
	.B(bit_position[1]), 
	.A(bit_position[0]));
   NOR2X2 U851 (.Y(n882), 
	.B(n812), 
	.A(n732));
   NAND4X2 U852 (.Y(n923), 
	.D(n920), 
	.C(n956), 
	.B(n939), 
	.A(n921));
   NOR2X2 U853 (.Y(n960), 
	.B(n931), 
	.A(n679));
   NAND4X2 U854 (.Y(n938), 
	.D(n679), 
	.C(n734), 
	.B(n731), 
	.A(n728));
   NOR3X2 U855 (.Y(n833), 
	.C(n678), 
	.B(n726), 
	.A(bit_position[2]));
   NOR2X2 U856 (.Y(n984), 
	.B(n744), 
	.A(n733));
   NOR2X2 U857 (.Y(n916), 
	.B(n920), 
	.A(n728));
   CLKBUFX8 U858 (.Y(DOUT), 
	.A(n990));
   OAI21XL U859 (.Y(n990), 
	.B0(n797), 
	.A1(n884), 
	.A0(n788));
   CLKINVX3 U860 (.Y(n764), 
	.A(n760));
   CLKINVX3 U861 (.Y(n765), 
	.A(n760));
   CLKINVX3 U862 (.Y(n763), 
	.A(n760));
   CLKINVX3 U863 (.Y(n762), 
	.A(n760));
   CLKINVX3 U864 (.Y(n761), 
	.A(n760));
   CLKINVX3 U865 (.Y(n767), 
	.A(n760));
   CLKINVX3 U866 (.Y(n760), 
	.A(RESETn));
   AND3X1 U867 (.Y(swapper0_negp_int), 
	.C(n860), 
	.B(swapper0_nege_negp_clk_3), 
	.A(swapper0_pose_negp_clk_2));
   OAI21XL U868 (.Y(n217), 
	.B0(n879), 
	.A1(n880), 
	.A0(n881));
   CLKINVX3 U869 (.Y(n756), 
	.A(n737));
   CLKINVX3 U870 (.Y(n755), 
	.A(n737));
   NOR2X1 U871 (.Y(n939), 
	.B(n919), 
	.A(n979));
   INVX1 U872 (.Y(n979), 
	.A(n918));
   NOR2BX1 U873 (.Y(n940), 
	.B(BUS_INT), 
	.AN(n936));
   CLKINVX3 U874 (.Y(n758), 
	.A(n736));
   NAND2X1 U875 (.Y(n735), 
	.B(n312), 
	.A(n966));
   CLKINVX3 U876 (.Y(n759), 
	.A(n736));
   OR3XL U877 (.Y(n736), 
	.C(n964), 
	.B(n962), 
	.A(BUS_INT));
   NAND3X1 U878 (.Y(n964), 
	.C(n952), 
	.B(n969), 
	.A(n960));
   OAI211X1 U879 (.Y(n967), 
	.C0(n312), 
	.B0(n968), 
	.A1(n961), 
	.A0(n969));
   NOR2X1 U880 (.Y(n952), 
	.B(n950), 
	.A(n745));
   NOR2X1 U881 (.Y(n969), 
	.B(n944), 
	.A(n884));
   CLKINVX3 U882 (.Y(n751), 
	.A(n927));
   CLKINVX3 U883 (.Y(n752), 
	.A(n927));
   OAI221XL U884 (.Y(n927), 
	.C0(n925), 
	.B1(n975), 
	.B0(n926), 
	.A1(n975), 
	.A0(n937));
   OAI21XL U885 (.Y(n928), 
	.B0(n924), 
	.A1(n956), 
	.A0(n926));
   INVX1 U886 (.Y(n932), 
	.A(n912));
   INVX1 U887 (.Y(n963), 
	.A(n962));
   NAND2X1 U888 (.Y(n962), 
	.B(n832), 
	.A(n744));
   NAND2X1 U889 (.Y(n936), 
	.B(n890), 
	.A(n920));
   INVX1 U890 (.Y(n890), 
	.A(n946));
   NOR2X1 U891 (.Y(n946), 
	.B(n950), 
	.A(n956));
   CLKINVX3 U892 (.Y(n950), 
	.A(n862));
   NOR2X1 U893 (.Y(n862), 
	.B(mode[0]), 
	.A(n254));
   NOR2X1 U894 (.Y(n926), 
	.B(n262), 
	.A(n861));
   INVX1 U895 (.Y(n911), 
	.A(n894));
   NAND2X1 U896 (.Y(n894), 
	.B(BUS_INT), 
	.A(n745));
   INVX1 U897 (.Y(n961), 
	.A(n960));
   INVX1 U898 (.Y(n863), 
	.A(n854));
   CLKINVX3 U899 (.Y(n956), 
	.A(n937));
   INVX1 U900 (.Y(n832), 
	.A(n846));
   INVX1 U901 (.Y(n856), 
	.A(n953));
   INVX1 U902 (.Y(n910), 
	.A(n931));
   NAND2X1 U903 (.Y(n931), 
	.B(n889), 
	.A(n725));
   INVX1 U904 (.Y(n529), 
	.A(n865));
   NOR2X1 U905 (.Y(n912), 
	.B(n731), 
	.A(n800));
   INVX1 U906 (.Y(n861), 
	.A(TX_REQ));
   INVX1 U907 (.Y(n954), 
	.A(n887));
   NOR2X1 U908 (.Y(n887), 
	.B(n727), 
	.A(n965));
   NAND2X1 U909 (.Y(n965), 
	.B(n796), 
	.A(n728));
   INVX1 U910 (.Y(n884), 
	.A(n750));
   BUFX3 U911 (.Y(n750), 
	.A(DIN));
   NOR2X2 U912 (.Y(n937), 
	.B(n791), 
	.A(n728));
   NAND2X1 U913 (.Y(n920), 
	.B(n796), 
	.A(n727));
   NOR2X1 U914 (.Y(n796), 
	.B(n679), 
	.A(n725));
   AND2X2 U915 (.Y(n221), 
	.B(BUS_INT_RSTn), 
	.A(n766));
   INVX8 U916 (.Y(n766), 
	.A(n760));
   AND4X2 U917 (.Y(n860), 
	.D(swapper0_pose_negp_clk_4), 
	.C(swapper0_nege_negp_clk_1), 
	.B(swapper0_nege_negp_clk_5), 
	.A(swapper0_pose_negp_clk_0));
   OR4X2 U918 (.Y(n808), 
	.D(n803), 
	.C(n958), 
	.B(n875), 
	.A(n910));
   AND4X2 U919 (.Y(n933), 
	.D(n954), 
	.C(n811), 
	.B(n955), 
	.A(n872));
   AND3X2 U920 (.Y(n896), 
	.C(n529), 
	.B(n895), 
	.A(n932));
   NOR2BX4 U921 (.Y(n975), 
	.B(n954), 
	.AN(n807));
   NAND2X2 U922 (.Y(n973), 
	.B(n733), 
	.A(n963));
   OR4X2 U923 (.Y(n789), 
	.D(RX_ADDR[1]), 
	.C(RX_ADDR[3]), 
	.B(RX_ADDR[5]), 
	.A(RX_ADDR[7]));
   NAND3X1 U924 (.Y(n791), 
	.C(n679), 
	.B(n731), 
	.A(n727));
   NOR2X1 U926 (.Y(n865), 
	.B(n718), 
	.A(n791));
   NOR2X1 U927 (.Y(n772), 
	.B(bus_state_neg[2]), 
	.A(n741));
   NOR2BX1 U928 (.Y(n771), 
	.B(bus_state_neg[3]), 
	.AN(bus_state_neg[0]));
   AOI211X1 U929 (.Y(n768), 
	.C0(n720), 
	.B0(BUS_INT), 
	.A1(n741), 
	.A0(bus_state_neg[2]));
   NAND3BX1 U930 (.Y(n783), 
	.C(n768), 
	.B(n771), 
	.AN(n772));
   AOI21X1 U931 (.Y(n769), 
	.B0(bus_state_neg[2]), 
	.A1(bus_state_neg[0]), 
	.A0(n741));
   INVX1 U932 (.Y(n780), 
	.A(n769));
   NOR4X1 U933 (.Y(n781), 
	.D(bus_state_neg[2]), 
	.C(bus_state_neg[3]), 
	.B(bus_state_neg[0]), 
	.A(n308));
   OAI21XL U934 (.Y(n770), 
	.B0(\mode_neg[1] ), 
	.A1(n771), 
	.A0(n781));
   INVX1 U935 (.Y(n779), 
	.A(n770));
   AOI21X1 U936 (.Y(n777), 
	.B0(n781), 
	.A1(n771), 
	.A0(n772));
   NAND2X1 U937 (.Y(n784), 
	.B(n772), 
	.A(bus_state_neg[3]));
   INVX1 U938 (.Y(n775), 
	.A(n784));
   AOI31X1 U939 (.Y(n785), 
	.B0(n745), 
	.A2(n720), 
	.A1(\mode_neg[1] ), 
	.A0(bus_state_neg[0]));
   NOR2X1 U940 (.Y(n773), 
	.B(bus_state_neg[3]), 
	.A(n308));
   AOI211X1 U941 (.Y(n774), 
	.C0(n773), 
	.B0(bus_state_neg[0]), 
	.A1(bus_state_neg[3]), 
	.A0(n308));
   AOI22X1 U942 (.Y(n776), 
	.B1(n861), 
	.B0(n774), 
	.A1(n785), 
	.A0(n775));
   OAI21XL U943 (.Y(n778), 
	.B0(n776), 
	.A1(n777), 
	.A0(n720));
   AOI211X1 U944 (.Y(n788), 
	.C0(n778), 
	.B0(n779), 
	.A1(n780), 
	.A0(n783));
   INVX1 U945 (.Y(n782), 
	.A(n781));
   AOI211X1 U946 (.Y(n787), 
	.C0(n719), 
	.B0(n782), 
	.A1(n861), 
	.A0(\mode_neg[1] ));
   OAI22X1 U947 (.Y(n786), 
	.B1(n783), 
	.B0(\mode_neg[1] ), 
	.A1(n784), 
	.A0(n785));
   AOI22X1 U948 (.Y(n797), 
	.B1(n786), 
	.B0(out_reg_neg), 
	.A1(n787), 
	.A0(PRIORITY));
   NOR2X1 U949 (.Y(N754), 
	.B(n718), 
	.A(n911));
   OAI21XL U950 (.Y(n897), 
	.B0(n889), 
	.A1(n679), 
	.A0(n725));
   NOR3X1 U951 (.Y(n793), 
	.C(RX_ADDR[2]), 
	.B(RX_ADDR[4]), 
	.A(RX_ADDR[6]));
   NAND4X1 U952 (.Y(n790), 
	.D(RX_ADDR[1]), 
	.C(RX_ADDR[3]), 
	.B(RX_ADDR[5]), 
	.A(RX_ADDR[7]));
   AOI22X1 U953 (.Y(n792), 
	.B1(n746), 
	.B0(n789), 
	.A1(n790), 
	.A0(RX_ADDR[0]));
   AOI31X1 U954 (.Y(n794), 
	.B0(n937), 
	.A2(n792), 
	.A1(n793), 
	.A0(n916));
   NAND2X1 U955 (.Y(n811), 
	.B(n728), 
	.A(n727));
   NAND4X1 U956 (.Y(n913), 
	.D(n938), 
	.C(n811), 
	.B(n794), 
	.A(n897));
   NAND2BX1 U957 (.Y(n805), 
	.B(n750), 
	.AN(PRIORITY));
   NAND3X1 U958 (.Y(n804), 
	.C(n884), 
	.B(TX_REQ), 
	.A(PRIORITY));
   OAI21XL U959 (.Y(n795), 
	.B0(n804), 
	.A1(mode[1]), 
	.A0(mode[0]));
   AOI21X1 U960 (.Y(n875), 
	.B0(n954), 
	.A1(n795), 
	.A0(n805));
   NAND2X1 U961 (.Y(n918), 
	.B(n796), 
	.A(n889));
   AOI22X1 U962 (.Y(n798), 
	.B1(n884), 
	.B0(n797), 
	.A1(DOUT), 
	.A0(n750));
   NAND3X1 U963 (.Y(n895), 
	.C(n248), 
	.B(n728), 
	.A(n725));
   OAI21XL U964 (.Y(n799), 
	.B0(n895), 
	.A1(n798), 
	.A0(n918));
   NOR3X1 U965 (.Y(n802), 
	.C(n799), 
	.B(n875), 
	.A(n916));
   AOI21X1 U966 (.Y(n800), 
	.B0(n727), 
	.A1(n679), 
	.A0(n728));
   OAI21XL U967 (.Y(n801), 
	.B0(mode[1]), 
	.A1(n912), 
	.A0(n913));
   OAI21XL U968 (.Y(n623), 
	.B0(n801), 
	.A1(n802), 
	.A0(n913));
   INVX1 U969 (.Y(n868), 
	.A(n938));
   AOI21X1 U970 (.Y(n809), 
	.B0(n868), 
	.A1(n731), 
	.A0(n889));
   NAND4X1 U971 (.Y(n958), 
	.D(n529), 
	.C(n895), 
	.B(n932), 
	.A(n809));
   NAND2X1 U972 (.Y(n803), 
	.B(n920), 
	.A(n956));
   NOR2X1 U973 (.Y(n806), 
	.B(mode[1]), 
	.A(mode[0]));
   OAI2BB1X1 U974 (.Y(n807), 
	.B0(n804), 
	.A1N(n805), 
	.A0N(n806));
   NAND2X1 U975 (.Y(n854), 
	.B(mode[0]), 
	.A(n254));
   NAND2X1 U976 (.Y(n974), 
	.B(n863), 
	.A(n937));
   INVX1 U977 (.Y(n877), 
	.A(n974));
   NAND3X1 U978 (.Y(n846), 
	.C(n678), 
	.B(n742), 
	.A(n732));
   NOR3X1 U979 (.Y(n898), 
	.C(n956), 
	.B(n862), 
	.A(n863));
   INVX1 U980 (.Y(n810), 
	.A(n809));
   AOI211X1 U981 (.Y(n872), 
	.C0(n810), 
	.B0(n898), 
	.A1(n973), 
	.A0(n877));
   INVX1 U982 (.Y(n955), 
	.A(n916));
   NAND2X1 U983 (.Y(n930), 
	.B(n890), 
	.A(n933));
   NAND2X1 U984 (.Y(n953), 
	.B(n910), 
	.A(n679));
   NOR2BX1 U985 (.Y(n942), 
	.B(n750), 
	.AN(ctrl_bit_buf));
   NAND2BX1 U986 (.Y(n941), 
	.B(n863), 
	.AN(tx_underflow));
   NAND3X1 U987 (.Y(n929), 
	.C(n747), 
	.B(n861), 
	.A(n937));
   NOR2X1 U988 (.Y(n869), 
	.B(n744), 
	.A(bit_position[0]));
   NAND3X1 U989 (.Y(n842), 
	.C(bit_position[2]), 
	.B(n678), 
	.A(n742));
   INVX1 U990 (.Y(n827), 
	.A(n842));
   NAND2X1 U991 (.Y(n812), 
	.B(bit_position[3]), 
	.A(n726));
   AOI22X1 U992 (.Y(n816), 
	.B1(DATA[30]), 
	.B0(n882), 
	.A1(DATA[6]), 
	.A0(n827));
   NOR2X1 U993 (.Y(n829), 
	.B(n812), 
	.A(bit_position[2]));
   AOI22X1 U994 (.Y(n815), 
	.B1(DATA[22]), 
	.B0(n828), 
	.A1(DATA[26]), 
	.A0(n829));
   AOI22X1 U995 (.Y(n814), 
	.B1(DATA[14]), 
	.B0(n830), 
	.A1(DATA[18]), 
	.A0(n831));
   AOI22X1 U996 (.Y(n813), 
	.B1(DATA[2]), 
	.B0(n832), 
	.A1(DATA[10]), 
	.A0(n833));
   NAND4X1 U997 (.Y(n822), 
	.D(n813), 
	.C(n814), 
	.B(n815), 
	.A(n816));
   AOI22X1 U998 (.Y(n820), 
	.B1(DATA[28]), 
	.B0(n882), 
	.A1(DATA[4]), 
	.A0(n827));
   AOI22X1 U999 (.Y(n819), 
	.B1(DATA[20]), 
	.B0(n828), 
	.A1(DATA[24]), 
	.A0(n829));
   AOI22X1 U1000 (.Y(n818), 
	.B1(DATA[12]), 
	.B0(n830), 
	.A1(DATA[16]), 
	.A0(n831));
   AOI22X1 U1001 (.Y(n817), 
	.B1(DATA[0]), 
	.B0(n832), 
	.A1(DATA[8]), 
	.A0(n833));
   NAND4X1 U1002 (.Y(n821), 
	.D(n817), 
	.C(n818), 
	.B(n819), 
	.A(n820));
   AOI22X1 U1003 (.Y(n841), 
	.B1(n821), 
	.B0(n983), 
	.A1(n822), 
	.A0(n869));
   AOI22X1 U1004 (.Y(n826), 
	.B1(DATA[31]), 
	.B0(n882), 
	.A1(DATA[7]), 
	.A0(n827));
   AOI22X1 U1005 (.Y(n825), 
	.B1(DATA[23]), 
	.B0(n828), 
	.A1(DATA[27]), 
	.A0(n829));
   AOI22X1 U1006 (.Y(n824), 
	.B1(DATA[15]), 
	.B0(n830), 
	.A1(DATA[19]), 
	.A0(n831));
   AOI22X1 U1007 (.Y(n823), 
	.B1(DATA[3]), 
	.B0(n832), 
	.A1(DATA[11]), 
	.A0(n833));
   NAND4X1 U1008 (.Y(n839), 
	.D(n823), 
	.C(n824), 
	.B(n825), 
	.A(n826));
   NOR2X1 U1009 (.Y(n845), 
	.B(n733), 
	.A(bit_position[1]));
   AOI22X1 U1010 (.Y(n837), 
	.B1(DATA[29]), 
	.B0(n882), 
	.A1(n827), 
	.A0(DATA[5]));
   AOI22X1 U1011 (.Y(n836), 
	.B1(n828), 
	.B0(DATA[21]), 
	.A1(n829), 
	.A0(DATA[25]));
   AOI22X1 U1012 (.Y(n835), 
	.B1(n830), 
	.B0(DATA[13]), 
	.A1(n831), 
	.A0(DATA[17]));
   AOI22X1 U1013 (.Y(n834), 
	.B1(DATA[1]), 
	.B0(n832), 
	.A1(n833), 
	.A0(DATA[9]));
   NAND4X1 U1014 (.Y(n838), 
	.D(n834), 
	.C(n835), 
	.B(n836), 
	.A(n837));
   AOI22X1 U1015 (.Y(n840), 
	.B1(n838), 
	.B0(n845), 
	.A1(n839), 
	.A0(n984));
   AOI21X1 U1016 (.Y(n853), 
	.B0(n956), 
	.A1(n840), 
	.A0(n841));
   AOI22X1 U1017 (.Y(n844), 
	.B1(ADDR[4]), 
	.B0(n983), 
	.A1(ADDR[6]), 
	.A0(n869));
   AOI22X1 U1018 (.Y(n843), 
	.B1(ADDR[7]), 
	.B0(n984), 
	.A1(ADDR[5]), 
	.A0(n845));
   AOI21X1 U1019 (.Y(n850), 
	.B0(n842), 
	.A1(n843), 
	.A0(n844));
   AOI22X1 U1020 (.Y(n848), 
	.B1(ADDR[0]), 
	.B0(n983), 
	.A1(ADDR[2]), 
	.A0(n869));
   AOI22X1 U1021 (.Y(n847), 
	.B1(ADDR[3]), 
	.B0(n984), 
	.A1(ADDR[1]), 
	.A0(n845));
   AOI21X1 U1022 (.Y(n849), 
	.B0(n846), 
	.A1(n847), 
	.A0(n848));
   OAI21XL U1023 (.Y(n851), 
	.B0(n868), 
	.A1(n849), 
	.A0(n850));
   OAI21XL U1024 (.Y(n852), 
	.B0(n851), 
	.A1(n961), 
	.A0(n941));
   AOI211X1 U1025 (.Y(n859), 
	.C0(n852), 
	.B0(n853), 
	.A1(out_reg_pos), 
	.A0(n856));
   AOI21X1 U1026 (.Y(n855), 
	.B0(n854), 
	.A1(n938), 
	.A0(n956));
   AOI211X1 U1027 (.Y(n858), 
	.C0(n855), 
	.B0(n856), 
	.A1(n745), 
	.A0(n910));
   NAND2X1 U1028 (.Y(n857), 
	.B(out_reg_neg), 
	.A(n858));
   OAI21XL U1029 (.Y(n583), 
	.B0(n857), 
	.A1(n858), 
	.A0(n859));
   INVX1 U1030 (.Y(n972), 
	.A(n926));
   AOI22X1 U1031 (.Y(n864), 
	.B1(n862), 
	.B0(RX_REQ), 
	.A1(n972), 
	.A0(n863));
   NOR3X1 U1032 (.Y(n888), 
	.C(n956), 
	.B(n973), 
	.A(n864));
   AOI211X1 U1033 (.Y(n909), 
	.C0(n865), 
	.B0(n912), 
	.A1(n973), 
	.A0(n868));
   OAI21XL U1034 (.Y(n866), 
	.B0(n937), 
	.A1(n973), 
	.A0(n950));
   AOI21X1 U1035 (.Y(n867), 
	.B0(n248), 
	.A1(n866), 
	.A0(n909));
   AOI211X1 U1036 (.Y(n870), 
	.C0(n867), 
	.B0(n960), 
	.A1(n950), 
	.A0(n868));
   NAND3X1 U1037 (.Y(n903), 
	.C(n869), 
	.B(n882), 
	.A(n916));
   NAND4X1 U1038 (.Y(n871), 
	.D(n903), 
	.C(n918), 
	.B(n965), 
	.A(n870));
   OAI21XL U1039 (.Y(n219), 
	.B0(n312), 
	.A1(n871), 
	.A0(n888));
   NAND4X1 U1040 (.Y(n873), 
	.D(n529), 
	.C(n895), 
	.B(n931), 
	.A(n872));
   NOR2X1 U1041 (.Y(n925), 
	.B(n873), 
	.A(n936));
   NAND2X1 U1042 (.Y(n874), 
	.B(n932), 
	.A(n925));
   NOR2X1 U1043 (.Y(n924), 
	.B(n874), 
	.A(n875));
   OAI21XL U1044 (.Y(n876), 
	.B0(n924), 
	.A1(n956), 
	.A0(TX_REQ));
   NOR2X1 U1045 (.Y(n947), 
	.B(n973), 
	.A(n738));
   OAI211X1 U1046 (.Y(n881), 
	.C0(n931), 
	.B0(n933), 
	.A1(n890), 
	.A0(n947));
   NAND3X1 U1047 (.Y(n880), 
	.C(n890), 
	.B(n974), 
	.A(n932));
   AOI21X1 U1048 (.Y(n878), 
	.B0(n946), 
	.A1(n972), 
	.A0(n877));
   OAI21XL U1049 (.Y(n879), 
	.B0(n260), 
	.A1(n878), 
	.A0(n881));
   NAND2X1 U1050 (.Y(n216), 
	.B(n894), 
	.A(n679));
   NOR2X1 U1051 (.Y(n970), 
	.B(n965), 
	.A(n734));
   AOI22X1 U1052 (.Y(n883), 
	.B1(n963), 
	.B0(bit_position[0]), 
	.A1(n984), 
	.A0(n882));
   NAND2BX1 U1053 (.Y(n944), 
	.B(n738), 
	.AN(n883));
   NAND2BX1 U1054 (.Y(n886), 
	.B(n964), 
	.AN(n970));
   AOI21X1 U1055 (.Y(n885), 
	.B0(n738), 
	.A1(n312), 
	.A0(RX_ACK));
   AOI21X1 U1056 (.Y(n214), 
	.B0(n885), 
	.A1(n312), 
	.A0(n886));
   AOI211X1 U1057 (.Y(n891), 
	.C0(n887), 
	.B0(n888), 
	.A1(n679), 
	.A0(n889));
   OR3XL U1058 (.Y(n902), 
	.C(RX_REQ), 
	.B(n890), 
	.A(n973));
   OAI211X1 U1059 (.Y(n892), 
	.C0(n902), 
	.B0(n891), 
	.A1(n718), 
	.A0(n909));
   NAND2X1 U1060 (.Y(n213), 
	.B(n892), 
	.A(n312));
   OAI21XL U1061 (.Y(n893), 
	.B0(n734), 
	.A1(n973), 
	.A0(n938));
   NAND2X1 U1062 (.Y(n211), 
	.B(n312), 
	.A(n893));
   NAND2X1 U1063 (.Y(n210), 
	.B(n894), 
	.A(n727));
   NAND3X1 U1064 (.Y(n919), 
	.C(n954), 
	.B(n896), 
	.A(n897));
   NAND2X1 U1065 (.Y(n981), 
	.B(n732), 
	.A(n983));
   NAND3X1 U1066 (.Y(n899), 
	.C(n974), 
	.B(n938), 
	.A(n920));
   AOI21X1 U1067 (.Y(n977), 
	.B0(n899), 
	.A1(n973), 
	.A0(n946));
   AOI21X1 U1068 (.Y(n900), 
	.B0(n977), 
	.A1(n678), 
	.A0(n981));
   OAI21XL U1069 (.Y(n901), 
	.B0(n900), 
	.A1(n678), 
	.A0(n981));
   OAI21XL U1070 (.Y(n904), 
	.B0(n901), 
	.A1(n678), 
	.A0(n987));
   NAND2X1 U1071 (.Y(n978), 
	.B(n902), 
	.A(n903));
   OAI22X1 U1072 (.Y(n207), 
	.B1(n978), 
	.B0(n904), 
	.A1(n312), 
	.A0(bit_position[3]));
   NOR2X1 U1073 (.Y(n906), 
	.B(n981), 
	.A(bit_position[3]));
   AOI21X1 U1074 (.Y(n905), 
	.B0(n977), 
	.A1(n906), 
	.A0(n726));
   OAI21XL U1075 (.Y(n907), 
	.B0(n905), 
	.A1(n906), 
	.A0(n726));
   OAI21XL U1076 (.Y(n908), 
	.B0(n907), 
	.A1(n742), 
	.A0(n987));
   OAI22X1 U1077 (.Y(n205), 
	.B1(n908), 
	.B0(n978), 
	.A1(n312), 
	.A0(n726));
   NOR2X1 U1078 (.Y(n203), 
	.B(n911), 
	.A(n725));
   INVX1 U1079 (.Y(n917), 
	.A(n913));
   OAI21XL U1080 (.Y(n914), 
	.B0(mode[0]), 
	.A1(n912), 
	.A0(n913));
   INVX1 U1081 (.Y(n915), 
	.A(n914));
   AOI211X1 U1082 (.Y(n201), 
	.C0(n915), 
	.B0(n975), 
	.A1(n916), 
	.A0(n917));
   NOR2X1 U1083 (.Y(n921), 
	.B(n950), 
	.A(BUS_INT));
   OAI22X1 U1084 (.Y(n199), 
	.B1(n922), 
	.B0(RX_ADDR[0]), 
	.A1(n923), 
	.A0(n750));
   OAI22X1 U1085 (.Y(n197), 
	.B1(n923), 
	.B0(RX_ADDR[0]), 
	.A1(n922), 
	.A0(RX_ADDR[1]));
   OAI22X1 U1086 (.Y(n195), 
	.B1(n923), 
	.B0(RX_ADDR[1]), 
	.A1(n922), 
	.A0(RX_ADDR[2]));
   OAI22X1 U1087 (.Y(n193), 
	.B1(n922), 
	.B0(RX_ADDR[3]), 
	.A1(n923), 
	.A0(RX_ADDR[2]));
   OAI22X1 U1088 (.Y(n191), 
	.B1(n923), 
	.B0(RX_ADDR[3]), 
	.A1(n922), 
	.A0(RX_ADDR[4]));
   OAI22X1 U1089 (.Y(n189), 
	.B1(n922), 
	.B0(RX_ADDR[5]), 
	.A1(n923), 
	.A0(RX_ADDR[4]));
   OAI22X1 U1090 (.Y(n187), 
	.B1(n923), 
	.B0(RX_ADDR[5]), 
	.A1(n922), 
	.A0(RX_ADDR[6]));
   OAI22X1 U1091 (.Y(n185), 
	.B1(n922), 
	.B0(RX_ADDR[7]), 
	.A1(n923), 
	.A0(RX_ADDR[6]));
   NOR2X1 U1092 (.Y(n935), 
	.B(n929), 
	.A(n930));
   NAND4X1 U1093 (.Y(n934), 
	.D(n956), 
	.C(n931), 
	.B(n932), 
	.A(n933));
   OAI21XL U1094 (.Y(n152), 
	.B0(n934), 
	.A1(n935), 
	.A0(tx_underflow));
   OAI22X1 U1095 (.Y(n150), 
	.B1(n756), 
	.B0(n750), 
	.A1(n7540), 
	.A0(n721));
   OAI22X1 U1096 (.Y(n148), 
	.B1(n7540), 
	.B0(n722), 
	.A1(n755), 
	.A0(n721));
   OAI22X1 U1097 (.Y(n146), 
	.B1(n740), 
	.B0(n7540), 
	.A1(n756), 
	.A0(n722));
   OAI22X1 U1098 (.Y(n144), 
	.B1(n756), 
	.B0(n740), 
	.A1(n748), 
	.A0(n7540));
   OAI22X1 U1099 (.Y(n142), 
	.B1(n748), 
	.B0(n755), 
	.A1(n7540), 
	.A0(rx_data_buf[4]));
   OAI22X1 U1100 (.Y(n140), 
	.B1(n7540), 
	.B0(rx_data_buf[5]), 
	.A1(n755), 
	.A0(rx_data_buf[4]));
   OAI22X1 U1101 (.Y(n138), 
	.B1(n7540), 
	.B0(rx_data_buf[6]), 
	.A1(n756), 
	.A0(rx_data_buf[5]));
   OAI22X1 U1102 (.Y(n136), 
	.B1(n7540), 
	.B0(rx_data_buf[7]), 
	.A1(n756), 
	.A0(rx_data_buf[6]));
   OAI22X1 U1103 (.Y(n134), 
	.B1(n7540), 
	.B0(rx_data_buf[8]), 
	.A1(n756), 
	.A0(rx_data_buf[7]));
   OAI22X1 U1104 (.Y(n132), 
	.B1(n7540), 
	.B0(rx_data_buf[9]), 
	.A1(n756), 
	.A0(rx_data_buf[8]));
   OAI22X1 U1105 (.Y(n130), 
	.B1(n755), 
	.B0(rx_data_buf[9]), 
	.A1(n7540), 
	.A0(rx_data_buf[10]));
   OAI22X1 U1106 (.Y(n128), 
	.B1(n7540), 
	.B0(rx_data_buf[11]), 
	.A1(n756), 
	.A0(rx_data_buf[10]));
   OAI22X1 U1107 (.Y(n126), 
	.B1(n739), 
	.B0(n7540), 
	.A1(n756), 
	.A0(rx_data_buf[11]));
   OAI22X1 U1108 (.Y(n124), 
	.B1(n756), 
	.B0(n739), 
	.A1(n749), 
	.A0(n7540));
   OAI22X1 U1109 (.Y(n122), 
	.B1(n749), 
	.B0(n755), 
	.A1(n7540), 
	.A0(rx_data_buf[14]));
   OAI22X1 U1110 (.Y(n120), 
	.B1(n7540), 
	.B0(rx_data_buf[15]), 
	.A1(n756), 
	.A0(rx_data_buf[14]));
   OAI22X1 U1111 (.Y(n118), 
	.B1(n7540), 
	.B0(rx_data_buf[16]), 
	.A1(n756), 
	.A0(rx_data_buf[15]));
   OAI22X1 U1112 (.Y(n116), 
	.B1(n7540), 
	.B0(rx_data_buf[17]), 
	.A1(n756), 
	.A0(rx_data_buf[16]));
   OAI22X1 U1113 (.Y(n114), 
	.B1(n7540), 
	.B0(rx_data_buf[18]), 
	.A1(n756), 
	.A0(rx_data_buf[17]));
   OAI22X1 U1114 (.Y(n112), 
	.B1(n7540), 
	.B0(rx_data_buf[19]), 
	.A1(n756), 
	.A0(rx_data_buf[18]));
   OAI22X1 U1115 (.Y(n110), 
	.B1(n7540), 
	.B0(rx_data_buf[20]), 
	.A1(n756), 
	.A0(rx_data_buf[19]));
   OAI22X1 U1116 (.Y(n108), 
	.B1(n7540), 
	.B0(rx_data_buf[21]), 
	.A1(n755), 
	.A0(rx_data_buf[20]));
   OAI22X1 U1117 (.Y(n106), 
	.B1(n7540), 
	.B0(rx_data_buf[22]), 
	.A1(n755), 
	.A0(rx_data_buf[21]));
   OAI22X1 U1118 (.Y(n104), 
	.B1(n7540), 
	.B0(rx_data_buf[23]), 
	.A1(n755), 
	.A0(rx_data_buf[22]));
   OAI22X1 U1119 (.Y(n102), 
	.B1(n7540), 
	.B0(rx_data_buf[24]), 
	.A1(n755), 
	.A0(rx_data_buf[23]));
   OAI22X1 U1120 (.Y(n100), 
	.B1(n7540), 
	.B0(rx_data_buf[25]), 
	.A1(n755), 
	.A0(rx_data_buf[24]));
   OAI22X1 U1121 (.Y(n98), 
	.B1(n7540), 
	.B0(rx_data_buf[26]), 
	.A1(n755), 
	.A0(rx_data_buf[25]));
   OAI22X1 U1122 (.Y(n96), 
	.B1(n7540), 
	.B0(rx_data_buf[27]), 
	.A1(n755), 
	.A0(rx_data_buf[26]));
   OAI22X1 U1123 (.Y(n94), 
	.B1(n7540), 
	.B0(rx_data_buf[28]), 
	.A1(n755), 
	.A0(rx_data_buf[27]));
   OAI22X1 U1124 (.Y(n92), 
	.B1(n7540), 
	.B0(rx_data_buf[29]), 
	.A1(n755), 
	.A0(rx_data_buf[28]));
   OAI22X1 U1125 (.Y(n90), 
	.B1(n7540), 
	.B0(rx_data_buf[30]), 
	.A1(n755), 
	.A0(rx_data_buf[29]));
   OAI22X1 U1126 (.Y(n88), 
	.B1(n7540), 
	.B0(rx_data_buf[31]), 
	.A1(n755), 
	.A0(rx_data_buf[30]));
   OAI22X1 U1127 (.Y(n86), 
	.B1(n755), 
	.B0(rx_data_buf[31]), 
	.A1(n7540), 
	.A0(n723));
   OAI22X1 U1128 (.Y(n84), 
	.B1(n7540), 
	.B0(rx_data_buf[33]), 
	.A1(n756), 
	.A0(n723));
   AOI22X1 U1129 (.Y(n83), 
	.B1(n961), 
	.B0(ctrl_bit_buf), 
	.A1(n750), 
	.A0(n960));
   NOR2X1 U1130 (.Y(n943), 
	.B(n953), 
	.A(n941));
   AOI31X1 U1131 (.Y(n82), 
	.B0(n1026), 
	.A2(n745), 
	.A1(n942), 
	.A0(n943));
   NOR2BX1 U1132 (.Y(n81), 
	.B(TX_RESP_ACK), 
	.AN(n767));
   NAND4X1 U1133 (.Y(n945), 
	.D(n944), 
	.C(n952), 
	.B(n750), 
	.A(n960));
   OAI2BB1X1 U1134 (.Y(n949), 
	.B0(n945), 
	.A1N(n946), 
	.A0N(n947));
   NAND2X1 U1135 (.Y(n948), 
	.B(n312), 
	.A(RX_ACK));
   AOI21X1 U1136 (.Y(n951), 
	.B0(n961), 
	.A1(n950), 
	.A0(n260));
   OAI21XL U1137 (.Y(n78), 
	.B0(n964), 
	.A1(n951), 
	.A0(out_reg_pos));
   INVX1 U1138 (.Y(n959), 
	.A(n952));
   NAND4X1 U1139 (.Y(n957), 
	.D(n953), 
	.C(n954), 
	.B(n955), 
	.A(n956));
   AOI211X1 U1140 (.Y(n968), 
	.C0(n957), 
	.B0(n958), 
	.A1(n959), 
	.A0(n960));
   OAI22X1 U1141 (.Y(n966), 
	.B1(n963), 
	.B0(n964), 
	.A1(n965), 
	.A0(n734));
   AOI222X1 U1142 (.Y(n76), 
	.C1(rx_data_buf[11]), 
	.C0(n680), 
	.B1(rx_data_buf[9]), 
	.B0(n758), 
	.A1(n1014), 
	.A0(n757));
   AOI222X1 U1143 (.Y(n74), 
	.C1(rx_data_buf[10]), 
	.C0(n680), 
	.B1(rx_data_buf[8]), 
	.B0(n759), 
	.A1(n1015), 
	.A0(n757));
   AOI222X1 U1144 (.Y(n72), 
	.C1(rx_data_buf[9]), 
	.C0(n680), 
	.B1(rx_data_buf[7]), 
	.B0(n758), 
	.A1(n1016), 
	.A0(n757));
   AOI222X1 U1145 (.Y(n70), 
	.C1(rx_data_buf[8]), 
	.C0(n680), 
	.B1(rx_data_buf[6]), 
	.B0(n759), 
	.A1(n1017), 
	.A0(n757));
   AOI222X1 U1146 (.Y(n68), 
	.C1(rx_data_buf[7]), 
	.C0(n680), 
	.B1(rx_data_buf[5]), 
	.B0(n758), 
	.A1(n1018), 
	.A0(n757));
   AOI222X1 U1147 (.Y(n66), 
	.C1(rx_data_buf[6]), 
	.C0(n680), 
	.B1(rx_data_buf[4]), 
	.B0(n759), 
	.A1(n1019), 
	.A0(n757));
   AOI222X1 U1148 (.Y(n64), 
	.C1(n1020), 
	.C0(n757), 
	.B1(n680), 
	.B0(rx_data_buf[5]), 
	.A1(n758), 
	.A0(n748));
   AOI222X1 U1149 (.Y(n62), 
	.C1(rx_data_buf[33]), 
	.C0(n680), 
	.B1(rx_data_buf[31]), 
	.B0(n759), 
	.A1(n992), 
	.A0(n757));
   AOI222X1 U1150 (.Y(n60), 
	.C1(n723), 
	.C0(n680), 
	.B1(rx_data_buf[30]), 
	.B0(n759), 
	.A1(n993), 
	.A0(n757));
   AOI222X1 U1151 (.Y(n58), 
	.C1(n1021), 
	.C0(n757), 
	.B1(n680), 
	.B0(rx_data_buf[4]), 
	.A1(n758), 
	.A0(n740));
   AOI222X1 U1152 (.Y(n56), 
	.C1(rx_data_buf[31]), 
	.C0(n680), 
	.B1(rx_data_buf[29]), 
	.B0(n759), 
	.A1(n994), 
	.A0(n757));
   AOI222X1 U1153 (.Y(n54), 
	.C1(rx_data_buf[30]), 
	.C0(n680), 
	.B1(rx_data_buf[28]), 
	.B0(n759), 
	.A1(n995), 
	.A0(n757));
   AOI222X1 U1154 (.Y(n52), 
	.C1(rx_data_buf[29]), 
	.C0(n680), 
	.B1(rx_data_buf[27]), 
	.B0(n759), 
	.A1(n996), 
	.A0(n757));
   AOI222X1 U1155 (.Y(n50), 
	.C1(rx_data_buf[28]), 
	.C0(n680), 
	.B1(rx_data_buf[26]), 
	.B0(n759), 
	.A1(n997), 
	.A0(n757));
   AOI222X1 U1156 (.Y(n48), 
	.C1(rx_data_buf[27]), 
	.C0(n680), 
	.B1(rx_data_buf[25]), 
	.B0(n759), 
	.A1(n998), 
	.A0(n757));
   AOI222X1 U1157 (.Y(n46), 
	.C1(rx_data_buf[26]), 
	.C0(n680), 
	.B1(rx_data_buf[24]), 
	.B0(n759), 
	.A1(n999), 
	.A0(n757));
   AOI222X1 U1158 (.Y(n44), 
	.C1(rx_data_buf[25]), 
	.C0(n680), 
	.B1(rx_data_buf[23]), 
	.B0(n759), 
	.A1(n1000), 
	.A0(n757));
   AOI222X1 U1159 (.Y(n42), 
	.C1(rx_data_buf[24]), 
	.C0(n680), 
	.B1(rx_data_buf[22]), 
	.B0(n759), 
	.A1(n1001), 
	.A0(n757));
   AOI222X1 U1160 (.Y(n40), 
	.C1(rx_data_buf[23]), 
	.C0(n680), 
	.B1(rx_data_buf[21]), 
	.B0(n759), 
	.A1(n1002), 
	.A0(n757));
   AOI222X1 U1161 (.Y(n38), 
	.C1(rx_data_buf[22]), 
	.C0(n680), 
	.B1(rx_data_buf[20]), 
	.B0(n758), 
	.A1(n1003), 
	.A0(n757));
   AOI222X1 U1162 (.Y(n36), 
	.C1(n1022), 
	.C0(n757), 
	.B1(n722), 
	.B0(n758), 
	.A1(n680), 
	.A0(n748));
   AOI222X1 U1163 (.Y(n34), 
	.C1(rx_data_buf[21]), 
	.C0(n680), 
	.B1(rx_data_buf[19]), 
	.B0(n758), 
	.A1(n1004), 
	.A0(n757));
   AOI222X1 U1164 (.Y(n32), 
	.C1(rx_data_buf[20]), 
	.C0(n680), 
	.B1(rx_data_buf[18]), 
	.B0(n758), 
	.A1(n1005), 
	.A0(n757));
   AOI222X1 U1165 (.Y(n30), 
	.C1(rx_data_buf[19]), 
	.C0(n680), 
	.B1(rx_data_buf[17]), 
	.B0(n758), 
	.A1(n1006), 
	.A0(n757));
   AOI222X1 U1166 (.Y(n28), 
	.C1(rx_data_buf[18]), 
	.C0(n680), 
	.B1(rx_data_buf[16]), 
	.B0(n758), 
	.A1(n1007), 
	.A0(n757));
   AOI222X1 U1167 (.Y(n26), 
	.C1(rx_data_buf[17]), 
	.C0(n680), 
	.B1(rx_data_buf[15]), 
	.B0(n758), 
	.A1(n1008), 
	.A0(n757));
   AOI222X1 U1168 (.Y(n24), 
	.C1(rx_data_buf[16]), 
	.C0(n680), 
	.B1(rx_data_buf[14]), 
	.B0(n758), 
	.A1(n1009), 
	.A0(n757));
   AOI222X1 U1169 (.Y(n22), 
	.C1(n1010), 
	.C0(n757), 
	.B1(n680), 
	.B0(rx_data_buf[15]), 
	.A1(n758), 
	.A0(n749));
   AOI222X1 U1170 (.Y(n20), 
	.C1(n1011), 
	.C0(n757), 
	.B1(n680), 
	.B0(rx_data_buf[14]), 
	.A1(n758), 
	.A0(n739));
   AOI222X1 U1171 (.Y(n18), 
	.C1(n1012), 
	.C0(n757), 
	.B1(n759), 
	.B0(rx_data_buf[11]), 
	.A1(n680), 
	.A0(n749));
   AOI222X1 U1172 (.Y(n16), 
	.C1(n1013), 
	.C0(n757), 
	.B1(n758), 
	.B0(rx_data_buf[10]), 
	.A1(n680), 
	.A0(n739));
   AOI222X1 U1173 (.Y(n14), 
	.C1(n1023), 
	.C0(n757), 
	.B1(n721), 
	.B0(n759), 
	.A1(n680), 
	.A0(n740));
   AOI22X1 U1174 (.Y(n971), 
	.B1(n968), 
	.B0(n969), 
	.A1(RX_ACK), 
	.A0(RX_REQ));
   NOR3X1 U1175 (.Y(n976), 
	.C(n972), 
	.B(n973), 
	.A(n974));
   NOR2X1 U1176 (.Y(n982), 
	.B(n977), 
	.A(BUS_INT));
   INVX1 U1177 (.Y(n988), 
	.A(n982));
   OAI2BB1X1 U1178 (.Y(n980), 
	.B0(bit_position[2]), 
	.A1N(n987), 
	.A0N(n983));
   OAI211X1 U1179 (.Y(n209), 
	.C0(n980), 
	.B0(n986), 
	.A1(n988), 
	.A0(n981));
   OAI21XL U1180 (.Y(n985), 
	.B0(n982), 
	.A1(n983), 
	.A0(n984));
endmodule

