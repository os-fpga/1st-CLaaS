//  (c) Copyright 2016 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES. 
//-----------------------------------------------------------------------------
//============================================================================
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited.
//  
//                 (C) COPYRIGHT 2010-2012 ARM Limited.
//                        ALL RIGHTS RESERVED
// 
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited.
//
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  315.  Module: axi_vip_v1_0_1_axi4pc
//  388.    1) Parameters
//  391.         - Configurable (user can set)
//  438.         - Calculated (user should not override)
//  991.    2) Inputs (no outputs)
//  994.         - Global Signals
//  999.         - Write Address Channel
// 1015.         - Write Data Channel
// 1024.         - Write Response Channel
// 1032.         - Read Address Channel
// 1048.         - Read Data Channel
// 1058.         - Low Power Interface
// 1065.    3) Wire and Reg Declarations
// 1159.    4) Verilog Defines
// 1162.         - Clock and Reset
// 1194.    5) Initialize simulation
// 1199.         - Format for time reporting
// 1204.         - Indicate version and release state of axi_vip_v1_0_1_axi4pc
// 1209.         - Warn if any/some recommended rules are disabled
// 1221. 
// 1222.  AXI4 Rules: Write Address Channel (*_AW*)
// 1226.    1) Functional Rules
// 1229.         - AXI4_ERRM_AWADDR_BOUNDARY
// 1253.         - AXI4_ERRM_AWADDR_WRAP_ALIGN
// 1265.         - AXI4_ERRM_AWBURST
// 1277.         - AXI4_ERRM_AWLEN_LOCK
// 1289.         - AXI4_ERRM_AWCACHE
// 1301.         - AXI4_ERRM_AWLEN_FIXED
// 1313.         - AXI4_ERRM_AWLEN_WRAP
// 1328.         - AXI4_ERRM_AWSIZE
// 1342.         - AXI4_ERRM_AWVALID_RESET
// 1354.    2) Handshake Rules
// 1357.         - AXI4_ERRM_AWADDR_STABLE
// 1370.         - AXI4_ERRM_AWBURST_STABLE
// 1383.         - AXI4_ERRM_AWCACHE_STABLE
// 1396.         - AXI4_ERRM_AWID_STABLE
// 1409.         - AXI4_ERRM_AWLEN_STABLE
// 1422.         - AXI4_ERRM_AWLOCK_STABLE
// 1435.         - AXI4_ERRM_AWPROT_STABLE
// 1448.         - AXI4_ERRM_AWSIZE_STABLE
// 1461.         - AXI4_ERRM_AWQOS_STABLE
// 1474.         - AXI4_ERRM_AWREGION_STABLE
// 1487.         - AXI4_ERRM_AWVALID_STABLE
// 1499.         - AXI4_RECS_AWREADY_MAX_WAIT
// 1514.    3) X-Propagation Rules
// 1521.         - AXI4_ERRM_AWADDR_X
// 1532.         - AXI4_ERRM_AWBURST_X
// 1543.         - AXI4_ERRM_AWCACHE_X
// 1554.         - AXI4_ERRM_AWID_X
// 1565.         - AXI4_ERRM_AWLEN_X
// 1576.         - AXI4_ERRM_AWLOCK_X
// 1587.         - AXI4_ERRM_AWPROT_X
// 1598.         - AXI4_ERRM_AWSIZE_X
// 1609.         - AXI4_ERRM_AWQOS_X
// 1620.         - AXI4_ERRM_AWREGION_X
// 1631.         - AXI4_ERRM_AWVALID_X
// 1642.         - AXI4_ERRS_AWREADY_X
// 1655. 
// 1656.  AXI4 Rules: Write Data Channel (*_W*)
// 1660.    1) Functional Rules
// 1669.         - AXI4_ERRM_WDATA_NUM_PROP1
// 1680.         - AXI4_ERRM_WDATA_NUM_PROP2
// 1691.         - AXI4_ERRM_WDATA_NUM_PROP3
// 1702.         - AXI4_ERRM_WDATA_NUM_PROP4
// 1713.         - AXI4_ERRM_WDATA_NUM_PROP5
// 1724.         - AXI4_ERRM_WSTRB
// 1738.         - AXI4_ERRM_WVALID_RESET
// 1750.    2) Handshake Rules
// 1753.         - AXI4_ERRM_WDATA_STABLE
// 1766.         - AXI4_ERRM_WLAST_STABLE
// 1779.         - AXI4_ERRM_WSTRB_STABLE
// 1792.         - AXI4_ERRM_WVALID_STABLE
// 1804.         - AXI4_RECS_WREADY_MAX_WAIT 
// 1819.    3) X-Propagation Rules
// 1826.         - AXI4_ERRM_WDATA_X
// 1837.         - AXI4_ERRM_WLAST_X
// 1848.         - AXI4_ERRM_WSTRB_X
// 1859.         - AXI4_ERRM_WVALID_X
// 1870.         - AXI4_ERRS_WREADY_X
// 1884. 
// 1885.  AXI4 Rules: Write Response Channel (*_B*)
// 1889.    1) Functional Rules
// 1893.         - AXI4_ERRS_BRESP_WLAST
// 1907.         - AXI4_ERRS_BRESP_EXOKAY
// 1920.         - AXI4_ERRS_BVALID_RESET
// 1932.         - AXI4_ERRS_BRESP_AW 
// 1944.    2) Handshake Rules
// 1947.         - AXI4_ERRS_BID_STABLE
// 1960.         - AXI4_ERRS_BRESP_STABLE
// 1973.         - AXI4_ERRS_BVALID_STABLE
// 1985.         - AXI4_RECM_BREADY_MAX_WAIT 
// 2000.    3) X-Propagation Rules
// 2007.         - AXI4_ERRM_BREADY_X
// 2018.         - AXI4_ERRS_BID_X
// 2029.         - AXI4_ERRS_BRESP_X
// 2040.         - AXI4_ERRS_BVALID_X
// 2054. 
// 2055.  AXI4 Rules: Read Address Channel (*_AR*)
// 2059.    1) Functional Rules
// 2062.         - AXI4_ERRM_ARADDR_BOUNDARY
// 2086.         - AXI4_ERRM_ARADDR_WRAP_ALIGN
// 2098.         - AXI4_ERRM_ARBURST
// 2110.         - AXI4_ERRM_ARLEN_LOCK
// 2122.         - AXI4_ERRM_ARCACHE
// 2134.         - AXI4_ERRM_ARLEN_FIXED
// 2146.         - AXI4_ERRM_ARLEN_WRAP
// 2164.         - AXI4_ERRM_ARSIZE
// 2176.         - AXI4_ERRM_ARVALID_RESET
// 2188.    2) Handshake Rules
// 2191.         - AXI4_ERRM_ARADDR_STABLE
// 2204.         - AXI4_ERRM_ARBURST_STABLE
// 2217.         - AXI4_ERRM_ARCACHE_STABLE
// 2230.         - AXI4_ERRM_ARID_STABLE
// 2243.         - AXI4_ERRM_ARLEN_STABLE
// 2256.         - AXI4_ERRM_ARLOCK_STABLE
// 2269.         - AXI4_ERRM_ARPROT_STABLE
// 2282.         - AXI4_ERRM_ARSIZE_STABLE
// 2295.         - AXI4_ERRM_ARQOS_STABLE
// 2308.         - AXI4_ERRM_ARREGION_STABLE
// 2321.         - AXI4_ERRM_ARVALID_STABLE
// 2333.         - AXI4_RECS_ARREADY_MAX_WAIT 
// 2348.    3) X-Propagation Rules
// 2355.         - AXI4_ERRM_ARADDR_X
// 2366.         - AXI4_ERRM_ARBURST_X
// 2377.         - AXI4_ERRM_ARCACHE_X
// 2388.         - AXI4_ERRM_ARID_X
// 2399.         - AXI4_ERRM_ARLEN_X
// 2410.         - AXI4_ERRM_ARLOCK_X
// 2421.         - AXI4_ERRM_ARPROT_X
// 2432.         - AXI4_ERRM_ARSIZE_X
// 2443.         - AXI4_ERRM_ARQOS_X
// 2454.         - AXI4_ERRM_ARREGION_X
// 2465.         - AXI4_ERRM_ARVALID_X
// 2476.         - AXI4_ERRS_ARREADY_X
// 2489. 
// 2490.  AXI4 Rules: Read Data Channel (*_R*)
// 2494.    1) Functional Rules
// 2497.         - AXI4_ERRS_RDATA_NUM
// 2510.         - AXI4_ERRS_RID
// 2523.         - AXI4_ERRS_RRESP_EXOKAY
// 2535.         - AXI4_ERRS_RVALID_RESET
// 2547.    2) Handshake Rules
// 2550.         - AXI4_ERRS_RDATA_STABLE
// 2563.         - AXI4_ERRS_RID_STABLE
// 2576.         - AXI4_ERRS_RLAST_STABLE
// 2589.         - AXI4_ERRS_RRESP_STABLE
// 2602.         - AXI4_ERRS_RVALID_STABLE
// 2614.         - AXI4_RECM_RREADY_MAX_WAIT 
// 2629.    3) X-Propagation Rules
// 2636.         - AXI4_ERRS_RDATA_X
// 2647.         - AXI4_ERRM_RREADY_X
// 2658.         - AXI4_ERRS_RID_X
// 2669.         - AXI4_ERRS_RLAST_X
// 2680.         - AXI4_ERRS_RRESP_X
// 2691.         - AXI4_ERRS_RVALID_X
// 2704. 
// 2705.  AXI4 Rules: Low Power Interface (*_C*)
// 2709.    1) Functional Rules (none for Low Power signals)
// 2713.    2) Handshake Rules (asynchronous to ACLK)
// 2720.         - AXI4_ERRL_CSYSACK_FALL
// 2731.         - AXI4_ERRL_CSYSACK_RISE
// 2742.         - AXI4_ERRL_CSYSREQ_FALL
// 2753.         - AXI4_ERRL_CSYSREQ_RISE
// 2764.    3) X-Propagation Rules
// 2771.         - AXI4_ERRL_CACTIVE_X
// 2782.         - AXI4_ERRL_CSYSACK_X
// 2793.         - AXI4_ERRL_CSYSREQ_X
// 2806. 
// 2807.  AXI Rules: Exclusive Access
// 2814.    1) Functional Rules
// 2817.         - AXI4_ERRM_EXCL_ALIGN
// 2839.         - AXI4_ERRM_EXCL_LEN
// 2857.         - AXI4_RECM_EXCL_MATCH
// 2883.         - AXI4_ERRM_EXCL_MAX
// 2904.         - AXI4_RECM_EXCL_PAIR
// 2921.         - AXI4_RECM_EXCL_R_W
// 2936. 
// 2937.  AXI4 Rules: USER_* Rules (extension to AXI4)
// 2944.    1) Functional Rules (none for USER signals)
// 2948.    2) Handshake Rules
// 2951.         - AXI4_ERRM_AWUSER_STABLE
// 2964.         - AXI4_ERRM_WUSER_STABLE
// 2977.         - AXI4_ERRS_BUSER_STABLE
// 2990.         - AXI4_ERRM_ARUSER_STABLE
// 3003.         - AXI4_ERRS_RUSER_STABLE
// 3016.    3) X-Propagation Rules
// 3022.         - AXI4_ERRM_AWUSER_X
// 3033.         - AXI4_ERRM_WUSER_X
// 3044.         - AXI4_ERRS_BUSER_X
// 3055.         - AXI4_ERRM_ARUSER_X
// 3066.         - AXI4_ERRS_RUSER_X
// 3079.    4) Zero Width Stability Rules
// 3082.         - AXI4_ERRM_AWUSER_TIEOFF
// 3095.         - AXI4_ERRM_WUSER_TIEOFF
// 3108.         - AXI4_ERRS_BUSER_TIEOFF
// 3121.         - AXI4_ERRM_ARUSER_TIEOFF
// 3134.         - AXI4_ERRS_RUSER_TIEOFF
// 3147.         - AXI4_ERRM_AWID_TIEOFF
// 3160.         - AXI4_ERRS_BID_TIEOFF
// 3173.         - AXI4_ERRM_ARID_TIEOFF
// 3186.         - AXI4_ERRS_RID_TIEOFF
// 3199.    5) EOS checks
// 3206.         - AXI4_ERRS_BRESP_ALL_DONE_EOS
// 3214.         - AXI4_ERRS_RLAST_ALL_DONE_EOS
// 3227. 
// 3228.  Auxiliary Logic
// 3232.    1) Rules for Auxiliary Logic
// 3236.       a) Master (AUX*)
// 3239.         - AXI4_AUX_DATA_WIDTH
// 3254.         - AXI4_AUX_ADDR_WIDTH
// 3264.         - AXI4_AUX_EXMON_WIDTH
// 3274.         - AXI4_AUX_MAXRBURSTS
// 3284.         - AXI4_AUX_MAXWBURSTS
// 3294.         - AXI4_AUX_RCAM_OVERFLOW
// 3305.         - AXI4_AUX_RCAM_UNDERFLOW
// 3316.         - AXI4_AUX_WCAM_OVERFLOW
// 3327.         - AXI4_AUX_WCAM_UNDERFLOW
// 3338.         - AXI4_AUX_EXCL_OVERFLOW
// 3349.    2) Combinatorial Logic
// 3353.       a) Masks
// 3356.            - AlignMaskR
// 3378.            - AlignMaskW
// 3400.            - ExclMask
// 3408.            - WdataMask
// 3421.            - RdataMask
// 3427.       b) Increments
// 3430.            - ArAddrIncr
// 3438.            - AwAddrIncr
// 3447.       c) Conversions
// 3450.            - ArLenInBytes
// 3459.            - ArSizeInBits
// 3467.            - AwSizeInBits
// 3476.       d) Other
// 3479.            - ArExclPending
// 3485.            - ArLenPending
// 3490.            - ArCountPending
// 3496.    3) EXCL Accesses
// 3499.         - Exclusive Access ID Lookup
// 3627.         - Exclusive Access Storage
// 3688.    4) Content addressable memories (CAMs)
// 3691.         - Read CAMSs (CAM+Shift)
// 3931.         - Write CAMs (CAM+Shift)
// 4326.    5) Verilog Functions
// 4328.         - function integer clogb2 (input integer n)
// 4339.         - CheckBurst
// 4679.         - CheckStrb
// 4717.         - ReadDataMask
// 4737.         - ByteShift
// 4832.         - ByteCount
// 4880.  End of File
// 4883.    1) Clear Verilog Defines
// 4897.    2) End of module
//----------------------------------------------------------------------------

`timescale 1ps/1ps

//------------------------------------------------------------------------------
// AXI4 definitions
//------------------------------------------------------------------------------

`ifndef axi_vip_v1_0_1_AXI4PC_OFF
`define axi_vip_v1_0_1_AXI4PC_OFF

//  ----------------------------------------------------------------------------
//  Purpose             : Standard AXI4 SVA Protocol Assertions defines
//  ========================================================================--

`ifndef axi_vip_v1_0_1_AXI4PC_TYPES
  `define axi_vip_v1_0_1_AXI4PC_TYPES
  // ALEN Encoding
  `define AXI4PC_ALEN_1            8'b00000000
  `define AXI4PC_ALEN_2            8'b00000001
  `define AXI4PC_ALEN_3            8'b00000010
  `define AXI4PC_ALEN_4            8'b00000011
  `define AXI4PC_ALEN_5            8'b00000100
  `define AXI4PC_ALEN_6            8'b00000101
  `define AXI4PC_ALEN_7            8'b00000110
  `define AXI4PC_ALEN_8            8'b00000111
  `define AXI4PC_ALEN_9            8'b00001000
  `define AXI4PC_ALEN_10           8'b00001001
  `define AXI4PC_ALEN_11           8'b00001010
  `define AXI4PC_ALEN_12           8'b00001011
  `define AXI4PC_ALEN_13           8'b00001100
  `define AXI4PC_ALEN_14           8'b00001101
  `define AXI4PC_ALEN_15           8'b00001110
  `define AXI4PC_ALEN_16           8'b00001111

  // ASIZE Encoding
  `define AXI4PC_ASIZE_8           3'b000
  `define AXI4PC_ASIZE_16          3'b001
  `define AXI4PC_ASIZE_32          3'b010
  `define AXI4PC_ASIZE_64          3'b011
  `define AXI4PC_ASIZE_128         3'b100
  `define AXI4PC_ASIZE_256         3'b101
  `define AXI4PC_ASIZE_512         3'b110
  `define AXI4PC_ASIZE_1024        3'b111

  // ABURST Encoding
  `define AXI4PC_ABURST_FIXED      2'b00
  `define AXI4PC_ABURST_INCR       2'b01 
  `define AXI4PC_ABURST_WRAP       2'b10 

  // ALOCK Encoding
  `define AXI4PC_ALOCK_EXCL        1'b1

  // RRESP / BRESP Encoding
  `define AXI4PC_RESP_OKAY         2'b00
  `define AXI4PC_RESP_EXOKAY       2'b01
  `define AXI4PC_RESP_SLVERR       2'b10
  `define AXI4PC_RESP_DECERR       2'b11

  //PROTOCOL define the protocol
    `define AXI4PC_AMBA_AXI4         3'b000
    `define AXI4PC_AMBA_ACE          3'b011
    `define AXI4PC_AMBA_ACE_LITE     3'b100
    `define AXI4PC_AMBA_AXI4LITE     3'b010
    `define AXI4PC_AMBA_AXI3         3'b001
`endif

// --========================= End ===========================================--

//  ----------------------------------------------------------------------------
//  Purpose             : AXI4 SV Protocol Assertions message `defines
//  ========================================================================--


