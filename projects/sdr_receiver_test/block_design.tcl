
# Create processing_system7
cell xilinx.com:ip:processing_system7:5.5 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset:5.0 rst_0

# PLL

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:5.3 pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_USED true
  CLKOUT2_REQUESTED_OUT_FREQ 250.0
  CLKOUT2_REQUESTED_PHASE -90.0
  USE_RESET false
} {
  clk_in1_p adc_clk_p_i
  clk_in1_n adc_clk_n_i
}

# ADC

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc:2.0 adc_0 {} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary:12.0 cntr_0 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26 DOUT_WIDTH 1
} {
  Din cntr_0/Q
  Dout led_o
}

# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register:1.0 cfg_0 {
  CFG_DATA_WIDTH 160
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]
set_property OFFSET 0x40000000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_1 {
  DIN_WIDTH 160 DIN_FROM 0 DIN_TO 0 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_2 {
  DIN_WIDTH 160 DIN_FROM 1 DIN_TO 1 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_3 {
  DIN_WIDTH 160 DIN_FROM 2 DIN_TO 2 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_4 {
  DIN_WIDTH 160 DIN_FROM 3 DIN_TO 3 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_5 {
  DIN_WIDTH 160 DIN_FROM 61 DIN_TO 32 DOUT_WIDTH 30
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_6 {
  DIN_WIDTH 160 DIN_FROM 79 DIN_TO 64 DOUT_WIDTH 16
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_7 {
  DIN_WIDTH 160 DIN_FROM 127 DIN_TO 96 DOUT_WIDTH 32
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_8 {
  DIN_WIDTH 160 DIN_FROM 157 DIN_TO 128 DOUT_WIDTH 30
} {
  Din cfg_0/cfg_data
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_0

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 const_test {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_7/Dout
  aclk ps_0/FCLK_CLK0
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_test {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
  TDATA_REMAP {tdata[31:0],32'b00000000000000000000000000000000}
} {
  S_AXIS const_test/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_phase_generator
cell pavel-demin:user:axis_phase_generator:1.0 phase_test {
  AXIS_TDATA_WIDTH 32
  PHASE_WIDTH 30
} {
  cfg_data slice_8/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_2/Dout
}

# Create cordic
cell xilinx.com:ip:cordic:6.0 cordic_test {
  INPUT_WIDTH.VALUE_SRC USER
  FLOW_CONTROL Blocking
  PIPELINING_MODE Optimal
  PHASE_FORMAT Scaled_Radians
  INPUT_WIDTH 32
  OUTPUT_WIDTH 15
  OUT_TREADY true
  ROUND_MODE Round_Pos_Neg_Inf
  COMPENSATION_SCALING Embedded_Multiplier
} {
  S_AXIS_CARTESIAN subset_test/M_AXIS
  S_AXIS_PHASE phase_test/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:5.3 pll_test {
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 250.0
} {
  clk_in1 pll_0/clk_out1
}

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_test {} {
  S_AXIS cordic_test/M_AXIS_DOUT
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn slice_1/Dout
  m_axis_aclk pll_0/clk_out1
  m_axis_aresetn const_0/dout
}

# DAC

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac:1.0 dac_test {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  locked pll_test/locked
  S_AXIS fifo_test/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_0 {} {
  S_AXIS adc_0/M_AXIS
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn const_0/dout
  m_axis_aclk ps_0/FCLK_CLK0
  m_axis_aresetn slice_1/Dout
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
  TDATA_REMAP {tdata[30:16],49'b0000000000000000000000000000000000000000000000000}
} {
  S_AXIS fifo_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_phase_generator
cell pavel-demin:user:axis_phase_generator:1.0 phase_0 {
  AXIS_TDATA_WIDTH 32
  PHASE_WIDTH 30
} {
  cfg_data slice_5/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_2/Dout
}

# Create cordic
cell xilinx.com:ip:cordic:6.0 cordic_0 {
  INPUT_WIDTH.VALUE_SRC USER
  FLOW_CONTROL Blocking
  PIPELINING_MODE Optimal
  PHASE_FORMAT Scaled_Radians
  INPUT_WIDTH 32
  OUTPUT_WIDTH 32
  OUT_TREADY true
  ROUND_MODE Round_Pos_Neg_Inf
  COMPENSATION_SCALING Embedded_Multiplier
} {
  S_AXIS_CARTESIAN subset_0/M_AXIS
  S_AXIS_PHASE phase_0/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[63:32]}
  M01_TDATA_REMAP {tdata[31:0]}
} {
  S_AXIS cordic_0/M_AXIS_DOUT
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_1

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_6/Dout
  aclk ps_0/FCLK_CLK0
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer:1.0 pktzr_0 {
  AXIS_TDATA_WIDTH 16
  CNTR_WIDTH 1
  CONTINUOUS FALSE
} {
  S_AXIS rate_0/M_AXIS
  cfg_data const_1/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 rate_1 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_6/Dout
  aclk ps_0/FCLK_CLK0
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer:1.0 pktzr_1 {
  AXIS_TDATA_WIDTH 16
  CNTR_WIDTH 1
  CONTINUOUS FALSE
} {
  S_AXIS rate_1/M_AXIS
  cfg_data const_1/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 125
  MAXIMUM_RATE 1250
  FIXED_OR_INITIAL_RATE 625
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M00_AXIS
  S_AXIS_CONFIG pktzr_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 125
  MAXIMUM_RATE 1250
  FIXED_OR_INITIAL_RATE 625
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M01_AXIS
  S_AXIS_CONFIG pktzr_1/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler:7.2 fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.64776395523261e-08, -4.73223982493382e-08, -7.93114097748734e-10, 3.09341607494277e-08, 1.86268604565617e-08, 3.27485571200346e-08, -6.29908653657968e-09, -1.52279861575043e-07, -8.30460847858456e-08, 3.14535491822606e-07, 3.05626738325402e-07, -4.74172694219994e-07, -7.13495049416347e-07, 5.47323968241002e-07, 1.33462183148789e-06, -4.14140755019506e-07, -2.15051006195781e-06, -6.77410015715413e-08, 3.07546485446303e-06, 1.03702255417565e-06, -3.94436393706816e-06, -2.59191311589838e-06, 4.51537519422448e-06, 4.74782575774399e-06, -4.49284245797096e-06, -7.39824596121288e-06, 3.57216304293944e-06, 1.0289531398643e-05, -1.50382000963687e-06, -1.30208669437029e-05, -1.8320780740752e-06, 1.50781578706169e-05, 6.35464869916574e-06, -1.5905693254477e-05, -1.17324822432291e-05, 1.50110146034995e-05, 1.73719815499574e-05, -1.20943524633858e-05, -2.24668827259553e-05, 7.16974344173206e-06, 2.61032685003911e-05, -6.63576078703743e-07, -2.74292794572945e-05, -6.55062322922545e-06, 2.5864354889803e-05, 1.32043152416442e-05, -2.13170377303369e-05, -1.7790015052466e-05, 1.4366401658372e-05, 1.88196488042346e-05, -6.35769575620025e-06, -1.51624671610732e-05, -6.3454751890034e-07, 6.41574547942767e-06, 4.00779001049893e-06, 6.75760336386084e-06, -1.00538045567379e-06, -2.24030234065108e-05, -1.07626302618669e-05, 3.72333834565482e-05, 3.27008161208513e-05, -4.68605170112616e-05, -6.46526581514427e-05, 4.62599879903061e-05, 0.000104401861517261, -3.05403948192664e-05, -0.00014745720335074, -4.12013707266912e-06, 0.000187185910308468, 5.9472285269084e-05, -0.000215374917579779, -0.000134302073078784, 0.000223224152976694, 0.00022383529853513, -0.000202700646279518, -0.000319623716269056, 0.000148096208070561, 0.00041005036860653, -5.75597854424301e-05, -0.000481514995957391, -6.56763133492148e-05, 0.000520250999114949, 0.000212664164338231, -0.000514618719419215, -0.000369005842837135, 0.000457467389871147, 0.000515973656086604, -0.000348477939755869, -0.000632881279945779, 0.000195649794954827, 0.000700188749146281, -1.57992717633881e-05, -0.000703205392036612, -0.000166376697710665, 0.000635843920605569, 0.00032083226194399, -0.000503811084211153, -0.000416255319934634, 0.000326569991673316, 0.000425391875921946, -0.00013746695448704, -0.000331045335837557, -1.84322419198225e-05, 0.000131952870425038, 8.8991373620273e-05, 0.000152406451111629, -2.20059552576483e-05, -0.000479109327658611, -0.000226158943701414, 0.000781596108897923, 0.000680336287236396, -0.000973841573779158, -0.00133743086810108, 0.000957505429554979, 0.00215823795933061, -0.000633058497914659, -0.00306239583565753, -8.62773868301778e-05, 0.00392749237767837, 0.00125890086582158, -0.0045932013828814, -0.002899064621986, 0.00487080892138405, 0.00496271652177841, -0.00455788126865406, -0.00733667233358662, 0.00345716360480598, 0.00983253607996904, -0.00139819324342049, -0.0121861637129463, -0.00174034328863689, 0.014062282608939, 0.00600853672502155, -0.0150655751552465, -0.01137014160612, 0.0147483575782911, 0.0176872274320504, -0.0126185258485222, -0.0247131655485743, 0.00813090350262748, 0.0320864711007864, -0.000645151353472906, -0.0393170493516836, -0.0106924075067383, 0.0457366439777749, 0.0272501703222767, -0.0503214712404459, -0.0517158392679872, 0.0510195785361982, 0.0905708960358907, -0.0416085827802432, -0.163747940036716, -0.0107991247506511, 0.356391980570419, 0.554821620626239, 0.356391980570419, -0.0107991247506511, -0.163747940036716, -0.0416085827802432, 0.0905708960358907, 0.0510195785361982, -0.0517158392679871, -0.0503214712404459, 0.0272501703222767, 0.0457366439777748, -0.0106924075067384, -0.0393170493516836, -0.000645151353472902, 0.0320864711007864, 0.00813090350262744, -0.0247131655485743, -0.0126185258485222, 0.0176872274320504, 0.014748357578291, -0.01137014160612, -0.0150655751552464, 0.00600853672502154, 0.014062282608939, -0.00174034328863689, -0.0121861637129463, -0.0013981932434205, 0.00983253607996903, 0.00345716360480599, -0.00733667233358662, -0.00455788126865407, 0.00496271652177837, 0.00487080892138405, -0.00289906462198599, -0.0045932013828814, 0.00125890086582158, 0.00392749237767837, -8.62773868301858e-05, -0.00306239583565753, -0.000633058497914665, 0.00215823795933062, 0.000957505429554986, -0.00133743086810109, -0.00097384157377915, 0.000680336287236399, 0.000781596108897926, -0.000226158943701417, -0.000479109327658599, -2.20059552576474e-05, 0.000152406451111619, 8.89913736202697e-05, 0.000131952870425043, -1.84322419198184e-05, -0.000331045335837562, -0.000137466954487046, 0.000425391875921945, 0.000326569991673318, -0.000416255319934626, -0.000503811084211157, 0.000320832261943976, 0.000635843920605571, -0.000166376697710658, -0.000703205392036611, -1.57992717634175e-05, 0.000700188749146282, 0.000195649794954849, -0.00063288127994578, -0.000348477939755879, 0.000515973656086602, 0.000457467389871152, -0.000369005842837133, -0.00051461871941922, 0.00021266416433823, 0.00052025099911495, -6.5676313349214e-05, -0.000481514995957386, -5.75597854424309e-05, 0.00041005036860653, 0.000148096208070561, -0.000319623716269053, -0.000202700646279518, 0.00022383529853513, 0.000223224152976694, -0.000134302073078785, -0.000215374917579779, 5.94722852690836e-05, 0.000187185910308467, -4.1201370726696e-06, -0.000147457203350739, -3.05403948192655e-05, 0.00010440186151726, 4.62599879903048e-05, -6.46526581514424e-05, -4.68605170112612e-05, 3.27008161208512e-05, 3.72333834565472e-05, -1.07626302618669e-05, -2.24030234065122e-05, -1.00538045567376e-06, 6.75760336386114e-06, 4.00779001049914e-06, 6.41574547942654e-06, -6.34547518900236e-07, -1.51624671610739e-05, -6.35769575620011e-06, 1.88196488042347e-05, 1.43664016583718e-05, -1.77900150524658e-05, -2.13170377303367e-05, 1.32043152416438e-05, 2.58643548898028e-05, -6.55062322922483e-06, -2.74292794572945e-05, -6.63576078704085e-07, 2.61032685003909e-05, 7.16974344173231e-06, -2.24668827259554e-05, -1.20943524633859e-05, 1.73719815499574e-05, 1.50110146034996e-05, -1.1732482243229e-05, -1.59056932544774e-05, 6.35464869916573e-06, 1.5078157870617e-05, -1.83207807407521e-06, -1.30208669437035e-05, -1.50382000963686e-06, 1.02895313986436e-05, 3.57216304293944e-06, -7.39824596121333e-06, -4.49284245797099e-06, 4.74782575774417e-06, 4.51537519422448e-06, -2.59191311589829e-06, -3.94436393706815e-06, 1.03702255417562e-06, 3.07546485446302e-06, -6.77410015715271e-08, -2.15051006195779e-06, -4.14140755019505e-07, 1.33462183148789e-06, 5.47323968241007e-07, -7.13495049416342e-07, -4.7417269421995e-07, 3.05626738325399e-07, 3.1453549182257e-07, -8.30460847858442e-08, -1.52279861575044e-07, -6.29908653657931e-09, 3.27485571200189e-08, 1.86268604565597e-08, 3.09341607494308e-08, -7.93114097748315e-10, -4.73223982493358e-08, -1.64776395523266e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_PATHS 2
  RATESPECIFICATION Input_Sample_Period
  SAMPLEPERIOD 125
  OUTPUT_ROUNDING_MODE Truncate_LSBs
  OUTPUT_WIDTH 32
} {
  S_AXIS_DATA comb_0/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen:8.3 bram_0 {
  MEMORY_TYPE True_Dual_Port_RAM
  USE_BRAM_BLOCK Stand_Alone
  USE_BYTE_WRITE_ENABLE true
  BYTE_SIZE 8
  WRITE_WIDTH_A 64
  WRITE_DEPTH_A 512
  WRITE_WIDTH_B 32
  WRITE_DEPTH_B 1024
  ENABLE_A Always_Enabled
  ENABLE_B Always_Enabled
  REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
}

# Create axis_bram_writer
cell pavel-demin:user:axis_bram_writer:1.0 writer_0 {
  AXIS_TDATA_WIDTH 64
  BRAM_DATA_WIDTH 64
  BRAM_ADDR_WIDTH 9
} {
  S_AXIS fir_0/M_AXIS_DATA
  BRAM_PORTA bram_0/BRAM_PORTA
  aclk ps_0/FCLK_CLK0
  aresetn slice_3/Dout
}

# Create axi_bram_reader
cell pavel-demin:user:axi_bram_reader:1.0 reader_0 {
  AXI_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  BRAM_DATA_WIDTH 32
  BRAM_ADDR_WIDTH 10
} {
  BRAM_PORTA bram_0/BRAM_PORTB
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins reader_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg0]
set_property OFFSET 0x40002000 [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg0]

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register:1.0 sts_0 {
  STS_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data writer_0/sts_data
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