`ifndef axi_vip_v1_0_1_AXI4PC_MESSAGES
        `define axi_vip_v1_0_1_AXI4PC_MESSAGES
  `define ERRM_AWADDR_BOUNDARY      "AXI4_ERRM_AWADDR_BOUNDARY: A burst must not cross a 4kbyte boundary. Spec: section A3.4.1."
  `define ERRM_AWADDR_WRAP_ALIGN    "AXI4_ERRM_AWADDR_WRAP_ALIGN: For a wrapping burst, the start address must be aligned to the size of each transfer. Spec: section A3.4.1."
  `define ERRM_AWBURST              "AXI4_ERRM_AWBURST: When AWVALID is high, a value of 2'b11 on AWBURST is reserved. Spec: table A3-3."
  `define ERRM_AWCACHE              "AXI4_ERRM_AWCACHE: When AWVALID is high, a reserved value on AWCACHE is not allowed. Spec: table A4-5."
  `define ERRM_ARCACHE              "AXI4_ERRM_ARCACHE: When AWVALID is high, a reserved value on ARCACHE is not allowed. Spec: table A4-5."
  `define ERRM_AWLEN_WRAP           "AXI4_ERRM_AWLEN_WRAP: For a wrapping burst, the length of the burst must be 2, 4, 8 or 16 transfers. Spec: section A3.4.1."
  `define ERRM_AWSIZE               "AXI4_ERRM_AWSIZE: The size of any transfer must not exceed the data bus width of either agent in the transaction. Spec: section A3.4.1."
  `define ERRM_AWVALID_RESET        "AXI4_ERRM_AWVALID_RESET: The earliest point after reset that a master is permitted to begin driving ARVALID, AWVALID, or WVALID HIGH is at a rising ACLK edge after ARESETn is HIGH. Spec: Figure A3-1."
  `define ERRM_AWADDR_STABLE        "AXI4_ERRM_AWADDR_STABLE: AWADDR must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWBURST_STABLE       "AXI4_ERRM_AWBURST_STABLE: AWBURST must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWCACHE_STABLE       "AXI4_ERRM_AWCACHE_STABLE: AWCACHE must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWID_STABLE          "AXI4_ERRM_AWID_STABLE: AWID must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWLEN_STABLE         "AXI4_ERRM_AWLEN_STABLE: AWLEN must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWLOCK_STABLE        "AXI4_ERRM_AWLOCK_STABLE: AWLOCK must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWPROT_STABLE        "AXI4_ERRM_AWPROT_STABLE: AWPROT must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWSIZE_STABLE        "AXI4_ERRM_AWSIZE_STABLE: AWSIZE must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWQOS_STABLE         "AXI4_ERRM_AWQOS_STABLE: AWQOS must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWREGION_STABLE      "AXI4_ERRM_AWREGION_STABLE: AWREGION must remain stable when ARVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_AWVALID_STABLE       "AXI4_ERRM_AWVALID_STABLE: Once AWVALID is asserted, it must remain asserted until AWREADY is high. Spec: section A3.2.2."
  `define ERRM_AWADDR_X             "AXI4_ERRM_AWADDR_X: When AWVALID is high, a value of X on AWADDR is not permitted. Spec: section A3.2.2."
  `define ERRM_AWBURST_X            "AXI4_ERRM_AWBURST_X: When AWVALID is high, a value of X on AWBURST is not permitted. Spec: section A3.2.2."
  `define ERRM_AWCACHE_X            "AXI4_ERRM_AWCACHE_X: When AWVALID is high, a value of X on AWCACHE is not permitted. Spec: section A3.2.2."
  `define ERRM_AWID_X               "AXI4_ERRM_AWID_X: When AWVALID is high, a value of X on AWID is not permitted. Spec: section A3.2.2."
  `define ERRM_AWLEN_X              "AXI4_ERRM_AWLEN_X: When AWVALID is high, a value of X on AWLEN is not permitted. Spec: section A3.2.2."
  `define ERRM_AWLOCK_X             "AXI4_ERRM_AWLOCK_X: When AWVALID is high, a value of X on AWLOCK is not permitted. Spec: section A3.2.2."
  `define ERRM_AWPROT_X             "AXI4_ERRM_AWPROT_X: When AWVALID is high, a value of X on AWPROT is not permitted. Spec: section A3.2.2."
  `define ERRM_AWSIZE_X             "AXI4_ERRM_AWSIZE_X: When AWVALID is high, a value of X on AWSIZE is not permitted. Spec: section A3.2.2."
  `define ERRM_AWQOS_X              "AXI4_ERRM_AWQOS_X: When AWVALID is high, a value of X on AWQOS is not permitted. Spec: section A3.2.2."
  `define ERRM_AWREGION_X           "AXI4_ERRM_AWREGION_X: When AWVALID is high, a value of X on AWREGION is not permitted. Spec: section A3.2.2."
  `define ERRM_AWVALID_X            "AXI4_ERRM_AWVALID_X: When not in reset, a value of X on AWVALID is not permitted. Spec: section A3.1.2."
  `define ERRS_AWREADY_X            "AXI4_ERRS_AWREADY_X: When not in reset, a value of X on AWREADY is not permitted. Spec: section A3.1.2."
  `define ERRM_WDATA_NUM            "AXI4_ERRM_WDATA_NUM: The number of write data items must match AWLEN for the corresponding address. Spec: section A3.4.1."
  `define ERRM_WSTRB                "AXI4_ERRM_WSTRB: Write strobes must only be asserted for the correct byte lanes as determined from start address, transfer size and beat number. Spec: section A3.4.3."
  `define ERRM_WVALID_RESET         "AXI4_ERRM_WVALID_RESET: The earliest point after reset that a master is permitted to begin driving ARVALID, AWVALID, or WVALID HIGH is at a rising ACLK edge after ARESETn is HIGH. Spec: Figure A3-1."
  `define ERRM_WDATA_STABLE         "AXI4_ERRM_WDATA_STABLE: WDATA must remain stable when WVALID is asserted and WREADY low. Spec: section A3.2.1."
  `define ERRM_WLAST_STABLE         "AXI4_ERRM_WLAST_STABLE: WLAST must remain stable when WVALID is asserted and WREADY low. Spec: section A3.2.1."
  `define ERRM_WSTRB_STABLE         "AXI4_ERRM_WSTRB_STABLE: WSTRB must remain stable when WVALID is asserted and WREADY low. Spec: section A3.2.1."
  `define ERRM_WVALID_STABLE        "AXI4_ERRM_WVALID_STABLE: Once WVALID is asserted, it must remain asserted until WREADY is high. Spec: section A3.2.2."
  `define ERRM_WDATA_X              "AXI4_ERRM_WDATA_X: When WVALID is high, a value of X on active byte lanes of WDATA is not permitted. Spec: section A3.2.2."
  `define ERRM_WLAST_X              "AXI4_ERRM_WLAST_X: When WVALID is high, a value of X on WLAST is not permitted. Spec: section A3.2.2."
  `define ERRM_WSTRB_X              "AXI4_ERRM_WSTRB_X: When WVALID is high, a value of X on WSTRB is not permitted. Spec: section A3.2.2."
  `define ERRM_WVALID_X             "AXI4_ERRM_WVALID_X: When not in reset, a value of X on WVALID is not permitted. Spec: section A3.2.2."
  `define ERRS_WREADY_X             "AXI4_ERRS_WREADY_X: When not in reset, a value of X on WREADY is not permitted. Spec: section A3.2.2."
  `define ERRS_BRESP_WLAST          "AXI4_ERRS_BRESP_WLAST: A slave must only give a write response after the last write data item is transferred. Spec: section A3.3.1 and figure A3-7."
  `define ERRS_BRESP_ALL_DONE_EOS   "AXI4_ERRS_BRESP_ALL_DONE_EOS: All write transaction addresses must have been matched with corresponding write response."
  `define ERRS_BRESP_EXOKAY         "AXI4_ERRS_BRESP_EXOKAY: An EXOKAY write response can only be given to an exclusive write access. Spec: section A7.2."
  `define ERRS_BVALID_RESET         "AXI4_ERRS_BVALID_RESET: The earliest point after reset that a master is permitted to begin driving ARVALID, AWVALID, or WVALID HIGH is at a rising ACLK edge after ARESETn is HIGH. Spec: Figure A3-1."
  `define ERRS_BRESP_AW             "AXI4_ERRS_BRESP_AW: A slave must not give a write response before the write address. Spec: section A3.3.1 and figure A3-7."
  `define ERRS_BID_STABLE           "AXI4_ERRS_BID_STABLE: BID must remain stable when BVALID is asserted and BREADY low. Spec: section A3.2.1."
  `define ERRS_BRESP_STABLE         "AXI4_ERRS_BRESP_STABLE: BRESP must remain stable when BVALID is asserted and BREADY low. Spec: section A3.2.1."
  `define ERRS_BVALID_STABLE        "AXI4_ERRS_BVALID_STABLE: Once BVALID is asserted, it must remain asserted until BREADY is high. Spec: section A3.2.2."
  `define ERRM_BREADY_X             "AXI4_ERRM_BREADY_X: When not in reset, a value of X on BREADY is not permitted. Spec: section A3.1.2."
  `define ERRS_BID_X                "AXI4_ERRS_BID_X: When BVALID is high, a value of X on BID is not permitted. Spec: section A3.2.2."
  `define ERRS_BRESP_X              "AXI4_ERRS_BRESP_X: When BVALID is high, a value of X on BRESP is not permitted.  Spec: section A3.2.2."
  `define ERRS_BVALID_X             "AXI4_ERRS_BVALID_X: When not in reset, a value of X on BVALID is not permitted. Spec: section A3.2.2."
  `define ERRM_ARADDR_BOUNDARY      "AXI4_ERRM_ARADDR_BOUNDARY: A burst must not cross a 4kbyte boundary. Spec: section A3.4.1."
  `define ERRM_ARADDR_WRAP_ALIGN    "AXI4_ERRM_ARADDR_WRAP_ALIGN: For a wrapping burst, the start address must be aligned to the size of each transfer. Spec: section A3.4.1."
  `define ERRM_ARBURST              "AXI4_ERRM_ARBURST: When ARVALID is high, a value of 2'b11 on ARBURST is not permitted. Spec: table A3-3."
  `define ERRM_ARLEN_FIXED          "AXI4_ERRM_ARLEN_FIXED: Transactions of burst type FIXED cannot have a length greater than 16 beats. Spec: section A3.4.1."
  `define ERRM_AWLEN_FIXED          "AXI4_ERRM_AWLEN_FIXED: Transactions of burst type FIXED cannot have a length greater than 16 beats. Spec: section A3.4.1."
  `define ERRM_AWLEN_LOCK           "AXI4_ERRM_AWLEN_LOCK: Exclusive access transactions cannot have a length greater than 16 beats. Spec: section A7.2.4."
  `define ERRM_ARLEN_LOCK           "AXI4_ERRM_ARLEN_LOCK: Exclusive access transactions cannot have a length greater than 16 beats. Spec: section A7.2.4."
  `define ERRM_ARLEN_WRAP           "AXI4_ERRM_ARLEN_WRAP: For a wrapping burst, the length of the burst must be 2, 4, 8 or 16 transfers. Spec: section A3.4.1."
  `define ERRM_ARSIZE               "AXI4_ERRM_ARSIZE: The size of any transfer must not exceed the data bus width of either agent in the transaction. Spec: section A3.4.1."
  `define ERRM_ARVALID_RESET        "AXI4_ERRM_ARVALID_RESET: The earliest point after reset that a master is permitted to begin driving ARVALID, AWVALID, or WVALID HIGH is at a rising ACLK edge after ARESETn is HIGH. Spec: Figure A3-1."
  `define ERRM_ARADDR_STABLE        "AXI4_ERRM_ARADDR_STABLE: ARADDR must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARBURST_STABLE       "AXI4_ERRM_ARBURST_STABLE: ARBURST must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARCACHE_STABLE       "AXI4_ERRM_ARCACHE_STABLE: ARCACHE must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARID_STABLE          "AXI4_ERRM_ARID_STABLE: ARID must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARLEN_STABLE         "AXI4_ERRM_ARLEN_STABLE: ARLEN must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARLOCK_STABLE        "AXI4_ERRM_ARLOCK_STABLE: ARLOCK must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARPROT_STABLE        "AXI4_ERRM_ARPROT_STABLE: ARPROT must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARSIZE_STABLE        "AXI4_ERRM_ARSIZE_STABLE: ARSIZE must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARQOS_STABLE         "AXI4_ERRM_ARQOS_STABLE: ARQOS must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARREGION_STABLE      "AXI4_ERRM_ARREGION_STABLE: ARREGION must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRM_ARVALID_STABLE       "AXI4_ERRM_ARVALID_STABLE: Once ARVALID is asserted, it must remain asserted until ARREADY is high. Spec: section A3.2.1."
  `define ERRM_ARADDR_X             "AXI4_ERRM_ARADDR_X: When ARVALID is high, a value of X on ARADDR is not permitted. Spec: section A3.2.2."
  `define ERRM_ARBURST_X            "AXI4_ERRM_ARBURST_X: When ARVALID is high, a value of X on ARBURST is not permitted. Spec: section A3.2.2."
  `define ERRM_ARCACHE_X            "AXI4_ERRM_ARCACHE_X: When ARVALID is high, a value of X on ARCACHE is not permitted. Spec: section A3.2.2."
  `define ERRM_ARID_X               "AXI4_ERRM_ARID_X: When ARVALID is high, a value of X on ARID is not permitted. Spec: section A3.2.2."
  `define ERRM_ARLEN_X              "AXI4_ERRM_ARLEN_X: When ARVALID is high, a value of X on ARLEN is not permitted. Spec: section A3.2.2."
  `define ERRM_ARLOCK_X             "AXI4_ERRM_ARLOCK_X: When ARVALID is high, a value of X on ARLOCK is not permitted. Spec: section A3.2.2."
  `define ERRM_ARPROT_X             "AXI4_ERRM_ARPROT_X: When ARVALID is high, a value of X on ARPROT is not permitted. Spec: section A3.2.2."
  `define ERRM_ARSIZE_X             "AXI4_ERRM_ARSIZE_X: When ARVALID is high, a value of X on ARSIZE is not permitted. Spec: section A3.2.2."
  `define ERRM_ARQOS_X              "AXI4_ERRM_ARQOS_X: When ARVALID is high, a value of X on ARQOS is not permitted. Spec: section A3.2.2."
  `define ERRM_ARREGION_X           "AXI4_ERRM_ARREGION_X: When ARVALID is high, a value of X on ARREGION is not permitted. Spec: section A3.2.2."
  `define ERRM_ARVALID_X            "AXI4_ERRM_ARVALID_X: When not in reset, a value of X on ARVALID is not permitted. Spec: section A3.1.2."
  `define ERRS_ARREADY_X            "AXI4_ERRS_ARREADY_X: When not in reset, a value of X on ARREADY is not permitted. Spec: section A3.1.2."
  `define ERRS_RDATA_NUM            "AXI4_ERRS_RDATA_NUM: The number of read data items must match the corresponding ARLEN. Spec: section A3.4.1."
  `define ERRS_RLAST_ALL_DONE_EOS   "AXI4_ERRS_RLAST_ALL_DONE_EOS: All outstanding read bursts must have completed a the end of the simulation."
  `define ERRS_RID                  "AXI4_ERRS_RID: A slave can only give read data with an ID to match an outstanding read transaction. Spec: section A5.3.1."
  `define ERRS_RRESP_EXOKAY         "AXI4_ERRS_RRESP_EXOKAY: An EXOKAY read response can only be given to an exclusive read access. Spec: section A7.2.3."
  `define ERRS_RVALID_RESET         "AXI4_ERRS_RVALID_RESET: The earliest point after reset that a master is permitted to begin driving ARVALID, AWVALID, or WVALID HIGH is at a rising ACLK edge after ARESETn is HIGH. Spec: Figure A3-1."
  `define ERRS_RDATA_STABLE         "AXI4_ERRS_RDATA_STABLE: RDATA must remain stable when RVALID is asserted and RREADY low. Spec: section A3.2.1."
  `define ERRS_RID_STABLE           "AXI4_ERRS_RID_STABLE: RID must remain stable when RVALID is asserted and RREADY low. Spec: section A3.2.1."
  `define ERRS_RLAST_STABLE         "AXI4_ERRS_RLAST_STABLE: RLAST must remain stable when RVALID is asserted and RREADY low. Spec: section A3.2.1."
  `define ERRS_RRESP_STABLE         "AXI4_ERRS_RRESP_STABLE: RRESP must remain stable when RVALID is asserted and RREADY low. Spec: section A3.2.1."
  `define ERRS_RVALID_STABLE        "AXI4_ERRS_RVALID_STABLE: Once RVALID is asserted, it must remain asserted until RREADY is high. Spec: section A3.2.1."
  `define ERRS_RDATA_X              "AXI4_ERRS_RDATA_X: When RVALID is high, a value of X on RDATA valid byte lanes is not permitted. Spec: section A3.2.2."
  `define ERRM_RREADY_X             "AXI4_ERRM_RREADY_X: When not in reset, a value of X on RREADY is not permitted. Spec: section A3.1.2."
  `define ERRS_RID_X                "AXI4_ERRS_RID_X: When RVALID is high, a value of X on RID is not permitted. Spec: section A3.2.2."
  `define ERRS_RLAST_X              "AXI4_ERRS_RLAST_X: When RVALID is high, a value of X on RLAST is not permitted. Spec: section A3.2.2."
  `define ERRS_RRESP_X              "AXI4_ERRS_RRESP_X: When RVALID is high, a value of X on RRESP is not permitted. Spec: section A3.2.2."
  `define ERRS_RVALID_X             "AXI4_ERRS_RVALID_X: When not in reset, a value of X on RVALID is not permitted. Spec: section A3.1.2."
  `define ERRL_CSYSACK_FALL         "AXI4_ERRL_CSYSACK_FALL: When CSYSACK transitions from high to low, CSYSREQ must be low. Spec: figure A9-1."
  `define ERRL_CSYSACK_RISE         "AXI4_ERRL_CSYSACK_RISE: When CSYSACK transitions from low to high, CSYSREQ must be high. Spec: figure A9-1."
  `define ERRL_CSYSREQ_FALL         "AXI4_ERRL_CSYSREQ_FALL: When CSYSREQ transitions from high to low, CSYSACK must be high. Spec: figure A9-1."
  `define ERRL_CSYSREQ_RISE         "AXI4_ERRL_CSYSREQ_RISE: When CSYSREQ transitions from low to high, CSYSACK must be low. Spec: figure A9-1."
  `define ERRL_CACTIVE_X            "AXI4_ERRL_CACTIVE_X: When not in reset, a value of X on CACTIVE is not permitted. Spec: section A9.2."
  `define ERRL_CSYSACK_X            "AXI4_ERRL_CSYSACK_X: When not in reset, a value of X on CSYSACK is not permitted. Spec: section A9.2."
  `define ERRL_CSYSREQ_X            "AXI4_ERRL_CSYSREQ_X: When not in reset, a value of X on CSYSREQ is not permitted. Spec: section A9.2."
  `define ERRM_EXCL_ALIGN           "AXI4_ERRM_EXCL_ALIGN: The address of an exclusive access must be aligned to the total number of bytes in the transaction. Spec: section A7.2.4."
  `define ERRM_EXCL_LEN             "AXI4_ERRM_EXCL_LEN: The number of bytes to be transferred in an exclusive access burst must be a power of 2. Spec: section A7.2.4."
  `define ERRM_EXCL_MAX             "AXI4_ERRM_EXCL_MAX: The maximum number of bytes that can be transferred in an exclusive burst is 128. Spec: section A7.2.4."
  `define ERRM_AWUSER_STABLE        "AXI4_ERRM_AWUSER_STABLE: AWUSER must remain stable when AWVALID is asserted and AWREADY low. Spec: section A3.2.1."
  `define ERRM_WUSER_STABLE         "AXI4_ERRM_WUSER_STABLE: WUSER must remain stable when WVALID is asserted and WREADY low. Spec: section A3.2.1."
  `define ERRS_BUSER_STABLE         "AXI4_ERRS_BUSER_STABLE: BUSER must remain stable when BVALID is asserted and BREADY low. Spec: section A3.2.1."
  `define ERRM_ARUSER_STABLE        "AXI4_ERRM_ARUSER_STABLE: ARUSER must remain stable when ARVALID is asserted and ARREADY low. Spec: section A3.2.1."
  `define ERRS_RUSER_STABLE         "AXI4_ERRS_RUSER_STABLE: RUSER must remain stable when RVALID is asserted and RREADY low. Spec: section A3.2.1."
  `define ERRM_AWUSER_X             "AXI4_ERRM_AWUSER_X: When AWVALID is high, a value of X on AWUSER is not permitted. Spec: section A3.2.2."
  `define ERRM_WUSER_X              "AXI4_ERRM_WUSER_X: When WVALID is high, a value of X on WUSER is not permitted. Spec: section A3.2.2."
  `define ERRS_BUSER_X              "AXI4_ERRS_BUSER_X: When BVALID is high, a value of X on BUSER is not permitted. Spec: section A3.2.2."
  `define ERRM_ARUSER_X             "AXI4_ERRM_ARUSER_X: When ARVALID is high, a value of X on ARUSER is not permitted. Spec: section A3.2.2."
  `define ERRS_RUSER_X              "AXI4_ERRS_RUSER_X: When RVALID is high, a value of X on RUSER is not permitted.  Spec: section A3.2.2."
  `define ERRM_AWUSER_TIEOFF        "AXI4_ERRM_AWUSER_TIEOFF: AWUSER must be stable when AWUSER_WIDTH is set to 0." 
  `define ERRM_WUSER_TIEOFF         "AXI4_ERRM_WUSER_TIEOFF: WUSER must be stable when WUSER_WIDTH is set to 0." 
  `define ERRS_BUSER_TIEOFF         "AXI4_ERRS_BUSER_TIEOFF: BUSER must be stable when BUSER_WIDTH is set to 0." 
  `define ERRM_ARUSER_TIEOFF        "AXI4_ERRM_ARUSER_TIEOFF: ARUSER must be stable when ARUSER_WIDTH is set to 0." 
  `define ERRS_RUSER_TIEOFF         "AXI4_ERRS_RUSER_TIEOFF: RUSER must be stable when RUSER_WIDTH is set to 0." 
  `define ERRM_AWID_TIEOFF          "AXI4_ERRM_AWID_TIEOFF: AWID must be stable when ID_WIDTH is set to 0." 
  `define ERRS_BID_TIEOFF           "AXI4_ERRS_BID_TIEOFF: BID must be stable when ID_WIDTH is set to 0." 
  `define ERRM_ARID_TIEOFF          "AXI4_ERRM_ARID_TIEOFF: ARID must be stable when ID_WIDTH is set to 0." 
  `define ERRS_RID_TIEOFF           "AXI4_ERRS_RID_TIEOFF: RID must be stable when ID_WIDTH is set to 0." 
  `define AUX_DATA_WIDTH            "AXI4_AUX_DATA_WIDTH: Parameter DATA_WIDTH must be 32, 64, 128, 256, 512 or 1024."
  `define AUX_ADDR_WIDTH            "AXI4_AUX_ADDR_WIDTH: Parameter ADDR_WIDTH must be between 32 and 64 bits inclusive."
  `define AUX_EXMON_WIDTH           "AXI4_AUX_EXMON_WIDTH: Parameter EXMON_WIDTH must be greater than or equal to 1."
  `define AUX_MAXRBURSTS            "AXI4_AUX_MAXRBURSTS: Parameter MAXRBURSTS must be greater than or equal to 1."
  `define AUX_MAXWBURSTS            "AXI4_AUX_MAXWBURSTS: Parameter MAXWBURSTS must be greater than or equal to 1."
  `define AUX_RCAM_OVERFLOW         "AXI4_AUX_RCAM_OVERFLOW: Read CAM overflow. There are too many outstanding read transactiions. Increase MAXRBURSTS parameter."
  `define AUX_RCAM_UNDERFLOW        "AXI4_AUX_RCAM_UNDERFLOW: Read CAM underflow."
  `define AUX_WCAM_OVERFLOW         "AXI4_AUX_WCAM_OVERFLOW: Write CAM overflow. There are too many outstanding write transactiions. Increase MAXWBURSTS parameter."
  `define AUX_WCAM_UNDERFLOW        "AXI4_AUX_WCAM_UNDERFLOW: Write CAM underflow"
  `define AUX_EXCL_OVERFLOW         "AXI4_AUX_EXCL_OVERFLOW: Exclusive access monitor overflow, increase EXMON_WIDTH parameter."
  `define RECM_EXCL_PAIR            "AXI4_RECM_EXCL_PAIR: An exclusive write should have an earlier outstanding completed exclusive read with the same ID. Spec: section A7.2.2."
  `define RECM_EXCL_R_W             "AXI4_RECM_EXCL_R_W: Exclusive reads and writes with the same ID should not be issued at the same time. Spec: section A7.2.2."
  `define RECS_AWREADY_MAX_WAIT     "AXI4_RECS_AWREADY_MAX_WAIT: AWREADY should be asserted within MAXWAITS cycles of AWVALID being asserted."
  `define RECS_WREADY_MAX_WAIT      "AXI4_RECS_WREADY_MAX_WAIT: WREADY should be asserted within MAXWAITS cycles of WVALID being asserted."
  `define RECM_BREADY_MAX_WAIT      "AXI4_RECM_BREADY_MAX_WAIT: BREADY should be asserted within MAXWAITS cycles of BVALID being asserted."
  `define RECS_ARREADY_MAX_WAIT     "AXI4_RECS_ARREADY_MAX_WAIT: ARREADY should be asserted within MAXWAITS cycles of ARVALID being asserted."
  `define RECM_RREADY_MAX_WAIT      "AXI4_RECM_RREADY_MAX_WAIT: RREADY should be asserted within MAXWAITS cycles of RVALID being asserted."
  `define RECS_WLAST_TO_AWVALID_MAX_WAIT        "XILINX_RECS_WLAST_TO_AWVALID_MAX_WAIT: AWVALID should be asserted within MAXWAITS cycles of WLAST being accepted."
  `define RECS_CONTINUOUS_RTRANSFERS_MAX_WAIT   "XILINX_RECS_CONTINUOUS_RTRANSFERS_MAX_WAIT: RVALID should be asserted within MAXWAITS cycles of AR Command being accepted."
  `define RECS_CONTINUOUS_WTRANSFERS_MAX_WAIT   "XILINX_RECS_CONTINUOUS_WTRANSFERS_MAX_WAIT: WVALID should be asserted within MAXWAITS cycles of a previous W being accepted when there are outstanding AW Commands."
  `define RECS_WLCMD_TO_BVALID_MAX_WAIT         "XILINX_RECS_WLCMD_TO_BVALID_MAX_WAIT: BVALID should be asserted within MAXWAITS cycles when there are outstanding AW Commands and WLast's finished."
  `define RECM_EXCL_MATCH           "AXI4_RECM_EXCL_MATCH: The address payload of an exclusive write should be the same as the preceding exclusive read with the same ID. Spec: section A7.2.4."
  `ifndef AXI4LITEPC_MESSAGES
    `define AXI4LITEPC_MESSAGES
    `define ERRS_AXI4LITE_BRESP_EXOKAY   "AXI4LITE_ERRS_BRESP_EXOKAY: A slave must not give an EXOKAY response on an Axi4Lite interface. Spec: section B1.1.1."
    `define ERRS_AXI4LITE_RRESP_EXOKAY   "AXI4LITE_ERRS_RRESP_EXOKAY: A slave must not give an EXOKAY response on an Axi4Lite interface. Spec: section B1.1.1."
    `define AUX_AXI4LITE_DATA_WIDTH      "AXI4LITE_AUX_DATA_WIDTH: Parameter DATA_WIDTH must be either 32 or 64."
  `endif
`endif

// --========================= End ===========================================--

`define ARM_AMBA4_PC_MSG_ERR(msg) arm_amba4_pc_msg_err(msg)

`ifndef ARM_AMBA4_PC_MSG_WARN
  `define ARM_AMBA4_PC_MSG_WARN $warning
`endif

//------------------------------------------------------------------------------
// INDEX: Module: axi_vip_v1_0_1_axi4pc
//------------------------------------------------------------------------------

`ifndef axi_vip_v1_0_1_AXI4PC
  `define axi_vip_v1_0_1_AXI4PC

interface axi_vip_v1_0_1_axi4pc 
  #(int WADDR_WIDTH=32, 
        RADDR_WIDTH=32, 
        WDATA_WIDTH=64, 
        RDATA_WIDTH=64, 
        PROTOCOL = 0,
        RID_WIDTH = 4,
        WID_WIDTH = 4,
        AWUSER_WIDTH=0, 
        WUSER_WIDTH=0, 
        BUSER_WIDTH=0, 
        ARUSER_WIDTH=0,
        RUSER_WIDTH=0,
        MAXRBURSTS=16,
        MAXWBURSTS=16,
        MAXWAITS=64,
        MAXSTALLWAITS=1024,
        RecommendOn=1,
        RecMaxWaitOn=0,
        HAS_ARESETN=1
  ) (
  input bit                               ACLK, 
  input bit                               ACLKEN,
  input bit                               ARESETn,
  input logic [(WADDR_WIDTH-1):0]         AWADDR,
  input tri1  [((WID_WIDTH==0) ? 1:WID_WIDTH)-1:0]      AWID,
  input logic [7:0]                       AWLEN,
  input logic [2:0]                       AWSIZE,
  input logic [1:0]                       AWBURST,
  input logic                             AWLOCK,
  input logic [3:0]                       AWCACHE,
  input logic [2:0]                       AWPROT,
  input logic                             AWVALID,
  input logic                             AWREADY,
  input tri1  [((AWUSER_WIDTH==0) ? 1 : AWUSER_WIDTH)-1:0]  AWUSER,
  input logic [3:0]                       AWREGION,
  input logic [3:0]                       AWQOS,

  // write data channel
  input logic                             WLAST,
  input logic [(WDATA_WIDTH-1):0]         WDATA,
  input logic [(WDATA_WIDTH/8)-1:0]       WSTRB,
  input logic                             WVALID,
  input logic                             WREADY,
  input tri1  [((WUSER_WIDTH==0) ? 1 : WUSER_WIDTH)-1:0]    WUSER,

  // write response channel
  input logic [1:0]                       BRESP,
  input tri1  [((WID_WIDTH==0) ? 1:WID_WIDTH)-1:0]      BID,
  input logic                             BVALID,
  input logic                             BREADY,
  input tri1  [((BUSER_WIDTH==0) ? 1 : BUSER_WIDTH)-1:0]    BUSER,

  // read address channel
  input logic [(RADDR_WIDTH-1):0]         ARADDR,
  input tri1  [((RID_WIDTH==0) ? 1:RID_WIDTH)-1:0]      ARID,
  input logic [7:0]                       ARLEN,
  input logic [2:0]                       ARSIZE,
  input logic [1:0]                       ARBURST,
  input logic                             ARLOCK,
  input logic [3:0]                       ARCACHE,
  input logic [2:0]                       ARPROT,
  input logic                             ARVALID,
  input logic                             ARREADY,
  input tri1  [((ARUSER_WIDTH==0) ? 1 : ARUSER_WIDTH)-1:0]  ARUSER,
  input logic [3:0]                       ARREGION,
  input logic [3:0]                       ARQOS,

  // read data  channel
  input tri1  [((RID_WIDTH==0) ? 1:RID_WIDTH)-1:0]      RID,
  input logic                             RLAST,
  input logic [(RDATA_WIDTH-1):0]         RDATA,
  input logic [1:0]                       RRESP,
  input logic                             RVALID,
  input logic                             RREADY,
  input tri1  [((RUSER_WIDTH==0) ? 1 : RUSER_WIDTH)-1:0]    RUSER,
  input tri1                              CACTIVE,
  input tri1                              CSYSREQ,
  input tri1                              CSYSACK

  );

//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------

  // INDEX:        - Configurable (user can set)
  // =====
  // Parameters below can be set by the user.

  // Set DATA_WIDTH to the data-bus width required
//  parameter DATA_WIDTH = 64;         // data bus width, default = 64-bit
//
//  // Select the number of channel ID bits required
//  parameter ID_WIDTH = 4;            // (A|W|R|B)ID width
//
//  // Select the size of the USER buses, default = 32-bit
//  parameter AWUSER_WIDTH = 32;       // width of the user AW sideband field
//  parameter WUSER_WIDTH  = 32;       // width of the user W  sideband field
//  parameter BUSER_WIDTH  = 32;       // width of the user B  sideband field
//  parameter ARUSER_WIDTH = 32;       // width of the user AR sideband field
//  parameter RUSER_WIDTH  = 32;       // width of the user R  sideband field
//
//  // Size of CAMs for storing outstanding read bursts, this should match or
//  // exceed the number of outstanding read addresses accepted into the slave
//  // interface
//  parameter MAXRBURSTS = 16;
//
//  // Size of CAMs for storing outstanding write bursts, this should match or
//  // exceed the number of outstanding write bursts into the slave  interface
//  parameter MAXWBURSTS = 16;

  // Maximum number of cycles between VALID -> READY high before a warning is
  // generated
//  parameter MAXWAITS = 16;

  // Recommended Rules Enable
  // enable/disable reporting of all  AXI4_REC*_* rules
//  parameter RecommendOn   = 1'b1;   
  // enable/disable reporting of just AXI4_REC*_MAX_WAIT rules
//  parameter RecMaxWaitOn  = 1'b0;   

  // enable/disable coverage collection
  parameter CoverageOn  = 1'b0;
  // set the instance name for the coverage collection
  parameter string CoverageInstanceName  = "axi_vip_v1_0_1_axi4pc_1";

  // Set ADDR_WIDTH to the address-bus width required
//  parameter ADDR_WIDTH = 32;        // address bus width, default = 32-bit

  // Set EXMON_WIDTH to the exclusive access monitor width required
  parameter EXMON_WIDTH = 4;        // exclusive access width, default = 4-bit

  // INDEX:        - Calculated (user should not override)
  // =====
  // Do not override the following parameters: they must be calculated exactly
  // as shown below
  localparam RDATA_MAX  = RDATA_WIDTH-1;              // data max index
  localparam WDATA_MAX  = WDATA_WIDTH-1;              // data max index
  localparam WADDR_MAX  = WADDR_WIDTH-1;              // address max index
  localparam RADDR_MAX  = RADDR_WIDTH-1;              // address max index
  localparam ADDR_MAX   = WADDR_MAX > RADDR_MAX ? WADDR_MAX : RADDR_MAX;
  localparam STRB_WIDTH = WDATA_WIDTH/8;              // WSTRB width
  localparam STRB_MAX   = STRB_WIDTH-1;              // WSTRB max index
  localparam STRB_1     = {{STRB_MAX{1'b0}}, 1'b1};  // value 1 in strobe width
  localparam ID_MAX_R   = RID_WIDTH? RID_WIDTH-1:0;    // ID max index
  localparam ID_MAX_W   = WID_WIDTH? WID_WIDTH-1:0;    // ID max index
  localparam ID_MAX     = ID_MAX_W > ID_MAX_R ? ID_MAX_W : ID_MAX_R;    // ID max index
  localparam EXMON_MAX  = EXMON_WIDTH-1;             // EXMON max index
  localparam EXMON_HI   = {EXMON_WIDTH{1'b1}};       // EXMON max value

  localparam AWUSER_MAX = AWUSER_WIDTH ? AWUSER_WIDTH-1:0; // AWUSER max index
  localparam WUSER_MAX  = WUSER_WIDTH ? WUSER_WIDTH-1:0;   // WUSER  max index
  localparam BUSER_MAX  = BUSER_WIDTH ? BUSER_WIDTH-1:0;   // BUSER  max index
  localparam ARUSER_MAX = ARUSER_WIDTH ? ARUSER_WIDTH-1:0; // ARUSER max index
  localparam RUSER_MAX  = RUSER_WIDTH ? RUSER_WIDTH-1:0;   // RUSER  max index

  typedef struct packed {
    bit [7-1:0]     addr;
    bit             excl;
    bit [8-1:0]     len ;
    bit [3-1:0]     size;
    bit [2-1:0]     burst;
    bit [ID_MAX:0]  id;
  } t_cmd_message;

  localparam LOG2MAXRBURSTS  = clogb2(MAXRBURSTS);
  localparam LOG2MAXWBURSTS  = clogb2(MAXWBURSTS);

  typedef struct packed {
    t_cmd_message       cmd;
    bit [(STRB_WIDTH*256)-1:0]  strb;
  } t_wburst_message;

  logic reset_first_asserted = (HAS_ARESETN == 0) ? 1 : 0;
  logic fatal_to_warnings = 0;

  function void arm_amba4_pc_msg_err(
    input string msg
  );
    if (fatal_to_warnings == 1) begin
      $warning(msg);
    end else if (reset_first_asserted == 1) begin
      $fatal(1,msg);
    end else begin
      $error($sformatf("Pre-reset violation: %s", msg));
    end
  endfunction : arm_amba4_pc_msg_err

  integer unsigned max_aw_wait_cycles                 = MAXWAITS;
  integer unsigned max_ar_wait_cycles                 = MAXWAITS;
  integer unsigned max_r_wait_cycles                  = MAXWAITS;
  integer unsigned max_b_wait_cycles                  = MAXWAITS;
  integer unsigned max_w_wait_cycles                  = MAXWAITS;
  integer unsigned max_wlast_to_awvalid_wait_cycles   = MAXSTALLWAITS;
  integer unsigned max_rtransfers_wait_cycles         = MAXSTALLWAITS;
  integer unsigned max_wtransfers_wait_cycles         = MAXSTALLWAITS;
  integer unsigned max_wlcmd_wait_cycles              = MAXSTALLWAITS;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Functions to set conditions for wait cycles
function void set_max_wait_cycles(input integer unsigned new_num);
  max_aw_wait_cycles = new_num;
  max_ar_wait_cycles = new_num;
  max_r_wait_cycles = new_num;
  max_b_wait_cycles = new_num;
  max_w_wait_cycles = new_num;
endfunction : set_max_wait_cycles

function void set_max_aw_wait_cycles(input integer unsigned new_num);
  max_aw_wait_cycles = new_num;
endfunction : set_max_aw_wait_cycles

function void set_max_ar_wait_cycles(input integer unsigned new_num);
  max_ar_wait_cycles = new_num;
endfunction : set_max_ar_wait_cycles

function void set_max_r_wait_cycles(input integer unsigned new_num);
  max_r_wait_cycles = new_num;
endfunction : set_max_r_wait_cycles

function void set_max_b_wait_cycles(input integer unsigned new_num);
  max_b_wait_cycles = new_num;
endfunction : set_max_b_wait_cycles

function void set_max_w_wait_cycles(input integer unsigned new_num);
  max_w_wait_cycles = new_num;
endfunction : set_max_w_wait_cycles

function void set_max_wlast_wait_cycles(input integer unsigned new_num);
  max_wlast_to_awvalid_wait_cycles = new_num;
endfunction : set_max_wlast_wait_cycles

function void set_max_rtransfers_wait_cycles(input integer unsigned new_num);
  max_rtransfers_wait_cycles = new_num;
endfunction : set_max_rtransfers_wait_cycles

function void set_max_wtransfers_wait_cycles(input integer unsigned new_num);
  max_wtransfers_wait_cycles = new_num;
endfunction : set_max_wtransfers_wait_cycles

function void set_max_wlcmd_wait_cycles(input integer unsigned new_num);
  max_wlcmd_wait_cycles = new_num;
endfunction : set_max_wlcmd_wait_cycles

function integer unsigned get_max_wait_cycles();
  return(max_aw_wait_cycles);
endfunction : get_max_wait_cycles

function integer unsigned get_max_aw_wait_cycles();
  return(max_aw_wait_cycles);
endfunction : get_max_aw_wait_cycles

function integer unsigned get_max_ar_wait_cycles();
  return(max_ar_wait_cycles);
endfunction : get_max_ar_wait_cycles

function integer unsigned get_max_r_wait_cycles();
  return(max_r_wait_cycles);
endfunction : get_max_r_wait_cycles

function integer unsigned get_max_b_wait_cycles();
  return(max_b_wait_cycles);
endfunction : get_max_b_wait_cycles

function integer unsigned get_max_w_wait_cycles();
  return(max_w_wait_cycles);
endfunction :get_max_w_wait_cycles

function integer unsigned get_max_wlast_wait_cycles();
  return(max_wlast_to_awvalid_wait_cycles);
endfunction :get_max_wlast_wait_cycles

function integer unsigned get_max_rtransfers_wait_cycles();
  return(max_rtransfers_wait_cycles);
endfunction :get_max_rtransfers_wait_cycles

function integer unsigned get_max_wtransfers_wait_cycles();
  return(max_wtransfers_wait_cycles);
endfunction :get_max_wtransfers_wait_cycles

function integer unsigned get_max_wlcmd_wait_cycles();
  return(max_wlcmd_wait_cycles);
endfunction :get_max_wlcmd_wait_cycles

function void set_fatal_to_warnings();
  fatal_to_warnings = 1;
endfunction : set_fatal_to_warnings

function void clr_fatal_to_warnings();
  fatal_to_warnings = 0;
endfunction : clr_fatal_to_warnings

////------------------------------------------------------------------------------
//// INDEX:   2) Inputs (no outputs)
////------------------------------------------------------------------------------
//
//  // INDEX:        - Global Signals
//  // =====
//  input                ACLK;        // AXI Clock
//  input                ARESETn;     // AXI Reset
//
//  // INDEX:        - Write Address Channel
//  // =====
//  input     [ID_MAX:0] AWID;
//  input   [ADDR_MAX:0] AWADDR;
//  input          [7:0] AWLEN;
//  input          [2:0] AWSIZE;
//  input          [1:0] AWBURST;
//  input          [3:0] AWCACHE;
//  input          [2:0] AWPROT;
//  input          [3:0] AWQOS;
//  input          [3:0] AWREGION;
//  input                AWLOCK;
//  input [AWUSER_MAX:0] AWUSER;
//  input                AWVALID;
//  input                AWREADY;
//
//  // INDEX:        - Write Data Channel
//  // =====
//  input   [DATA_MAX:0] WDATA;
//  input   [STRB_MAX:0] WSTRB;
//  input  [WUSER_MAX:0] WUSER;
//  input                WLAST;
//  input                WVALID;
//  input                WREADY;
//
//  // INDEX:        - Write Response Channel
//  // =====
//  input     [ID_MAX:0] BID;
//  input          [1:0] BRESP;
//  input  [BUSER_MAX:0] BUSER;
//  input                BVALID;
//  input                BREADY;
//
//  // INDEX:        - Read Address Channel
//  // =====
//  input     [ID_MAX:0] ARID;
//  input   [ADDR_MAX:0] ARADDR;
//  input          [7:0] ARLEN;
//  input          [2:0] ARSIZE;
//  input          [1:0] ARBURST;
//  input          [3:0] ARCACHE;
//  input          [3:0] ARQOS;
//  input          [3:0] ARREGION;
//  input          [2:0] ARPROT;
//  input                ARLOCK;
//  input [ARUSER_MAX:0] ARUSER;
//  input                ARVALID;
//  input                ARREADY;
//
//  // INDEX:        - Read Data Channel
//  // =====
//  input     [ID_MAX:0] RID;
//  input   [DATA_MAX:0] RDATA;
//  input          [1:0] RRESP;
//  input  [RUSER_MAX:0] RUSER;
//  input                RLAST;
//  input                RVALID;
//  input                RREADY;
//
//  // INDEX:        - Low Power Interface
//  // =====
//  input                CACTIVE;
//  input                CSYSREQ;
//  input                CSYSACK;


//------------------------------------------------------------------------------
// INDEX:   3) Wire and Reg Declarations
//------------------------------------------------------------------------------

  // Write CAMs
  integer unsigned WIndex = 1;

  typedef struct {
    t_wburst_message    xfer;
    bit          [8:0] WCount;  // number of write data stored
    bit                WLast;   // WLAST handshake for 
                                                 // outstanding writes
    bit                WAddr;   // flag for write addr hsk
    bit                BResp;   // flag for write resp hsk 
  } t_wburst_xfer;
  
  t_wburst_xfer   WCam[1:MAXWBURSTS];

  // Read CAMs
  typedef struct packed {
    t_cmd_message       cmd;
    bit          [8:0]  Count;
  } t_rburst_xfer;
  
  t_rburst_xfer RCam[0:MAXRBURSTS];


  integer unsigned   RIndex = 1;
  integer unsigned   RIndexNext = 1;
  wire               RPop;
  wire               RPush;
  wire               nROutstanding;  // flag for an empty cmd
  reg                RIdCamDelta;    // flag indicates that RidCam has changed

  // Protocol error flags
  reg                AWDataNumError1;   // flag to derive WriteDataNumError
  reg                AWDataNumError2;   // flag to derive WriteDataNumError
  reg                AWDataNumError3;   // flag to derive WriteDataNumError
  reg                WDataNumError1;    // flag to derive WriteDataNumError
  reg                WDataNumError2;    // flag to derive WriteDataNumError

  // signals for checking for match in ID CAMs
  integer unsigned   AIDMatch = 1;
  integer unsigned   AIDMatch_next;
  integer unsigned   WIDMatch = 1;
  integer unsigned   WIDMatch_next;
  integer unsigned   RidMatch;
  integer unsigned   BIDMatch;

  reg          [6:0] AlignMaskR; // mask for checking read address alignment
  reg          [6:0] AlignMaskW; // mask for checking write address alignment

  // signals for Address Checking
  reg   [RADDR_MAX:0] ArAddrIncr;
  reg   [WADDR_MAX:0] AwAddrIncr;

  // signals for Data Checking
  wire  [RDATA_MAX:0] RdataMask;
  reg   [WDATA_MAX:0] WdataMask;
  reg         [10:0] ArSizeInBits;
  reg         [10:0] AwSizeInBits;
  reg         [15:0] ArLenInBytes;
  wire         [8:0] ArLenPending;
  wire         [8:0] ArCountPending;
  wire               ArExclPending;

  // arrays to store exclusive access control info
  reg     [ID_MAX:0] ExclId[EXMON_HI:0];
  reg                ExclIdDelta = 1'b0;
  reg   [EXMON_HI:0] ExclIdValid = 'b0;
  wire               ExclIdFull;
  wire               ExclIdOverflow;
  reg  [EXMON_MAX:0] ExclIdFreePtr;
  wire [EXMON_MAX:0] ExclIdWrPtr;
  reg  [EXMON_MAX:0] ExclAwId;
  reg                ExclAwMatch;
  reg  [EXMON_MAX:0] ExclArId;
  reg                ExclArMatch;
  reg  [EXMON_MAX:0] ExclRId;
  reg                ExclRMatch;
  
  typedef struct packed {
    bit                ReadAddr; // tracks excl read addr
    bit                ReadData; // tracks excl read data
    bit   [ADDR_MAX:0] Addr;
    bit          [2:0] Size;
    bit          [7:0] Len;
    bit          [1:0] Burst;
    bit          [3:0] Cache;
    bit          [2:0] Prot;
    bit          [3:0] Qos;
    bit          [3:0] Region;
    bit [AWUSER_MAX:0] User;
  } t_exclsive_xfer;
  
  t_exclsive_xfer     excl_pipe [EXMON_HI:0];
  
  reg         [14:0] ExclMask;   // mask to check alignment of exclusive address

  // Signals to avoid feeding parameters directly into assertions as this can
  // stop assertions triggering in some cases
  reg                i_RecommendOn;
  reg                i_RecMaxWaitOn;

  initial begin
    for (int i = 0; i <= EXMON_HI; i = i + 1) begin
      ExclId[i] = {ID_MAX+1{1'b0}};
      excl_pipe[i] = '0;
    end
    for (int i=0; i<=MAXRBURSTS; i++) begin
      RCam[i].cmd = '0;
      RCam[i].Count = 9'h0;
      RIdCamDelta  = 1'b0;
    end //for (i=1; i<=MAXBURSTS; i++)
    for (int i=1; i<=MAXWBURSTS; i++) begin
      WCam[i].WCount = '0;
      WCam[i].WLast = '0;
      WCam[i].WAddr = '0;
      WCam[i].BResp = '0;
      WCam[i].xfer = '0;
    end
  end

  reg AwPop;

//------------------------------------------------------------------------------
// INDEX:   4) Verilog Defines
//------------------------------------------------------------------------------

  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  //
  // Can also be used to clock SVA on negedge (to avoid race hazards with
  // auxiliary logic) by compiling with the override:
  //
  // +define+AXI4_SVA_CLK=~ACLK
  // 
  // SVA: Assertions
  `ifdef AXI4_SVA_CLK
  `else
     `define AXI4_SVA_CLK ACLK
  `endif
  
  `ifdef AXI4_SVA_RSTn
  `else
     `define AXI4_SVA_RSTn ARESETn
  `endif
  
  // AUX: Auxiliary Logic
  `ifdef AXI4_AUX_CLK
  `else
     `define AXI4_AUX_CLK ACLK
  `endif
  
  `ifdef AXI4_AUX_RSTn
  `else
     `define AXI4_AUX_RSTn ARESETn
  `endif

//------------------------------------------------------------------------------
// INDEX:   5) Initialize simulation
//------------------------------------------------------------------------------

  initial
  begin
    // INDEX:        - Format for time reporting
    // =====
    // Format for time reporting
    $timeformat(-9, 0, " ns", 0);

    // INDEX:        - Indicate version and release state of axi_vip_v1_0_1_axi4pc
    // =====
    //$display("AXI4_INFO: Running axi_vip_v1_0_1_axi4pc $State");


    // INDEX:        - Warn if any/some recommended rules are disabled
    // =====
//    if (~RecommendOn)
      // All AXI4_REC*_* rules disabled
      //$display("AXI4_WARN: All recommended AXI rules have been disabled by the RecommendOn parameter");
//    else if (~RecMaxWaitOn)
      // Just AXI4_REC*_MAX_WAIT rules disabled
      //$display("AXI4_WARN: Five recommended MAX_WAIT rules have been disabled by the RecMaxWaitOn parameter");

    if (RecommendOn)
      i_RecommendOn = 1'b1;
    else
      i_RecommendOn = 1'b0;
    if (RecMaxWaitOn)
      i_RecMaxWaitOn = 1'b1;
    else
      i_RecMaxWaitOn = 1'b0;
    ////////////////////////////////////////////////////////////////////////////////////////
    //Detect the initial assertion of reset
    #1ps;
    @(posedge ARESETn);
    reset_first_asserted = 1;
  end

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4LITE Rules: Read Data Channel (*_R*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4LITE_ERRS_BRESP_EXOKAY
  // =====
  property AXI4LITE_ERRS_BRESP_EXOKAY;
    @(posedge `AXI4_SVA_CLK) disable iff (PROTOCOL != `AXI4PC_AMBA_AXI4LITE)
        !($isunknown({BVALID,BRESP})) &
        BVALID
        |-> BRESP != `AXI4PC_RESP_EXOKAY;
  endproperty
  axi4lite_errs_bresp_exokay: assert property (AXI4LITE_ERRS_BRESP_EXOKAY) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_AXI4LITE_BRESP_EXOKAY);


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4LITE Rules: Write Response Channel (*_B*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4LITE_ERRS_RRESP_EXOKAY
  // =====
  property AXI4LITE_ERRS_RRESP_EXOKAY;
    @(posedge `AXI4_SVA_CLK) disable iff (PROTOCOL != `AXI4PC_AMBA_AXI4LITE)
        !($isunknown({RVALID,RRESP})) &
        RVALID
        |-> RRESP != `AXI4PC_RESP_EXOKAY;
  endproperty
  axi4lite_errs_rresp_exokay: assert property (AXI4LITE_ERRS_RRESP_EXOKAY) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_AXI4LITE_RRESP_EXOKAY);


//------------------------------------------------------------------------------
// INDEX:
// INDEX: Auxiliary Logic
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Rules for Auxiliary Logic
//------------------------------------------------------------------------------

  // INDEX:        - AXI4LITE_AUX_DATA_WIDTH
  // =====
  property AXI4LITE_AUX_WDATA_WIDTH;
    @(posedge `AXI4_SVA_CLK) disable iff (PROTOCOL != `AXI4PC_AMBA_AXI4LITE)
      (WDATA_WIDTH ==   32 ||
       WDATA_WIDTH ==   64);
  endproperty
  axi4lite_aux_wdata_width: assert property (AXI4LITE_AUX_WDATA_WIDTH) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_AXI4LITE_DATA_WIDTH);

  property AXI4LITE_AUX_RDATA_WIDTH;
    @(posedge `AXI4_SVA_CLK) disable iff (PROTOCOL != `AXI4PC_AMBA_AXI4LITE)
      (RDATA_WIDTH ==   32 ||
       RDATA_WIDTH ==   64);
  endproperty
  axi4lite_aux_rdata_width: assert property (AXI4LITE_AUX_RDATA_WIDTH) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_AXI4LITE_DATA_WIDTH);

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4 Rules: Write Address Channel (*_AW*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_AWADDR_BOUNDARY
  // =====
  // 4kbyte boundary: only bottom twelve bits (11 to 0) can change
  //
  // Only need to check INCR bursts since:
  //
  //   a) FIXED bursts cannot violate the 4kB boundary by definition
  //
  //   b) WRAP bursts always stay within a <4kB region because of the wrap
  //      address boundary.  The biggest WRAP burst possible has length 16,
  //      size 128 bytes (1024 bits), so it can transfer 2048 bytes. The
  //      individual transfer addresses wrap at a 2048 byte address boundary,
  //      and the max data transferred in also 2048 bytes, so a 4kB boundary
  //      can never be broken.
  property AXI4_ERRM_AWADDR_BOUNDARY;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
    !($isunknown({AWVALID,AWBURST,AWADDR})) &
      AWVALID & (AWBURST == `AXI4PC_ABURST_INCR)
      |-> (AwAddrIncr[WADDR_MAX:12] == AWADDR[WADDR_MAX:12]);
  endproperty
  axi4_errm_awaddr_boundary: assert property (AXI4_ERRM_AWADDR_BOUNDARY) else
        `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWADDR_BOUNDARY);


  // INDEX:        - AXI4_ERRM_AWADDR_WRAP_ALIGN
  // =====
  property AXI4_ERRM_AWADDR_WRAP_ALIGN;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWBURST,AWADDR})) &
      AWVALID & (AWBURST == `AXI4PC_ABURST_WRAP)
      |-> ((AWADDR[6:0] & AlignMaskW) == AWADDR[6:0]);
  endproperty
  axi4_errm_awaddr_wrap_align: assert property (AXI4_ERRM_AWADDR_WRAP_ALIGN) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWADDR_WRAP_ALIGN);


  // INDEX:        - AXI4_ERRM_AWBURST
  // =====
  property AXI4_ERRM_AWBURST;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWBURST})) &
      AWVALID
      |-> (AWBURST != 2'b11);
  endproperty
  axi4_errm_awburst: assert property (AXI4_ERRM_AWBURST) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBURST);


  // INDEX:        - AXI4_ERRM_AWLEN_LOCK
  // =====
  property AXI4_ERRM_AWLEN_LOCK;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWLEN,AWLOCK})) &
      AWVALID & AWLEN > `AXI4PC_ALEN_16
      |-> (AWLOCK != `AXI4PC_ALOCK_EXCL);
  endproperty
  axi4_errm_awlen_lock: assert property (AXI4_ERRM_AWLEN_LOCK) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_LOCK);


  // INDEX:        - AXI4_ERRM_AWCACHE
  // =====
  property AXI4_ERRM_AWCACHE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWCACHE})) &
      AWVALID & ~AWCACHE[1]
      |-> (AWCACHE[3:2] == 2'b00);
  endproperty
  axi4_errm_awcache: assert property (AXI4_ERRM_AWCACHE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWCACHE);


  // INDEX:        - AXI4_ERRM_AWLEN_FIXED
  // =====
  property AXI4_ERRM_AWLEN_FIXED;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWLEN,AWBURST})) &
      AWVALID & AWLEN > `AXI4PC_ALEN_16
      |-> (AWBURST != `AXI4PC_ABURST_FIXED);
  endproperty
  axi4_errm_awlen_fixed: assert property (AXI4_ERRM_AWLEN_FIXED) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_FIXED);


  // INDEX:        - AXI4_ERRM_AWLEN_WRAP
  // =====
  property AXI4_ERRM_AWLEN_WRAP;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWBURST,AWLEN})) &
      AWVALID & (AWBURST == `AXI4PC_ABURST_WRAP)
      |-> (AWLEN == `AXI4PC_ALEN_2 ||
           AWLEN == `AXI4PC_ALEN_4 ||
           AWLEN == `AXI4PC_ALEN_8 ||
           AWLEN == `AXI4PC_ALEN_16);
  endproperty
  axi4_errm_awlen_wrap: assert property (AXI4_ERRM_AWLEN_WRAP) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_WRAP);


  // INDEX:        - AXI4_ERRM_AWSIZE
  // =====
  // Deliberately keeping AwSizeInBits logic outside of assertion, to
  // simplify formal-proofs flow.
  property AXI4_ERRM_AWSIZE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWSIZE})) &
      AWVALID
      |-> (AwSizeInBits <= WDATA_WIDTH);
  endproperty
  axi4_errm_awsize: assert property (AXI4_ERRM_AWSIZE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSIZE);


  // INDEX:        - AXI4_ERRM_AWVALID_RESET
  // =====
  property AXI4_ERRM_AWVALID_RESET;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !(`AXI4_SVA_RSTn) & !($isunknown(`AXI4_SVA_RSTn))
      ##1   `AXI4_SVA_RSTn
      |-> !AWVALID;
  endproperty
  axi4_errm_awvalid_reset: assert property (AXI4_ERRM_AWVALID_RESET) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWVALID_RESET);

//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_AWADDR_STABLE
  // =====
  property AXI4_ERRM_AWADDR_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWADDR})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWADDR);
  endproperty
  axi4_errm_awaddr_stable: assert property (AXI4_ERRM_AWADDR_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWADDR_STABLE);


  // INDEX:        - AXI4_ERRM_AWBURST_STABLE
  // =====
  property AXI4_ERRM_AWBURST_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWBURST})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWBURST);
  endproperty
  axi4_errm_awburst_stable: assert property (AXI4_ERRM_AWBURST_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBURST_STABLE);


  // INDEX:        - AXI4_ERRM_AWCACHE_STABLE
  // =====
  property AXI4_ERRM_AWCACHE_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWCACHE})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWCACHE);
  endproperty
  axi4_errm_awcache_stable: assert property (AXI4_ERRM_AWCACHE_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWCACHE_STABLE);


  // INDEX:        - AXI4_ERRM_AWID_STABLE
  // =====
  property AXI4_ERRM_AWID_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWID})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWID);
  endproperty
  axi4_errm_awid_stable: assert property (AXI4_ERRM_AWID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWID_STABLE);


  // INDEX:        - AXI4_ERRM_AWLEN_STABLE
  // =====
  property AXI4_ERRM_AWLEN_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWLEN})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWLEN);
  endproperty
  axi4_errm_awlen_stable: assert property (AXI4_ERRM_AWLEN_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_STABLE);


  // INDEX:        - AXI4_ERRM_AWLOCK_STABLE
  // =====
  property AXI4_ERRM_AWLOCK_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWLOCK})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWLOCK);
  endproperty
  axi4_errm_awlock_stable: assert property (AXI4_ERRM_AWLOCK_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLOCK_STABLE);


  // INDEX:        - AXI4_ERRM_AWPROT_STABLE
  // =====
  property AXI4_ERRM_AWPROT_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWPROT})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWPROT);
  endproperty
  axi4_errm_awprot_stable: assert property (AXI4_ERRM_AWPROT_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWPROT_STABLE);


  // INDEX:        - AXI4_ERRM_AWSIZE_STABLE
  // =====
  property AXI4_ERRM_AWSIZE_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWSIZE})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWSIZE);
  endproperty
  axi4_errm_awsize_stable: assert property (AXI4_ERRM_AWSIZE_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSIZE_STABLE);


  // INDEX:        - AXI4_ERRM_AWQOS_STABLE
  // =====
  property AXI4_ERRM_AWQOS_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWQOS})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWQOS);
  endproperty
  axi4_errm_awqos_stable: assert property (AXI4_ERRM_AWQOS_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWQOS_STABLE);


  // INDEX:        - AXI4_ERRM_AWREGION_STABLE
  // =====
  property AXI4_ERRM_AWREGION_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWREGION})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWREGION);
  endproperty
  axi4_errm_awregion_stable: assert property (AXI4_ERRM_AWREGION_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWREGION_STABLE);


  // INDEX:        - AXI4_ERRM_AWVALID_STABLE
  // =====
  property AXI4_ERRM_AWVALID_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID & !AWREADY & !($isunknown({AWVALID,AWREADY}))
      ##1 `AXI4_SVA_RSTn
      |-> AWVALID;
  endproperty
  axi4_errm_awvalid_stable: assert property (AXI4_ERRM_AWVALID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWVALID_STABLE);


  // INDEX:        - AXI4_RECS_AWREADY_MAX_WAIT
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
//  property   AXI4_RECS_AWREADY_MAX_WAIT;
//    @(posedge `AXI4_SVA_CLK) disable iff (((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)) || (ACLKEN == 0))
//      `AXI4_SVA_RSTn & !($isunknown({AWVALID,AWREADY})) &
//      i_RecommendOn  & // Parameter that can disable all AXI4_REC*_* rules
//      i_RecMaxWaitOn & // Parameter that can disable just AXI4_REC*_MAX_WAIT rules
//      ( AWVALID & !AWREADY)  // READY=1 within max_wait_cycles cycles (or VALID=0)
//      |-> ##[1:max_wait_cycles] (!AWVALID |  AWREADY); 
//  endproperty
//  axi4_recs_awready_max_wait: assert property (AXI4_RECS_AWREADY_MAX_WAIT) else
//   `ARM_AMBA4_PC_MSG_WARN(`RECS_AWREADY_MAX_WAIT);  

integer unsigned  aw_wait_counter = 0;
integer unsigned  ar_wait_counter = 0;
integer unsigned  b_wait_counter = 0;
integer unsigned  w_wait_counter = 0;
integer unsigned  r_wait_counter = 0;

integer unsigned  awcmd_outstanding_count = 0;
integer unsigned  arcmd_outstanding_count = 0;
integer unsigned  wlast_outstanding_count = 0;

integer unsigned  wlast_to_awvalid_counter = 0;
integer unsigned  rtransfers_wait_counter = 0;
integer unsigned  wtransfers_wait_counter = 0;
integer unsigned  wlcmd_wait_counter = 0;

always @(posedge `AXI4_SVA_CLK) begin
  if (!ARESETn) begin
    aw_wait_counter = 0;
    ar_wait_counter = 0;
    b_wait_counter = 0;
    w_wait_counter = 0;
    r_wait_counter = 0;
    awcmd_outstanding_count = 0;
    arcmd_outstanding_count = 0;
    wlast_outstanding_count = 0;
    wlast_to_awvalid_counter = 0;
    rtransfers_wait_counter = 0;
    wtransfers_wait_counter = 0;
    wlcmd_wait_counter = 0;
  end else begin
    if (ACLKEN == 1) begin
      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //AW Channel
      if (max_aw_wait_cycles != 0) begin
      if (AWVALID & !AWREADY) begin
        aw_wait_counter++;
      end else if (!AWVALID | AWREADY) begin
        aw_wait_counter = 0;
      end else if (aw_wait_counter > max_aw_wait_cycles) begin
        `ARM_AMBA4_PC_MSG_WARN(`RECS_AWREADY_MAX_WAIT);  
      end
      end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //AR Channel
      if (max_ar_wait_cycles != 0) begin
        if (ARVALID & !ARREADY) begin
          ar_wait_counter++;
        end else if (!ARVALID | ARREADY) begin
          ar_wait_counter = 0;
        end else if (ar_wait_counter > max_ar_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECS_ARREADY_MAX_WAIT);
        end 
      end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //W Channel
      if (max_w_wait_cycles != 0) begin
        if (WVALID & !WREADY) begin
          w_wait_counter++;
        end else if (!WVALID | WREADY) begin
          w_wait_counter = 0;
        end else if (w_wait_counter > max_w_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECS_WREADY_MAX_WAIT);
        end
      end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //B Channel
      if (max_b_wait_cycles != 0) begin
        if (BVALID & !BREADY) begin
          b_wait_counter++;
        end else if (!BVALID | BREADY) begin
          b_wait_counter = 0;
        end else if (b_wait_counter > max_b_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECM_BREADY_MAX_WAIT);
        end
      end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //R Channel
      if (max_r_wait_cycles != 0) begin
        if (RVALID & !RREADY) begin
          r_wait_counter++;
        end else if (!RVALID | RREADY) begin
          r_wait_counter = 0;
        end else if (r_wait_counter > max_r_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECM_RREADY_MAX_WAIT);
        end
    end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Outstanding Counters
      if (RVALID & RREADY & RLAST) begin
        arcmd_outstanding_count--;
      end
      if (BVALID & BREADY) begin
        awcmd_outstanding_count--;
        wlast_outstanding_count--;
      end
      if (AWVALID & AWREADY) begin
        awcmd_outstanding_count++;
      end
      if (ARVALID & ARREADY) begin
        arcmd_outstanding_count++;
      end
      if (WVALID & WREADY & WLAST) begin
        wlast_outstanding_count++;
      end
      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //RECS_WLAST_TO_AWVALID_MAX_WAIT
      if (max_wlast_to_awvalid_wait_cycles != 0) begin
        if (AWVALID) begin
          wlast_to_awvalid_counter = 0;
        end else if (wlast_to_awvalid_counter > max_wlast_to_awvalid_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECS_WLAST_TO_AWVALID_MAX_WAIT);
          wlast_to_awvalid_counter = 0;
        end else if (wlast_outstanding_count > awcmd_outstanding_count) begin
          wlast_to_awvalid_counter++;
        end
      end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //RECS_CONTINUOUS_RTRANSFERS_MAX_WAIT
      if (max_rtransfers_wait_cycles != 0) begin
        if (RVALID) begin
          rtransfers_wait_counter = 0;
        end else if (rtransfers_wait_counter > max_rtransfers_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECS_CONTINUOUS_RTRANSFERS_MAX_WAIT);
          rtransfers_wait_counter = 0;
        end else if (arcmd_outstanding_count > 0) begin
          rtransfers_wait_counter++;
        end
      end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //RECS_CONTINUOUS_WTRANSFERS_MAX_WAIT
      if (max_wtransfers_wait_cycles != 0) begin
        if (WVALID) begin
          wtransfers_wait_counter = 0;
        end else if (wtransfers_wait_counter > max_wtransfers_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECS_CONTINUOUS_WTRANSFERS_MAX_WAIT);
          wtransfers_wait_counter = 0;
        end else if (awcmd_outstanding_count > wlast_outstanding_count) begin
          wtransfers_wait_counter++;
        end
      end

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //RECS_WLCMD_TO_BVALID_MAX_WAIT
      if (max_wlcmd_wait_cycles != 0) begin
        if (BVALID) begin
          wlcmd_wait_counter = 0;
        end else if (wlcmd_wait_counter > max_wlcmd_wait_cycles) begin
          `ARM_AMBA4_PC_MSG_WARN(`RECS_WLCMD_TO_BVALID_MAX_WAIT);
          wlcmd_wait_counter = 0;
        end else if ((awcmd_outstanding_count > 0) && (wlast_outstanding_count > 0)) begin
          wlcmd_wait_counter++;
        end
      end
    end
  end
end

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI4_ERRM_AWADDR_X
  // =====
  property AXI4_ERRM_AWADDR_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWADDR);
  endproperty
  axi4_errm_awaddr_x: assert property (AXI4_ERRM_AWADDR_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWADDR_X);


  // INDEX:        - AXI4_ERRM_AWBURST_X
  // =====
  property AXI4_ERRM_AWBURST_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWBURST);
  endproperty
  axi4_errm_awburst_x: assert property (AXI4_ERRM_AWBURST_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBURST_X);


  // INDEX:        - AXI4_ERRM_AWCACHE_X
  // =====
  property AXI4_ERRM_AWCACHE_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWCACHE);
  endproperty
  axi4_errm_awcache_x: assert property (AXI4_ERRM_AWCACHE_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWCACHE_X);


  // INDEX:        - AXI4_ERRM_AWID_X
  // =====
  property AXI4_ERRM_AWID_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWID);
  endproperty
  axi4_errm_awid_x: assert property (AXI4_ERRM_AWID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWID_X);


  // INDEX:        - AXI4_ERRM_AWLEN_X
  // =====
  property AXI4_ERRM_AWLEN_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWLEN);
  endproperty
  axi4_errm_awlen_x: assert property (AXI4_ERRM_AWLEN_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_X);


  // INDEX:        - AXI4_ERRM_AWLOCK_X
  // =====
  property AXI4_ERRM_AWLOCK_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWLOCK);
  endproperty
  axi4_errm_awlock_x: assert property (AXI4_ERRM_AWLOCK_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLOCK_X);


  // INDEX:        - AXI4_ERRM_AWPROT_X
  // =====
  property AXI4_ERRM_AWPROT_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWPROT);
  endproperty
  axi4_errm_awprot_x: assert property (AXI4_ERRM_AWPROT_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWPROT_X);


  // INDEX:        - AXI4_ERRM_AWSIZE_X
  // =====
  property AXI4_ERRM_AWSIZE_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWSIZE);
  endproperty
  axi4_errm_awsize_x: assert property (AXI4_ERRM_AWSIZE_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSIZE_X);


  // INDEX:        - AXI4_ERRM_AWQOS_X
  // =====
  property AXI4_ERRM_AWQOS_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWQOS);
  endproperty
  axi4_errm_awqos_x: assert property (AXI4_ERRM_AWQOS_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWQOS_X);


  // INDEX:        - AXI4_ERRM_AWREGION_X
  // =====
  property AXI4_ERRM_AWREGION_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWREGION);
  endproperty
  axi4_errm_awregion_x: assert property (AXI4_ERRM_AWREGION_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWREGION_X);


  // INDEX:        - AXI4_ERRM_AWVALID_X
  // =====
  property AXI4_ERRM_AWVALID_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn
      |-> ! $isunknown(AWVALID);
  endproperty
  axi4_errm_awvalid_x: assert property (AXI4_ERRM_AWVALID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWVALID_X);


  // INDEX:        - AXI4_ERRS_AWREADY_X
  // =====
  property AXI4_ERRS_AWREADY_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(AWREADY);
  endproperty
  axi4_errs_awready_x: assert property (AXI4_ERRS_AWREADY_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_AWREADY_X);

`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4 Rules: Write Data Channel (*_W*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------

  // This will fire in one of the following situations:
  // 1) Write data arrives and WLAST set and WDATA count is not equal to AWLEN
  // 2) Write data arrives and WLAST not set and WDATA count is equal to AWLEN
  // 3) ADDR arrives, WLAST already received and WDATA count not equal to AWLEN

  // =====
  // INDEX:        - AXI4_ERRM_WDATA_NUM_PROP1
  // =====
  property AXI4_ERRM_WDATA_NUM_PROP1;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(AWDataNumError1))
      |-> ~AWDataNumError1;
  endproperty
  axi4_errm_wdata_num_prop1: assert property (AXI4_ERRM_WDATA_NUM_PROP1) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WDATA_NUM);

  // =====
  // INDEX:        - AXI4_ERRM_WDATA_NUM_PROP2
  // =====
  property AXI4_ERRM_WDATA_NUM_PROP2;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(AWDataNumError2))
      |-> ~AWDataNumError2;
  endproperty
  axi4_errm_wdata_num_prop2: assert property (AXI4_ERRM_WDATA_NUM_PROP2) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WDATA_NUM);

  // =====
  // INDEX:        - AXI4_ERRM_WDATA_NUM_PROP3
  // =====
  property AXI4_ERRM_WDATA_NUM_PROP3;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(AWDataNumError3))
      |-> ~AWDataNumError3;
  endproperty
  axi4_errm_wdata_num_prop3: assert property (AXI4_ERRM_WDATA_NUM_PROP3) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WDATA_NUM);

  // =====
  // INDEX:        - AXI4_ERRM_WDATA_NUM_PROP4
  // =====
  property AXI4_ERRM_WDATA_NUM_PROP4;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(WDataNumError1))
      |-> ~WDataNumError1;
  endproperty
  axi4_errm_wdata_num_prop4: assert property (AXI4_ERRM_WDATA_NUM_PROP4) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WDATA_NUM);

  // =====
  // INDEX:        - AXI4_ERRM_WDATA_NUM_PROP5
  // =====
  property AXI4_ERRM_WDATA_NUM_PROP5;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(WDataNumError2))
      |-> ~WDataNumError2;
  endproperty
  axi4_errm_wdata_num_prop5: assert property (AXI4_ERRM_WDATA_NUM_PROP5) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WDATA_NUM);


  // INDEX:        - AXI4_ERRM_WSTRB
  // =====
  wire BStrbError = BVALID ? CheckBurst(WCam[BIDMatch].xfer, WCam[BIDMatch].WCount) : 1'b0;
  property AXI4_ERRM_WSTRB;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown({BVALID,BREADY,WCam[BIDMatch].WAddr,WCam[BIDMatch].WLast,WCam[BIDMatch].xfer.cmd,WCam[BIDMatch].WCount})) 
      & BVALID & BREADY & WCam[BIDMatch].WAddr & WCam[BIDMatch].WLast
      |-> ~BStrbError;
  endproperty
  axi4_errm_wstrb: assert property (AXI4_ERRM_WSTRB) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WSTRB);



  // INDEX:        - AXI4_ERRM_WVALID_RESET
  // =====
  property AXI4_ERRM_WVALID_RESET;
    @(posedge `AXI4_SVA_CLK)
          !(`AXI4_SVA_RSTn) & !($isunknown(`AXI4_SVA_RSTn))
      ##1   `AXI4_SVA_RSTn
      |-> !WVALID;
  endproperty
  axi4_errm_wvalid_reset: assert property (AXI4_ERRM_WVALID_RESET) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WVALID_RESET);

//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_WDATA_STABLE
  // =====
  property AXI4_ERRM_WDATA_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({WVALID,WREADY,WDATA})) &
      `AXI4_SVA_RSTn & WVALID & !WREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(WDATA & WdataMask);
  endproperty
  axi4_errm_wdata_stable: assert property (AXI4_ERRM_WDATA_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WDATA_STABLE);


  // INDEX:        - AXI4_ERRM_WLAST_STABLE
  // =====
  property AXI4_ERRM_WLAST_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({WVALID,WREADY,WLAST})) &
      `AXI4_SVA_RSTn & WVALID & !WREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(WLAST);
  endproperty
  axi4_errm_wlast_stable: assert property (AXI4_ERRM_WLAST_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WLAST_STABLE);


  // INDEX:        - AXI4_ERRM_WSTRB_STABLE
  // =====
  property AXI4_ERRM_WSTRB_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({WVALID,WREADY,WSTRB})) &
      `AXI4_SVA_RSTn & WVALID & !WREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(WSTRB);
  endproperty
  axi4_errm_wstrb_stable: assert property (AXI4_ERRM_WSTRB_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WSTRB_STABLE);


  // INDEX:        - AXI4_ERRM_WVALID_STABLE
  // =====
  property AXI4_ERRM_WVALID_STABLE;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & WVALID & !WREADY & !($isunknown({WVALID,WREADY}))
      ##1 `AXI4_SVA_RSTn
      |-> WVALID;
  endproperty
  axi4_errm_wvalid_stable: assert property (AXI4_ERRM_WVALID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WVALID_STABLE);


//  // INDEX:        - AXI4_RECS_WREADY_MAX_WAIT 
//  // =====
//  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
//  property   AXI4_RECS_WREADY_MAX_WAIT;
//    @(posedge `AXI4_SVA_CLK) disable iff (ACLKEN == 0)
//      `AXI4_SVA_RSTn & !($isunknown({WVALID,WREADY})) &
//      i_RecommendOn  & // Parameter that can disable all AXI4_REC*_* rules
//      i_RecMaxWaitOn & // Parameter that can disable just AXI4_REC*_MAX_WAIT rules
//      ( WVALID & !WREADY) // READY=1 within max_wait_cycles cycles (or VALID=0)
//      |-> ##[1:max_wait_cycles] (!WVALID |  WREADY);    
//  endproperty
//  axi4_recs_wready_max_wait: assert property (AXI4_RECS_WREADY_MAX_WAIT) else
//   `ARM_AMBA4_PC_MSG_WARN(`RECS_WREADY_MAX_WAIT);  

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI4_ERRM_WDATA_X
  // =====
  property AXI4_ERRM_WDATA_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & WVALID & !($isunknown(WdataMask))
      |-> ! $isunknown(WDATA & WdataMask);
  endproperty
  axi4_errm_wdata_x: assert property (AXI4_ERRM_WDATA_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WDATA_X);


  // INDEX:        - AXI4_ERRM_WLAST_X
  // =====
  property AXI4_ERRM_WLAST_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & WVALID
      |-> ! $isunknown(WLAST);
  endproperty
  axi4_errm_wlast_x: assert property (AXI4_ERRM_WLAST_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WLAST_X);


  // INDEX:        - AXI4_ERRM_WSTRB_X
  // =====
  property AXI4_ERRM_WSTRB_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & WVALID
      |-> ! $isunknown(WSTRB);
  endproperty
  axi4_errm_wstrb_x: assert property (AXI4_ERRM_WSTRB_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WSTRB_X);


  // INDEX:        - AXI4_ERRM_WVALID_X
  // =====
  property AXI4_ERRM_WVALID_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(WVALID);
  endproperty
  axi4_errm_wvalid_x: assert property (AXI4_ERRM_WVALID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WVALID_X);


  // INDEX:        - AXI4_ERRS_WREADY_X
  // =====
  property AXI4_ERRS_WREADY_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(WREADY);
  endproperty
  axi4_errs_wready_x: assert property (AXI4_ERRS_WREADY_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_WREADY_X);


`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4 Rules: Write Response Channel (*_B*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI4_ERRS_BRESP_WLAST
  // =====
  property AXI4_ERRS_BRESP_WLAST;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & !($isunknown({BVALID,WCam[BIDMatch].WLast}))
      & BVALID
      |-> WCam[BIDMatch].WLast && (BIDMatch <= MAXWBURSTS);
  endproperty
  axi4_errs_bresp_wlast: assert property (AXI4_ERRS_BRESP_WLAST) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_WLAST);




  // INDEX:        - AXI4_ERRS_BRESP_EXOKAY
  // =====
  //if (Burst[EXCL] == 1'b0 && BRESP == `AXI4PC_RESP_EXOKAY)
  property AXI4_ERRS_BRESP_EXOKAY;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown({BVALID,BRESP})) 
      & BVALID & (BRESP == `AXI4PC_RESP_EXOKAY)
      |-> WCam[BIDMatch].xfer.cmd.excl ;
  endproperty
  axi4_errs_bresp_exokay: assert property (AXI4_ERRS_BRESP_EXOKAY) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_EXOKAY);


  // INDEX:        - AXI4_ERRS_BVALID_RESET
  // =====
  property AXI4_ERRS_BVALID_RESET;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !(`AXI4_SVA_RSTn) & !($isunknown(`AXI4_SVA_RSTn))
      ##1  `AXI4_SVA_RSTn
      |-> !BVALID;
  endproperty
axi4_errs_bvalid_reset: assert property (AXI4_ERRS_BVALID_RESET) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BVALID_RESET);


  // INDEX:        - AXI4_ERRS_BRESP_AW 
  // =====
  property AXI4_ERRS_BRESP_AW;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & !($isunknown(BVALID)) 
      & BVALID
      |-> WCam[BIDMatch].WAddr && (BIDMatch <= MAXWBURSTS);
  endproperty
  axi4_errs_bresp_aw: assert property (AXI4_ERRS_BRESP_AW) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_AW);

//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRS_BID_STABLE
  // =====
  property AXI4_ERRS_BID_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({BVALID,BREADY,BID})) &
      `AXI4_SVA_RSTn & BVALID & !BREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(BID);
  endproperty
  axi4_errs_bid_stable: assert property (AXI4_ERRS_BID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BID_STABLE);


  // INDEX:        - AXI4_ERRS_BRESP_STABLE
  // =====
  property AXI4_ERRS_BRESP_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({BVALID,BREADY,BRESP})) &
      `AXI4_SVA_RSTn & BVALID & !BREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(BRESP);
  endproperty
  axi4_errs_bresp_stable: assert property (AXI4_ERRS_BRESP_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_STABLE);


  // INDEX:        - AXI4_ERRS_BVALID_STABLE
  // =====
  property AXI4_ERRS_BVALID_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & BVALID & !BREADY & !($isunknown({BVALID,BREADY}))
      ##1 `AXI4_SVA_RSTn
      |-> BVALID;
  endproperty
  axi4_errs_bvalid_stable: assert property (AXI4_ERRS_BVALID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BVALID_STABLE);


  // INDEX:        - AXI4_RECM_BREADY_MAX_WAIT 
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
//  property   AXI4_RECM_BREADY_MAX_WAIT;
//    @(posedge `AXI4_SVA_CLK) disable iff (((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)) || (ACLKEN == 0))
//      `AXI4_SVA_RSTn & !($isunknown({BVALID,BREADY})) &
//      i_RecommendOn  & // Parameter that can disable all AXI4_REC*_* rules
//      i_RecMaxWaitOn & // Parameter that can disable just AXI4_REC*_MAX_WAIT rules
//      ( BVALID & !BREADY) // READY=1 within max_wait_cycles cycles (or VALID=0)
//      |-> ##[1:max_wait_cycles] (!BVALID |  BREADY);    
//  endproperty
//  axi4_recm_bready_max_wait: assert property (AXI4_RECM_BREADY_MAX_WAIT) else
//   `ARM_AMBA4_PC_MSG_WARN(`RECM_BREADY_MAX_WAIT);

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI4_ERRM_BREADY_X
  // =====
  property AXI4_ERRM_BREADY_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(BREADY);
  endproperty
  axi4_errm_bready_x: assert property (AXI4_ERRM_BREADY_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_BREADY_X);


  // INDEX:        - AXI4_ERRS_BID_X
  // =====
  property AXI4_ERRS_BID_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & BVALID
      |-> ! $isunknown(BID);
  endproperty
  axi4_errs_bid_x: assert property (AXI4_ERRS_BID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BID_X);


  // INDEX:        - AXI4_ERRS_BRESP_X
  // =====
  property AXI4_ERRS_BRESP_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & BVALID
      |-> ! $isunknown(BRESP);
  endproperty
  axi4_errs_bresp_x: assert property (AXI4_ERRS_BRESP_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_X);


  // INDEX:        - AXI4_ERRS_BVALID_X
  // =====
  property AXI4_ERRS_BVALID_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn
      |-> ! $isunknown(BVALID);
  endproperty
  axi4_errs_bvalid_x: assert property (AXI4_ERRS_BVALID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BVALID_X);


`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4 Rules: Read Address Channel (*_AR*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_ARADDR_BOUNDARY
  // =====
  // 4kbyte boundary: only bottom twelve bits (11 to 0) can change
  //
  // Only need to check INCR bursts since:
  //
  //   a) FIXED bursts cannot violate the 4kB boundary by definition
  //
  //   b) WRAP bursts always stay within a <4kB region because of the wrap
  //      address boundary.  The biggest WRAP burst possible has length 16,
  //      size 128 bytes (1024 bits), so it can transfer 2048 bytes. The
  //      individual transfer addresses wrap at a 2048 byte address boundary,
  //      and the max data transferred in also 2048 bytes, so a 4kB boundary
  //      can never be broken.
  property AXI4_ERRM_ARADDR_BOUNDARY;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARBURST,ARADDR})) &
      ARVALID & (ARBURST == `AXI4PC_ABURST_INCR)
      |-> (ArAddrIncr[RADDR_MAX:12] == ARADDR[RADDR_MAX:12]);
  endproperty
  axi4_errm_araddr_boundary: assert property (AXI4_ERRM_ARADDR_BOUNDARY) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARADDR_BOUNDARY);


  // INDEX:        - AXI4_ERRM_ARADDR_WRAP_ALIGN
  // =====
  property AXI4_ERRM_ARADDR_WRAP_ALIGN;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARBURST,ARADDR})) &
      ARVALID & (ARBURST == `AXI4PC_ABURST_WRAP)
      |-> ((ARADDR[6:0] & AlignMaskR) == ARADDR[6:0]);
  endproperty
  axi4_errm_araddr_wrap_align: assert property (AXI4_ERRM_ARADDR_WRAP_ALIGN) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARADDR_WRAP_ALIGN);


  // INDEX:        - AXI4_ERRM_ARBURST
  // =====
  property AXI4_ERRM_ARBURST;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARBURST})) &
      ARVALID
      |-> (ARBURST != 2'b11);
  endproperty
  axi4_errm_arburst: assert property (AXI4_ERRM_ARBURST) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARBURST);


  // INDEX:        - AXI4_ERRM_ARLEN_LOCK
  // =====
  property AXI4_ERRM_ARLEN_LOCK;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARLEN,ARLOCK})) &
      ARVALID & ARLEN > `AXI4PC_ALEN_16
      |-> (ARLOCK != `AXI4PC_ALOCK_EXCL);
  endproperty
  axi4_errm_arlen_lock: assert property (AXI4_ERRM_ARLEN_LOCK) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_LOCK);


  // INDEX:        - AXI4_ERRM_ARCACHE
  // =====
  property AXI4_ERRM_ARCACHE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARCACHE})) &
      ARVALID & ~ARCACHE[1]
      |-> (ARCACHE[3:2] == 2'b00);
  endproperty
  axi4_errm_arcache: assert property (AXI4_ERRM_ARCACHE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARCACHE);


  // INDEX:        - AXI4_ERRM_ARLEN_FIXED
  // =====
  property AXI4_ERRM_ARLEN_FIXED;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARLEN,ARBURST})) &
      ARVALID & ARLEN > `AXI4PC_ALEN_16
      |-> (ARBURST != `AXI4PC_ABURST_FIXED);
  endproperty
  axi4_errm_arlen_fixed: assert property (AXI4_ERRM_ARLEN_FIXED) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_FIXED);


  // INDEX:        - AXI4_ERRM_ARLEN_WRAP
  // =====
  // This property is disabled for ACE because a cache maintenance transfer 
  // can have a length of 1 and be a wrap. This rule is duplicated in the
  // ACEPC to cover this rule.
  property AXI4_ERRM_ARLEN_WRAP;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({ARVALID,ARBURST,ARLEN})) &
      ARVALID & (ARBURST == `AXI4PC_ABURST_WRAP)
      |-> (ARLEN == `AXI4PC_ALEN_2 ||
           ARLEN == `AXI4PC_ALEN_4 ||
           ARLEN == `AXI4PC_ALEN_8 ||
           ARLEN == `AXI4PC_ALEN_16);
  endproperty
  axi4_errm_arlen_wrap: assert property (AXI4_ERRM_ARLEN_WRAP) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_WRAP);


  // INDEX:        - AXI4_ERRM_ARSIZE
  // =====
  property AXI4_ERRM_ARSIZE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARSIZE})) &
      ARVALID
      |-> (ArSizeInBits <= RDATA_WIDTH);
  endproperty
  axi4_errm_arsize: assert property (AXI4_ERRM_ARSIZE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARSIZE);


  // INDEX:        - AXI4_ERRM_ARVALID_RESET
  // =====
  property AXI4_ERRM_ARVALID_RESET;
    @(posedge `AXI4_SVA_CLK)
      !(`AXI4_SVA_RSTn) & !($isunknown(`AXI4_SVA_RSTn))
      ##1  `AXI4_SVA_RSTn
      |-> !ARVALID;
  endproperty
  axi4_errm_arvalid_reset: assert property (AXI4_ERRM_ARVALID_RESET) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARVALID_RESET);

//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_ARADDR_STABLE
  // =====
  property AXI4_ERRM_ARADDR_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARADDR})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARADDR);
  endproperty
  axi4_errm_araddr_stable: assert property (AXI4_ERRM_ARADDR_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARADDR_STABLE);


  // INDEX:        - AXI4_ERRM_ARBURST_STABLE
  // =====
  property AXI4_ERRM_ARBURST_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARBURST})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARBURST);
  endproperty
  axi4_errm_arburst_stable: assert property (AXI4_ERRM_ARBURST_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARBURST_STABLE);


  // INDEX:        - AXI4_ERRM_ARCACHE_STABLE
  // =====
  property AXI4_ERRM_ARCACHE_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARCACHE})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARCACHE);
  endproperty
  axi4_errm_arcache_stable: assert property (AXI4_ERRM_ARCACHE_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARCACHE_STABLE);


  // INDEX:        - AXI4_ERRM_ARID_STABLE
  // =====
  property AXI4_ERRM_ARID_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARID})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARID);
  endproperty
  axi4_errm_arid_stable: assert property (AXI4_ERRM_ARID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARID_STABLE);


  // INDEX:        - AXI4_ERRM_ARLEN_STABLE
  // =====
  property AXI4_ERRM_ARLEN_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({ARVALID,ARREADY,ARLEN})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARLEN);
  endproperty
  axi4_errm_arlen_stable: assert property (AXI4_ERRM_ARLEN_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_STABLE);


  // INDEX:        - AXI4_ERRM_ARLOCK_STABLE
  // =====
  property AXI4_ERRM_ARLOCK_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARLOCK})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARLOCK);
  endproperty
  axi4_errm_arlock_stable: assert property (AXI4_ERRM_ARLOCK_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLOCK_STABLE);


  // INDEX:        - AXI4_ERRM_ARPROT_STABLE
  // =====
  property AXI4_ERRM_ARPROT_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARPROT})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARPROT);
  endproperty
  axi4_errm_arprot_stable: assert property (AXI4_ERRM_ARPROT_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARPROT_STABLE);


  // INDEX:        - AXI4_ERRM_ARSIZE_STABLE
  // =====
  property AXI4_ERRM_ARSIZE_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARSIZE})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARSIZE);
  endproperty
  axi4_errm_arsize_stable: assert property (AXI4_ERRM_ARSIZE_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARSIZE_STABLE);


  // INDEX:        - AXI4_ERRM_ARQOS_STABLE
  // =====
  property AXI4_ERRM_ARQOS_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARQOS})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARQOS);
  endproperty
  axi4_errm_arqos_stable: assert property (AXI4_ERRM_ARQOS_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARQOS_STABLE);


  // INDEX:        - AXI4_ERRM_ARREGION_STABLE
  // =====
  property AXI4_ERRM_ARREGION_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARREGION})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARREGION);
  endproperty
  axi4_errm_arregion_stable: assert property (AXI4_ERRM_ARREGION_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARREGION_STABLE);


  // INDEX:        - AXI4_ERRM_ARVALID_STABLE
  // =====
  property AXI4_ERRM_ARVALID_STABLE;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID & !ARREADY & !($isunknown({ARVALID,ARREADY}))
      ##1 `AXI4_SVA_RSTn
      |-> ARVALID;
  endproperty
  axi4_errm_arvalid_stable: assert property (AXI4_ERRM_ARVALID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARVALID_STABLE);


  // INDEX:        - AXI4_RECS_ARREADY_MAX_WAIT 
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
//  property   AXI4_RECS_ARREADY_MAX_WAIT;
//    @(posedge `AXI4_SVA_CLK) disable iff (ACLKEN == 0)
//      `AXI4_SVA_RSTn & !($isunknown({ARVALID,ARREADY})) &
//      i_RecommendOn  & // Parameter that can disable all AXI4_REC*_* rules
//      i_RecMaxWaitOn & // Parameter that can disable just AXI4_REC*_MAX_WAIT rules
//      ( ARVALID & !ARREADY) // READY=1 within max_wait_cycles cycles (or VALID=0)
//      |-> ##[1:max_wait_cycles] (!ARVALID |  ARREADY);  
//  endproperty
//  axi4_recs_arready_max_wait: assert property (AXI4_RECS_ARREADY_MAX_WAIT) else
//   `ARM_AMBA4_PC_MSG_WARN(`RECS_ARREADY_MAX_WAIT);  

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI4_ERRM_ARADDR_X
  // =====
  property AXI4_ERRM_ARADDR_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARADDR);
  endproperty
  axi4_errm_araddr_x: assert property (AXI4_ERRM_ARADDR_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARADDR_X);


  // INDEX:        - AXI4_ERRM_ARBURST_X
  // =====
  property AXI4_ERRM_ARBURST_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARBURST);
  endproperty
  axi4_errm_arburst_x: assert property (AXI4_ERRM_ARBURST_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARBURST_X);


  // INDEX:        - AXI4_ERRM_ARCACHE_X
  // =====
  property AXI4_ERRM_ARCACHE_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARCACHE);
  endproperty
  axi4_errm_arcache_x: assert property (AXI4_ERRM_ARCACHE_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARCACHE_X);


  // INDEX:        - AXI4_ERRM_ARID_X
  // =====
  property AXI4_ERRM_ARID_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARID);
  endproperty
  axi4_errm_arid_x: assert property (AXI4_ERRM_ARID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARID_X);


  // INDEX:        - AXI4_ERRM_ARLEN_X
  // =====
  property AXI4_ERRM_ARLEN_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARLEN);
  endproperty
  axi4_errm_arlen_x: assert property (AXI4_ERRM_ARLEN_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_X);


  // INDEX:        - AXI4_ERRM_ARLOCK_X
  // =====
  property AXI4_ERRM_ARLOCK_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARLOCK);
  endproperty
  axi4_errm_arlock_x: assert property (AXI4_ERRM_ARLOCK_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLOCK_X);


  // INDEX:        - AXI4_ERRM_ARPROT_X
  // =====
  property AXI4_ERRM_ARPROT_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARPROT);
  endproperty
  axi4_errm_arprot_x: assert property (AXI4_ERRM_ARPROT_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARPROT_X);


  // INDEX:        - AXI4_ERRM_ARSIZE_X
  // =====
  property AXI4_ERRM_ARSIZE_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARSIZE);
  endproperty
  axi4_errm_arsize_x: assert property (AXI4_ERRM_ARSIZE_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARSIZE_X);


  // INDEX:        - AXI4_ERRM_ARQOS_X
  // =====
  property AXI4_ERRM_ARQOS_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARQOS);
  endproperty
  axi4_errm_arqos_x: assert property (AXI4_ERRM_ARQOS_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARQOS_X);


  // INDEX:        - AXI4_ERRM_ARREGION_X
  // =====
  property AXI4_ERRM_ARREGION_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARREGION);
  endproperty
  axi4_errm_arregion_x: assert property (AXI4_ERRM_ARREGION_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARREGION_X);


  // INDEX:        - AXI4_ERRM_ARVALID_X
  // =====
  property AXI4_ERRM_ARVALID_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(ARVALID);
  endproperty
  axi4_errm_arvalid_x: assert property (AXI4_ERRM_ARVALID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARVALID_X);


  // INDEX:        - AXI4_ERRS_ARREADY_X
  // =====
  property AXI4_ERRS_ARREADY_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(ARREADY);
  endproperty
  axi4_errs_arready_x: assert property (AXI4_ERRS_ARREADY_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_ARREADY_X);

`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4 Rules: Read Data Channel (*_R*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRS_RDATA_NUM
  // =====
  property AXI4_ERRS_RDATA_NUM;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({RVALID,RREADY,RLAST,ArLenPending})) &
      `AXI4_SVA_RSTn & RVALID // Last RDATA and RLAST is asserted
      |-> ( ((ArCountPending == ArLenPending) & RLAST)  
      // Not last RDATA and RLAST is not asserted
      |((ArCountPending != ArLenPending) & ~RLAST)); 
  endproperty
  axi4_errs_rdata_num: assert property (AXI4_ERRS_RDATA_NUM) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RDATA_NUM);

  // INDEX:        - AXI4_ERRS_RID
  // =====
  // Read data must always follow the address that it relates to.
  property AXI4_ERRS_RID;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(RVALID)) &
      `AXI4_SVA_RSTn & RVALID
      |-> (RidMatch > 0);
  endproperty
  axi4_errs_rid: assert property (AXI4_ERRS_RID) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RID);


  // INDEX:        - AXI4_ERRS_RRESP_EXOKAY
  // =====
  property AXI4_ERRS_RRESP_EXOKAY;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({RVALID,RREADY,RRESP})) &
      `AXI4_SVA_RSTn & RVALID & RREADY & (RRESP == `AXI4PC_RESP_EXOKAY)
      |-> (ArExclPending);
  endproperty
  axi4_errs_rresp_exokay: assert property (AXI4_ERRS_RRESP_EXOKAY) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_EXOKAY);


  // INDEX:        - AXI4_ERRS_RVALID_RESET
  // =====
  property AXI4_ERRS_RVALID_RESET;
    @(posedge `AXI4_SVA_CLK)
      !(`AXI4_SVA_RSTn) & !($isunknown(`AXI4_SVA_RSTn))
      ##1   `AXI4_SVA_RSTn
      |-> !RVALID;
  endproperty
   axi4_errs_rvalid_reset: assert property (AXI4_ERRS_RVALID_RESET) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RVALID_RESET);

//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRS_RDATA_STABLE
  // =====
  property AXI4_ERRS_RDATA_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({RVALID,RREADY,RDATA})) &
      `AXI4_SVA_RSTn & RVALID & !RREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(RDATA | ~RdataMask);
  endproperty
  axi4_errs_rdata_stable: assert property (AXI4_ERRS_RDATA_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RDATA_STABLE);


  // INDEX:        - AXI4_ERRS_RID_STABLE
  // =====
  property AXI4_ERRS_RID_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({RVALID,RREADY,RID})) &
      `AXI4_SVA_RSTn & RVALID & !RREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(RID);
  endproperty
  axi4_errs_rid_stable: assert property (AXI4_ERRS_RID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RID_STABLE);


  // INDEX:        - AXI4_ERRS_RLAST_STABLE
  // =====
  property AXI4_ERRS_RLAST_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({RVALID,RREADY,RLAST})) &
      `AXI4_SVA_RSTn & RVALID & !RREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(RLAST);
  endproperty
  axi4_errs_rlast_stable: assert property (AXI4_ERRS_RLAST_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RLAST_STABLE);


  // INDEX:        - AXI4_ERRS_RRESP_STABLE
  // =====
  property AXI4_ERRS_RRESP_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({RVALID,RREADY,RRESP})) &
      `AXI4_SVA_RSTn & RVALID & !RREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(RRESP);
  endproperty
  axi4_errs_rresp_stable: assert property (AXI4_ERRS_RRESP_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_STABLE);


  // INDEX:        - AXI4_ERRS_RVALID_STABLE
  // =====
  property AXI4_ERRS_RVALID_STABLE;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & RVALID & !RREADY & !($isunknown({RVALID,RREADY}))
      ##1 `AXI4_SVA_RSTn
      |-> RVALID;
  endproperty
  axi4_errs_rvalid_stable: assert property (AXI4_ERRS_RVALID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RVALID_STABLE);


  // INDEX:        - AXI4_RECM_RREADY_MAX_WAIT 
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
//  property   AXI4_RECM_RREADY_MAX_WAIT;
//    @(posedge `AXI4_SVA_CLK) disable iff (ACLKEN == 0)
//      `AXI4_SVA_RSTn & !($isunknown({RVALID,RREADY})) &
//      i_RecommendOn  & // Parameter that can disable all AXI4_REC*_* rules
//      i_RecMaxWaitOn & // Parameter that can disable just AXI4_REC*_MAX_WAIT rules
//      ( RVALID & !RREADY) // READY=1 within max_wait_cycles cycles (or VALID=0)
//      |-> ##[1:max_wait_cycles] (!RVALID |  RREADY);    
//  endproperty
//  axi4_recm_rready_max_wait: assert property (AXI4_RECM_RREADY_MAX_WAIT) else
//   `ARM_AMBA4_PC_MSG_WARN(`RECM_RREADY_MAX_WAIT);  

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI4_ERRS_RDATA_X
  // =====
  property AXI4_ERRS_RDATA_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & RVALID
      |-> ! $isunknown(RDATA | ~RdataMask);
  endproperty
  axi4_errs_rdata_x: assert property (AXI4_ERRS_RDATA_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RDATA_X);


  // INDEX:        - AXI4_ERRM_RREADY_X
  // =====
  property AXI4_ERRM_RREADY_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(RREADY);
  endproperty
  axi4_errm_rready_x: assert property (AXI4_ERRM_RREADY_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_RREADY_X);


  // INDEX:        - AXI4_ERRS_RID_X
  // =====
  property AXI4_ERRS_RID_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & RVALID
      |-> ! $isunknown(RID);
  endproperty
  axi4_errs_rid_x: assert property (AXI4_ERRS_RID_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RID_X);


  // INDEX:        - AXI4_ERRS_RLAST_X
  // =====
  property AXI4_ERRS_RLAST_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & RVALID
      |-> ! $isunknown(RLAST);
  endproperty
  axi4_errs_rlast_x: assert property (AXI4_ERRS_RLAST_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RLAST_X);


  // INDEX:        - AXI4_ERRS_RRESP_X
  // =====
  property AXI4_ERRS_RRESP_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & RVALID
      |-> ! $isunknown(RRESP);
  endproperty
  axi4_errs_rresp_x: assert property (AXI4_ERRS_RRESP_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_X);


  // INDEX:        - AXI4_ERRS_RVALID_X
  // =====
  property AXI4_ERRS_RVALID_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(RVALID);
  endproperty
  axi4_errs_rvalid_x: assert property (AXI4_ERRS_RVALID_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RVALID_X);

`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4 Rules: Low Power Interface (*_C*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules (none for Low Power signals)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules (asynchronous to ACLK)
// =====
// The low-power handshake rules below use rising/falling edges on REQ and ACK,
// in order to detect changes within ACLK cycles (including low power state).
//------------------------------------------------------------------------------


  // INDEX:        - AXI4_ERRL_CSYSACK_FALL
  // =====
  property AXI4_ERRL_CSYSACK_FALL;
    @(negedge CSYSACK) disable iff (~`AXI4_SVA_RSTn) // falling edge of CSYSACK
      !($isunknown(CSYSREQ))
      |-> ~CSYSREQ;                     // CSYSREQ low
  endproperty
  axi4_errl_csysack_fall: assert property (AXI4_ERRL_CSYSACK_FALL) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRL_CSYSACK_FALL);


  // INDEX:        - AXI4_ERRL_CSYSACK_RISE
  // =====
  property AXI4_ERRL_CSYSACK_RISE;
    @(posedge CSYSACK) disable iff (~`AXI4_SVA_RSTn) // rising edge of CSYSACK
      !($isunknown(CSYSREQ))
      |-> CSYSREQ;                      // CSYSREQ high
  endproperty
  axi4_errl_csysack_rise: assert property (AXI4_ERRL_CSYSACK_RISE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRL_CSYSACK_RISE);


  // INDEX:        - AXI4_ERRL_CSYSREQ_FALL
  // =====
  property AXI4_ERRL_CSYSREQ_FALL;
    @(negedge CSYSREQ) disable iff (~`AXI4_SVA_RSTn) // falling edge of CSYSREQ
      !($isunknown(CSYSACK))
      |-> CSYSACK;                      // CSYSACK high
  endproperty
  axi4_errl_csysreq_fall: assert property (AXI4_ERRL_CSYSREQ_FALL) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRL_CSYSREQ_FALL);


  // INDEX:        - AXI4_ERRL_CSYSREQ_RISE
  // =====
  property AXI4_ERRL_CSYSREQ_RISE;
    @(posedge CSYSREQ) disable iff (~`AXI4_SVA_RSTn) // rising edge of CSYSREQ
      !($isunknown(CSYSACK))
      |-> ~CSYSACK;                     // CSYSACK low
  endproperty
  axi4_errl_csysreq_rise: assert property (AXI4_ERRL_CSYSREQ_RISE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRL_CSYSREQ_RISE);

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI4_ERRL_CACTIVE_X
  // =====
  property AXI4_ERRL_CACTIVE_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(CACTIVE);
  endproperty
  axi4_errl_cactive_x: assert property (AXI4_ERRL_CACTIVE_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRL_CACTIVE_X);


  // INDEX:        - AXI4_ERRL_CSYSACK_X
  // =====
  property AXI4_ERRL_CSYSACK_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(CSYSACK);
  endproperty
  axi4_errl_csysack_x: assert property (AXI4_ERRL_CSYSACK_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRL_CSYSACK_X);


  // INDEX:        - AXI4_ERRL_CSYSREQ_X
  // =====
  property AXI4_ERRL_CSYSREQ_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn
      |-> ! $isunknown(CSYSREQ);
  endproperty
  axi4_errl_csysreq_x: assert property (AXI4_ERRL_CSYSREQ_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRL_CSYSREQ_X);

`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Exclusive Access
// =====
// These are inter-channel rules.
// Supports one outstanding exclusive access per ID
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_EXCL_ALIGN
  // =====
  // Burst lengths that are not a power of two are not checked here, because
  // these will violate EXCLLEN. Checked for excl reads only as 
  // AXI4_RECM_EXCL_PAIR or AXI4_RECM_EXCL_MATCH will fire if an excl write 
  // violates.
  property AXI4_ERRM_EXCL_ALIGN;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARLOCK,ARLEN,ARADDR})) &
      (ARVALID &                                   // valid address
       (ARLOCK == `AXI4PC_ALOCK_EXCL) &            // exclusive transaction
       (ARLEN == `AXI4PC_ALEN_1 ||                 // length is power of 2
        ARLEN == `AXI4PC_ALEN_2 ||
        ARLEN == `AXI4PC_ALEN_4 ||
        ARLEN == `AXI4PC_ALEN_8 ||
        ARLEN == `AXI4PC_ALEN_16))
      |-> ((ARADDR[10:0] & ExclMask) == ARADDR[10:0]); // address aligned
  endproperty
  axi4_errm_excl_align: assert property (AXI4_ERRM_EXCL_ALIGN) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_EXCL_ALIGN);


  // INDEX:        - AXI4_ERRM_EXCL_LEN
  // =====
  // Checked for excl reads only as AXI4_RECM_EXCL_PAIR or AXI4_RECM_EXCL_MATCH
  // will fire if an excl write violates.
  property AXI4_ERRM_EXCL_LEN;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARLOCK,ARLEN})) &
      ARVALID & (ARLOCK == `AXI4PC_ALOCK_EXCL)
      |-> ((ARLEN == `AXI4PC_ALEN_1)  ||
           (ARLEN == `AXI4PC_ALEN_2)  ||
           (ARLEN == `AXI4PC_ALEN_4)  ||
           (ARLEN == `AXI4PC_ALEN_8)  ||
           (ARLEN == `AXI4PC_ALEN_16));
  endproperty
  axi4_errm_excl_len: assert property (AXI4_ERRM_EXCL_LEN) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_EXCL_LEN);


  // INDEX:        - AXI4_RECM_EXCL_MATCH
  // =====
  // Recommendation as it can be affected by software, e.g. if a dummy STREX is 
  // used to clear any outstanding exclusive accesses.
  // User and QOS removed as these may change
  property   AXI4_RECM_EXCL_MATCH;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWLOCK,ExclAwId,ExclAwMatch,AWADDR,AWSIZE,
      AWLEN,AWBURST,AWCACHE,AWPROT,AWREGION})) &
      i_RecommendOn &       // Parameter that can disable all AXI4_REC*_* rules
      AWVALID &   // excl write & excl read outstanding
      (AWLOCK == `AXI4PC_ALOCK_EXCL) & excl_pipe[ExclAwId].ReadAddr 
      & ExclAwMatch
      |-> ((excl_pipe[ExclAwId].Addr   == AWADDR)  &
           (excl_pipe[ExclAwId].Size   == AWSIZE)  &
           (excl_pipe[ExclAwId].Len    == AWLEN)   &
           (excl_pipe[ExclAwId].Burst  == AWBURST) &
           (excl_pipe[ExclAwId].Cache  == AWCACHE) &
           (excl_pipe[ExclAwId].Prot   == AWPROT)  &
           (excl_pipe[ExclAwId].Region == AWREGION)
          );
  endproperty
  axi4_recm_excl_match: assert property (AXI4_RECM_EXCL_MATCH) else
   `ARM_AMBA4_PC_MSG_WARN(`RECM_EXCL_MATCH);


  // INDEX:        - AXI4_ERRM_EXCL_MAX
  // =====
  // Burst lengths that are not a power of two are not checked here, because
  // these will violate EXCLLEN. Bursts of length 1 can never violate this
  // rule. Checked for excl reads only as AXI4_RECM_EXCL_PAIR or 
  // AXI4_RECM_EXCL_MATCH will fire if an excl write violates.
  property AXI4_ERRM_EXCL_MAX;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARLOCK,ARLEN})) &
      (ARVALID &                         // valid address
       (ARLOCK == `AXI4PC_ALOCK_EXCL) &  // exclusive transaction
       (ARLEN == `AXI4PC_ALEN_2 ||       // length is power of 2
        ARLEN == `AXI4PC_ALEN_4 ||
        ARLEN == `AXI4PC_ALEN_8 ||
        ARLEN == `AXI4PC_ALEN_16))
      |-> (ArLenInBytes <= 128 );            // max 128 bytes transferred
  endproperty
  axi4_errm_excl_max: assert property (AXI4_ERRM_EXCL_MAX) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_EXCL_MAX);


  // INDEX:        - AXI4_RECM_EXCL_PAIR
  // =====
  // Recommendation as it can be affected by software, e.g. if a dummy STREX is 
  // used to clear any outstanding exclusive accesses.
  property   AXI4_RECM_EXCL_PAIR;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWLOCK,ExclAwMatch,ExclAwId})) &
      i_RecommendOn & // Parameter that can disable all AXI4_REC*_* rules
      AWVALID & (AWLOCK == `AXI4PC_ALOCK_EXCL) // excl write
      |-> (ExclAwMatch &&
      excl_pipe[ExclAwId].ReadAddr &&
      excl_pipe[ExclAwId].ReadData);               // excl read with same ID complete
  endproperty
  axi4_recm_excl_pair: assert property (AXI4_RECM_EXCL_PAIR) else
   `ARM_AMBA4_PC_MSG_WARN(`RECM_EXCL_PAIR);


  // INDEX:        - AXI4_RECM_EXCL_R_W
  // =====
  //Should not have conurrent exclusive reads and writes with the same ID
  property   AXI4_RECM_EXCL_R_W;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({AWVALID,AWLOCK,AWID,ARVALID,ARLOCK,ARID})) &
      i_RecommendOn & // Parameter that can disable all AXI4_REC*_* rules
      AWVALID & (AWLOCK == `AXI4PC_ALOCK_EXCL) && // excl write
      ARVALID & (ARLOCK == `AXI4PC_ALOCK_EXCL) // excl read
      |-> ARID != AWID;               //IDs not the same
  endproperty
  axi4_recm_excl_r_w: assert property (AXI4_RECM_EXCL_R_W) else
   `ARM_AMBA4_PC_MSG_WARN(`RECM_EXCL_R_W);

//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI4 Rules: USER_* Rules (extension to AXI4)
// =====
// The USER signals are user-defined extensions to the AXI4 spec, so have been
// located separately from the channel-specific rules.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules (none for USER signals)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_AWUSER_STABLE
  // =====
  property AXI4_ERRM_AWUSER_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({AWVALID,AWREADY,AWUSER})) &
      `AXI4_SVA_RSTn & AWVALID & !AWREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(AWUSER);
  endproperty
  axi4_errm_awuser_stable: assert property (AXI4_ERRM_AWUSER_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWUSER_STABLE);


  // INDEX:        - AXI4_ERRM_WUSER_STABLE
  // =====
  property AXI4_ERRM_WUSER_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({WVALID,WREADY,WUSER})) &
      `AXI4_SVA_RSTn & WVALID & !WREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(WUSER);
  endproperty
  axi4_errm_wuser_stable: assert property (AXI4_ERRM_WUSER_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WUSER_STABLE);


  // INDEX:        - AXI4_ERRS_BUSER_STABLE
  // =====
  property AXI4_ERRS_BUSER_STABLE;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      !($isunknown({BVALID,BREADY,BUSER})) &
      `AXI4_SVA_RSTn & BVALID & !BREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(BUSER);
  endproperty
  axi4_errs_buser_stable: assert property (AXI4_ERRS_BUSER_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BUSER_STABLE);


  // INDEX:        - AXI4_ERRM_ARUSER_STABLE
  // =====
  property AXI4_ERRM_ARUSER_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARUSER})) &
      `AXI4_SVA_RSTn & ARVALID & !ARREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(ARUSER);
  endproperty
  axi4_errm_aruser_stable: assert property (AXI4_ERRM_ARUSER_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARUSER_STABLE);


  // INDEX:        - AXI4_ERRS_RUSER_STABLE
  // =====
  property AXI4_ERRS_RUSER_STABLE;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown({RVALID,RREADY,RUSER})) &
      `AXI4_SVA_RSTn & RVALID & !RREADY
      ##1 `AXI4_SVA_RSTn
      |-> $stable(RUSER);
  endproperty
  axi4_errs_ruser_stable: assert property (AXI4_ERRS_RUSER_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RUSER_STABLE);

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default

  // INDEX:        - AXI4_ERRM_AWUSER_X
  // =====
  property AXI4_ERRM_AWUSER_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & AWVALID
      |-> ! $isunknown(AWUSER);
  endproperty
  axi4_errm_awuser_x: assert property (AXI4_ERRM_AWUSER_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWUSER_X);


  // INDEX:        - AXI4_ERRM_WUSER_X
  // =====
  property AXI4_ERRM_WUSER_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & WVALID
      |-> ! $isunknown(WUSER);
  endproperty
  axi4_errm_wuser_x: assert property (AXI4_ERRM_WUSER_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WUSER_X);


  // INDEX:        - AXI4_ERRS_BUSER_X
  // =====
  property AXI4_ERRS_BUSER_X;
    @(posedge `AXI4_SVA_CLK) disable iff ((PROTOCOL == `AXI4PC_AMBA_ACE) || (PROTOCOL == `AXI4PC_AMBA_ACE_LITE))
      `AXI4_SVA_RSTn & BVALID
      |-> ! $isunknown(BUSER);
  endproperty
  axi4_errs_buser_x: assert property (AXI4_ERRS_BUSER_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BUSER_X);


  // INDEX:        - AXI4_ERRM_ARUSER_X
  // =====
  property AXI4_ERRM_ARUSER_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARUSER);
  endproperty
  axi4_errm_aruser_x: assert property (AXI4_ERRM_ARUSER_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARUSER_X);


  // INDEX:        - AXI4_ERRS_RUSER_X
  // =====
  property AXI4_ERRS_RUSER_X;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & RVALID
      |-> ! $isunknown(RUSER);
  endproperty
  axi4_errs_ruser_x: assert property (AXI4_ERRS_RUSER_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RUSER_X);

`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:   4) Zero Width Stability Rules
//------------------------------------------------------------------------------

  // INDEX:        - AXI4_ERRM_AWUSER_TIEOFF
  // =====
  property AXI4_ERRM_AWUSER_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(AWUSER)) &
      `AXI4_SVA_RSTn &
      (AWUSER_WIDTH == 0)
      |=> $stable(AWUSER);
  endproperty
  axi4_errm_awuser_tieoff: assert property (AXI4_ERRM_AWUSER_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWUSER_TIEOFF);


  // INDEX:        - AXI4_ERRM_WUSER_TIEOFF
  // =====
  property AXI4_ERRM_WUSER_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(WUSER)) &
      `AXI4_SVA_RSTn &
      (WUSER_WIDTH == 0)
      |=> $stable(WUSER);
  endproperty
  axi4_errm_wuser_tieoff: assert property (AXI4_ERRM_WUSER_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_WUSER_TIEOFF);


  // INDEX:        - AXI4_ERRS_BUSER_TIEOFF
  // =====
  property AXI4_ERRS_BUSER_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(BUSER)) &
      `AXI4_SVA_RSTn &
      (BUSER_WIDTH == 0)
      |=> $stable(BUSER);
  endproperty
  axi4_errs_buser_tieoff: assert property (AXI4_ERRS_BUSER_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BUSER_TIEOFF);


  // INDEX:        - AXI4_ERRM_ARUSER_TIEOFF
  // =====
  property AXI4_ERRM_ARUSER_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(ARUSER)) &
      `AXI4_SVA_RSTn &
      (ARUSER_WIDTH == 0)
      |=> $stable(ARUSER);
  endproperty
  axi4_errm_aruser_tieoff: assert property (AXI4_ERRM_ARUSER_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARUSER_TIEOFF);


  // INDEX:        - AXI4_ERRS_RUSER_TIEOFF
  // =====
  property AXI4_ERRS_RUSER_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(RUSER)) &
      `AXI4_SVA_RSTn &
      (RUSER_WIDTH == 0)
      |=> $stable(RUSER);
  endproperty
  axi4_errs_ruser_tieoff: assert property (AXI4_ERRS_RUSER_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RUSER_TIEOFF);


  // INDEX:        - AXI4_ERRM_AWID_TIEOFF
  // =====
  property AXI4_ERRM_AWID_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(AWID)) &
      `AXI4_SVA_RSTn &
      (WID_WIDTH == 0)
      |=> $stable(AWID);
  endproperty
  axi4_errm_awid_tieoff: assert property (AXI4_ERRM_AWID_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWID_TIEOFF);


  // INDEX:        - AXI4_ERRS_BID_TIEOFF
  // =====
  property AXI4_ERRS_BID_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(BID)) &
      `AXI4_SVA_RSTn &
      (WID_WIDTH == 0)
      |=> $stable(BID);
  endproperty
  axi4_errs_bid_tieoff: assert property (AXI4_ERRS_BID_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BID_TIEOFF);


  // INDEX:        - AXI4_ERRM_ARID_TIEOFF
  // =====
  property AXI4_ERRM_ARID_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(ARID)) &
      `AXI4_SVA_RSTn &
      (RID_WIDTH == 0)
      |=> $stable(ARID);
  endproperty
  axi4_errm_arid_tieoff: assert property (AXI4_ERRM_ARID_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARID_TIEOFF);

  
  // INDEX:        - AXI4_ERRS_RID_TIEOFF
  // =====
  property AXI4_ERRS_RID_TIEOFF;
    @(posedge `AXI4_SVA_CLK)
      !($isunknown(RID)) &
      `AXI4_SVA_RSTn &
      (RID_WIDTH == 0)
      |=> $stable(RID);
  endproperty
  axi4_errs_rid_tieoff: assert property (AXI4_ERRS_RID_TIEOFF) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RID_TIEOFF);

 //------------------------------------------------------------------------------
// INDEX:   5) EOS checks
//------------------------------------------------------------------------------
final
begin
  `ifndef AXI4PC_EOS_OFF
  fatal_to_warnings = 1;
  $display ("Executing Axi4 End Of Simulation checks");

  // INDEX:        - AXI4_ERRS_BRESP_ALL_DONE_EOS
  // =====
  //property AXI4_ERRS_BRESP_ALL_DONE_EOS;
  axi4_errs_bresp_all_done_eos: 
  assert (WIndex == 1)
  else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_ALL_DONE_EOS);

  // INDEX:        - AXI4_ERRS_RLAST_ALL_DONE_EOS
  // =====
  //property AXI4_ERRS_RLAST_ALL_DONE_EOS;
  axi4_errs_rlast_all_done_eos:
   assert (nROutstanding == 1'b1)
   else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_RLAST_ALL_DONE_EOS);


  `endif
end
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// INDEX:
// INDEX: Auxiliary Logic
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:   1) Rules for Auxiliary Logic
//------------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // INDEX:      a) Master (AUX*)
  //----------------------------------------------------------------------------

  // INDEX:        - AXI4_AUX_DATA_WIDTH
  // =====
  property AXI4_AUX_WDATA_WIDTH;
    @(posedge `AXI4_SVA_CLK)
      (WDATA_WIDTH ==   32 ||
       WDATA_WIDTH ==   64 ||
       WDATA_WIDTH ==  128 ||
       WDATA_WIDTH ==  256 ||
       WDATA_WIDTH ==  512 ||
       WDATA_WIDTH == 1024);
  endproperty
  axi4_aux_wdata_width: assert property (AXI4_AUX_WDATA_WIDTH) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_DATA_WIDTH);

  property AXI4_AUX_RDATA_WIDTH;
    @(posedge `AXI4_SVA_CLK)
      (RDATA_WIDTH ==   32 ||
       RDATA_WIDTH ==   64 ||
       RDATA_WIDTH ==  128 ||
       RDATA_WIDTH ==  256 ||
       RDATA_WIDTH ==  512 ||
       RDATA_WIDTH == 1024);
  endproperty
  axi4_aux_rdata_width: assert property (AXI4_AUX_RDATA_WIDTH) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_DATA_WIDTH);


  // INDEX:        - AXI4_AUX_ADDR_WIDTH
  // =====
//  property AXI4_AUX_ADDR_WIDTH;
//    @(posedge `AXI4_SVA_CLK)
//      (ADDR_WIDTH >= 32 && ADDR_WIDTH <= 64);
//  endproperty
//  axi4_aux_addr_width: assert property (AXI4_AUX_ADDR_WIDTH) else
//   `ARM_AMBA4_PC_MSG_ERR(`AUX_ADDR_WIDTH);


  // INDEX:        - AXI4_AUX_EXMON_WIDTH
  // =====
  property AXI4_AUX_EXMON_WIDTH;
    @(posedge `AXI4_SVA_CLK)
      (EXMON_WIDTH >= 1);
  endproperty
  axi4_aux_exmon_width: assert property (AXI4_AUX_EXMON_WIDTH) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_EXMON_WIDTH);


  // INDEX:        - AXI4_AUX_MAXRBURSTS
  // =====
  property AXI4_AUX_MAXRBURSTS;
    @(posedge `AXI4_SVA_CLK)
      (MAXRBURSTS >= 1);
  endproperty
  axi4_aux_maxrbursts: assert property (AXI4_AUX_MAXRBURSTS) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_MAXRBURSTS);


  // INDEX:        - AXI4_AUX_MAXWBURSTS
  // =====
  property AXI4_AUX_MAXWBURSTS;
    @(posedge `AXI4_SVA_CLK)
      (MAXWBURSTS >= 1);
  endproperty
  axi4_aux_maxwbursts: assert property (AXI4_AUX_MAXWBURSTS) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_MAXWBURSTS);


  // INDEX:        - AXI4_AUX_RCAM_OVERFLOW
  // =====
  property AXI4_AUX_RCAM_OVERFLOW;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(RIndex))
      |-> (RIndex <= (MAXRBURSTS+1));
  endproperty
  axi4_aux_rcam_overflow: assert property (AXI4_AUX_RCAM_OVERFLOW) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_RCAM_OVERFLOW);


  // INDEX:        - AXI4_AUX_RCAM_UNDERFLOW
  // =====
  property AXI4_AUX_RCAM_UNDERFLOW;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(RIndex))
      |-> (RIndex > 0);
  endproperty
  axi4_aux_rcam_underflow: assert property (AXI4_AUX_RCAM_UNDERFLOW) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_RCAM_UNDERFLOW);


  // INDEX:        - AXI4_AUX_WCAM_OVERFLOW
  // =====
  property AXI4_AUX_WCAM_OVERFLOW;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(WIndex))
      |-> (WIndex <= (MAXWBURSTS+1));
  endproperty
  axi4_aux_wcam_overflow: assert property (AXI4_AUX_WCAM_OVERFLOW) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_WCAM_OVERFLOW);


  // INDEX:        - AXI4_AUX_WCAM_UNDERFLOW
  // =====
  property AXI4_AUX_WCAM_UNDERFLOW;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(WIndex))
      |-> (WIndex > 0);
  endproperty
  axi4_aux_wcam_underflow: assert property (AXI4_AUX_WCAM_UNDERFLOW) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_WCAM_UNDERFLOW);


  // INDEX:        - AXI4_AUX_EXCL_OVERFLOW
  // =====
  property AXI4_AUX_EXCL_OVERFLOW;
    @(posedge `AXI4_SVA_CLK)
      `AXI4_SVA_RSTn & !($isunknown(ExclIdOverflow))
      |-> (!ExclIdOverflow);
  endproperty
  axi4_aux_excl_overflow: assert property (AXI4_AUX_EXCL_OVERFLOW) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_EXCL_OVERFLOW);

//------------------------------------------------------------------------------
// INDEX:   2) Combinatorial Logic
//------------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // INDEX:      a) Masks
  //----------------------------------------------------------------------------

  // INDEX:           - AlignMaskR
  // =====
  // Calculate wrap mask for read address
  always @(ARSIZE or ARVALID)
  begin
    if (ARVALID)
      case (ARSIZE)
        `AXI4PC_ASIZE_1024:  AlignMaskR = 7'b0000000;
        `AXI4PC_ASIZE_512:   AlignMaskR = 7'b1000000;
        `AXI4PC_ASIZE_256:   AlignMaskR = 7'b1100000;
        `AXI4PC_ASIZE_128:   AlignMaskR = 7'b1110000;
        `AXI4PC_ASIZE_64:    AlignMaskR = 7'b1111000;
        `AXI4PC_ASIZE_32:    AlignMaskR = 7'b1111100;
        `AXI4PC_ASIZE_16:    AlignMaskR = 7'b1111110;
        `AXI4PC_ASIZE_8:     AlignMaskR = 7'b1111111;
        default:             AlignMaskR = 7'b1111111;
      endcase
    else
      AlignMaskR = 7'b1111111;
  end


  // INDEX:           - AlignMaskW
  // =====
  // Calculate wrap mask for write address
  always @(AWSIZE or AWVALID)
  begin
    if (AWVALID)
      case (AWSIZE)
        `AXI4PC_ASIZE_1024:  AlignMaskW = 7'b0000000;
        `AXI4PC_ASIZE_512:   AlignMaskW = 7'b1000000;
        `AXI4PC_ASIZE_256:   AlignMaskW = 7'b1100000;
        `AXI4PC_ASIZE_128:   AlignMaskW = 7'b1110000;
        `AXI4PC_ASIZE_64:    AlignMaskW = 7'b1111000;
        `AXI4PC_ASIZE_32:    AlignMaskW = 7'b1111100;
        `AXI4PC_ASIZE_16:    AlignMaskW = 7'b1111110;
        `AXI4PC_ASIZE_8:     AlignMaskW = 7'b1111111;
        default:             AlignMaskW = 7'b1111111;
      endcase // case(AWSIZE)
    else
      AlignMaskW = 7'b1111111;
  end


  // INDEX:           - ExclMask
  // =====
  always @(ARLEN or ARSIZE)
  begin : p_ExclMaskComb
    ExclMask = ~((({7'b000_0000, ARLEN} + 15'b000_0000_0000_0001) << ARSIZE) - 15'b000_0000_0000_0001);
  end // block: p_ExclMaskComb


  // INDEX:           - WdataMask
  // =====
  always @(WSTRB)
  begin : p_WdataMaskComb
    integer i;  // data byte loop counter
    integer j;  // data bit loop counter

    for (i = 0; i < STRB_WIDTH; i = i + 1)
      for (j = i * 8; j <= (i * 8) + 7; j = j + 1)
        WdataMask[j] = WSTRB[i];
  end


  // INDEX:           - RdataMask
  // =====
  assign RdataMask = ReadDataMask(RCam[RidMatch].cmd, RCam[RidMatch].Count);


  //----------------------------------------------------------------------------
  // INDEX:      b) Increments
  //----------------------------------------------------------------------------

  // INDEX:           - ArAddrIncr
  // =====
  always @(ARSIZE or ARLEN or ARADDR)
  begin : p_RAddrIncrComb
    ArAddrIncr = ARADDR + (ARLEN << ARSIZE);  // The final address of the burst
  end


  // INDEX:           - AwAddrIncr
  // =====
  always @(AWSIZE or AWLEN or AWADDR)
  begin : p_WAddrIncrComb
    AwAddrIncr = AWADDR + (AWLEN << AWSIZE);  // The final address of the burst
  end


  //----------------------------------------------------------------------------
  // INDEX:      c) Conversions
  //----------------------------------------------------------------------------

  // INDEX:           - ArLenInBytes
  // =====
  always @(ARSIZE or ARLEN)
  begin : p_ArLenInBytes
    // bytes = (ARLEN+1) data transfers x ARSIZE bytes
    ArLenInBytes = (({8'h00, ARLEN} + 16'h001) << ARSIZE); 
  end


  // INDEX:           - ArSizeInBits
  // =====
  always @(ARSIZE)
  begin : p_ArSizeInBits
    ArSizeInBits = (11'b000_0000_1000 << ARSIZE); // bits = 8 x ARSIZE bytes
  end


  // INDEX:           - AwSizeInBits
  // =====
  always @(AWSIZE)
  begin : p_AwSizeInBits
    AwSizeInBits = (11'b000_0000_1000 << AWSIZE); // bits = 8 x AWSIZE bytes
  end


  //----------------------------------------------------------------------------
  // INDEX:      d) Other
  //----------------------------------------------------------------------------

  // INDEX:           - ArExclPending
  // =====
  // Avoid putting on assertion directly as index is an integer
  assign ArExclPending = RCam[RidMatch].cmd.excl;


  // INDEX:           - ArLenPending
  // =====
  // Avoid putting on assertion directly as index is an integer
  assign ArLenPending = {1'b0, RCam[RidMatch].cmd.len};

  // INDEX:           - ArCountPending
  // =====
  // Avoid putting on assertion directly as index is an integer
  assign ArCountPending = RCam[RidMatch].Count;

//------------------------------------------------------------------------------
// INDEX:   3) EXCL Accesses
//------------------------------------------------------------------------------

  // INDEX:        - Exclusive Access ID Lookup
  // =====
  // Map transaction IDs to the available exclusive access storage locations

  // Lookup table for IDs used by the exclusive access monitor
  // Each location in the table has a valid flag to indicate if the ID is in use
  // The location of an ID flagged as valid is used as a virtual ID in the
  // exclusive access monitor checks
  always @(negedge `AXI4_AUX_RSTn or posedge `AXI4_AUX_CLK)
  begin : p_ExclIdSeq
    integer i;  // loop counter
    if (!`AXI4_AUX_RSTn)
    begin
      ExclIdValid <= {EXMON_HI+1{1'b0}};
      ExclIdDelta <= 1'b0;
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        ExclId[i] <= {ID_MAX+1{1'b0}};
      end
    end
    else if (ACLKEN == 1)// clk edge
    begin
      // The write conditions need to be done first. If there is
      // a simultaneous read and write then the read condition must succeed.
      // exclusive write
      if (AWVALID && AWREADY && (AWLOCK == `AXI4PC_ALOCK_EXCL) &&
          ExclAwMatch)
      begin
        ExclIdValid[ExclAwId] <= 1'b0;
        ExclIdDelta <= ~ExclIdDelta;
      end
      // exclusive read address transfer
      if (ARVALID && ARREADY && (ARLOCK == `AXI4PC_ALOCK_EXCL) &&
          !ExclIdFull)
      begin
        ExclId[ExclIdWrPtr] <= ARID;
        ExclIdValid[ExclIdWrPtr] <= 1'b1;
        ExclIdDelta <= ~ExclIdDelta;
      end
    end // else: !if(!`AXI4_AUX_RSTn)
  end // block: p_ExclIdSeq

  // Lookup table is full when all valid bits are set
  assign ExclIdFull = &ExclIdValid;

  // Lookup table overflows when it is full and another exclusive read happens
  // with an ID that does not match any already being monitored
  assign ExclIdOverflow = ExclIdFull &&
                          ARVALID && ARREADY && (ARLOCK == `AXI4PC_ALOCK_EXCL) &&
                          !ExclArMatch;

  // New IDs are written to the highest location
  // that does not have the valid flag set 
  always @(ExclIdValid or ExclIdDelta)
  begin : p_ExclIdFreePtrComb
    integer i;  // loop counter
    ExclIdFreePtr = '0;
    for (i = 0; i <= EXMON_HI; i = i + 1)
    begin
      if (ExclIdValid[i] == 1'b0)
      begin
        ExclIdFreePtr = i;
      end
    end
  end // p_ExclIdFreePtrComb

  // If the ID is already being monitored then reuse the location
  // New IDs are written to the highest location
  // that does not have the valid flag set 
  assign ExclIdWrPtr = ExclArMatch ? ExclArId : ExclIdFreePtr;

  // Write address ID comparator
  always @(AWVALID or AWID or ExclIdValid or ExclIdDelta)
  begin : p_ExclAwMatchComb
    integer i;  // loop counter
    ExclAwMatch = 1'b0;
    ExclAwId = {EXMON_WIDTH{1'b0}};
    if (AWVALID)
    begin
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        if (ExclIdValid[i] && (AWID == ExclId[i]))
        begin
          ExclAwMatch = 1'b1;
          ExclAwId = i;
        end
      end
    end
  end // p_ExclAwMatchComb

  // Read address ID comparator
  always @(ARVALID or ARID or ExclIdValid or ExclIdDelta)
  begin : p_ExclArMatchComb
    integer i;  // loop counter
    ExclArMatch = 1'b0;
    ExclArId = {EXMON_WIDTH{1'b0}};
    if (ARVALID)
    begin
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        if (ExclIdValid[i] && (ARID == ExclId[i]))
        begin
          ExclArMatch = 1'b1;
          ExclArId = i;
        end
      end
    end
  end // p_ExclArMatchComb

  // Read data ID comparator
  always @(RVALID or RID or ExclIdValid or ExclIdDelta)
  begin : p_ExclRMatchComb
    integer i;  // loop counter
    ExclRMatch = 1'b0;
    ExclRId = {EXMON_WIDTH{1'b0}};
    if (RVALID)
    begin
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        if (ExclIdValid[i] && (RID == ExclId[i]))
        begin
          ExclRMatch = 1'b1;
          ExclRId = i;
        end
      end
    end
  end // p_ExclRMatchComb

  // INDEX:        - Exclusive Access Storage
  // =====
  // Store exclusive control info on each read for checking against write

  always @(negedge `AXI4_AUX_RSTn or posedge `AXI4_AUX_CLK)
  begin : p_ExclCtrlSeq
    integer i;  // loop counter

    if (!`AXI4_AUX_RSTn)
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        excl_pipe[i] <= '0;
      end
    else if (ACLKEN == 1) // clk edge
    begin
      // The write conditions need to be done first. If there is
      // a simultaneous read and write then the read condition must succeed.
      // exclusive write
      if (AWVALID && AWREADY && (AWLOCK == `AXI4PC_ALOCK_EXCL) &&
          ExclAwMatch)
      begin
        excl_pipe[ExclAwId].ReadAddr <= 1'b0; // reset exclusive address flag for AWID
        excl_pipe[ExclAwId].ReadData <= 1'b0; // reset exclusive read data flag for AWID
      end
      // completion of exclusive read data transaction
      if ((RVALID && RREADY && RLAST && excl_pipe[ExclRId].ReadAddr &&
           ExclRMatch) &&
           // check the read CAM that this is part of an exclusive transfer 
           RCam[RidMatch].cmd.excl
         )
        excl_pipe[ExclRId].ReadData  <= (RRESP == `AXI4PC_RESP_EXOKAY); // set exclusive read data flag for RID
      // exclusive read address transfer
      if (ARVALID && ARREADY && (ARLOCK == `AXI4PC_ALOCK_EXCL) &&
          (!ExclIdFull || ExclArMatch) )
      begin
        excl_pipe[ExclIdWrPtr].ReadAddr              <= 1'b1; // set exclusive read addr flag for ARID
        excl_pipe[ExclIdWrPtr].ReadData              <= 1'b0; // reset exclusive read data flag for ARID
        excl_pipe[ExclIdWrPtr].Addr                  <= ARADDR;
        excl_pipe[ExclIdWrPtr].Size                  <= ARSIZE;
        excl_pipe[ExclIdWrPtr].Len                   <= ARLEN;
        excl_pipe[ExclIdWrPtr].Burst                 <= ARBURST;
        excl_pipe[ExclIdWrPtr].Cache                 <= ARCACHE;
        excl_pipe[ExclIdWrPtr].Prot                  <= ARPROT;
        excl_pipe[ExclIdWrPtr].Qos                   <= ARQOS;
        excl_pipe[ExclIdWrPtr].Region                <= ARREGION;
        excl_pipe[ExclIdWrPtr].User                  <= ARUSER;
      end
    end // else: !if(!`AXI4_AUX_RSTn)
  end // block: p_ExclCtrlSeq

//------------------------------------------------------------------------------
// INDEX:   4) Content addressable memories (CAMs)
//------------------------------------------------------------------------------

  // INDEX:        - Read CAMSs (CAM+Shift)
  // =====
  // New entries are added at the end of the CAM.
  // Elements may be removed from any location in the CAM, determined by the
  // first matching RID. When an element is removed, remaining elements
  // with a higher index are shifted down to fill the empty space.

  // Read CAMs store all outstanding addresses for read transactions
  assign RPush  = ARVALID & ARREADY;        // Push on address handshake
  assign RPop   = RVALID & RREADY & RLAST;  // Pop on last handshake

  // Flag when there are no outstanding read transactions
  assign nROutstanding = (RIndex == 1);

  // Find the index of the first item in the CAM that matches the current RID
  // (Note that RIdCamDelta is used to determine when RIdCam has changed)
  always @(RID or RIndex or RIdCamDelta)
  begin : p_RidMatch
    integer i;  // loop counter
    RidMatch = '0;
    for (i=MAXRBURSTS; i>0; i--)
      if ((i < RIndex) && (RID == RCam[i].cmd.id))
        RidMatch = i;
  end

  // Calculate the index of the next free element in the CAM
  always @(RIndex or RPop or RPush)
  begin : p_RIndexNextComb
    case ({RPush,RPop})
      2'b00   : RIndexNext = RIndex;      // no push, no pop
      2'b01   : RIndexNext = RIndex - 1;  // pop, no push
      2'b10   : RIndexNext = RIndex + 1;  // push, no pop
      2'b11   : RIndexNext = RIndex;      // push and pop
//      default : RIndexNext = 'bX;         // X-propagation
    endcase
  end
  
  // RIndex Register
  always @(negedge `AXI4_AUX_RSTn or posedge `AXI4_AUX_CLK)
  begin : p_RIndexSeq
    if (!`AXI4_AUX_RSTn)
      RIndex <= 1;
    else if (ACLKEN == 1)
      RIndex <= RIndexNext;
  end
  
  // CAM Implementation
  always @(negedge `AXI4_AUX_RSTn or posedge `AXI4_AUX_CLK)
  begin : p_ReadCam
    t_cmd_message Burst; // temporary store for burst data structure
    if (!`AXI4_AUX_RSTn)
    begin : p_ReadCamReset
      integer i;  // loop counter
      // Reset all the entries in the CAM
      for (i=1; i<=MAXRBURSTS; i++)
      begin
        RCam[i].cmd <= '0;
        RCam[i].Count <= 9'h0;
        RIdCamDelta  <= 1'b0;
      end //for (i=1; i<=MAXBURSTS; i++)
    end //p_ReadCamReset 
    else if (ACLKEN == 1)
    begin

      // Pop item from the CAM, at location determined by RidMatch
      if (RPop)
      begin : p_ReadCamPop
        integer i;  // loop counter
        for (i=1; i<MAXRBURSTS; i++)
          if (i >= RidMatch)
          begin
              RCam[i].cmd <= RCam[i+1].cmd;
              RCam[i].Count <= RCam[i+1].Count;
              RIdCamDelta  <= ~RIdCamDelta;
          end //for (i=1; i<MAXRBURSTS; i++)
      end //p_ReadCamPop
      else if (RVALID & RREADY)
      // if not last data item, increment beat count
      begin
        RCam[RidMatch].Count <= RCam[RidMatch].Count + 9'b0_0000_0001;
      end

      if (ARVALID)
      begin
          Burst.addr             = ARADDR[6:0];
          Burst.excl             = (ARLOCK == `AXI4PC_ALOCK_EXCL);
          Burst.burst            = ARBURST;
          Burst.len              = ARLEN;
          Burst.size             = ARSIZE;
          Burst.id               = ARID;

          // Push item at end of the CAM
          // Note that the value of the final index in the CAM is depends on
          // whether another item has been popped
          if (RPush)
          begin
            if (RPop)
            begin
              RCam[RIndex-1].cmd <= Burst;
              RCam[RIndex-1].Count <= 9'h00;
            end
            else
            begin
              RCam[RIndex].cmd   <= Burst;
              RCam[RIndex].Count   <= 9'h00;
            end // else: !if(RPop)
            RIdCamDelta <= ~RIdCamDelta;
          end // if (RPush)
      end // if (ARVALID)
    end // else: if(!`AXI4_AUX_RSTn)
  end // always @(negedge `AXI4_AUX_RSTn or posedge `AXI4_AUX_CLK)


  always @(*)
  begin : p_AIDMatch
    integer i;  // loop counter
    AIDMatch = WIndex;
    for (i=MAXWBURSTS; i>0 ; i--)
      if (i < WIndex)                  // only consider valid entries in WBurstCam
      begin
        if (~WCam[i].WAddr)              // write address not already transferred
          AIDMatch = i;
      end
  end


  always @(*)
  begin : p_WIDMatch
    integer i;  // loop counter
    WIDMatch = WIndex;
    for (i=MAXWBURSTS; i>0 ; i--)
      if ((i < WIndex) && ~WCam[i].WLast )
        WIDMatch = i ;
  end
  assign WIDMatch_next = (AwPop && (BIDMatch < WIDMatch)) ? WIDMatch -1 : WIDMatch;
  assign AIDMatch_next = (AwPop && (BIDMatch < AIDMatch)) ? AIDMatch -1 : AIDMatch;


  // Find the index of the first item in the CAM that matches the current BID
  // that has seen WLAST
  always @(*)
  begin : p_BIDMatch
    integer i;  // loop counter
    BIDMatch = WIndex;
    for (i=MAXWBURSTS; i>0 ; i--)
      if (i < WIndex) 
      begin
        if (BID == WCam[i].xfer.cmd.id && ~WCam[i].BResp)  
        begin
          BIDMatch = i;
        end
      end
  end

  //
  // assert protocol error flag if address received after leading write
  // data and:
  // - WLAST was asserted when the beat count is less than AWLEN
  // - WLAST was not asserted when the beat count is equal to AWLEN
  // - the beat count is greater than AWLEN
  //always @(*)
  always @(AWVALID or WCam[AIDMatch].WLast or WCam[AIDMatch].WCount or AIDMatch or AWLEN or WLAST or WVALID or WIDMatch)
  begin : p_AWDataNumError
    if (AWVALID)
    begin
      if ((WCam[AIDMatch].WLast & 
      (({1'b0, AWLEN} + 9'b000000001) > WCam[AIDMatch].WCount))
      ||
      (WVALID & WLAST && (WCam[AIDMatch].WCount < AWLEN) & (AIDMatch == WIDMatch)) )
      begin
        AWDataNumError1 = 1'b1;
      end
      else
      begin
          AWDataNumError1 = 1'b0;
      end
      
      if ((~WCam[AIDMatch].WLast & 
        (({1'b0, AWLEN} + 9'b000000001) == WCam[AIDMatch].WCount))
         ||
         (WVALID & ~WLAST & (WCam[AIDMatch].WCount == AWLEN) & (AIDMatch == WIDMatch)))
      begin
        AWDataNumError2 = 1'b1;
      end
      else
      begin
          AWDataNumError2 = 1'b0;
      end
      
      if (({1'b0, AWLEN} + 9'b000000001) < WCam[AIDMatch].WCount)
      begin
        AWDataNumError3 = 1'b1;
      end
      else
      begin
          AWDataNumError3 = 1'b0;
      end
    end
    else
    begin
        AWDataNumError1 = 1'b0;
        AWDataNumError2 = 1'b0;
        AWDataNumError3 = 1'b0;
    end
  end


  // if last data item or correct number of data items received already,
  // check number of data items and WLAST against AWLEN.
  // WCount hasn't yet incremented so can be compared with AWLEN
  always @(WVALID or WLAST or WCam[WIDMatch].WAddr or WCam[WIDMatch].WCount or WCam[WIDMatch].xfer.cmd.len or WIDMatch)
  begin : p_WDataNumError
    if (WVALID)
    begin
      if   (WCam[WIDMatch].WAddr &       // Only perform test if address is known
            ( (WLAST & (WCam[WIDMatch].WCount != {1'b0,WCam[WIDMatch].xfer.cmd.len}))) )
      begin
        WDataNumError1 = 1'b1;
      end
      else
      begin
        WDataNumError1 = 1'b0;
      end
      if  ( WCam[WIDMatch].WAddr &       // Only perform test if address is known
              (~WLAST & (WCam[WIDMatch].WCount == {1'b0,WCam[WIDMatch].xfer.cmd.len})))
      begin
        WDataNumError2 = 1'b1;
      end
      //else if (AWVALID & (AIDMatch == WIDMatch) & ~WLAST & (WCam[WIDMatch].WCount == AWLEN))
      else
      begin
        WDataNumError2 = 1'b0;
      end
    end
    else
    begin
      WDataNumError1 = 1'b0;
      WDataNumError2 = 1'b0;
    end
  end
  // INDEX:        - Write CAMs (CAM+Shift)
  // =====
  // New entries are added at the end of the CAM.
  // Elements may be removed from any location in the CAM, determined by the
  // first matching WID and/or BID. When an element is removed, remaining
  // elements with a higher index are shifted down to fill the empty space.

  assign AwPop = BVALID && BREADY ;

  // Write bursts stored in single structure for checking when complete.
  // This avoids the problem of early write data.
  
  t_wburst_message WrBurst;
  initial begin
    WrBurst = '0;
  end
  
  always @(negedge `AXI4_AUX_RSTn or posedge `AXI4_AUX_CLK)
  begin : p_WriteCam
    t_wburst_message  Burst;
    integer i;               // loop counter
    if (!`AXI4_AUX_RSTn) begin : p_WriteCamReset
      for (i=1; i<=MAXWBURSTS; i++)
      begin
        WCam[i].WCount <= '0;
        WCam[i].WLast <= '0;
        WCam[i].WAddr <= '0;
        WCam[i].BResp <= '0;
        WCam[i].xfer <= '0;
      end

      WIndex   = 1;
      WrBurst <= '0;
   end
    else
    begin

      // -----------------------------------------------------------------------
      // Valid write response
      if (BVALID)
      begin


        WrBurst = WCam[BIDMatch].xfer;
        WCam[BIDMatch].BResp <= BREADY;         // record if write response completed

          // Write response handshake completes burst when write address has
          // already been received, and triggers protocol checking
          // WlastCam added for AXI4. 
          if ((BREADY & WCam[BIDMatch].WAddr) & (WCam[BIDMatch].WLast) )
          begin : p_WriteCamPopB
            // pop completed burst from CAM
            for (i = 1; i < MAXWBURSTS; i++)
            begin
              if (i >= BIDMatch)             // only shift items after popped burst
              begin
                WCam[i]    <= WCam[i+1];
              end
            end

            WIndex--;             // decrement index

            // Reset flags on new empty element
            WCam[WIndex].xfer              <= '0;
            WCam[WIndex].WCount            <= 9'b0;
            WCam[WIndex].WLast             <= 1'b0;
            WCam[WIndex].WAddr             <= 1'b0;
            WCam[WIndex].BResp             <= 1'b0;

          //end // if (BREADY & WCam[BIDMatch].WAddr)

        end // else !(~(BIDMatch < WIndex))
      end // if (BVALID)



      // -----------------------------------------------------------------------
      // Valid write data
      if (WVALID)
      begin : p_WriteCamWValid


        WrBurst = WCam[WIDMatch].xfer;

        // need to use full case statement to occupy WSTRB as in Verilog the
        // bit slice range must be bounded by constant expressions
        if (WCam[WIDMatch].WCount > 9'hFF) begin
          WrBurst.strb[WCam[WIDMatch].WCount * STRB_WIDTH+:STRB_WIDTH] = {STRB_WIDTH{1'bx}};
        end else begin
          WrBurst.strb[WCam[WIDMatch].WCount* STRB_WIDTH+:STRB_WIDTH] = WSTRB;
        end

        WCam[WIDMatch_next].xfer <= WrBurst;          // copy back from temp store
        // when write data transfer completes, determine if last
        WCam[WIDMatch_next].WLast <= WLAST & WREADY; // record whether last data completed

        // When transfer completes, increment the count
        WCam[WIDMatch_next].WCount <=
          WREADY ? WCam[WIDMatch].WCount + 9'b000000001:  // inc count
                   WCam[WIDMatch].WCount;


        if (WIDMatch_next == WIndex)              // if new burst, increment CAM index
          WIndex++;

      end // if (WVALID)

      // -----------------------------------------------------------------------
      // Valid write address
      if (AWVALID)
      begin : p_WriteCamAWVALID


        //if WVALID and AWVALID for the same transaction then the WVALID
        //assignments in section above will not have been assigned so will
        //lose strobe information
        if(!(WVALID & (AIDMatch == WIDMatch))) begin
          WrBurst = WCam[AIDMatch].xfer;
        end
        WrBurst.cmd.addr         = AWADDR[6:0];
        WrBurst.cmd.excl         = (AWLOCK == `AXI4PC_ALOCK_EXCL);
        WrBurst.cmd.burst        = AWBURST;
        WrBurst.cmd.len          = AWLEN;
        WrBurst.cmd.size         = AWSIZE;
        WrBurst.cmd.id           = AWID;

        WCam[AIDMatch_next].xfer      <= WrBurst;         // copy back from temp store
        WCam[AIDMatch_next].WAddr <= AWREADY;        // record if write address completed
        // If new burst, increment CAM index
        if (AIDMatch_next == WIndex)
        begin
          WIndex++;
        end
      end // p_WriteCamAWVALID new write address

    end // else: !if(!`AXI4_AUX_RSTn)
  end // always @(negedge `AXI4_AUX_RSTn or posedge `AXI4_AUX_CLK)
  

//------------------------------------------------------------------------------
// INDEX:   5) Verilog Functions
//------------------------------------------------------------------------------
// INDEX:        - function integer clogb2 (input integer n)
// function to determine ceil of log2(n)
//-----------------------------------------------------------------------------
  function integer clogb2 (input integer n);
    begin
      for (clogb2=0; n>0; clogb2++)
        n = n >> 1;
    end
  endfunction


  // INDEX:        - CheckBurst
  // =====
  // Inputs: Burst (burst data structure)
  //         Count (number of data items)
  // Returns: High is any of the write strobes are illegal
  // Calls CheckStrb to test each WSTRB value.
  //------------------------------------------------------------------------------
  function CheckBurst;
    input t_wburst_message  Burst;
    input         [9:0] Count;         // number of beats in the burst
    integer             loop_ctr;          // general loop counter
    integer             NumBytes;      // number of bytes in the burst
    reg           [6:0] StartAddr;     // start address of burst
    reg           [6:0] StrbAddr;      // address used to check WSTRB
    reg           [2:0] StrbSize;      // size used to check WSTRB
    reg           [7:0] StrbLen;       // length used to check WSTRB
    reg    [STRB_MAX:0] Strb;          // WSTRB to be checked
    reg           [9:0] WrapMaskWide;  // address mask for wrapping bursts
    reg           [6:0] WrapMask;      // relevant bits WrapMaskWide
  begin

    StartAddr   = Burst.cmd.addr;
    StrbAddr    = StartAddr;   // incrementing address initialises to start addr
    StrbSize    = Burst.cmd.size;
    StrbLen     = Burst.cmd.len;

    CheckBurst  = 1'b0;

    // Initialize to avoid latch warnings (not really latches as they are set in loop)
    Strb         = {STRB_WIDTH{1'bX}};
    WrapMask     =          {7{1'bX}};
    WrapMaskWide =         {10{1'bX}};

    // determine the number of bytes in the burst for wrapping purposes
    NumBytes = (StrbLen + 1) << StrbSize;

    // Check the strobe for each write data transfer
    for (loop_ctr=0; loop_ctr<256; loop_ctr++)
    begin
      if (loop_ctr <= Count)               // Only consider entries up to burst length
      begin
        Strb = Burst.strb >> (loop_ctr * STRB_WIDTH);

        // returns high if any strobes are illegal
        if (CheckStrb(StrbAddr, StrbSize, Strb))
        begin
          CheckBurst = 1'b1;
        end

        // -----------------------------------------------------------------------
        // Increment aligned StrbAddr
        if (Burst.cmd.burst != `AXI4PC_ABURST_FIXED)
          // fixed bursts don't increment or align the address
        begin
          // align and increment address,
          // Address is incremented from an aligned version
          StrbAddr = StrbAddr &
            (7'b111_1111 - (7'b000_0001 << StrbSize) + 7'b000_0001);
                                                                // align to size
          StrbAddr = StrbAddr + (7'b000_0001 << StrbSize);      // increment
        end // if (Burst.cmd.burst != `AXI4PC_ABURST_FIXED)

        // for wrapping bursts the top bits of the strobe address remain
        // unchanged
        if (Burst.cmd.burst == `AXI4PC_ABURST_WRAP)
        begin
          WrapMaskWide = (10'b11_1111_1111 - NumBytes + 10'b00_0000_0001);
          // To wrap the address, need 10 bits
          WrapMask = WrapMaskWide[6:0];
          // Only 7 bits of address are necessary to calculate strobe
          StrbAddr = (StartAddr & WrapMask) | (StrbAddr & ~WrapMask);
          // upper bits remain stable for wrapping bursts depending on the
          // number of bytes in the burst
        end
      end // if (loop_ctr < Count)
    end // for (loop_ctr=1; loop_ctr<=256; loop_ctr=loop_ctr+1)
  end
  endfunction // CheckBurst


  // INDEX:        - CheckStrb
  // =====
  function CheckStrb;
    input        [6:0] StrbAddr;
    input        [2:0] StrbSize;
    input [STRB_MAX:0] Strb;
    reg   [STRB_MAX:0] StrbMask;
  begin

    // The basic strobe for an aligned address
    StrbMask = (STRB_1 << (STRB_1 << StrbSize)) - STRB_1;

    // Zero the unaligned byte lanes
    // Note: the number of unaligned byte lanes is given by:
    // (StrbAddr & ((1 << StrbSize) - 1)), i.e. the unaligned part of the
    // address with respect to the transfer size
    //
    // Note! {{STRB_MAX{1'b0}}, 1'b1} gives 1 in the correct vector length

    StrbMask = StrbMask &                   // Mask off unaligned byte lanes
      (StrbMask <<                          // shift the strb mask left by
        (StrbAddr & ((STRB_1 << StrbSize) -  STRB_1))
                                            // the number of unaligned byte lanes
      );

    // Shift mask into correct byte lanes
    // Note: (STRB_MAX << StrbSize) & STRB_MAX is used as a mask on the address
    // to pick out the bits significant bits, with respect to the bus width and
    // transfer size, for shifting the mask to the correct byte lanes.
    StrbMask = StrbMask << (StrbAddr & ((STRB_MAX << StrbSize) & STRB_MAX));

    // check for strobe error
    CheckStrb = (|(Strb & ~StrbMask));

  end
  endfunction // CheckStrb


  // INDEX:        - ReadDataMask
  // =====
  // Inputs: Burst (Burst data structure)
  //         Beat  (Data beat number)
  // Returns: Read data mask for valid byte lanes.
  //----------------------------------------------------------------------------
  function [RDATA_MAX:0]  ReadDataMask;
    input t_cmd_message  Burst;         // burst vector
    input [9:0]          Beat;          // beat number in the burst (1-256)
    reg   [11:0]         bit_count;
    reg   [RDATA_MAX+1:0] byte_mask;
  begin
    bit_count = ByteCount(Burst, Beat) << 3;
    byte_mask = (1'b1 << bit_count) - 1;
    // Result is the valid byte mask shifted by the calculated bit shift
    ReadDataMask = byte_mask[RDATA_MAX:0] << (ByteShift(Burst, Beat)*8);
  end
  endfunction // ReadDataMask


  // INDEX:        - ByteShift
  // =====
  // Inputs: Burst (Burst data structure)
  //         Beat  (Data beat number)
  // Returns: Byte Shift for valid byte lanes.
  //------------------------------------------------------------------------------
  function [RDATA_MAX:0] ByteShift;
    input t_cmd_message Burst;         // burst vector
    input [9:0]        Beat;           // beat number in the burst (1-256)
    reg   [6:0]        axaddr;
    reg   [2:0]        axsize;
    reg   [7:0]        axlen;
    reg   [1:0]        axburst;
    integer bus_data_bytes;
    integer length;
    integer unaligned_byte_shift;
    integer beat_addr_inc;
    integer addr_trans_bus;
    integer addr_trans_bus_inc;
    integer wrap_point;
    integer transfer_byte_shift;
  begin
    axaddr  = Burst.addr;
    axsize  = Burst.size;
    axlen   = Burst.len;
    axburst = Burst.burst;

    bus_data_bytes = RDATA_WIDTH/8;

    length = axlen + 1;

    // Number of bytes that the data needs to be shifted when
    // the address is unaligned
    unaligned_byte_shift =
      axaddr &                        // Byte address
      ((1<<axsize)-1);                //   masked by the number of bytes
                                      //   in a transfer

    // Burst beat address increment
    beat_addr_inc = 0;
    // For a FIXED burst ther is no increment
    // For INCR and WRAP it is the beat number minus 1
    if (axburst != 0)
    begin
      beat_addr_inc = Beat;
    end

    // Transfer address within data bus
    // The root of the transfer address within the data bus is byte address
    // divided by the number of bytes in each transfer. This is also masked
    // so that the upper bits that do not control the byte shift are not
    // included.
    addr_trans_bus = (axaddr & (bus_data_bytes - 1))>>axsize;

    // The address may increment with each beat. The increment will be zero
    // for a FIXED burst.
    addr_trans_bus_inc = addr_trans_bus + beat_addr_inc;

    // Modify the byte shift for wrapping bursts
    if (axburst == 2)
    begin
      // The upper address of the transfer before wrapping
      wrap_point = length + (addr_trans_bus & ~(length - 1));
      // If adding the beat number to the transfer address causes it to
      // pass the upper wrap address then wrap to the lower address.
      if (addr_trans_bus_inc >= wrap_point)
      begin
        addr_trans_bus_inc = addr_trans_bus_inc - length;
      end
    end

    // Address calculation may exceed the number of transfers that can fit
    // in the data bus for INCR bursts. So the calculation is truncated to
    // make the byte shift wrap round to zero. 
    addr_trans_bus_inc = addr_trans_bus_inc & ((bus_data_bytes-1)>>axsize);

    // Number of bytes that the data needs to be shifted when
    // the transfer size is less than the data bus width
    transfer_byte_shift = (1<<axsize) *      // Number of bytes in a transfer
                          addr_trans_bus_inc;// Transfer address within data bus

    // For a FIXED burst or on the frist beat of an INCR burst
    // shift the data if the address is unaligned
    if ((axburst == 0) || ((axburst == 1) && (Beat == 0)))
    begin
      ByteShift = transfer_byte_shift + unaligned_byte_shift;
    end
    else
    begin
      ByteShift = transfer_byte_shift;
    end
  end
  endfunction // ByteShift


  // INDEX:        - ByteCount
  // =====
  // Inputs: Burst (Burst data structure)
  //         Beat  (Data beat number)
  // Returns: Byte Count of valid byte lanes.
  //----------------------------------------------------------------------------
  function [7:0] ByteCount;
    input t_cmd_message Burst;         // burst vector
    input [9:0]        Beat;           // beat number in the burst (1-256)
    reg   [6:0]        axaddr;
    reg   [2:0]        axsize;
    reg   [7:0]        axlen;
    reg   [1:0]        axburst;
    integer bus_data_bytes;
    integer unaligned_byte_shift;
  begin
    axaddr  = Burst.addr;
    axsize  = Burst.size;
    axlen   = Burst.len;
    axburst = Burst.burst;

    bus_data_bytes = RDATA_WIDTH/8;

    // Number of bytes that the data needs to be shifted when
    // the address is unaligned
    unaligned_byte_shift =
      axaddr &              // Byte address
      ((1<<axsize)-1);      //   masked by the number of bytes
                            //   in a transfer

    // The number of valid bits depends on the transfer size.
    ByteCount = (1<<axsize);
    // For FIXED bursts or on the first beat of an INCR burst
    // if the address is unaligned modify the number of
    // valid strobe bits
    if ((axburst == 0) || (Beat == 0))
    begin
      // The number of valid bits depends on the transfer size
      // and the offset of the unaligned address.
      ByteCount = ByteCount - unaligned_byte_shift;
    end
  end
  endfunction // ByteCount



//------------------------------------------------------------------------------
// INDEX: End of File
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// INDEX:   1) Clear Verilog Defines
//------------------------------------------------------------------------------

  // Error and Warning Messages
  `undef ARM_AMBA4_PC_MSG_ERR
  `undef ARM_AMBA4_PC_MSG_WARN

  // Clock and Reset
  `undef AXI4_AUX_CLK
  `undef AXI4_SVA_CLK
  `undef AXI4_AUX_RSTn
  `undef AXI4_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   2) End of module
//------------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//  Purpose             : AXI4 SV Protocol Assertions undefines
//=============================================================================

//-----------------------------------------------------------------------------
// AXI Constants
//-----------------------------------------------------------------------------

`ifdef axi_vip_v1_0_1_AXI4PC_TYPES
  `undef axi_vip_v1_0_1_AXI4PC_TYPES
  // ALEN Encoding
  `undef AXI4PC_ALEN_1  
  `undef AXI4PC_ALEN_2  
  `undef AXI4PC_ALEN_3  
  `undef AXI4PC_ALEN_4  
  `undef AXI4PC_ALEN_5  
  `undef AXI4PC_ALEN_6  
  `undef AXI4PC_ALEN_7  
  `undef AXI4PC_ALEN_8  
  `undef AXI4PC_ALEN_9  
  `undef AXI4PC_ALEN_10 
  `undef AXI4PC_ALEN_11 
  `undef AXI4PC_ALEN_12 
  `undef AXI4PC_ALEN_13 
  `undef AXI4PC_ALEN_14 
  `undef AXI4PC_ALEN_15 
  `undef AXI4PC_ALEN_16 

  // ASIZE Encoding
  `undef AXI4PC_ASIZE_8      
  `undef AXI4PC_ASIZE_16     
  `undef AXI4PC_ASIZE_32     
  `undef AXI4PC_ASIZE_64     
  `undef AXI4PC_ASIZE_128    
  `undef AXI4PC_ASIZE_256    
  `undef AXI4PC_ASIZE_512    
  `undef AXI4PC_ASIZE_1024   

  // ABURST Encoding
  `undef AXI4PC_ABURST_FIXED 
  `undef AXI4PC_ABURST_INCR   
  `undef AXI4PC_ABURST_WRAP   

  // ALOCK Encoding
  `undef AXI4PC_ALOCK_EXCL

  // RRESP / BRESP Encoding
  `undef AXI4PC_RESP_OKAY         
  `undef AXI4PC_RESP_EXOKAY       
  `undef AXI4PC_RESP_SLVERR       
  `undef AXI4PC_RESP_DECERR       
  
  //define the protocol
  `undef AXI4PC_AMBA_AXI4        
  `undef AXI4PC_AMBA_ACE         
  `undef AXI4PC_AMBA_ACE_LITE    
  `undef AXI4PC_AMBA_AXI4LITE    
  `undef AXI4PC_AMBA_AXI3        
`endif

// --========================= End ===========================================--
//  ----------------------------------------------------------------------------
//  Purpose             : AXI4 SV Protocol Assertions Error Message undefines
//  ========================================================================--


`ifdef axi_vip_v1_0_1_AXI4PC_MESSAGES
  `undef axi_vip_v1_0_1_AXI4PC_MESSAGES
  `undef ERRM_AWADDR_BOUNDARY      
  `undef ERRM_AWADDR_WRAP_ALIGN    
  `undef ERRM_AWBURST              
  `undef ERRM_AWCACHE              
  `undef ERRM_ARCACHE              
  `undef ERRM_AWLEN_WRAP           
  `undef ERRM_AWSIZE               
  `undef ERRM_AWVALID_RESET        
  `undef ERRM_AWADDR_STABLE        
  `undef ERRM_AWBURST_STABLE       
  `undef ERRM_AWCACHE_STABLE       
  `undef ERRM_AWID_STABLE          
  `undef ERRM_AWLEN_STABLE         
  `undef ERRM_AWLOCK_STABLE        
  `undef ERRM_AWPROT_STABLE        
  `undef ERRM_AWSIZE_STABLE        
  `undef ERRM_AWQOS_STABLE         
  `undef ERRM_AWREGION_STABLE      
  `undef ERRM_AWVALID_STABLE       
  `undef ERRM_AWADDR_X             
  `undef ERRM_AWBURST_X            
  `undef ERRM_AWCACHE_X            
  `undef ERRM_AWID_X               
  `undef ERRM_AWLEN_X              
  `undef ERRM_AWLOCK_X             
  `undef ERRM_AWPROT_X             
  `undef ERRM_AWSIZE_X             
  `undef ERRM_AWQOS_X              
  `undef ERRM_AWREGION_X           
  `undef ERRM_AWVALID_X            
  `undef ERRS_AWREADY_X            
  `undef ERRM_WDATA_NUM            
  `undef ERRM_WSTRB                
  `undef ERRM_WVALID_RESET         
  `undef ERRM_WDATA_STABLE         
  `undef ERRM_WLAST_STABLE         
  `undef ERRM_WSTRB_STABLE         
  `undef ERRM_WVALID_STABLE        
  `undef ERRM_WDATA_X              
  `undef ERRM_WLAST_X              
  `undef ERRM_WSTRB_X              
  `undef ERRM_WVALID_X             
  `undef ERRS_WREADY_X             
  `undef ERRS_BRESP_WLAST          
  `undef ERRS_BRESP_ALL_DONE_EOS   
  `undef ERRS_BRESP_EXOKAY         
  `undef ERRS_BVALID_RESET         
  `undef ERRS_BRESP_AW             
  `undef ERRS_BID_STABLE           
  `undef ERRS_BRESP_STABLE         
  `undef ERRS_BVALID_STABLE        
  `undef ERRM_BREADY_X             
  `undef ERRS_BID_X                
  `undef ERRS_BRESP_X              
  `undef ERRS_BVALID_X             
  `undef ERRM_ARADDR_BOUNDARY      
  `undef ERRM_ARADDR_WRAP_ALIGN    
  `undef ERRM_ARBURST              
  `undef ERRM_ARLEN_FIXED          
  `undef ERRM_AWLEN_FIXED          
  `undef ERRM_AWLEN_LOCK           
  `undef ERRM_ARLEN_LOCK           
  `undef ERRM_ARLEN_WRAP           
  `undef ERRM_ARSIZE               
  `undef ERRM_ARVALID_RESET        
  `undef ERRM_ARADDR_STABLE        
  `undef ERRM_ARBURST_STABLE       
  `undef ERRM_ARCACHE_STABLE       
  `undef ERRM_ARID_STABLE          
  `undef ERRM_ARLEN_STABLE         
  `undef ERRM_ARLOCK_STABLE        
  `undef ERRM_ARPROT_STABLE        
  `undef ERRM_ARSIZE_STABLE        
  `undef ERRM_ARQOS_STABLE         
  `undef ERRM_ARREGION_STABLE      
  `undef ERRM_ARVALID_STABLE       
  `undef ERRM_ARADDR_X             
  `undef ERRM_ARBURST_X            
  `undef ERRM_ARCACHE_X            
  `undef ERRM_ARID_X               
  `undef ERRM_ARLEN_X              
  `undef ERRM_ARLOCK_X             
  `undef ERRM_ARPROT_X             
  `undef ERRM_ARSIZE_X             
  `undef ERRM_ARQOS_X              
  `undef ERRM_ARREGION_X           
  `undef ERRM_ARVALID_X            
  `undef ERRS_ARREADY_X            
  `undef ERRS_RDATA_NUM            
  `undef ERRS_RLAST_ALL_DONE_EOS   
  `undef ERRS_RID                  
  `undef ERRS_RRESP_EXOKAY         
  `undef ERRS_RVALID_RESET         
  `undef ERRS_RDATA_STABLE         
  `undef ERRS_RID_STABLE           
  `undef ERRS_RLAST_STABLE         
  `undef ERRS_RRESP_STABLE         
  `undef ERRS_RVALID_STABLE        
  `undef ERRS_RDATA_X              
  `undef ERRM_RREADY_X             
  `undef ERRS_RID_X                
  `undef ERRS_RLAST_X              
  `undef ERRS_RRESP_X              
  `undef ERRS_RVALID_X             
  `undef ERRL_CSYSACK_FALL         
  `undef ERRL_CSYSACK_RISE         
  `undef ERRL_CSYSREQ_FALL         
  `undef ERRL_CSYSREQ_RISE         
  `undef ERRL_CACTIVE_X            
  `undef ERRL_CSYSACK_X            
  `undef ERRL_CSYSREQ_X            
  `undef ERRM_EXCL_ALIGN           
  `undef ERRM_EXCL_LEN             
  `undef ERRM_EXCL_MAX             
  `undef ERRM_AWUSER_STABLE        
  `undef ERRM_WUSER_STABLE         
  `undef ERRS_BUSER_STABLE         
  `undef ERRM_ARUSER_STABLE        
  `undef ERRS_RUSER_STABLE         
  `undef ERRM_AWUSER_X             
  `undef ERRM_WUSER_X              
  `undef ERRS_BUSER_X              
  `undef ERRM_ARUSER_X             
  `undef ERRS_RUSER_X              
  `undef ERRM_AWUSER_TIEOFF
  `undef ERRM_WUSER_TIEOFF
  `undef ERRS_BUSER_TIEOFF
  `undef ERRM_ARUSER_TIEOFF
  `undef ERRS_RUSER_TIEOFF
  `undef ERRM_AWID_TIEOFF 
  `undef ERRS_BID_TIEOFF 
  `undef ERRM_ARID_TIEOFF 
  `undef ERRS_RID_TIEOFF 
  `undef AUX_DATA_WIDTH           
  `undef AUX_ADDR_WIDTH           
  `undef AUX_EXMON_WIDTH          
  `undef AUX_MAXRBURSTS           
  `undef AUX_MAXWBURSTS           
  `undef AUX_RCAM_OVERFLOW        
  `undef AUX_RCAM_UNDERFLOW       
  `undef AUX_WCAM_OVERFLOW        
  `undef AUX_WCAM_UNDERFLOW       
  `undef AUX_EXCL_OVERFLOW        
  `undef RECM_EXCL_PAIR            
  `undef RECM_EXCL_R_W           
  `undef RECS_AWREADY_MAX_WAIT     
  `undef RECS_WREADY_MAX_WAIT      
  `undef RECM_BREADY_MAX_WAIT      
  `undef RECS_ARREADY_MAX_WAIT     
  `undef RECM_RREADY_MAX_WAIT      
  `undef RECS_WLAST_TO_AWVALID_MAX_WAIT     
  `undef RECS_CONTINUOUS_RTRANSFERS_MAX_WAIT      
  `undef RECS_CONTINUOUS_WTRANSFERS_MAX_WAIT      
  `undef RECS_WLCMD_TO_BVALID_MAX_WAIT     
  `undef RECM_EXCL_MATCH           
  `ifdef AXI4LITEPC_MESSAGES
    `undef ERRS_AXI4LITE_BRESP_EXOKAY 
    `undef ERRS_AXI4LITE_RRESP_EXOKAY 
    `undef AUX_AXI4LITE_DATA_WIDTH
    `undef AXI4LITEPC_MESSAGES 
  `endif
`endif

// --========================= End ===========================================--
endinterface : axi_vip_v1_0_1_axi4pc
`endif    //axi_vip_v1_0_1_AXI4PC
`endif    //axi_vip_v1_0_1_AXI4PC_OFF
