//  (c) Copyright 2016 - 2017 Xilinx, Inc. All rights reserved.
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
`ifndef _axi_vip_v1_0_1_PKG_SV_
`define _axi_vip_v1_0_1_PKG_SV_

`timescale 1ps/1ps

package axi_vip_v1_0_1_pkg;
  import xil_common_vip_v1_0_0_pkg::*;
  `include "xil_common_vip_v1_0_0_macros.svh"

`define AXI_PARAM_DECL #(int C_AXI_PROTOCOL=0, C_AXI_ADDR_WIDTH=32, C_AXI_WDATA_WIDTH=32, C_AXI_RDATA_WIDTH=32, C_AXI_WID_WIDTH = 0,C_AXI_RID_WIDTH = 0, C_AXI_AWUSER_WIDTH=0, C_AXI_WUSER_WIDTH=0, C_AXI_BUSER_WIDTH=0, C_AXI_ARUSER_WIDTH=0, C_AXI_RUSER_WIDTH=0,     C_AXI_SUPPORTS_NARROW = 1, C_AXI_HAS_BURST = 1,C_AXI_HAS_LOCK = 1,C_AXI_HAS_CACHE= 1,C_AXI_HAS_REGION = 1,C_AXI_HAS_PROT= 1,C_AXI_HAS_QOS= 1, C_AXI_HAS_WSTRB= 1, C_AXI_HAS_BRESP= 1,C_AXI_HAS_RRESP= 1,C_AXI_HAS_ARESETN = 1)
`define AXI_PARAM_ORDER #(C_AXI_PROTOCOL,C_AXI_ADDR_WIDTH, C_AXI_WDATA_WIDTH, C_AXI_RDATA_WIDTH, C_AXI_WID_WIDTH,C_AXI_RID_WIDTH, C_AXI_AWUSER_WIDTH, C_AXI_WUSER_WIDTH, C_AXI_BUSER_WIDTH, C_AXI_ARUSER_WIDTH, C_AXI_RUSER_WIDTH, C_AXI_SUPPORTS_NARROW, C_AXI_HAS_BURST,C_AXI_HAS_LOCK,C_AXI_HAS_CACHE,C_AXI_HAS_REGION,C_AXI_HAS_PROT,C_AXI_HAS_QOS, C_AXI_HAS_WSTRB, C_AXI_HAS_BRESP,C_AXI_HAS_RRESP,C_AXI_HAS_ARESETN)

parameter XIL_AXI_MAX_DATA_WIDTH      = 1024;
parameter XIL_AXI_USER_BEAT_WIDTH     = 1024;
parameter XIL_AXI_USER_ELEMENT_WIDTH  = 32;
parameter XIL_AXI_VERBOSITY_NONE      = 0;
parameter XIL_AXI_VERBOSITY_FULL      = 400;
typedef integer                               xil_axi_int;
typedef longint                               xil_axi_long;
typedef integer unsigned                      xil_axi_uint;
typedef longint unsigned                      xil_axi_ulong;
typedef logic [7:0]                           xil_axi_payload_byte;
typedef logic                                 xil_axi_strb_1byte;
typedef logic [XIL_AXI_USER_BEAT_WIDTH-1:0]   xil_axi_user_beat;
typedef logic [XIL_AXI_MAX_DATA_WIDTH-1:0]    xil_axi_data_beat;
typedef logic [XIL_AXI_MAX_DATA_WIDTH/8-1:0]  xil_axi_strb_beat;
typedef integer unsigned                      xil_axi_user_element;

///////////////////////////////////////////////////////////////////////////
// AXI Memory Model Default fill in policy
/*
  Enum: xil_axi_memory_fill_policy_t

  XIL_AXI_MEMORY_FILL_FIXED   - Memory default fill in with fixed value
  XIL_AXI_MEMORY_FILL_RANDOM  - Memory default fill in with random value
*/

 typedef enum{
    XIL_AXI_MEMORY_FILL_FIXED,
    XIL_AXI_MEMORY_FILL_RANDOM
  } xil_axi_memory_fill_policy_t;

///////////////////////////////////////////////////////////////////////////
// AXI Memory Model Delay policy
/*
  Enum: xil_axi_memory_delay_policy_t

  XIL_AXI_MEMORY_DELAY_FIXED  - Use a constant delay for the timing of the responses from the memory model.
  XIL_AXI_MEMORY_DELAY_RANDOM - Use a random delay for the timing of the responses from the memory model.
*/
 typedef enum{
    XIL_AXI_MEMORY_DELAY_FIXED,
    XIL_AXI_MEMORY_DELAY_RANDOM
  } xil_axi_memory_delay_policy_t;

///////////////////////////////////////////////////////////////////////////
// ASIZE Enconding
/*
  Enum: xil_axi_size_t

  XIL_AXI_SIZE_1BYTE   - 3'b000
  XIL_AXI_SIZE_2BYTE   - 3'b001
  XIL_AXI_SIZE_4BYTE   - 3'b010
  XIL_AXI_SIZE_8BYTE   - 3'b011
  XIL_AXI_SIZE_16BYTE  - 3'b100
  XIL_AXI_SIZE_32BYTE  - 3'b101
  XIL_AXI_SIZE_64BYTE  - 3'b110
  XIL_AXI_SIZE_128BYTE - 3'b111
*/
typedef enum bit [2:0] {
  XIL_AXI_SIZE_1BYTE    = 3'b000,
  XIL_AXI_SIZE_2BYTE    = 3'b001,
  XIL_AXI_SIZE_4BYTE    = 3'b010,
  XIL_AXI_SIZE_8BYTE    = 3'b011,
  XIL_AXI_SIZE_16BYTE   = 3'b100,
  XIL_AXI_SIZE_32BYTE   = 3'b101,
  XIL_AXI_SIZE_64BYTE   = 3'b110,
  XIL_AXI_SIZE_128BYTE  = 3'b111
} xil_axi_size_t;

///////////////////////////////////////////////////////////////////////////
// ALOCK Encoding
/*
  Enum: xil_axi_lock_t

  XIL_AXI_ALOCK_NOLOCK - 2'b00
  XIL_AXI_ALOCK_EXCL   - 2'b01
  XIL_AXI_ALOCK_LOCKED - 2'b10
  XIL_AXI_ALOCK_RSVD   - 2'b11
*/
typedef enum bit [1:0] {
  XIL_AXI_ALOCK_NOLOCK              = 2'b00,
  XIL_AXI_ALOCK_EXCL                = 2'b01,
  XIL_AXI_ALOCK_LOCKED              = 2'b10,
  XIL_AXI_ALOCK_RSVD                = 2'b11
} xil_axi_lock_t;


///////////////////////////////////////////////////////////////////////////
// RRESP / BRESP Encoding
/*
  Enum: xil_axi_resp_t

  XIL_AXI_RESP_OKAY    - 2'b00
  XIL_AXI_RESP_EXOKAY  - 2'b01
  XIL_AXI_RESP_SLVERR  - 2'b10
  XIL_AXI_RESP_DECERR  - 2'b11
*/
typedef enum bit [1:0] {
  XIL_AXI_RESP_OKAY     = 2'b00,
  XIL_AXI_RESP_EXOKAY   = 2'b01,
  XIL_AXI_RESP_SLVERR   = 2'b10,
  XIL_AXI_RESP_DECERR   = 2'b11
} xil_axi_resp_t;

///////////////////////////////////////////////////////////////////////////
// AXI Burst Encoding
/*
  Enum: xil_axi_burst_t

  XIL_AXI_BURST_TYPE_FIXED - 2'b00
  XIL_AXI_BURST_TYPE_INCR  - 2'b01
  XIL_AXI_BURST_TYPE_WRAP  - 2'b10
  XIL_AXI_BURST_TYPE_RSVD  - 2'b11
*/
typedef enum bit [1:0] {
  XIL_AXI_BURST_TYPE_FIXED  = 2'b00,
  XIL_AXI_BURST_TYPE_INCR   = 2'b01,
  XIL_AXI_BURST_TYPE_WRAP   = 2'b10,
  XIL_AXI_BURST_TYPE_RSVD   = 2'b11
} xil_axi_burst_t;

///////////////////////////////////////////////////////////////////////////
// AXI Command Encoding
/*
  Enum: xil_axi_cmd_t

  XIL_AXI_READ  - AXI Read
  XIL_AXI_WRITE - AXI Write
*/
typedef enum bit {
  XIL_AXI_READ = 1'b0,
  XIL_AXI_WRITE = 1'b1
} xil_axi_cmd_t;

///////////////////////////////////////////////////////////////////////////
// AXI Driver Return Policy Encoding
/*
  Enum: xil_axi_driver_return_policy_t

  XIL_AXI_NO_RETURN                - Driver has no return 
  XIL_AXI_CMD_RETURN               - Driver return when CMD is complete
  XIL_AXI_PAYLOAD_RETURN           - Driver return When PAYLOAD is complete
  XIL_AXI_CMD_PAYLOAD_RETURN       - Driver return when both CMD and PAYLOAD are complete
  XIL_AXI_CMD_WLAST_RETURN         - Driver return when both CMD and WLAST are complete
  XIL_AXI_CMD_WLAST_PAYLOAD_RETURN - Driver return when CMD,WLAST and PAYLOAD are complete
  XIL_AXI_WLAST_PAYLOAD_RETURN     - Driver return when WLAST and PAYLOAD are complete
  XIL_AXI_WLAST_RETURN             - Driver return when WLAST is complete
*/  
typedef enum {
  XIL_AXI_NO_RETURN,
  XIL_AXI_CMD_RETURN,
  XIL_AXI_PAYLOAD_RETURN,
  XIL_AXI_CMD_PAYLOAD_RETURN,
  XIL_AXI_CMD_WLAST_RETURN,
  XIL_AXI_CMD_WLAST_PAYLOAD_RETURN,
  XIL_AXI_WLAST_PAYLOAD_RETURN,
  XIL_AXI_WLAST_RETURN
  } xil_axi_driver_return_policy_t;

///////////////////////////////////////////////////////////////////////////
// AXI Reorder Ability Encoding
/*
  Enum: xil_axi_reorder_ability_t

  XIL_AXI_REORDER_CAPABLE  - Reorder is capable
  XIL_AXI_NO_REORDER       - No reorder
*/
typedef enum {
  XIL_AXI_REORDER_CAPABLE,
  XIL_AXI_NO_REORDER
  } xil_axi_reorder_ability_t;

///////////////////////////////////////////////////////////////////////////
// AXI Ready Generation Policy Encoding
/*
  Enum: xil_axi_ready_gen_policy_t

     XIL_AXI_READY_GEN_SINGLE             - Ready stays 0 for low_time clock cycles and then
                                             drives 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_EVENTS             - Ready stays 0 for low_time clock cycles and then
                                             drives 1 until event_count ready/valid handshakes
                                             occur,the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_OSC                - Ready stays 0 for low_time and then goes to 1 and      
                                             stays 1 for high_time,the policy repeats until the
                                             channel is given different policy.
     XIL_AXI_READY_GEN_RANDOM             - This policy generate random ready policy and uses
                                             min/max pair of low_time, high_time and event_count to
                                             generate low_time, high_time and event_count.
     XIL_AXI_READY_GEN_AFTER_VALID_SINGLE - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then drives 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_AFTER_VALID_EVENTS - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then drives 1 until event_count ready/valid handshake
                                             occurs,the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_AFTER_VALID_OSC    - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time and then goes to
                                             1 and stays 1 for high_time,the policy repeats until
                                             the channel is given different policy.
*/
typedef enum {
  XIL_AXI_READY_GEN_SINGLE,
  XIL_AXI_READY_GEN_EVENTS,
  XIL_AXI_READY_GEN_OSC,
  XIL_AXI_READY_GEN_RANDOM,
  XIL_AXI_READY_GEN_AFTER_VALID_SINGLE,
  XIL_AXI_READY_GEN_AFTER_VALID_EVENTS,
  XIL_AXI_READY_GEN_AFTER_VALID_OSC
  } xil_axi_ready_gen_policy_t;

/*
  Enum: xil_axi_ready_rand_policy_t
 
      XIL_AXI_READY_RAND_SINGLE             - Ready stays 0 for low_time clock cycles and then
                                             drives 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_RAND_EVENTS             - Ready stays 0 for low_time clock cycles and then
                                             drives 1 until event_count ready/valid handshakes
                                             occur,the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_RAND_OSC                - Ready stays 0 for low_time and then goes to 1 and      
                                             stays 1 for high_time,the policy repeats until the
                                             channel is given different policy.
     XIL_AXI_READY_RAND_AFTER_VALID_SINGLE - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then drives 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_RAND_AFTER_VALID_EVENTS - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then drives 1 until event_count ready/valid handshake
                                             occurs,the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_RAND_AFTER_VALID_OSC    - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time and then goes to
                                             1 and  stays 1 for high_time,the policy repeats until
                                             the channel is given different policy.

*/
typedef enum {
  XIL_AXI_READY_RAND_SINGLE,
  XIL_AXI_READY_RAND_OSC,
  XIL_AXI_READY_RAND_EVENTS,
  XIL_AXI_READY_RAND_AFTER_VALID_SINGLE,
  XIL_AXI_READY_RAND_AFTER_VALID_OSC,
  XIL_AXI_READY_RAND_AFTER_VALID_EVENTS
} xil_axi_ready_rand_policy_t;

///////////////////////////////////////////////////////////////////////////
// AXI Boolean Encoding
/*
  Enum: xil_axi_boolean_t

  XIL_AXI_TRUE  - Boolean TRUE
  XIL_AXI_FALSE - Boolean FALSE
*/
typedef enum bit {
  XIL_AXI_TRUE  = 1,
  XIL_AXI_FALSE = 0
  } xil_axi_boolean_t;

///////////////////////////////////////////////////////////////////////////
// AXI VIF Proxy Dummy Drive Encoding
/*
  Enum: xil_axi_vif_dummy_drive_t

  XIL_AXI_VIF_DRIVE_NONE  - VIF DRIVE ZERO in Dummy mode
  XIL_AXI_VIF_DRIVE_X     - VIF DRIVE X in Dummy mode
  XIL_AXI_VIF_DRIVE_NOISE - VIF DRIVE NOISE in Dummy mode
  XIL_AXI_VIF_DRIVE_Z     - VIF DRIVE Z in Dummy mode
*/
typedef enum {
  XIL_AXI_VIF_DRIVE_NONE,
  XIL_AXI_VIF_DRIVE_X,
  XIL_AXI_VIF_DRIVE_NOISE,
  XIL_AXI_VIF_DRIVE_Z
  } xil_axi_vif_dummy_drive_t;

///////////////////////////////////////////////////////////////////////////
// AXI Transfer Alignment Encoding
/*
  Enum: xil_axi_xfer_alignment_t

  XIL_AXI_XFER_CONT_ALIGNED        -  Transfer is aligned 
  XIL_AXI_XFER_CONT_ALIGNED_HEAD   -  Transfer is aligned with head 
  XIL_AXI_XFER_CONT_UNALIGNED      -  Transfer is unaligned 
  XIL_AXI_XFER_CONT_UNALIGNED_NULL -  Transfer is unaligned with null bytes 
  XIL_AXI_XFER_SPARSE              -  Transfer is sparse
*/
typedef enum {
  XIL_AXI_XFER_CONT_ALIGNED,
  XIL_AXI_XFER_CONT_ALIGNED_HEAD,
  XIL_AXI_XFER_CONT_UNALIGNED,
  XIL_AXI_XFER_CONT_UNALIGNED_NULL,
  XIL_AXI_XFER_SPARSE
  } xil_axi_xfer_alignment_t;

///////////////////////////////////////////////////////////////////////////
// AXI Write Beat and Command Order Encoding
/*
  Enum: xil_axi_xfer_wrcmd_order_t

  XIL_AXI_WRCMD_ORDER_DATA_BEFORE_CMD   - Write transaction order: Data before Command 
  XIL_AXI_WRCMD_ORDER_CMD_BEFORE_DATA   - Write transaction order: Command before Data 
  XIL_AXI_WRCMD_ORDER_ERROR             - Write transaction order: Error  
  XIL_AXI_WRCMD_ORDER_NONE              - Write transaction order: No order
*/
typedef enum {
  XIL_AXI_WRCMD_ORDER_DATA_BEFORE_CMD,
  XIL_AXI_WRCMD_ORDER_CMD_BEFORE_DATA,
  XIL_AXI_WRCMD_ORDER_ERROR,
  XIL_AXI_WRCMD_ORDER_NONE
  } xil_axi_xfer_wrcmd_order_t;

///////////////////////////////////////////////////////////////////////////
// AXI Write Command Insertion Policy Encoding
/*
  Enum: xil_axi_xfer_wrdata_insertion_policy_t

  XIL_AXI_WRCMD_INSERTION_ALWAYS      - Always insert data delay 
  XIL_AXI_WRCMD_INSERTION_FROM_IDLE   - Insert Data delay only from IDLE
*/
typedef enum {
  XIL_AXI_WRCMD_INSERTION_ALWAYS,
  XIL_AXI_WRCMD_INSERTION_FROM_IDLE
  } xil_axi_xfer_wrdata_insertion_policy_t;

/*
  Enum: xil_axi_trans_state_t
  XIL_AXI_TRANS_STATE_NEW               - Transaction state is new
  XIL_AXI_TRANS_STATE_ACTIVE            - Transaction state is active
  XIL_AXI_TRANS_STATE_COMPLETED         - Transaction state is completed
  XIL_AXI_TRANS_STATE_KILLED            - Transaction state is killed
  XIL_AXI_TRANS_STATE_COMPLETED_SLAVE   - Transaction state is slave completed
  XIL_AXI_TRANS_STATE_COMPLETED_MASTER  - Transaction state is master completed 
*/
typedef enum {
  XIL_AXI_TRANS_STATE_NEW,
  XIL_AXI_TRANS_STATE_ACTIVE,
  XIL_AXI_TRANS_STATE_COMPLETED,
  XIL_AXI_TRANS_STATE_KILLED,
  XIL_AXI_TRANS_STATE_COMPLETED_SLAVE,
  XIL_AXI_TRANS_STATE_COMPLETED_MASTER
  } xil_axi_trans_state_t;

parameter [3:0]   XIL_AXI_CACHE_BUFFERABLE_MASK = 4'h1;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_MASK = 4'h2;
parameter [3:0]   XIL_AXI_CACHE_READALLOC_MASK  = 4'h4;
parameter [3:0]   XIL_AXI_CACHE_WRITEALLOC_MASK = 4'h8;

parameter [3:0]   XIL_AXI_CACHE_NONCACHEABLE_NONBUFFERABLE      = 4'h0;
parameter [3:0]   XIL_AXI_CACHE_BUFFERABLE_NOALLOC              = XIL_AXI_CACHE_BUFFERABLE_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_NOALLOC              = XIL_AXI_CACHE_MODIFIABLE_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_BUFFERABLE_NOALLOC   = XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_WRITETHRU_READONLY   = XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_READALLOC_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_WRITEBACK_READONLY   = XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_WRITETHRU_WRITEONLY  = XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_WRITEALLOC_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_WRITEBACK_WRITEONLY  = XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_WRITEALLOC_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_WRITETHRU_BOTH       = XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_WRITEALLOC_MASK;
parameter [3:0]   XIL_AXI_CACHE_MODIFIABLE_WRITEBACK_BOTH       = XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_WRITEALLOC_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Common cache encodings
parameter [3:0]   XIL_AXI_CACHE_DEVICE_NONBUFFERABLE            = 4'h0;
parameter [3:0]   XIL_AXI_CACHE_DEVICE_BUFFERABLE               =                                                                                                XIL_AXI_CACHE_BUFFERABLE_MASK; //0001
parameter [3:0]   XIL_AXI_CACHE_NORM_NONCACHEABLE_NONBUFFERABLE =                                                                XIL_AXI_CACHE_MODIFIABLE_MASK;                                 //0010
parameter [3:0]   XIL_AXI_CACHE_NORM_NONCACHEABLE_BUFFERABLE    =                                                                XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK; //0011

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ARCACHE encodings
parameter [3:0]   XIL_AXI_CACHE_RD_WRITETHROUGH_NOALLOC         = XIL_AXI_CACHE_WRITEALLOC_MASK                                | XIL_AXI_CACHE_MODIFIABLE_MASK;                             //1010
parameter [3:0]   XIL_AXI_CACHE_RD_WRITETHROUGH_RDALLOC         = XIL_AXI_CACHE_WRITEALLOC_MASK | XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK;                             //1110
parameter [3:0]   XIL_AXI_CACHE_RDAXI3_WRITETHROUGH_RDALLOC     =                                 XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK;                             //0110
parameter [3:0]   XIL_AXI_CACHE_RD_WRITEBACK_NOALLOC            = XIL_AXI_CACHE_WRITEALLOC_MASK                                | XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK; //1011
parameter [3:0]   XIL_AXI_CACHE_RD_WRITEBACK_RDALLOC            = XIL_AXI_CACHE_WRITEALLOC_MASK | XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK; //1111
parameter [3:0]   XIL_AXI_CACHE_RDAXI3_WRITEBACK_RDALLOC        =                                 XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK; //0111

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//AWCACHE encodings
parameter [3:0]   XIL_AXI_CACHE_WR_WRITETHROUGH_NOALLOC         =                                 XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK;                             //0110
parameter [3:0]   XIL_AXI_CACHE_WR_WRITETHROUGH_WRALLOC         = XIL_AXI_CACHE_WRITEALLOC_MASK | XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK;                             //1110
parameter [3:0]   XIL_AXI_CACHE_WRAXI3_WRITETHROUGH_WRALLOC     = XIL_AXI_CACHE_WRITEALLOC_MASK                                | XIL_AXI_CACHE_MODIFIABLE_MASK;                             //1010
parameter [3:0]   XIL_AXI_CACHE_WR_WRITEBACK_NOALLOC            =                                 XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK; //0111
parameter [3:0]   XIL_AXI_CACHE_WR_WRITEBACK_WRALLOC            = XIL_AXI_CACHE_WRITEALLOC_MASK | XIL_AXI_CACHE_READALLOC_MASK | XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK; //1111
parameter [3:0]   XIL_AXI_CACHE_WRAXI3_WRITEBACK_WRALLOC        = XIL_AXI_CACHE_WRITEALLOC_MASK                                | XIL_AXI_CACHE_MODIFIABLE_MASK | XIL_AXI_CACHE_BUFFERABLE_MASK; //1011


typedef bit [7:0] xil_axi_len_t;
typedef bit [3:0] xil_axi_cache_t;
typedef bit [2:0] xil_axi_prot_t;
typedef bit [3:0] xil_axi_region_t;
typedef bit [3:0] xil_axi_qos_t;

parameter [2:0]   XIL_AXI_PROT_NORMAL_ACCESS_MASK       = 3'h0;
parameter [2:0]   XIL_AXI_PROT_PRIVILEGED_ACCESS_MASK   = 3'h1;
parameter [2:0]   XIL_AXI_PROT_SECURE_ACCESS_MASK       = 3'h0;
parameter [2:0]   XIL_AXI_PROT_NONSECURE_ACCESS_MASK    = 3'h2;
parameter [2:0]   XIL_AXI_PROT_DATA_ACCESS_MASK         = 3'h0;
parameter [2:0]   XIL_AXI_PROT_INSTRUCTION_ACCESS_MASK  = 3'h4;

parameter [2:0]   XIL_AXI_PROT_PRIVILEGED_ACCESS_WILDCARD_MASK  = 3'b??1;
parameter [2:0]   XIL_AXI_PROT_NORMAL_ACCESS_WILDCARD_MASK      = 3'b??0;
parameter [2:0]   XIL_AXI_PROT_NONSECURE_ACCESS_WILDCARD_MASK   = 3'b?1?;
parameter [2:0]   XIL_AXI_PROT_SECURE_ACCESS_WILDCARD_MASK      = 3'b?0?;
parameter [2:0]   XIL_AXI_PROT_INSTRUCTION_ACCESS_WILDCARD_MASK = 3'b1??;
parameter [2:0]   XIL_AXI_PROT_DATA_ACCESS_WILDCARD_MASK        = 3'b0??;

/*
  Function :  xil_clog2
  Returns the base 2 logarithm of input
*/
function automatic xil_axi_uint xil_clog2(input xil_axi_uint value);
  if (value !== 0) begin
    value = value - 1;
    for (xil_clog2 = 0; value > 0; xil_clog2 = xil_clog2 + 1) begin
      value = value >> 1;
    end
  end else begin
    xil_clog2 = 0;
  end
endfunction : xil_clog2

/*
  Function :  xil_pow2
  Returns the base 2 power of input
*/
function automatic xil_axi_ulong xil_pow2(input xil_axi_uint value);
  return(1 << value);
endfunction : xil_pow2

/*
  Function :  aligned_size_mask
  Returns inverted value of the base 2 power of size 
*/
function xil_axi_ulong aligned_size_mask(input xil_axi_size_t value);
  return(~(xil_pow2(value)-1));
endfunction

/*
  Function :  aligned_4k_mask
  Returns inverted value of the base 2 power of 12
*/
function xil_axi_ulong aligned_4k_mask();
  return(~(xil_pow2(12)-1));
endfunction

/*
  Function : convert_dw_to_axi_size
  Convert Data width to AXI size value 
*/
function xil_axi_size_t convert_dw_to_axi_size(input xil_axi_uint dw);
  bit [2:0] size_bit;
  size_bit = $clog2(dw/8);
  return(xil_axi_size_t'(size_bit));
endfunction

/*
  Enum: xil_axi_vif_axi_version_t

  XIL_VERSION_LITE - The version is AXI4LITE
  XIL_VERSION_AXI4 - The version is AXI4
  XIL_VERSION_AXI3 - The version is AXI3
*/

typedef enum {
  XIL_VERSION_LITE,
  XIL_VERSION_AXI4,
  XIL_VERSION_AXI3
} xil_axi_vif_axi_version_t;

///////////////////////////////////////////////////////////////////////////
/*
  Enum: xil_axi_data_fill_t
  XIL_AXI_DATA_FILL_NOTOUCH       - Do not modify the data beats of the transaction.
  XIL_AXI_DATA_FILL_CONSTANT      - Fill each beat of the transaction with the provided constant value.
  XIL_AXI_DATA_FILL_RANDOM        - Fill each beat of the transaction with random data.
  XIL_AXI_DATA_FILL_ADDR_AS_DATA  - Fill each beat of the transaction with the current value of the address.
  XIL_AXI_DATA_FILL_WALKING_1     - Fill the beats of the transaction with a walking 1 pattern.
  XIL_AXI_DATA_FILL_WALKING_0     - Fill the beats of the transaction with a walking 0 pattern.
  XIL_AXI_DATA_FILL_HAMMER        - Fill the beats of the transaction with an alternating pattern of all 1's and all 0's.
  XIL_AXI_DATA_FILL_NEIGHBOUR     - Fill the beats with shifting neighbour pattern.
*/
typedef enum {
  XIL_AXI_DATA_FILL_NOTOUCH,
  XIL_AXI_DATA_FILL_CONSTANT,
  XIL_AXI_DATA_FILL_RANDOM,
  XIL_AXI_DATA_FILL_ADDR_AS_DATA,
  XIL_AXI_DATA_FILL_WALKING_1,
  XIL_AXI_DATA_FILL_WALKING_0,
  XIL_AXI_DATA_FILL_HAMMER,
  XIL_AXI_DATA_FILL_NEIGHBOUR
} xil_axi_data_fill_t;


/*
  Enum: xil_axi_strb_fill_t
  XIL_AXI_STRB_FILL_NOTOUCH     - Do not modify the strb values of the transaction.
  XIL_AXI_STRB_FILL_RANDOM      - Fill each beat of strb in the transaction with random data.
  XIL_AXI_STRB_FILL_ALL_VALID   - Set all strb values to 1.
  XIL_AXI_STRB_FILL_ALT_VALID   - Fill each strb value with alternating bit pattern.
  XIL_AXI_STRB_FILL_NO_VALID    - Set all strb values to 0.
*/
typedef enum {
  XIL_AXI_STRB_FILL_NOTOUCH,
  XIL_AXI_STRB_FILL_RANDOM,
  XIL_AXI_STRB_FILL_ALL_VALID,
  XIL_AXI_STRB_FILL_ALT_VALID,
  XIL_AXI_STRB_FILL_NO_VALID
} xil_axi_strb_fill_t;


parameter integer XIL_AXI_DEFAULT_TRANSACTION_DEPTH = 16;

///////////////////////////////////////////////////////////////////////////
//Common transaction state class
/*
 Class: xil_axi_transaction_state
 XIL AXI Transaction State Object 
*/
class xil_axi_transaction_state;
  bit [3:0]                           state = 4'h0;
  parameter       P_WRT_ADDR_PHASE_COMPLETE = 4'h1;
  parameter       P_WRT_DATA_PHASE_COMPLETE = 4'h2;
  parameter       P_WRT_RESP_INFLIGHT       = 4'h4;
  parameter       P_WRT_RESP_PHASE_COMPLETE = 4'h8;

  event          state_event ;

  function new();
    this.state = 4'h0;
  endfunction

  /*
   Function: set_addr_phase_complete
   Sets state to be inclusive or of P_WRT_ADDR_PHASE_COMPLETE of xil_axi_transaction_state and trigger state_event
  */
  function void set_addr_phase_complete();
    this.state |= P_WRT_ADDR_PHASE_COMPLETE;
    ->state_event ;
  endfunction

  /*
   Function:  is_addr_phase_complete
   Returns 1 if (state & P_WRT_ADDR_PHASE_COMPLETE) bigger than 0, else returns 0
  */
  function bit is_addr_phase_complete();
    return((this.state & P_WRT_ADDR_PHASE_COMPLETE) > 0);
  endfunction

  /*
   Function: set_data_phase_complete
   Sets state to be inclusive or of P_WRT_DATA_PHASE_COMPLETE of xil_axi_transaction_state and trigger state_event
  */
  function void set_data_phase_complete();
    this.state |= P_WRT_DATA_PHASE_COMPLETE;
    ->state_event ;
  endfunction

  /*
   Function: is_data_phase_complete
   Returns 1 if (state & P_WRT_DATA_PHASE_COMPLETE) bigger than 0, else returns 0
  */
  function bit is_data_phase_complete();
    return((this.state & P_WRT_DATA_PHASE_COMPLETE) > 0);
  endfunction

  /*
   Function: set_resp_phase_complete
   Sets state to be inclusive or of P_WRT_RESP_PHASE_COMPLETE of xil_axi_transaction_state and trigger state_event
  */
  function void set_resp_phase_complete();
    this.state |= P_WRT_RESP_PHASE_COMPLETE;
    ->state_event ;
  endfunction

  /*
   Function: is_resp_phase_complete
   Returns 1 if (state & P_WRT_RESP_PHASE_COMPLETE) bigger than 0, else returns 0
  */
  function bit is_resp_phase_complete();
    return((this.state & P_WRT_RESP_PHASE_COMPLETE) > 0);
  endfunction

  /*
   Function: set_resp_inflight
   Sets state to be inclusive or of P_WRT_RESP_INFLIGHT of xil_axi_transaction_state and trigger state_event
  */
  function void set_resp_inflight();
    this.state |= P_WRT_RESP_INFLIGHT;
    ->state_event ;
  endfunction

  /*
   Function: is_resp_inflight
   Returns 1 if (state & P_WRT_RESP_INFLIGHT) bigger than 0, else returns 0
  */
  function bit is_resp_inflight();
    return((this.state & P_WRT_RESP_INFLIGHT) > 0);
  endfunction

  /*
   Function:  all_phase_complete
   Returns 1 if (state is any of( P_WRT_ADDR_PHASE_COMPLETE, P_WRT_DATA_PHASE_COMPLETE ,P_WRT_RESP_PHASE_COMPLETE, P_WRT_RESP_INFLIGHT) else returns 0
  */
  function bit all_phase_complete();
    return((this.state == (P_WRT_ADDR_PHASE_COMPLETE | P_WRT_DATA_PHASE_COMPLETE | P_WRT_RESP_PHASE_COMPLETE | P_WRT_RESP_INFLIGHT)));
  endfunction

  /*
   Function:  get_state
   Returns state of xil_axi_transaction_state
  */
  virtual function bit[3:0] get_state();
    return(this.state);
  endfunction

  /*
   Function:  set_state
   Sets state of xil_axi_transaction_state and trigger state_event
  */
  virtual function void set_state(input bit [3:0] update);
    this.state = update;
    ->state_event ;
  endfunction

  /*
   Function:   wait_state_change
   Wait state_event of xil_axi_transaction_state occurs.
  */
  virtual task wait_state_change();
    //@(this.state);
    @(state_event) ;
  endtask
endclass : xil_axi_transaction_state


///////////////////////////////////////////////////////////////////////////
//Single bus beat for the WRITE channel
/*
 Class: xil_axi_channel_beat_base
 XIL AXI Channel Beat Base Object -single bus beat for the Write Channel
*/
class xil_axi_channel_beat_base extends xil_sequence_item;
  time                  accepted;
  xil_axi_ulong         accepted_cycle = 0;

  /*
   Function: new
   Constructor to create a new xil_axi_channel_beat_base
  */
  function new(input string name = "unnamed_xil_axi_channel_beat_base");
    super.new(name);
  endfunction

  /*
   Function: trigger_accepted
   Sets accepted and accepted_cycle of xil_axi_channel_beat_base
  */
  virtual function void trigger_accepted(
    input time           now,
    input xil_axi_ulong  now_cycle
  );
    this.accepted = now;
    this.accepted_cycle = now_cycle;
  endfunction

  /*
   Function:  get_accepted_time
   Returns accepted of xil_axi_channel_beat_base
  */
  virtual function time get_accepted_time();
    return(this.accepted);
  endfunction

  /*
   Function: get_accepted_cycle
   Returns accepted_cycle of xil_axi_channel_beat_base
  */
  virtual function xil_axi_ulong get_accepted_cycle();
    return(this.accepted_cycle);
  endfunction

endclass : xil_axi_channel_beat_base

/*
  Class: xil_axi_data_channel_beat_base
  XIL AXI data channel beat base object
*/
class xil_axi_data_channel_beat_base extends xil_axi_channel_beat_base;
  rand xil_axi_user_element   user[];
  xil_axi_uint                width;

  /*
   Function: new
   Constructor to create a new xil_axi_data_channel_beat_base 
  */
  function new(input string name = "unnamed_xil_axi_data_channel_beat_base");
    super.new(name);
  endfunction : new

  /*
  Function:  set_user
  Sets user of the xil_axi_data_channel_beat_base
  */
  function void set_user(input xil_axi_uint width, input xil_axi_user_beat in);
    xil_axi_user_beat in_masked;
    xil_axi_uint      max_elements;
    max_elements = (width + XIL_AXI_USER_ELEMENT_WIDTH - 1)/XIL_AXI_USER_ELEMENT_WIDTH;
    this.width = width;
    if (width > 0) begin
      in_masked = in & ((1 << width) - 1);
      this.user = new[max_elements];
      for (xil_axi_uint i = 0; i < max_elements; i++) begin
        this.user[i] = in_masked[XIL_AXI_USER_ELEMENT_WIDTH*i+:XIL_AXI_USER_ELEMENT_WIDTH];
      end
    end
  endfunction : set_user

  /*
  Function:  get_user
  Returns the user of the xil_axi_data_channel_beat_base
  */
  function xil_axi_user_beat get_user();
    xil_axi_user_beat out;
    out = 'h0;
    if (this.user.size() > 0) begin
      for (xil_axi_uint i = 0; i < this.user.size(); i++) begin
        out[i*XIL_AXI_USER_ELEMENT_WIDTH+:XIL_AXI_USER_ELEMENT_WIDTH] = this.user[i];
      end
      return(out);
    end else begin
      return('h0);
    end
  endfunction : get_user

  /*
  Function:  set_user_size
  Sets user size of the xil_axi_data_channel_beat_base
  */
  virtual function void set_user_size(input xil_axi_uint update);
    if (update > 0) begin
      this.user = new[update];
    end
  endfunction

  /*
  Function:  get_user_size
  Returns user size of the xil_axi_data_channel_beat_base
  */
  virtual function xil_axi_uint get_user_size();
    return(this.user.size());
  endfunction

endclass : xil_axi_data_channel_beat_base

/*
  Class: xil_axi_write_beat
  XIL AXI write beat object
*/
class xil_axi_write_beat extends xil_axi_data_channel_beat_base;
  rand xil_axi_payload_byte     data[];
  rand bit                      strb[];
  rand bit                      last;
  time                          data_ready_assert_time;
  time                          data_valid_assert_time;
  xil_axi_ulong                 data_ready_assert_cycle;
  xil_axi_ulong                 data_valid_assert_cycle;
  xil_axi_int                   data_beat_accepted_cycles;

  ///////////////////////////////////////////////////////////////////////////
  // constructor ////////////////////////////////////////////////////////////
  /*
    Function: new
    Constructor to create a new AXI write beat
  */
  function new(input string name = "xil_axi_write_beat");
    super.new(name);
  endfunction

  /*
   Function: set_data_size
   Sets the data size of the write beat
  */
  virtual function void set_data_size(input xil_axi_uint update);
    this.data = new[update];
  endfunction

  /*
   Function: get_data_size
   Returns the data size of the write beat
  */
  virtual function xil_axi_uint get_data_size();
    return(this.data.size());
  endfunction

  /*
   Function: set_strb_size
   Sets the strobe size of the write beat
  */
  virtual function void set_strb_size(input xil_axi_uint update);
    this.strb = new[update];
  endfunction

  /*
   Function: get_strb_size
   Returns the strobe size of the write beat
  */
  virtual function xil_axi_uint get_strb_size();
    return(this.strb.size());
  endfunction

  /*
    Function: copy
    Copies the contents of the input write beat to the current write beat
  */
  function void copy(xil_axi_write_beat rhs);
    this.set_data_size(rhs.get_data_size());
    this.set_user_size(rhs.get_user_size());
    this.set_strb_size(rhs.get_strb_size());
    foreach(this.data[i]) begin
      this.data[i] = rhs.data[i];
    end
    this.strb = new[rhs.strb.size()];
    foreach(this.strb[i]) begin
      this.strb[i] = rhs.strb[i];
    end
    foreach(this.user[i]) begin
      this.user[i] = rhs.user[i];
    end
    this.last = rhs.last;
    this.data_ready_assert_time    = rhs.data_ready_assert_time;  
    this.data_valid_assert_time    = rhs.data_valid_assert_time;  
    this.data_ready_assert_cycle   = rhs.data_ready_assert_cycle; 
    this.data_valid_assert_cycle   = rhs.data_valid_assert_cycle; 
    this.data_beat_accepted_cycles = rhs.data_beat_accepted_cycles;
  endfunction : copy

  /*
    Function: my_clone
    Clones the current write beat and returns a handle to the new write beat.
  */
  virtual function xil_axi_write_beat my_clone();
    xil_axi_write_beat          my_obj;
    my_obj = new("xil_axi_write_beat_clone");
    my_obj.copy(this);
    return(my_obj);
  endfunction : my_clone

  /*
   Function: convert2string
   Returns string with last,data,size and user info of the write beat
  */
  virtual function string convert2string();
    string d;
    string s;
    string u;
    d = "";
    s = "";
    u = "";
    for (int i = 0; i < this.data.size(); i++) begin
      d = $sformatf("%x%s", this.data[i], d);
      s = $sformatf("%b%s", this.strb[i], s);
    end
    if (this.user.size() > 0) begin
      u = "";
      for (xil_axi_uint i = 0; i < this.user.size(); i++) begin
        u = $sformatf("%0b%s", this.user[i],u);
      end
      u = $sformatf("U:%s", u);
    end
    return($sformatf("Last:%b D:0x%s BE:0b%s %s", last, d, s, u));
  endfunction

  /*
    Function: do_print
    Print out last,data,size and user information of the write beat
  */
  virtual function void do_print(xil_printer printer);
    string d;
    string s;
    string u;
    d = "";
    s = "";
    u = "";
    super.do_print(printer);
    for (int i = 0; i < this.data.size(); i++) begin
      d = $sformatf("%x%s", this.data[i], d);
      s = $sformatf("%b%s", this.strb[i], s);
    end
    if (this.user.size() > 0) begin
      u = "";
      for (xil_axi_uint i = 0; i < this.user.size(); i++) begin
        u = $sformatf("%0b%s", this.user[i],u);
      end
      u = $sformatf("U:%s", u);
    end
    printer.print_string("write_beat",  $sformatf("Last:%b D:0x%s BE:0b%s %s", last, d, s, u));
  endfunction :do_print

  /*
    Function:  trigger_data_beat_accepted
    Sets write beat characterics of data_beat_accepted,data_ready_assert_time,
    data_valid_assert_time,data_ready_assert_cycle,data_valid_assert_cycle,data_beat_accepted_cycles,
  */
  virtual function void trigger_data_beat_accepted(
    input time          ready_time,
    input time          valid_time,
    input xil_axi_ulong ready_cycle,
    input xil_axi_ulong valid_cycle
  );
    ///////////////////////////////////////////////////////////////////////////
    //Because WDATA can lead AWADDR, we may not know the number of beats until
    //it is over. We will expand the array on every trigger.
    this.trigger_accepted($time, (ready_cycle > valid_cycle) ? ready_cycle : valid_cycle);
    this.data_ready_assert_time = ready_time;
    this.data_valid_assert_time = valid_time;
    this.data_ready_assert_cycle = ready_cycle;
    this.data_valid_assert_cycle = valid_cycle;

    if (valid_cycle >= ready_cycle) begin
      this.data_beat_accepted_cycles = -1*(valid_cycle - ready_cycle);
    end else begin
      this.data_beat_accepted_cycles = (ready_cycle - valid_cycle);
    end
  endfunction : trigger_data_beat_accepted

endclass : xil_axi_write_beat

///////////////////////////////////////////////////////////////////////////
//Single bus beat for the RESP channel
/*
 Class: xil_axi_resp_beat
 XIL AXI RESP beat object - Single bus beat for the RESP channel
*/
class xil_axi_resp_beat extends xil_axi_data_channel_beat_base;
  rand xil_axi_uint             id;
  rand xil_axi_resp_t           resp;

  /*
    Function: new
    Constructor to create a new axi resp beat
  */
  function new(input string name = "xil_axi_resp_beat");
    super.new(name);
  endfunction

endclass : xil_axi_resp_beat

///////////////////////////////////////////////////////////////////////////
//Single bus beat for the READ channel
/*
  Class: xil_axi_read_beat
  XIL AXI read beat object -Single bus beat for the READ channel
*/
class xil_axi_read_beat extends xil_axi_resp_beat;
  rand xil_axi_payload_byte     data[];
  rand bit                      last;

  /*
   Function: set_data_size
   Sets the data size of the read beat
  */
  virtual function void set_data_size(input xil_axi_uint update);
    this.data = new[update];
  endfunction

  /*
   Function: get_data_size
   Returns the data size of the read beat
  */
  virtual function xil_axi_uint get_data_size();
    return(this.data.size());
  endfunction

  /*
    Function: copy
    Copies the contents of the input read beat to the current read beat
  */
  function void copy(xil_axi_read_beat rhs);
    this.set_data_size(rhs.get_data_size());
    this.set_user_size(rhs.get_user_size());
    this.id = rhs.id;
    this.resp = rhs.resp;
    foreach(this.data[i]) begin
      this.data[i] = rhs.data[i];
    end
    foreach(this.user[i]) begin
      this.user[i] = rhs.user[i];
    end
    this.last = rhs.last;
  endfunction : copy

  /*
    Function: my_clone
    Clones the current read beat and returns a handle to the new read beat.
  */
  virtual function xil_axi_read_beat my_clone();
    xil_axi_read_beat          my_obj;
    my_obj = new("xil_axi_read_beat_clone");
    my_obj.copy(this);
    return(my_obj);
  endfunction : my_clone

  /*
   Function: convert2string
   Returns string with last,data,size and user information of read beat
  */
  virtual function string convert2string();
    string d;
    string u;
    d = "";
    u = "";
    for (int i = 0; i < data.size(); i++) begin
      d = $sformatf("%x%s", data[i], d);
    end
    if (this.user.size() > 0) begin
      u = "";
      for (xil_axi_uint i = 0; i < this.user.size(); i++) begin
        u = $sformatf("%0b%s", this.user[i],u);
      end
      u = $sformatf("U:%s", u);
    end
    return($sformatf("ID:0x%0x Last:%b D:0x%s - %s %s", id, last, d, resp.name(),u));
  endfunction

  /*
    Function: do_print
    Print out id,last,data,resp.name and user information of read beat
  */
  virtual function void do_print(xil_printer printer);
    string d;
    string u;
    d = "";
    u = "";
    super.do_print(printer);
    for (int i = 0; i < this.data.size(); i++) begin
      d = $sformatf("%x%s", this.data[i], d);
    end
    if (this.user.size() > 0) begin
      u = "";
      for (xil_axi_uint i = 0; i < this.user.size(); i++) begin
        u = $sformatf("%0b%s", this.user[i],u);
      end
      u = $sformatf("U:%s", u);
    end
    printer.print_string("read_beat",  $sformatf("ID:0x%0x Last:%b D:0x%s - %s %s", id, last, d, resp.name(),u));
  endfunction

   /*
    Function: new
    Constructor to create a new read beat
  */
  function new(input string name = "xil_axi_read_beat");
    super.new(name);
  endfunction

endclass : xil_axi_read_beat

///////////////////////////////////////////////////////////////////////////
//Single bus beat for the CMD channel
/*
  Class: xil_axi_write_beat
  XIL AXI cmd beat object  - Single bus beat for the CMD channel
*/
class xil_axi_cmd_beat extends xil_axi_channel_beat_base;
  xil_axi_cmd_t                      dir;
  rand xil_axi_ulong                 addr = 64'hdeadbeef;
  rand xil_axi_uint                  id = 0;
  rand xil_axi_burst_t               burst = XIL_AXI_BURST_TYPE_INCR;
  rand xil_axi_len_t                 len = 0;
  rand xil_axi_size_t                size = XIL_AXI_SIZE_4BYTE;
  rand xil_axi_lock_t                lock = XIL_AXI_ALOCK_NOLOCK;
  rand xil_axi_cache_t               cache = 0;
  rand xil_axi_prot_t                prot = 0;
  rand xil_axi_region_t              region = 0;
  rand xil_axi_qos_t                 qos = 0;
  rand xil_axi_user_beat             user = 'h0;
  xil_axi_uint                       user_width = 0;

  /*
    Function: new
    Constructor to create a new cmd beat
  */
  function new(input string name = "xil_axi_cmd_beat");
    super.new(name);
  endfunction

  /*
    Function: copy
    Copies the contents of the input cmd beat to the current cmd beat
  */
  function void copy(xil_axi_cmd_beat rhs);
    this.dir = rhs.dir;
    this.addr = rhs.addr;
    this.id = rhs.id;
    this.len = rhs.len;
    this.size = rhs.size;
    this.burst = rhs.burst;
    this.lock = rhs.lock;
    this.cache = rhs.cache;
    this.prot = rhs.prot;
    this.region = rhs.region;
    this.qos = rhs.qos;
    this.user = rhs.user;
    this.user_width = rhs.user_width;
  endfunction : copy

  /*
    Function: my_clone
    Clones the current cmd beat and returns a handle to the new cmd beat.
  */
  virtual function xil_axi_cmd_beat my_clone();
    xil_axi_cmd_beat          my_obj;
    my_obj = new("xil_axi_cmd_beat_clone");
    my_obj.copy(this);
    return(my_obj);
  endfunction : my_clone

  /*
   Function: convert2string
   Returns string with direction name,addr,id,len,size and user information of cmd beat
  */
  virtual function string convert2string();
    string s;
    string u;
    s = $sformatf("%s", super.convert2string());
    if (this.user_width > 0) begin
      u = $sformatf("U:0b%s", this.user);
    end
    s = $sformatf("(%s) 0x%x ID:%x LEN:%d %s %s", dir.name(), addr, id, len, s, u);
    return(s);
  endfunction

  /*
  Function:  set_user
  Sets user of the cmd beat 
  */
  function void set_user(input xil_axi_uint width, input xil_axi_user_beat in);
    this.user_width = width;
    if (this.user_width > 0) begin
      this.user = in & ((1 << this.user_width) - 1);
    end else begin
      this.user = 'h0;
    end
  endfunction : set_user
  
  /*
  Function:  get_user
  Returns the user of the cmd beat
  */
  function xil_axi_user_beat get_user();
    return(this.user);
  endfunction : get_user

  /*
    Function: do_print
    Print out direction,addr,id,length,size and user information of cmd beat
  */
  virtual function void do_print(xil_printer printer);
    string s;
    string u;
    s = "";
    u = "";
    super.do_print(printer);

    if (this.user_width > 0) begin
      u = $sformatf("U:0b%s", this.user);
    end
    s = $sformatf("(%s) 0x%x ID:%x LEN:%d %s %s", dir.name(), addr, id, len, s, u);
    printer.print_string("cmd_beat",  $sformatf("(%s) 0x%x ID:%x LEN:%d %s %s", dir.name(), addr, id, len, s, u));
  endfunction

endclass : xil_axi_cmd_beat

/*
 Class: xil_axi_generic_queue_container 
 AXI generic queue container object
*/
class xil_axi_generic_queue_container #(type T = xil_axi_write_beat);
  T                 q[$];
  xil_axi_uint      entries;

  /*
    Function: new
    Sets entries to be 0
  */
  function new ();
    this.entries = 0;
  endfunction

  /*
   Function: sprint
   Returns string with num_entries and beat information of xil_axi_generic_queue_container
  */
  virtual function string sprint();
    T   beat;
    string s;
    s = "";
    for (int i = 0; i < q.size();i++) begin
      beat = q[i];
      s = $sformatf("%s[%d] %s\n", s, i, beat.sprint());
    end
    return($sformatf("NumEntries:%d >>> \n%s <<<", get_num_entries(), s));
  endfunction

  /*
   Function: free
   Free non-empty q of xil_axi_generic_queue_container
  */
  function void free();
    if (entries > 0) begin
      `xil_warning("GENERIC_QUEUE", $sformatf("Freeing non-empty queue (%d)", entries))
      while (entries > 0) begin
        q.delete(0);
        entries--;
      end
    end
  endfunction

  /*
   Function: clean
   Delete all the items of  q and set entries to be 0 of xil_axi_generic_queue_container
  */
  function void clean();
    while (q.size() > 0) begin
      q.delete(0);
    end
    entries = 0;
  endfunction

  /*
   Function: get_num_entries
   Returns entries of xil_axi_generic_queue_container
  */
  function xil_axi_uint get_num_entries();
    return(this.entries);
  endfunction

  /*
   Function: peek_front
   Returns the first item of q of xil_axi_generic_queue_container
  */
  virtual function T peek_front();
    AXI_IBQ_PEEK_FRONT_NO_ENTRIES: assert(entries > 0) else begin
      `xil_error("GENERIC_QUEUE", $sformatf("AXI_IBQ_PEEK_FRONT_NO_ENTRIES: Peeking from zero entry queue at time %t",$time ))
    end
    return(q[0]);
  endfunction

  /*
   Function: peek_back
   Returns the last item of q of xil_axi_generic_queue_container
  */
  virtual function T peek_back();
    AXI_IBQ_PEEK_BACK_NO_ENTRIES: assert(entries > 0) else begin
      `xil_error("GENERIC_QUEUE", $sformatf("AXI_IBQ_PEEK_BACK_NO_ENTRIES: Peeking from zero entry queue at time %t",$time ))
    end
    return(q[(q.size()-1)]);
  endfunction

  /*
   Function: push_back
   Push item into q of xil_axi_generic_queue_container
  */
  virtual function void push_back(inout T t);
    q.push_back(t);
    entries++;
  endfunction

  /*
   Function: pop_front
   Return the first item of q if q has item, otherwise returns null
  */
  virtual function T pop_front();
    AXI_IBQ_POP_FRONT_INDEX_NO_ENTRIES: assert (entries > 0) begin
    end else begin
      `xil_error("GENERIC_QUEUE", $sformatf("AXI_IBQ_POP_FRONT_INDEX_NO_ENTRIES: pop_front no entries at time %t",$time ))
    end
    if (entries > 0) begin
      entries--;
      return(q.pop_front());
    end else begin
      return(null);
    end
  endfunction

  /*
   Function: peek_index
   Returns q[index] if index is smaller than q size, otherwise return the last item of q
  */
  virtual function T peek_index(input xil_axi_uint  index);
    int temp;
    AXI_IBQ_PEEK_INDEX_NO_ENTRIES: assert (index <= q.size()) begin
    end else begin
      `xil_error("GENERIC_QUEUE", $sformatf("AXI_IBQ_PEEK_INDEX_NO_ENTRIES: Peeking from invalid entry at time %t",$time))
    end
    temp = q.size();
    if (index <= temp) begin
      return(q[index]);
    end else begin
      return(this.peek_back());
    end
  endfunction

endclass : xil_axi_generic_queue_container

/////////////////////////////////////////////////////////////////////////////
////Prototype the write data beat class;
typedef class xil_axi_write_beat;

/*
  Class: xil_axi_rnd_uint
  XIL AXI RND Uint Object
*/
class xil_axi_rnd_uint;
  rand xil_axi_uint num;
endclass : xil_axi_rnd_uint

/*
  Class: axi_transaction
  AXI Transaction object.
*/
class axi_transaction extends xil_sequence_item;
  static xil_axi_uint                     s_cmd_id = 0;
  xil_axi_uint                            cmd_id = 0;
  xil_axi_cmd_t                           cmd;

  ///////////////////////////////////////////////////////////////////////////
  //Command
  rand xil_axi_burst_t                      burst = XIL_AXI_BURST_TYPE_INCR;
  rand xil_axi_ulong                        addr = 64'hdeadbeef;
  rand xil_axi_uint                         id = 99999;
  rand xil_axi_size_t                       size = XIL_AXI_SIZE_16BYTE;
  rand xil_axi_len_t                        len = 0;
  xil_axi_lock_t                            lock = XIL_AXI_ALOCK_NOLOCK;
  rand xil_axi_cache_t                      cache = 0;
  rand xil_axi_prot_t                       prot = 0;
  rand xil_axi_region_t                     region = 0;
  rand xil_axi_qos_t                        qos = 0;
  protected xil_axi_vif_axi_version_t       axi_version = XIL_VERSION_AXI4;
  protected xil_axi_boolean_t               supports_narrow = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               has_burst = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               has_lock = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               has_cache = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               has_region = XIL_AXI_TRUE ;
  protected xil_axi_boolean_t               has_prot = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               has_qos = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               has_wstrb = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               has_bresp = XIL_AXI_TRUE ;
  protected xil_axi_boolean_t               has_rresp = XIL_AXI_TRUE ;
  xil_axi_rnd_uint                          rnd_num;
  protected xil_axi_region_t                min_region = 4'h0;
  protected xil_axi_region_t                max_region = 4'hf;


  ///////////////////////////////////////////////////////////////////////////
  //Upper bounds on the values of the user configurable widths.
  protected xil_axi_uint                            addr_width = 10;
  protected xil_axi_uint                            id_width = 2;
  protected xil_axi_uint                            data_width = 128;
  protected xil_axi_driver_return_policy_t          driver_return_item = XIL_AXI_NO_RETURN;
  protected time                                    creation_time;
  protected time                                    submit_time;
  protected xil_axi_ulong                           submit_cycle;
  protected xil_axi_trans_state_t                   trans_state;

  ///////////////////////////////////////////////////////////////////////////
  //Delays
  rand xil_axi_uint                                 addr_delay = 2;
  rand xil_axi_uint                                 data_insertion_delay = 5;
  rand xil_axi_uint                                 response_delay = 4;
  rand xil_axi_uint                                 allow_data_before_cmd = 1;

  ///////////////////////////////////////////////////////////////////////////
  //Delay ranges for constraints
  protected xil_axi_uint                            min_addr_delay = 0;
  protected xil_axi_uint                            max_addr_delay = 20;
  protected xil_axi_uint                            min_data_insertion_delay = 0;
  protected xil_axi_uint                            max_data_insertion_delay = 20;
  protected xil_axi_uint                            min_response_delay = 0;
  protected xil_axi_uint                            max_response_delay = 5;
  protected xil_axi_uint                            min_allow_data_before_cmd = 0;
  protected xil_axi_uint                            max_allow_data_before_cmd = 16;
  protected xil_axi_uint                            min_beat_delay = 0;
  protected xil_axi_uint                            max_beat_delay = 5;
  protected xil_axi_uint                            report_errors_number = 5;

  protected xil_axi_boolean_t                       all_resp_okay = XIL_AXI_TRUE;
  protected xil_axi_boolean_t                       check_data_with_bad_resp = XIL_AXI_FALSE;
  protected xil_axi_boolean_t                       exclude_resp_exokay = XIL_AXI_TRUE;
  protected xil_axi_xfer_alignment_t                xfer_alignment = XIL_AXI_XFER_CONT_ALIGNED;
  protected xil_axi_xfer_wrcmd_order_t              xfer_wrcmd_order = XIL_AXI_WRCMD_ORDER_NONE;
  protected xil_axi_xfer_wrdata_insertion_policy_t  xfer_wrdata_insertion_policy = XIL_AXI_WRCMD_INSERTION_ALWAYS;
  protected xil_axi_boolean_t                       adjust_addr_delay_enabled = XIL_AXI_TRUE;
  protected xil_axi_boolean_t                       adjust_data_beat_delay_enabled = XIL_AXI_TRUE;

  ///////////////////////////////////////////////////////////////////////////
  //State information
  protected xil_axi_uint                             beat_index = 0;

  ///////////////////////////////////////////////////////////////////////////
  //Payload
  protected rand xil_axi_payload_byte                data[];
  protected rand bit                                 strb[];
  rand integer                                       beat_delay[];

  ///////////////////////////////////////////////////////////////////////////
  //Responses
  rand xil_axi_resp_t                         rresp[];
  rand xil_axi_resp_t                         bresp;

  ///////////////////////////////////////////////////////////////////////////
  //Slave reordering
  rand xil_axi_uint                           xfer_preemptive_probability = 25;

  ///////////////////////////////////////////////////////////////////////////
  //User bits
  protected rand xil_axi_user_beat            axuser = 'h0;
  protected rand xil_axi_user_element         user[];
  protected rand xil_axi_user_beat            buser = 'h0;
  protected xil_axi_uint                      awuser_width = 0;
  protected xil_axi_uint                      wuser_width = 0;
  protected xil_axi_uint                      buser_width = 0;
  protected xil_axi_uint                      aruser_width = 0;
  protected xil_axi_uint                      ruser_width = 0;

  ///////////////////////////////////////////////////////////////////////////
  // constructor ////////////////////////////////////////////////////////////
  /*
    Function: new
    Constructor to create a new AXI transaction.
  */
  function new(input string name = "unnamed_axi_transaction",
                     xil_axi_uint   protocol=0,
                     xil_axi_uint   addrw=32,
                     xil_axi_uint   dataw=32,
                     xil_axi_uint   idw=0,
                     xil_axi_uint   awusrw=0,
                     xil_axi_uint   wusrw=0,
                     xil_axi_uint   busrw=0,
                     xil_axi_uint   arusrw=0,
                     xil_axi_uint   rusrw=0,
                     xil_axi_uint   supports_narrow =1,
                     xil_axi_uint   has_burst =1,
                     xil_axi_uint   has_lock =1,
                     xil_axi_uint   has_cache =1,
                     xil_axi_uint   has_region =1,
                     xil_axi_uint   has_prot =1,
                     xil_axi_uint   has_qos =1,
                     xil_axi_uint   has_wstrb =1,
                     xil_axi_uint   has_bresp =1,
                     xil_axi_uint   has_rresp =1
  );
    super.new(name);
    cmd_id = s_cmd_id;
    this.s_cmd_id++;
    this.set_creation_time($time);
    this.set_trans_state(XIL_AXI_TRANS_STATE_NEW);
    this.set_protocol(protocol);
    this.set_addr_width(addrw);
    this.set_data_width(dataw);
    this.set_id_width(idw);
    this.set_awuser_width(awusrw);
    this.set_wuser_width(wusrw);
    this.set_buser_width(busrw);
    this.set_aruser_width(arusrw);
    this.set_ruser_width(rusrw);
    this.set_supports_narrow(supports_narrow);
    this.set_has_burst(has_burst);
    this.set_has_lock(has_lock);
    this.set_has_cache(has_cache);
    this.set_has_region(has_region);
    this.set_has_prot(has_prot);
    this.set_has_qos(has_qos);
    this.set_has_wstrb(has_wstrb);
    this.set_has_bresp(has_bresp);
    this.set_has_rresp(has_rresp);
    this.clr_beat_index();
    this.rnd_num = new;
  endfunction // new

  /*
    Function: copy
    Copies the contents of the input transaction to the current transaction
  */
  function void copy(axi_transaction rhs);
    xil_axi_region_t    min_region_tmp;
    xil_axi_region_t    max_region_tmp;
    xil_axi_uint        min_addr_delay_tmp;
    xil_axi_uint        max_addr_delay_tmp;
    xil_axi_uint        min_data_insertion_delay_tmp;
    xil_axi_uint        max_data_insertion_delay_tmp;
    xil_axi_uint        min_response_delay_tmp;
    xil_axi_uint        max_response_delay_tmp;
    xil_axi_uint        min_allow_data_before_cmd_tmp;
    xil_axi_uint        max_allow_data_before_cmd_tmp;
    xil_axi_uint        min_beat_delay_tmp;
    xil_axi_uint        max_beat_delay_tmp;
    this.set_addr_width(rhs.get_addr_width());
    this.set_data_width(rhs.get_data_width());
    this.set_id_width(rhs.get_id_width());
    this.set_awuser_width(rhs.get_awuser_width());
    this.set_wuser_width(rhs.get_wuser_width());
    this.set_buser_width(rhs.get_buser_width());
    this.set_aruser_width(rhs.get_aruser_width());
    this.set_ruser_width(rhs.get_ruser_width());
    this.set_supports_narrow(rhs.get_supports_narrow());
    this.set_has_burst(rhs.get_has_burst());
    this.set_has_lock(rhs.get_has_lock());
    this.set_has_cache(rhs.get_has_cache());
    this.set_has_region(rhs.get_has_region());
    this.set_has_prot(rhs.get_has_prot());
    this.set_has_qos(rhs.get_has_qos());
    this.set_has_wstrb(rhs.get_has_wstrb());
    this.set_has_bresp(rhs.get_has_bresp());
    this.set_has_rresp(rhs.get_has_rresp());
    this.cmd_id = rhs.cmd_id;
    this.verbosity = rhs.verbosity;
    this.set_axi_version(rhs.get_axi_version());
    this.set_cmd(
      rhs.cmd,
      rhs.addr,
      rhs.burst,
      rhs.id,
      rhs.len,
      rhs.size
    );
    this.set_lock(rhs.lock);
    this.set_cache(rhs.cache);
    this.set_prot(rhs.prot);
    this.set_region(rhs.region);
    this.set_qos(rhs.qos);
    this.rnd_num = rhs.rnd_num;
    rhs.get_region_range(min_region_tmp,max_region_tmp);
    this.min_region = min_region_tmp;
    this.max_region = max_region_tmp;
    this.driver_return_item = rhs.driver_return_item;
    this.set_creation_time(rhs.get_creation_time());
    this.set_submit_time(rhs.get_submit_time());
    this.set_submit_cycle(rhs.get_submit_cycle());
    this.trans_state = rhs.trans_state;
    this.addr_delay = rhs.addr_delay;
    this.data_insertion_delay = rhs.data_insertion_delay;
    this.response_delay = rhs.response_delay;
    this.allow_data_before_cmd = rhs.allow_data_before_cmd;
    rhs.get_addr_delay_range(min_addr_delay_tmp,max_addr_delay_tmp);
    this.min_addr_delay = min_addr_delay_tmp ;
    this.max_addr_delay = max_addr_delay_tmp ;
    rhs.get_data_insertion_delay_range(min_data_insertion_delay_tmp,max_data_insertion_delay_tmp);
    this.min_data_insertion_delay = min_data_insertion_delay_tmp ;
    this.max_data_insertion_delay = max_data_insertion_delay_tmp ;
    rhs.get_response_delay_range(min_response_delay_tmp,max_response_delay_tmp);
    this.min_response_delay = min_response_delay_tmp ;
    this.max_response_delay = max_response_delay_tmp ;
    rhs.get_allow_data_before_cmd_range(min_allow_data_before_cmd_tmp,max_allow_data_before_cmd_tmp);
    this.min_allow_data_before_cmd = min_allow_data_before_cmd_tmp  ;
    this.max_allow_data_before_cmd = max_allow_data_before_cmd_tmp ;
    rhs.get_beat_delay_range(min_beat_delay_tmp, max_beat_delay_tmp);
    this.min_beat_delay = min_beat_delay_tmp  ;
    this.max_beat_delay = max_beat_delay_tmp ;
    this.set_report_errors_number(rhs.get_report_errors_number()) ;
    this.all_resp_okay = rhs.all_resp_okay;
    this.check_data_with_bad_resp = rhs.check_data_with_bad_resp;
    this.exclude_resp_exokay = rhs.exclude_resp_exokay;
    this.xfer_alignment = rhs.xfer_alignment;
    this.xfer_wrcmd_order  = rhs.xfer_wrcmd_order ;
    this.xfer_wrdata_insertion_policy = rhs.xfer_wrdata_insertion_policy;
    this.beat_index = rhs.beat_index;
    this.xfer_preemptive_probability = rhs.xfer_preemptive_probability;
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      foreach(this.strb[i]) begin
        this.strb[i] = rhs.strb[i];
      end
      this.buser = rhs.buser;
      this.bresp = rhs.bresp;
    end else begin
      foreach(this.rresp[i]) begin
        this.rresp[i] = rhs.rresp[i];
      end
    end
    foreach(this.data[i]) begin
      this.data[i] = rhs.data[i];
    end
    foreach(this.beat_delay[i]) begin
      this.beat_delay[i] = rhs.beat_delay[i];
    end
    this.axuser = rhs.axuser;
    if (rhs.user.size() > 0) begin
      foreach(this.user[i]) begin
        this.user[i] = rhs.user[i];
      end
    end
  endfunction : copy

  /*
    Function: get_type_name
    Returns the name of the class type
  */
  virtual function string get_type_name();
    return "AXI_TRANSACTION";
  endfunction : get_type_name

  /*
    Function: my_clone
    Clones the current transaction and returns a handle to the new transaction.
  */
  virtual function axi_transaction my_clone ();
    axi_transaction           my_obj;
    my_obj = new(this.get_name(),
               this.get_protocol(),
               this.get_addr_width(),
               this.get_data_width(),
               this.get_id_width(),
               this.get_awuser_width(),
               this.get_wuser_width(),
               this.get_buser_width(),
               this.get_aruser_width(),
               this.get_ruser_width(),
               this.get_supports_narrow(),
               this.get_has_burst(),
               this.get_has_lock(),
               this.get_has_cache(),
               this.get_has_region(),
               this.get_has_prot(),
               this.get_has_qos(),
               this.get_has_wstrb(),
               this.get_has_bresp(),
               this.get_has_rresp()

    );
    my_obj.set_id_info(this);
    my_obj.copy(this);
    return(my_obj);
  endfunction : my_clone

  /*
    Function: set_protocol
    Sets the protocol type of the transaction.
  */
  virtual function void set_protocol(input xil_axi_uint update);
    if(update== 0) begin
      this.set_axi_version(XIL_VERSION_AXI4);
    end else if(update == 1) begin
      this.set_axi_version(XIL_VERSION_AXI3);
    end else if(update == 2) begin
      this.set_axi_version(XIL_VERSION_LITE);
    end else begin
      `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set transaction to illegal protocol %d",update))
    end
  endfunction : set_protocol

  /*
    Function: get_adjust_addr_delay_enabled
    Returns the current state of adjust_addr_delay_enabled of the transaction.
  */
  virtual function xil_axi_boolean_t get_adjust_addr_delay_enabled();
    return(this.adjust_addr_delay_enabled);
  endfunction: get_adjust_addr_delay_enabled

  /*
    Function: set_adjust_addr_delay_enabled
    Sets the value of adjust_addr_delay_enabled of the transaction.
  */
  virtual function void set_adjust_addr_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_addr_delay_enabled = update;
  endfunction: set_adjust_addr_delay_enabled

  /*
    Function: get_adjust_data_beat_delay_enabled
    Returns the current state of adjust_data_beat_delay_enabled of the transaction.
  */
  virtual function xil_axi_boolean_t get_adjust_data_beat_delay_enabled();
    return(this.adjust_data_beat_delay_enabled);
  endfunction: get_adjust_data_beat_delay_enabled

  /*
    Function: set_adjust_data_beat_delay_enabled
    Sets the value of adjust_data_beat_delay_enabled of the transaction.
  */
  virtual function void set_adjust_data_beat_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_data_beat_delay_enabled = update;
  endfunction: set_adjust_data_beat_delay_enabled

  /*
    Function: set_supports_narrow
    Sets the value of supports_narrow of the transaction.
  */
  virtual function void set_supports_narrow(input xil_axi_uint update);
    case (update)
    0 : this.supports_narrow = XIL_AXI_FALSE;
    1 : this.supports_narrow = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set supports_narrow out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_burst
    Sets the value of has_burst of the transaction.
  */
  virtual function void set_has_burst(input xil_axi_uint update);
    case (update)
    0 : this.has_burst = XIL_AXI_FALSE;
    1 : this.has_burst = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_burst out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_lock
    Sets the value of has_lock of the transaction.
  */
  virtual function void set_has_lock(input xil_axi_uint update);
    case (update)
    0 : this.has_lock = XIL_AXI_FALSE;
    1 : this.has_lock = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_lock out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_cache
    Sets the value of has_cache of the transaction.
  */
  virtual function void set_has_cache(input xil_axi_uint update);
    case (update)
    0 : this.has_cache = XIL_AXI_FALSE;
    1 : this.has_cache = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_cache out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_region
    Sets the value of has_region of the transaction.
  */
  virtual function void set_has_region(input xil_axi_uint update);
    case (update)
    0 : this.has_region = XIL_AXI_FALSE;
    1 : this.has_region = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_region out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_prot
    Sets the value of has_prot of the transaction.
  */
  virtual function void set_has_prot(input xil_axi_uint update);
    case (update)
    0 : this.has_prot = XIL_AXI_FALSE;
    1 : this.has_prot = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_prot out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_qos
    Sets the value of has_qos of the transaction.
  */
  virtual function void set_has_qos(input xil_axi_uint update);
    case (update)
    0 : this.has_qos = XIL_AXI_FALSE;
    1 : this.has_qos = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_qos out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_wstrb
    Sets the value of has_wstrb of the transaction.
  */
  virtual function void set_has_wstrb(input xil_axi_uint update);
    case (update)
    0 : this.has_wstrb = XIL_AXI_FALSE;
    1 : this.has_wstrb = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_wstrb out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_bresp
    Sets the value of has_bresp of the transaction.
  */
  virtual function void set_has_bresp(input xil_axi_uint update);
    case (update)
    0 : this.has_bresp = XIL_AXI_FALSE;
    1 : this.has_bresp = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_bresp out of range %p",update))
    endcase
  endfunction

  /*
    Function: set_has_rresp
    Sets the value of has_rresp of the transaction.
  */
  virtual function void set_has_rresp(input xil_axi_uint update);
    case (update)
    0 : this.has_rresp = XIL_AXI_FALSE;
    1 : this.has_rresp = XIL_AXI_TRUE;
    default : `xil_fatal(this.get_type_name(),$sformatf( "Attempt to set has_rresp out of range %p",update))
    endcase
  endfunction

  /*
    Function: get_supports_narrow
    Returns the value of supports_narrow of the transaction.
  */
  virtual function xil_axi_boolean_t get_supports_narrow();
    return(this.supports_narrow);
  endfunction

  /*
    Function: get_has_burst
    Returns the value of has_burst of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_burst();
    return(this.has_burst);
  endfunction

  /*
    Function: get_has_lock
    Returns the value of has_lock of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_lock();
    return(this.has_lock);
  endfunction

  /*
    Function: get_has_cache
    Returns the value of has_cache of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_cache();
    return(this.has_cache);
  endfunction

  /*
    Function: get_has_region
    Returns the value of has_region of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_region();
    return(this.has_region);
  endfunction

  /*
    Function: get_has_prot
    Returns the value of has_prot of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_prot();
    return(this.has_prot);
  endfunction

  /*
    Function: get_has_qos
    Returns the value of has_qos of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_qos();
    return(this.has_qos);
  endfunction

  /*
    Function: get_has_wstrb
    Returns the value of has_wstrb of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_wstrb();
    return(this.has_wstrb);
  endfunction

  /*
    Function: get_has_bresp
    Returns the value of has_bresp of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_bresp();
    return(this.has_bresp);
  endfunction

  /*
    Function: get_has_rresp
    Returns the value of has_rresp of the transaction.
  */
  virtual function xil_axi_boolean_t get_has_rresp();
    return(this.has_rresp);
  endfunction

  /*
    Function: get_protocol
    Returns the value of protocol type of the transaction.
  */
  virtual function xil_axi_uint get_protocol();
    if(this.get_axi_version()== XIL_VERSION_AXI4) begin
      return(0);
    end else if(this.get_axi_version() == XIL_VERSION_AXI3) begin
      return(1);
    end else if(this.get_axi_version() == XIL_VERSION_LITE) begin
      return(2);
    end
  endfunction

  /*
    Function: set_addr_width
    Sets the value of address width of the transaction.
  */
  virtual function void set_addr_width(input xil_axi_uint updated);
    if (updated > 64) begin
      `xil_fatal(this.get_name(), $sformatf("Attempted to set the address width (%d) to a value greater than 64", updated))
    end
    this.addr_width = updated;
  endfunction

  /*
    Function: get_addr_width
    Returns the value of address width of the transaction.
  */
  virtual function xil_axi_uint get_addr_width();
    if (this.addr_width > 64) begin
      `xil_fatal(this.get_name(), $sformatf("Address width (%d) to a value greater than 64", this.addr_width))
    end
    return(this.addr_width);
  endfunction

  /*
    Function: set_data_width
    Sets the value of WDATA/RDATA width of the transaction.
  */
  virtual function void set_data_width(xil_axi_uint updated);
    if (!((updated == 8) ||
          (updated == 16) ||
          (updated == 32) ||
          (updated == 64) ||
          (updated == 128) ||
          (updated == 256) ||
          (updated == 512) ||
          (updated == 1024))) begin
        `xil_fatal(this.get_name(), $sformatf("Data width of the transaction (%d) is not 8, 16, 32, 64, 128, 256, 512, 1024", updated))
    end
    this.data_width = updated;
  endfunction

  /*
    Function: get_data_width
    Returns the value of WDATA/RDATA width of the transaction.
  */
  virtual function xil_axi_uint get_data_width();
    if (!((this.data_width == 8) ||
          (this.data_width == 16) ||
          (this.data_width == 32) ||
          (this.data_width == 64) ||
          (this.data_width == 128) ||
          (this.data_width == 256) ||
          (this.data_width == 512) ||
          (this.data_width == 1024))) begin
        `xil_fatal(this.get_name(), $sformatf("Data width of the transaction (%d) is not 8, 16, 32, 64, 128, 256, 512, 1024", this.data_width))
    end
    return(this.data_width);
  endfunction

  /*
    Function: set_id_width
    Sets the value of ID width of the transaction.
  */
  virtual function void set_id_width(xil_axi_uint updated);
    if (updated > 32) begin
      `xil_fatal(this.get_name(), $sformatf("Attempting to set ID to (%d) width exceeding 32 bits", updated))
    end
    this.id_width = updated;
  endfunction

  /*
    Function: get_id_width
    Returns the value of ID width of the transaction.
  */
  virtual function xil_axi_uint get_id_width();
    if (this.id_width > 32) begin
      `xil_fatal(this.get_name(), $sformatf("Current transaction has ID (%d) width exceeding 32 bits", this.id_width))
    end
    return(this.id_width);
  endfunction

  /*
    Function: set_awuser_width
    Sets the value of AWUSER width of the transaction.
  */
  virtual function void set_awuser_width(xil_axi_uint updated);
    if (updated > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Attempting to set AWUSER to (%d) width exceeding 1024 bits", updated))
    end
    this.awuser_width = updated;
  endfunction

  /*
    Function: get_awuser_width
    Returns the value of AWUSER width of the transaction.
  */
  virtual function xil_axi_uint get_awuser_width();
    if (this.awuser_width > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Current transaction has AWUSER (%d) width exceeding 1024 bits", this.awuser_width))
    end
    return(this.awuser_width);
  endfunction

  /*
    Function: set_wuser_width
    Sets the value of WUSER width of the transaction.
  */
  virtual function void set_wuser_width(xil_axi_uint updated);
    if (updated > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Attempting to set WUSER to (%d) width exceeding 1024 bits", updated))
    end
    this.wuser_width = updated;
  endfunction

  /*
    Function: get_wuser_width
    Returns the value of WUSER width of the transaction.
  */
  virtual function xil_axi_uint get_wuser_width();
    if (this.wuser_width > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Current transaction has WUSER (%d) width exceeding 1024 bits", this.wuser_width))
    end
    return(this.wuser_width);
  endfunction

  /*
    Function: set_buser_width
    Sets the value of BUSER width of the transaction.
  */
  virtual function void set_buser_width(xil_axi_uint updated);
    if (updated > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Attempting to set BUSER to (%d) width exceeding 1024 bits", updated))
    end
    this.buser_width = updated;
  endfunction

  /*
    Function: get_buser_width
    Returns the value of BISER width of the transaction.
  */
  virtual function xil_axi_uint get_buser_width();
    if (this.buser_width > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Current transaction has BUSER (%d) width exceeding 1024 bits", this.buser_width))
    end
    return(this.buser_width);
  endfunction

  /*
    Function: set_aruser_width
    Sets the value of ARUSER width of the transaction.
  */
  virtual function void set_aruser_width(xil_axi_uint updated);
    if (updated > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Attempting to set ARUSER to (%d) width exceeding 1024 bits", updated))
    end
    this.aruser_width = updated;
  endfunction

  /*
    Function: get_aruser_width
    Returns the value of ARUSER width of the transaction.
  */
  virtual function xil_axi_uint get_aruser_width();
    if (this.aruser_width > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Current transaction has ARUSER (%d) width exceeding 1024 bits", this.aruser_width))
    end
    return(this.aruser_width);
  endfunction

  /*
    Function: set_ruser_width
    Sets the value of RUSER width of the transaction.
  */
  virtual function void set_ruser_width(xil_axi_uint updated);
    if (updated > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Attempting to set RUSER to (%d) width exceeding 1024bits", updated))
    end
    this.ruser_width = updated;
  endfunction

  /*
    Function: get_ruser_width
    Returns the value of RUSER width of the transaction.
  */
  virtual function xil_axi_uint get_ruser_width();
    if (this.ruser_width > 1024) begin
      `xil_fatal(this.get_name(), $sformatf("Current transaction has RUSER (%d) width exceeding 1024bits", this.ruser_width))
    end
    return(this.ruser_width);
  endfunction

  /*
    Function: get_axi_version
    Returns the value of AXI version of the transaction.
  */
  virtual function xil_axi_vif_axi_version_t get_axi_version();
    return(this.axi_version);
  endfunction

  /*
    Function: set_axi_version
    Sets the value of AXI VERSION of the transaction.
  */
  virtual function void set_axi_version(xil_axi_vif_axi_version_t updated);
    this.axi_version = updated;
  endfunction

  /*
    Function: get_axi_version_name
    Returns the string name of the AXI version of the transaction.
  */
  virtual function string get_axi_version_name();
    return(this.axi_version.name());
  endfunction

  /*
   Function: set_creation_time
   Sets creation_time of the transaction.
  */
  virtual function void set_creation_time(time in);
    this.creation_time = in;
  endfunction

  /*
   Function: get_creation_time
   Returns creation_time of the transaction.
  */
  virtual function time get_creation_time();
    return(this.creation_time);
  endfunction

  /*
    Function: cmd_sprintf
    Returns the string of the AXI basic command properties. This is debugging tool to observe the transaction.
  */
  virtual function string cmd_sprintf();
    return($sformatf("%s (%0d) A:0x%x ID:0x%x len:0x%x %s %s C:0b%b L:%s P:0b%b", cmd.name(), this.get_cmd_id(),
       this.get_addr(), this.get_id(), this.get_len(), size.name(),burst.name(), this.get_cache(), this.lock.name(),
       this.get_prot()));
  endfunction

  /*
    Function: set_submit_time
    Sets sumbit_time of the transaction.
  */
  virtual function void set_submit_time(time in);
    this.submit_time = in;
  endfunction

  /*
    Function:  get_submit_time
    Gets submit_time of the transaction.
  */
  virtual function time get_submit_time();
    return(this.submit_time);
  endfunction

  /*
    Function: set_submit_cycle
    Sets sumbit_cycle of the transaction.
  */
  virtual function void set_submit_cycle(xil_axi_ulong in);
    this.submit_cycle = in;
  endfunction

  /*
    Function:  get_submit_cycle
    Gets submit_cycle of the transaction.
  */
  virtual function xil_axi_ulong get_submit_cycle();
    return(this.submit_cycle);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //Ranges
  /*
    Function: get_region_range
    Returns the MIN/MAX values that are used to constrain the AxREGION value.
  */
  virtual function void get_region_range(output xil_axi_region_t min,
                                output xil_axi_region_t max);
    min = this.min_region;
    max = this.max_region;
  endfunction

  /*
    Function: set_region_range
    Sets the MIN/MAX values that are used to constrain the AxREGION value.
  */
  virtual function void set_region_range(input xil_axi_region_t min,
                                        input xil_axi_region_t max);
    this.min_region = min;
    this.max_region = max;
  endfunction

  /*
    Function: get_num_bytes_in_transaction
    Returns the number of bytes DATA of the transaction based on the current properties of the transaction.
  */
  virtual function xil_axi_uint get_num_bytes_in_transaction();
    xil_axi_uint  rc;
    rc = (this.get_len() +1) << this.get_size();
    return(rc);
  endfunction

  /*
    Function: set_read_cmd
    Helper function to set the most common READ command properties of the transaction.
  */
  virtual function void set_read_cmd(
    input xil_axi_ulong         addr,
    input xil_axi_burst_t       burst = XIL_AXI_BURST_TYPE_INCR,
    input xil_axi_uint          id  = 0,
    input xil_axi_len_t         len = 0,
    input xil_axi_size_t        size = XIL_AXI_SIZE_4BYTE
  );
    this.set_cmd(XIL_AXI_READ,
      addr,
      burst,
      id,
      len,
      size
    );
  endfunction: set_read_cmd

  /*
    Function: set_write_cmd
    Helper function to set the most common WRITE command properties of the transaction.
  */
  virtual function void set_write_cmd(
    input xil_axi_ulong         addr,
    input xil_axi_burst_t       burst = XIL_AXI_BURST_TYPE_INCR,
    input xil_axi_uint          id  = 0,
    input xil_axi_len_t         len = 0,
    input xil_axi_size_t        size = XIL_AXI_SIZE_4BYTE
  );
    this.set_cmd(XIL_AXI_WRITE,
      addr,
      burst,
      id,
      len,
      size
    );
  endfunction : set_write_cmd

  /*
    Function: set_cmd
    Helper function to set the most common command properties of the transaction.
  */
  virtual function void set_cmd(
    input xil_axi_cmd_t         cmd,
    input xil_axi_ulong         addr,
    input xil_axi_burst_t       burst = XIL_AXI_BURST_TYPE_INCR,
    input xil_axi_uint          id  = 0,
    input xil_axi_len_t         len = 0,
    input xil_axi_size_t        size = XIL_AXI_SIZE_4BYTE
  );
    ///////////////////////////////////////////////////////////////////////////
    //Fill in the command information
    this.set_addr(addr);
    if (this.get_axi_version() == XIL_VERSION_LITE) begin
      this.set_size(this.get_dw_size());
      this.set_len(0);
      this.set_id(0);
      this.set_burst(XIL_AXI_BURST_TYPE_INCR);
    end else begin
      this.set_size(size);
      this.set_burst(burst);
      this.set_len(len);
      this.set_id(id);
    end
    this.set_cmd_type(cmd);
    if (cmd == XIL_AXI_WRITE) begin
      this.size_wr_beats();
    end else begin
      this.size_rd_beats();
    end
  endfunction : set_cmd

  /*
    Function: get_region
    Returns the value of AxREGION of the transaction.
  */
  virtual function xil_axi_region_t get_region ();
    return(this.region);
  endfunction : get_region

  /*
    Function: set_region
    Sets the value of AxREGION of the transaction.
  */
  virtual function void set_region (input xil_axi_region_t updated);
    this.region = updated;
  endfunction : set_region

  /*
    Function: get_qos
    Returns the value of AxQOS of the transaction.
  */
  virtual function xil_axi_qos_t get_qos ();
    return(this.qos);
  endfunction : get_qos

  /*
    Function: set_qos
    Sets the value of AxQOS of the transaction.
  */
  virtual function void set_qos (input xil_axi_qos_t updated);
    this.qos = updated;
  endfunction : set_qos

  /*
    Function: get_id
    Returns the value of AxID/RID/BID of the transaction.
  */
  virtual function xil_axi_uint get_id ();
    return(this.id & ((1 << this.get_id_width()) - 1) );
  endfunction : get_id

  /*
    Function: set_id
    Sets the value of AxID/RID/BID of the transaction.
  */
  virtual function void set_id (input xil_axi_uint new_id);
    xil_axi_uint idmask;
    idmask = (1 << this.get_id_width())-1;
    if ((this.get_axi_version() == XIL_VERSION_LITE) && (new_id != 0)) begin
      `xil_fatal(get_name(), $sformatf("Attempted to send ID (0x%x) when AXI4LITE", new_id))
    end
    if ((new_id & ~idmask) > 0) begin
      `xil_warning(get_name(), $sformatf("Attempted to send ID (0x%x) which is wider than id_width (%d). Truncating ID to (0x%0x)", new_id, this.get_id_width(), new_id & idmask))
      new_id &= idmask;
    end
    this.id = new_id;
  endfunction

  /*
    Function: set_driver_return_item
    Sets the driver_return_item property to XIL_AXI_PAYLOAD_RETURN of the transaction.
  */
  virtual function void set_driver_return_item ();
    this.driver_return_item = XIL_AXI_PAYLOAD_RETURN;
  endfunction

  /*
    Function: set_driver_return_item_policy
    Sets the driver_return_item property of the transaction.
  */
  virtual function void set_driver_return_item_policy (input xil_axi_driver_return_policy_t set);
    this.driver_return_item = set;
  endfunction

  /*
    Function: get_driver_return_item_policy
    Returns the value of driver_return_item property of the transaction.
  */
  virtual function xil_axi_driver_return_policy_t get_driver_return_item_policy ();
    return(this.driver_return_item);
  endfunction

  /*
    Function: get_addr
    Returns the value of AxADDR of the transaction.
  */
  function xil_axi_ulong get_addr ();
    return(this.addr & ((1 << this.get_addr_width()) - 1) );
  endfunction

  /*
    Function: set_addr
    Sets the value of AxADDR of the transaction.
  */
  virtual function void set_addr (input xil_axi_ulong updated);
    xil_axi_ulong mask;
    mask = (1 << this.get_addr_width())-1;
    if ((updated & ~mask) > 0) begin
      `xil_warning(get_name(), $sformatf("Attempted to send ADDR (0x%x) which is wider than addr_width (%d). Truncating ADDR to (0x%0x)", updated, this.get_addr_width(), updated & mask))
      updated &= mask;
    end
    this.addr = updated;
  endfunction

  /*
    Function:  get_addr_offset
    Gets address offset of the transaction.
  */
  virtual function xil_axi_uint get_addr_offset();
    return (this.addr & ((1 << ($clog2(this.get_data_width()/8)))-1));
  endfunction

  /*
    Function: get_cmd_id
    Returns the value of an ID field for the transaction. This can be used for tracking the transaction within the DRIVER or environment.
  */
  virtual function xil_axi_uint get_cmd_id();
    return(this.cmd_id);
  endfunction

  /*
    Function: get_cmd_type
    Returns the transaction command type (READ/WRITE) of the transaction.
  */
  virtual function xil_axi_cmd_t get_cmd_type();
    return(this.cmd);
  endfunction

  /*
    Function: set_cmd_type
    Sets the transaction command type (READ/WRITE) of the transaction.
  */
  virtual function void set_cmd_type(input xil_axi_cmd_t updated);
    this.cmd = updated;
  endfunction

  /*
    Function: get_cmd_type_name
    Returns the string name of the command type of the transaction.
  */
  virtual function string get_cmd_type_name();
    return(this.cmd.name());
  endfunction

  /*
    Function: get_len
    Returns the value of AxLEN of the transaction.
  */
  virtual function xil_axi_len_t get_len();
    return(this.len);
  endfunction

  /*
    Function: set_len
    Sets the value of AxLEN of the transaction.
  */
  virtual function void set_len(input xil_axi_len_t updated);
    //////////////////////////////////////////////////////////////////////
    //DRC type checks
    if (this.get_axi_version() == XIL_VERSION_LITE) begin
      if (updated != 0) begin
        `xil_fatal(get_name(), $sformatf("axi_version is %s while length %d is not 0 ", this.axi_version, updated))
      end
    end else begin
      if ((updated > 15) && (this.get_axi_version() == XIL_VERSION_AXI3)) begin
        `xil_fatal(get_name(), $sformatf("AXI3 supports only lengths 0-15. Tried to set len %p", updated))
      end
      if ((this.get_burst() != XIL_AXI_BURST_TYPE_INCR) && (updated > 15)) begin
        `xil_fatal(get_name(), $sformatf("burst type is %s, length %p is not in range ", this.get_burst_name(), updated))
      end
      if ((this.get_burst() == XIL_AXI_BURST_TYPE_FIXED) && (updated > 15)) begin
        `xil_fatal(get_name(), $sformatf("burst type is %s while length %d is greater than 15", this.get_burst_name(), updated))
      end
      if ((this.get_burst() == XIL_AXI_BURST_TYPE_WRAP) && 
          ((updated != 1) && (updated != 3) && (updated != 7) && (updated != 15))) begin
        `xil_fatal(get_name(), $sformatf("burst type is %s while length %p is not 2,4,8,16", this.get_burst_name(), updated))
      end
    end
    this.len = updated;
  endfunction

  /*
    Function: get_size
    Returns the value of AxSIZE of the transaction.
  */
  virtual function xil_axi_size_t get_size();
    return(this.size);
  endfunction

  /*
    Function: get_size_name
    Returns the string name of the value of AxSIZE of the transaction.
  */
  virtual function string get_size_name();
    return(this.size.name());
  endfunction

  /*
    Function: get_dw_size
    Helper function that will convert the data width value to AxSIZE and return the value;
  */
  virtual function xil_axi_size_t get_dw_size();
    return(convert_dw_to_axi_size(this.get_data_width()));
  endfunction

  /*
    Function: set_size
    Sets the value of AxSIZE of the transaction.
  */
  virtual function void set_size(input xil_axi_size_t updated);
    if ((this.get_axi_version() == XIL_VERSION_LITE) && (this.get_dw_size() != updated)) begin
      `xil_fatal(get_name(), $sformatf("Attempted to set an invalid SIZE (%s). AXI4LITE can only have SIZE the same as the DW", updated.name()))
    end else begin
      if (updated > this.get_dw_size()) begin
      `xil_fatal(get_name(), $sformatf("Attempted to set an invalid SIZE (%p). AxSize cannot be larger than the DATA_WIDTH (%d)", updated.name(), this.get_data_width()))
      end
    end
    this.size = updated;
  endfunction

  /*
    Function: get_burst
    Returns the value of AxBURST of the transaction.
  */
  virtual function xil_axi_burst_t get_burst();
    return(this.burst);
  endfunction

  /*
    Function: get_burst_name
    Returns the string name of the value of AxBURST of the transaction.
  */
  virtual function string get_burst_name();
    return(this.burst.name());
  endfunction

  /*
    Function: set_burst
    Sets the value of AxBURST of the transaction.
  */
  virtual function void set_burst(input xil_axi_burst_t updated);
    if(this.has_burst == XIL_AXI_TRUE) begin
      if ((this.get_axi_version() == XIL_VERSION_LITE) && (updated != XIL_AXI_BURST_TYPE_INCR)) begin
        `xil_fatal(this.get_name(), $sformatf("Attempted to set burst type %s while IP is AXI4LITE.",updated.name()))
      end
      this.burst = updated;
    end else if (updated == XIL_AXI_BURST_TYPE_INCR) begin
      this.burst = updated;
    end else begin
      `xil_fatal(this.get_name(), $sformatf("Attempt to set burst type %s while IP HAS_BURST is not enabled",updated.name()))
    end
  endfunction

  /*
    Function: get_lock
    Returns the value of AxLOCK of the transaction.
  */
  virtual function xil_axi_lock_t get_lock();
    get_lock = this.lock;
  endfunction

  /*
    Function: set_lock
    Sets the value of AxLOCK of the transaction.
  */
  virtual function void set_lock(input xil_axi_lock_t updated);
    this.lock = updated;
  endfunction

  /*
    Function: get_cache
    Returns the value of AxCACHE of the transaction.
  */
  virtual function xil_axi_cache_t get_cache();
    get_cache = this.cache;
  endfunction

  /*
    Function: set_cache
    Sets the value of AxCACHE of the transaction.
  */
  virtual function void set_cache(input xil_axi_cache_t updated);
    this.cache = updated;
  endfunction

  /*
    Function: get_prot
    Returns the value of AxPROT of the transaction.
  */
  virtual function xil_axi_prot_t get_prot();
    get_prot = this.prot;
  endfunction

  /*
    Function: set_prot
    Sets the value of AxPROT of the transaction.
  */
  virtual function void set_prot(input xil_axi_prot_t updated);
    this.prot = updated;
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //Transaction State API
  /*
    Function:  set_trans_state
    Sets trans_state of the transaction.
  */
  virtual function void set_trans_state(input xil_axi_trans_state_t updated);
    this.trans_state = updated;
  endfunction

  /*
    Function:  get_trans_state
    Returns trans_state of the transaction.
  */
  virtual function xil_axi_trans_state_t get_trans_state();
    return(this.trans_state);
  endfunction

  protected function string get_user_format(
    input xil_axi_uint  width
  );
    return($sformatf("%%%0dx", (width+3)/4));
  endfunction : get_user_format

  /*
    Function: do_print
    Print out transaction information
  */
  virtual function void do_print(xil_printer printer);
    string sdata;
    string sstrb;
    string sresp;
    string sout;
    string sbeat_delay;
    xil_axi_uint        number_bytes;
    xil_axi_user_beat   user_beat;
    super.do_print(printer);

    printer.print_string("CMD_ID",  $sformatf("0x%x", this.cmd_id));

    printer.print_string("AXI_VERSION",  $sformatf("%s", this.axi_version));

    printer.print_string("CMD",  $sformatf("%s", this.cmd));

    printer.print_string("ADDR",  $sformatf("0x%x", this.addr));

    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      if (id_width > 0) begin
        printer.print_string("WID",    $sformatf("0x%x", this.id));
      end
    end else begin
    if (id_width > 0) begin
        printer.print_string("RID",    $sformatf("0x%x", this.id));
      end
    end

    printer.print_string("LEN",  $sformatf("0x%x", this.len));

    printer.print_string("SIZE",  $sformatf("%s", this.size));

    printer.print_string("BURST",  $sformatf("%s", this.burst));

    printer.print_string("LOCK",  $sformatf("%s", this.lock));

    printer.print_string("CACHE",  $sformatf("0x%x", this.cache));

    printer.print_string("PROT",  $sformatf("0x%x", this.prot));

    printer.print_string("REGION",  $sformatf("0x%x", this.region));

    printer.print_string("QOS",  $sformatf("0x%x", this.qos));

    printer.print_string("DRIVER_RETURN_ITEM",  $sformatf("%s", this.driver_return_item));

    printer.print_string("CREATION_TIME",  $sformatf("%0t", this.creation_time));

    printer.print_string("SUBMIT_TIME",  $sformatf("%0t", this.get_submit_time()));

    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      if (this.get_awuser_width() > 0) begin
        printer.print_string("AWUSER", $sformatf("0x%s", $sformatf(this.get_user_format(this.get_awuser_width()), this.get_axuser())));
      end
      if (this.get_buser_width() > 0) begin
        printer.print_string("BUSER", $sformatf("0x%s", $sformatf(this.get_user_format(this.get_buser_width()), this.get_buser())));
      end
      printer.print_string("BRESP", $sformatf("%s",bresp.name()));
    end else begin
      if (this.get_aruser_width() > 0) begin
        printer.print_string("ARUSER", $sformatf("0x%s", $sformatf(this.get_user_format(this.get_aruser_width()), this.get_axuser())));
      end
    end
    number_bytes = xil_pow2(this.get_size());
    if(this.get_cmd_type() == XIL_AXI_WRITE) begin
      printer.print_array_header("PAYLOAD", data.size());
    end
    for(int i=0; i<(this.get_len()+1); i++) begin
      sdata = "";
      sstrb = "";
      sbeat_delay = "";
      sout = "";
      sresp = "";
      for(int j=0; j < number_bytes;j++) begin
        sdata = $sformatf("%x%s",data[i*number_bytes+j],sdata);
        sstrb = $sformatf("%b%s",strb[i*number_bytes+j],sstrb);
      end
      sout = $sformatf("0x%s",sdata);
      if (this.get_cmd_type() == XIL_AXI_WRITE) begin
        sout = $sformatf("%s (strb : 0b%s)",sout,sstrb);
        if (this.get_wuser_width() > 0) begin
          sout = $sformatf("%s U:(0x%s)", sout, $sformatf(this.get_user_format(this.get_wuser_width()), this.get_user_beat(i)));
        end
      end else begin
        sout = $sformatf("%s (%s)",sout,rresp[i].name());
        if (this.get_ruser_width() > 0) begin
          sout = $sformatf("%s U:(0x%s)", sout, $sformatf(this.get_user_format(this.get_ruser_width()), this.get_user_beat(i)));
        end
      end
      sbeat_delay = $sformatf("%d%s",beat_delay[i],sbeat_delay);
      sout = $sformatf("%s :beat_delay:%0d)",sout,sbeat_delay);
      if(this.get_cmd_type() == XIL_AXI_WRITE) begin
        printer.print_string($sformatf("BEAT[%d]",i), sout);
      end
    end
    printer.print_array_footer(1);

  endfunction

  protected virtual function bit do_compare_cmd (
    axi_transaction rhs_
  );
    bit compare_result;
    xil_axi_user_beat   rhs_user_beat;
    xil_axi_user_beat   lhs_user_beat;
    compare_result = 1;
    if (this.get_axi_version() != XIL_VERSION_LITE) begin
      if (this.qos !== rhs_.qos) begin
        `xil_error(get_name(), $sformatf("Miscompare for QOS:\nlhs = 0x%x\nrhs = 0x%x", this.qos, rhs_.qos))
        compare_result = 0;
      end
    end
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      if (this.get_awuser_width() > 0) begin
        rhs_user_beat = rhs_.get_awuser();
        lhs_user_beat = this.get_awuser();
        if (rhs_user_beat !== lhs_user_beat) begin
          `xil_error(get_name(), $sformatf("Miscompare for %s vs %s awuser:\nlhs (width: %d) = 0x%x\nrhs (width: %d) = 0x%x",
            this.get_name(), rhs_.get_name(),
            this.get_awuser_width(), lhs_user_beat,
            rhs_.get_awuser_width(), rhs_user_beat))
          compare_result = 0;
        end
      end
    end else begin
      if (this.get_aruser_width() > 0) begin
        rhs_user_beat = rhs_.get_aruser();
        lhs_user_beat = this.get_aruser();
        if (rhs_user_beat !== lhs_user_beat) begin
          `xil_error(get_name(), $sformatf("Miscompare for %s vs %s aruser:\nlhs (width: %d) = 0x%x\nrhs (width: %d) = 0x%x",
            this.get_name(), rhs_.get_name(),
            this.get_aruser_width(), lhs_user_beat,
            rhs_.get_aruser_width(), rhs_user_beat))
          compare_result = 0;
        end
      end
    end
    return(compare_result);
  endfunction : do_compare_cmd

  protected virtual function bit do_compare_bchannel (
    axi_transaction rhs_
  );
    bit compare_result;
    xil_axi_user_beat   rhs_user_beat;
    xil_axi_user_beat   lhs_user_beat;
    compare_result = 1;
    ///////////////////////////////////////////////////////////////////////////
    //Compare the BRESP
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      if (this.bresp !== rhs_.bresp) begin
        `xil_error(get_name(), $sformatf("Miscompare for %s vs %s bresp:\nlhs = %s\nrhs = %s", this.get_name(), rhs_.get_name(), this.bresp.name(), rhs_.bresp.name()))
        compare_result = 0;
      end
      if (this.get_buser_width() > 0) begin
        rhs_user_beat = rhs_.get_buser();
        lhs_user_beat = this.get_buser();
        if (lhs_user_beat !== rhs_user_beat) begin
          `xil_error(get_name(), $sformatf("Miscompare for %s vs %s buser:\nlhs (width: %d) = 0x%x\nrhs (width: %d) = 0x%x",
            this.get_name(), rhs_.get_name(),
            this.get_buser_width(), lhs_user_beat,
            rhs_.get_buser_width(), rhs_user_beat))
          compare_result = 0;
        end
      end
    end
    return(compare_result);
  endfunction : do_compare_bchannel

  protected virtual function bit do_compare_rresp (
    inout axi_transaction rhs_
  );
    bit compare_result;
    xil_axi_resp_t  tmp_resp;
    xil_axi_resp_t  rhs_resp;
    xil_axi_uint        error_cnt;
    compare_result = 1;
    error_cnt = 0;
    ///////////////////////////////////////////////////////////////////////////
    //Compare the RRESP
    if (this.get_cmd_type() == XIL_AXI_READ) begin
      for (xil_axi_uint mylen = 0; mylen < this.get_len()+1;mylen++) begin
        tmp_resp = this.rresp[mylen];
        rhs_resp = rhs_.rresp[mylen];

        //if ((this.rresp[mylen] !== rhs_.rresp[mylen]) && (error_cnt < report_errors_number)) begin
        if ((tmp_resp !== rhs_resp) && (error_cnt < report_errors_number)) begin
          `xil_error(get_name(), $sformatf("Miscompare for %s vs %s rresp[%d]: lhs = %s : rhs = %s", this.get_name(), rhs_.get_name(), mylen, this.rresp[mylen].name(), rhs_.rresp[mylen].name()))
          compare_result = 0;
          error_cnt++;
        end
      end
    end
    return(compare_result);
  endfunction : do_compare_rresp

  protected virtual function bit do_compare_ruser (
    axi_transaction rhs_
  );
    bit compare_result;
    xil_axi_uint        error_cnt;
    xil_axi_user_beat   lhs_user;
    xil_axi_user_beat   rhs_user;
    compare_result = 1;
    error_cnt = 0;
    ///////////////////////////////////////////////////////////////////////////
    //Compare the RUSER
    if ((this.get_cmd_type() == XIL_AXI_READ) && (this.get_ruser_width() > 0)) begin
      for (xil_axi_uint mylen = 0; mylen < this.get_len()+1;mylen++) begin
        lhs_user = this.get_user_beat(mylen);
        rhs_user = rhs_.get_user_beat(mylen);

        if ((lhs_user !== rhs_user) && (error_cnt < report_errors_number)) begin
          `xil_error(get_name(), $sformatf("Miscompare for %s vs %s ruser[%d]:\nlhs (width: %d) = 0x%x\nrhs (width: %d) = 0x%x",
            this.get_name(), rhs_.get_name(), mylen,
            this.get_ruser_width(), lhs_user,
            rhs_.get_ruser_width(), rhs_user))
          compare_result = 0;
          error_cnt++;
        end
      end
    end
    return(compare_result);
  endfunction : do_compare_ruser

  protected virtual function bit do_compare_wuser (
    axi_transaction rhs_
  );
    bit compare_result;
    xil_axi_uint        error_cnt;
    xil_axi_user_beat   lhs_user;
    xil_axi_user_beat   rhs_user;
    compare_result = 1;
    error_cnt = 0;
    ///////////////////////////////////////////////////////////////////////////
    //Compare the WUSER
    if ((this.get_cmd_type() == XIL_AXI_WRITE) && (this.get_wuser_width() > 0)) begin
      for (xil_axi_uint mylen = 0; mylen < this.get_len()+1;mylen++) begin
        lhs_user = this.get_user_beat(mylen);
        rhs_user = rhs_.get_user_beat(mylen);
        if ((lhs_user !== rhs_user) && (error_cnt < report_errors_number)) begin
          `xil_error(get_name(), $sformatf("Miscompare for %s vs %s wuser[%d]:\nlhs (width: %d) = 0x%x\nrhs (width: %d) = 0x%x",
            this.get_name(), rhs_.get_name(), mylen,
            this.get_wuser_width(), lhs_user,
            rhs_.get_wuser_width(), rhs_user))
          compare_result = 0;
          error_cnt++;
        end
      end
    end
    return(compare_result);
  endfunction : do_compare_wuser

  protected virtual function bit do_compare_data (
      inout axi_transaction rhs_
    );
    bit compare_result;
    xil_axi_resp_t        tmp_resp;
    xil_axi_strb_1byte    tmp_strb;
    xil_axi_payload_byte  tmp_this_data;
    xil_axi_payload_byte  tmp_rhs_data;
    xil_axi_uint          error_cnt;
    xil_axi_uint mybc;
    compare_result = 1;
    error_cnt = 0;
    mybc = 0;
    ///////////////////////////////////////////////////////////////////////////
    //Compare the DATA
    for (xil_axi_uint mylen = 0; mylen < this.get_len()+1;mylen++) begin
      for (xil_axi_uint mydatawidth = 0; mydatawidth < (1 << this.get_size()); mydatawidth++) begin
        tmp_resp = this.rresp[mylen];
        tmp_strb = this.strb[mybc];
        if ((this.check_data_with_bad_resp == XIL_AXI_TRUE) || (((this.get_cmd_type() == XIL_AXI_READ) && ((tmp_resp != XIL_AXI_RESP_SLVERR) && (tmp_resp != XIL_AXI_RESP_DECERR))) ||
            ((this.get_cmd_type() == XIL_AXI_WRITE) && ( tmp_strb === 1'b1) &&
              ((this.get_bresp() != XIL_AXI_RESP_SLVERR) && (this.get_bresp() != XIL_AXI_RESP_DECERR)))
           )) begin
          tmp_this_data  = this.data[mybc];
          tmp_rhs_data  = rhs_.data[mybc];
          if ((tmp_this_data !== tmp_rhs_data) && (error_cnt < this.report_errors_number)) begin
            `xil_error(get_name(), $sformatf("Miscompare for %s vs %s data[%d]:\nlhs = 0x%0x\nrhs = 0x%0x", this.get_name(), rhs_.get_name(), mybc, this.data[mybc], rhs_.data[mybc]))
            compare_result = 0;
            error_cnt++;
          end
        end
        mybc++;
      end
    end
    return(compare_result);
  endfunction : do_compare_data

  /*
    Function: do_compare
    Compares two transactions together to make sure that they are identical. It will return 1 when successful.
  */
  virtual function bit do_compare (
    xil_object  rhs
    );
    bit compare_result;
    axi_transaction rhs_;
    xil_axi_uint        mybc;
    xil_axi_uint        error_cnt;
    compare_result = super.do_compare(rhs);
    $cast(rhs_,rhs);
    mybc = 0;
    ///////////////////////////////////////////////////////////////////////////
    //Compare the CMD
    compare_result &= this.do_compare_cmd(rhs_);
    ///////////////////////////////////////////////////////////////////////////
    //Compare the RRESP
    compare_result &= this.do_compare_rresp(rhs_);
    compare_result &= this.do_compare_bchannel(rhs_);
    compare_result &= this.do_compare_ruser(rhs_);
    compare_result &= this.do_compare_wuser(rhs_);
    compare_result &= this.do_compare_data(rhs_);
    return(compare_result);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //AWUSER bit configuration
  protected virtual function xil_axi_user_beat get_axuser();
    return(this.axuser);
  endfunction

  /*
    Function: get_awuser
    Returns the value of the AWUSER.
  */
  virtual function xil_axi_user_beat get_awuser();
    return(this.get_axuser() & ((1<< this.get_awuser_width()) - 1));
  endfunction

  protected virtual function void set_axuser(input xil_axi_user_beat updated);
    if ((this.get_cmd_type() == XIL_AXI_READ) && (this.get_aruser_width() > 0)) begin
      this.axuser = updated & ((1<< this.get_aruser_width()) - 1);
    end else if ((this.get_cmd_type() == XIL_AXI_WRITE) && (this.get_awuser_width() > 0)) begin
      this.axuser = updated & ((1<< this.get_awuser_width()) - 1);
    end
  endfunction

  /*
    Function: set_awuser
    Sets the value of the AWUSER.
  */
  virtual function void set_awuser(input xil_axi_user_beat updated);
    xil_axi_user_beat mask;
    mask = (1 << this.get_awuser_width())-1;
    if ((updated & ~mask) > 0) begin
      `xil_warning(get_name(), $sformatf("Attempted to send AWUSER (0x%x) which is wider than awuser_width (%d). Truncating AWUSER to (0x%0x)", updated, this.get_awuser_width(), updated & mask))
      updated &= mask;
    end
    this.set_axuser(updated);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //ARUSER bit configuration
  /*
    Function: get_aruser
    Returns the value of the ARUSER.
  */
  virtual function xil_axi_user_beat get_aruser();
    return(this.get_axuser() & ((1<< this.get_aruser_width()) - 1));
  endfunction

  /*
    Function: set_aruser
    Sets the value of the ARUSER.
  */
  virtual function void set_aruser(input xil_axi_user_beat updated);
    if (this.get_aruser_width() > 0) begin
      xil_axi_user_beat mask;
      mask = (1 << this.get_aruser_width())-1;
      if ((updated & ~mask) > 0) begin
        `xil_warning(get_name(), $sformatf("Attempted to send ARUSER (0x%x) which is wider than aruser_width (%d). Truncating ARUSER to (0x%0x)", updated, this.get_aruser_width(), updated & mask))
        updated &= mask;
      end
      this.set_axuser(updated);
    end else begin
      this.set_axuser('h0);
    end
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //BUSER bit configuration
  /*
    Function: get_buser
    Returns the value of the BUSER.
  */
  virtual function xil_axi_user_beat get_buser();
    return(this.buser & ((1<< this.get_buser_width()) - 1));
  endfunction

  /*
    Function: set_buser
    Sets the value of the BUSER of the transaction.
  */
  virtual function void set_buser(input xil_axi_user_beat updated);
    xil_axi_user_beat mask;
    if (this.get_buser_width() > 0) begin
      mask = (1 << this.get_buser_width())-1;
      if ((updated & ~mask) > 0) begin
        `xil_warning(get_name(), $sformatf("Attempted to send BUSER (0x%x) which is wider than buser_width (%d). Truncating BUSER to (0x%0x)", updated, this.get_buser_width(), updated & mask))
        updated &= mask;
      end
      this.buser = updated & ((1<< this.get_buser_width()) - 1);
    end else begin
      this.buser = 'h0;
    end
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //current beat indexing
  /*
    Function: get_beat_index
    Get current beat index of the beat.
  */
  virtual function xil_axi_uint get_beat_index();
    return(this.beat_index);
  endfunction

  /*
    Function: increment_beat_index
    Increment beat index of the beat.
  */
  virtual function void increment_beat_index();
    this.beat_index++;
  endfunction

  /*
    Function:  decrement_beat_index
    Decrement beat index of the beat.
  */
  virtual function void decrement_beat_index();
    if (this.beat_index == 0) begin
      `xil_fatal(this.get_type_name(), "Attempted to decrement beat index below 0")
    end
    this.beat_index--;
  endfunction

  /*
    Function:  clr_beat_index
    Clear beat index of the beat.
  */
  virtual function void clr_beat_index();
    this.beat_index = 0;
  endfunction

  /*
    Function: get_addr_delay
    Returns the value of the address delay that is used for the transaction.
  */
  virtual function xil_axi_uint get_addr_delay();
    return(this.addr_delay);
  endfunction

  /*
    Function: set_addr_delay
    Sets the value of the address delay that is used for the transaction.
  */
  virtual function void set_addr_delay(input xil_axi_uint         updated);
    this.addr_delay = updated;
  endfunction

  /*
    Function:  adjust_data_insertion_delay
    Adjust data insertion delay of the transaction.
  */
  virtual function void adjust_data_insertion_delay(input xil_axi_ulong now);
    xil_axi_uint  delta_cycles;
    if (this.get_adjust_data_beat_delay_enabled() == XIL_AXI_TRUE) begin
      delta_cycles = now - this.get_submit_cycle();
      if (delta_cycles >= get_data_insertion_delay()) begin
        this.set_data_insertion_delay(0);
      end else begin
        this.set_data_insertion_delay(get_data_insertion_delay() - delta_cycles);
      end
    end
  endfunction

  /*
    Function:  adjust_addr_delay
    Adjust address delay of the transaction.
  */
  virtual function void adjust_addr_delay(input xil_axi_ulong now);
    xil_axi_uint  delta_cycles;
    if (this.get_adjust_addr_delay_enabled() == XIL_AXI_TRUE) begin
      delta_cycles = now - this.get_submit_cycle();
      if (delta_cycles >= get_addr_delay()) begin
        this.set_addr_delay(0);
      end else begin
        this.set_addr_delay(get_addr_delay() - delta_cycles);
      end
    end
  endfunction

  /*
    Function: get_data_insertion_delay
    Returns the transactions insertion delay value. This is the value from when the command is to be processed
    to when it is applied to the interface.
  */
  virtual function xil_axi_uint get_data_insertion_delay();
    return(this.data_insertion_delay);
  endfunction : get_data_insertion_delay

  /*
    Function: set_data_insertion_delay
    Sets the transactions insertion delay value. This is the value from when the command is to be processed
    to when it is applied to the interface.
  */
  virtual function void set_data_insertion_delay(
    input xil_axi_uint         updated
  );
    this.data_insertion_delay = updated;
  endfunction : set_data_insertion_delay

  /*
    Function: get_response_delay
    Returns the number of cycles that the driver will wait before sending the response.
  */
  virtual function xil_axi_uint get_response_delay();
    return(this.response_delay);
  endfunction : get_response_delay

  /*
    Function: set_response_delay
    Sets the number of cycles that the driver will wait before sending the response.
  */
  virtual function void set_response_delay(
    input xil_axi_uint         updated
  );
    this.response_delay = updated;
  endfunction : set_response_delay

  /*
    Function:  get_allow_data_before_cmd
    Returns allow_data_before_cmd of the transaction.
  */
  virtual function xil_axi_uint get_allow_data_before_cmd();
    return(this.allow_data_before_cmd);
  endfunction : get_allow_data_before_cmd

  /*
    Function: set_allow_data_before_cmd
    Sets allow_data_before_cmd of the transaction.
  */
  virtual function void set_allow_data_before_cmd(
    input xil_axi_uint         updated
  );
    this.allow_data_before_cmd = updated;
  endfunction

  /*
    Function:  get_xfer_preemptive_probability
    Gets xfer_preemptive_probability of the transaction.
  */
  virtual function xil_axi_uint get_xfer_preemptive_probability();
    return(this.xfer_preemptive_probability);
  endfunction

  /*
    Function:  set_xfer_preemptive_probability
    Sets xfer_preemptive_probability of the transaction.
  */
  virtual function void set_xfer_preemptive_probability(
    input xil_axi_uint         updated
  );
    this.xfer_preemptive_probability = updated;
  endfunction

  /*
    Function: get_bresp
    Returns the value of BRESP of the transaction.
  */
  virtual function xil_axi_resp_t get_bresp();
    return(this.bresp);
  endfunction

  /*
    Function: set_bresp
    Sets the value of BRESP of the transaction.
  */
  virtual function void set_bresp(
    input xil_axi_resp_t updated
  );
    this.bresp = updated;
  endfunction

  /*
    Function:  get_bresp_name
    Gets bresp name of the transaction.
  */
  virtual function string get_bresp_name();
    return(this.bresp.name());
  endfunction

  /*
    Function:  is_bresp_okay
    Returns 1 if bresp is XIL_AXI_RESP_OKAY, else returns 0
  */
  virtual function xil_axi_uint is_bresp_okay();
    return(this.get_bresp() == XIL_AXI_RESP_OKAY);
  endfunction

  /*
    Function:  is_bresp_slverr
    Returns 1 if bresp is XIL_AXI_RESP_SLVERR, else returns 0
  */
  virtual function xil_axi_uint is_bresp_slverr();
    return(this.get_bresp() == XIL_AXI_RESP_SLVERR);
  endfunction

  /*
    Function:  is_bresp_decerr
    Returns 1 if bresp is XIL_AXI_RESP_DECERR, else returns 0
  */
  virtual function xil_axi_uint is_bresp_decerr();
    return(this.get_bresp() == XIL_AXI_RESP_DECERR);
  endfunction

  /*
    Function:  is_bresp_exokay
    Returns 1 if bresp is XIL_AXI_RESP_EXOKAY, else returns 0
  */
  virtual function xil_axi_uint is_bresp_exokay();
    return(this.get_bresp() == XIL_AXI_RESP_EXOKAY);
  endfunction

  /*
    Function:  all_rresp_okay
    Returns 1 if rresp is XIL_AXI_RESP_OKAY, else returns 0
  */
  virtual function xil_axi_uint all_rresp_okay();
    xil_axi_uint index;
    return(this.all_beats_same_rresp(XIL_AXI_RESP_OKAY, index));
  endfunction

  /*
    Function:  all_rresp_exokay
    Returns 1 if rresp is XIL_AXI_RESP_EXOKAY, else returns 0
  */
  virtual function xil_axi_uint all_rresp_exokay();
    xil_axi_uint index;
    return(this.all_beats_same_rresp(XIL_AXI_RESP_EXOKAY, index));
  endfunction

  /*
    Function: all_rresp_slverr
    Returns 1 if rresp is XIL_AXI_RESP_SLVERR, else returns 0
  */
  virtual function xil_axi_uint all_rresp_slverr();
    xil_axi_uint index;
    return(this.all_beats_same_rresp(XIL_AXI_RESP_SLVERR, index));
  endfunction

  /*
    Function:  all_rresp_decerr
    Returns 1 if rresp is XIL_AXI_RESP_DECERR, else returns 0
  */
  virtual function xil_axi_uint all_rresp_decerr();
    xil_axi_uint index;
    return(this.all_beats_same_rresp(XIL_AXI_RESP_DECERR, index));
  endfunction

  protected virtual function xil_axi_uint all_beats_same_rresp(input xil_axi_resp_t check, output xil_axi_uint index);
    index = 0;
    for (int i = 0; i < this.get_len()+1;i++) begin
      if (check != this.get_rresp(i)) begin
        index = i;
        return(0);
      end
    end
    return(1);
  endfunction

  /*
    Function: get_beat_index_delay
    Returns the current beat delay of the transaction.
  */
  virtual function xil_axi_uint get_beat_index_delay();
    return(this.get_beat_delay(this.get_beat_index()));
  endfunction

  /*
    Function: set_beat_index_delay
    Sets the specified beat delay of the transaction.
  */
  virtual function void set_beat_index_delay(input xil_axi_uint updated);
    this.set_beat_delay(beat_index, updated);
  endfunction

  /*
    Fucntion: get_strb_beat_unpacked
    Returns the strobe value of one beat of the transaction.
  */
  function void get_strb_beat_unpacked(
    input   xil_axi_uint  index,
    output  bit       r[]
    );

    if (index < (this.len+1)) begin
      r = new[(1 << this.size)];
      for (int i = 0; i < (1 << this.size); i++) begin
        r[i] = this.strb[(index * (1 << this.size)+i)];
      end
    end else begin
      `xil_fatal(get_name(), $sformatf("Index (%d) exceeds STRB size %d", index, (this.len+1)))
    end
  endfunction

  /*
    Function: set_strb_beat_unpacked
    Sets the strobe of one beat of the transaction.
  */
  function void set_strb_beat_unpacked(
    input xil_axi_uint  index,
    input bit           ret_strb[]
  );
    if (this.strb.size() < ret_strb.size()) begin
      `xil_fatal(get_name(), $sformatf("Could not set strb beat. Allocated size %d, incoming payload size %d",this.strb.size(), ret_strb.size()))
    end else if (this.strb.size() < ((index + 1) * (1 << this.size))) begin
      `xil_fatal(get_name(), $sformatf("Could not set strb beat. Allocated size %d is too small for beat (%d)",this.strb.size(), index))
    end else begin
      for (int i = 0; i < (1 << this.size); i++) begin
        this.strb[(index * (1 << this.size)+i)] = ret_strb[i];
      end
    end
  endfunction : set_strb_beat_unpacked

  /*
    Function: set_data_beat_unpacked
    Sets the data of one beat of the transaction.
  */
  function void set_data_beat_unpacked(
    input xil_axi_uint         index,
    input xil_axi_payload_byte ret_data[]
  );
    if (this.data.size() < ret_data.size()) begin
      `xil_fatal(get_name(), $sformatf("Allocated size %d, incoming payload size %d",this.data.size(), ret_data.size()))
    end else if (this.data.size() < ((index + 1) * (1 << this.size))) begin
      `xil_fatal(get_name(), $sformatf("Could not set data beat. Allocated size %d is too small for beat (%d)",this.data.size(), index))
    end else begin
      for (int i = 0; i < (1 << this.size); i++) begin
        this.data[(index * (1 << this.size)+i)] = ret_data[i];
      end
    end
  endfunction : set_data_beat_unpacked

  /*
    Function: get_data_beat_unpacked
    Returns the data of one beat of the transaction.
  */
  function void get_data_beat_unpacked(
    input   xil_axi_uint          index,
    output  xil_axi_payload_byte  ret_data[]
  );
  if (index < (this.len+1)) begin
    ret_data = new[(1 << this.size)];
    for (int i = 0; i < (1 << this.size); i++) begin
      ret_data[i] = this.data[(index * (1 << this.size)+i)];
    end
  end else begin
    `xil_fatal(get_name(), $sformatf("Index (%d) exceeds DATA size %d", index, (this.len+1)))
  end
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //Helper flags
  /*
    Fumction: set_check_data_with_bad_resp
    Sets check_data_with_bad_resp of the transaction to be true
  */
  virtual function void set_check_data_with_bad_resp();
    this.check_data_with_bad_resp = XIL_AXI_TRUE;
  endfunction

  /*
    Fumction: get_check_data_with_bad_resp
    Returns check_data_with_bad_resp of the transaction.
  */
  virtual function void clr_check_data_with_bad_resp();
    this.check_data_with_bad_resp = XIL_AXI_FALSE;
  endfunction

  /*
    Function: set_all_resp_okay
    Sets all_resp_okay of the transaction to be true
  */
  virtual function void set_all_resp_okay();
    this.all_resp_okay = XIL_AXI_TRUE;
  endfunction

  /*
    Function: get_all_resp_okay
    Returns all_resp_okay of the transaction.
  */
  function xil_axi_boolean_t get_all_resp_okay();
    return(this.all_resp_okay);
  endfunction

  /*
    Function: clr_all_resp_okay
    Sets all_resp_okay of the transaction.
  */
  virtual function void clr_all_resp_okay();
    this.all_resp_okay = XIL_AXI_FALSE;
  endfunction

  /*
    Function:  set_exclude_resp_exokay
    Sets exclude_resp_exokay of the transaction to be true
  */
  virtual function void set_exclude_resp_exokay();
    this.exclude_resp_exokay = XIL_AXI_TRUE;
  endfunction

  /*
    Function:  get_exclude_resp_exokay
    Returns exclude_resp_exokay of the transaction.
  */
  function xil_axi_boolean_t get_exclude_resp_exokay();
    return this.exclude_resp_exokay;
  endfunction

  /*
    Function:  clr_exclude_resp_exokay
    Sets exclude_resp_exokay of the transaction to be false
  */
  virtual function void clr_exclude_resp_exokay();
    this.exclude_resp_exokay = XIL_AXI_FALSE;
  endfunction

  /*
    Function:  set_xfer_alignment
    Sets xfer_alignent of the transaction.
  */
  virtual function void set_xfer_alignment(input xil_axi_xfer_alignment_t update);
    this.xfer_alignment = update;
  endfunction

  /*
    Function:  get_xfer_alignment
    Returns xfer_alignment of the transaction.
  */
  virtual function xil_axi_xfer_alignment_t get_xfer_alignment();
    return(this.xfer_alignment);
  endfunction

  /*
    Function:  set_xfer_wrcmd_order
    Sets xfer_wrcmd_order of the transaction.
  */
  virtual function void set_xfer_wrcmd_order(input xil_axi_xfer_wrcmd_order_t update);
    this.xfer_wrcmd_order = update;
  endfunction

  /*
    Function:  get_xfer_wrcmd_order
    Gets xfer_wrcmd_order of the transaction.
  */
  virtual function xil_axi_xfer_wrcmd_order_t get_xfer_wrcmd_order();
    return(this.xfer_wrcmd_order);
  endfunction

  /*
    Function:  set_xfer_wrdata_insertion_policy
    Sets xfer_wrdata_insertion_policy of the transaction.
  */
  virtual function void set_xfer_wrdata_insertion_policy(input xil_axi_xfer_wrdata_insertion_policy_t update);
    this.xfer_wrdata_insertion_policy = update;
  endfunction

  /*
    Function:  get_xfer_wrdata_insertion_policy
    Gets xfer_wrdata_insertion_policy of the transaction.
  */
  virtual function xil_axi_xfer_wrdata_insertion_policy_t get_xfer_wrdata_insertion_policy();
    return(this.xfer_wrdata_insertion_policy);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //Ranges
  /*
    Function:  get_addr_delay_range
    Returns min_addr_delay and max_addr_delay of the transaction.
  */
  function void get_addr_delay_range(output xil_axi_uint         min,
                            output xil_axi_uint         max);
    min = this.min_addr_delay;
    max = this.max_addr_delay;
  endfunction

  /*
    Function:  set_addr_delay_range
    Sets min_addr_delay and max_addr_delay of the transaction.
  */
  virtual function void set_addr_delay_range(input xil_axi_uint         min,
                                             input xil_axi_uint         max);
    this.min_addr_delay = min;
    this.max_addr_delay = max;
  endfunction

  /*
    Function:  get_data_insertion_delay_range
    Returns min_data_insertion_delay and max_data_insertion_delay of the transaction.
  */
  function void get_data_insertion_delay_range(output xil_axi_uint         min,
                            output xil_axi_uint         max);
    min = this.min_data_insertion_delay;
    max = this.max_data_insertion_delay;
  endfunction

  /*
    Function:  get_response_delay_range
    Returns min_response_delay and max_response_delay of the transaction.
  */
  function void get_response_delay_range(output xil_axi_uint         min,
                                output xil_axi_uint         max);
    min = this.min_response_delay;
    max = this.max_response_delay;
  endfunction

  /*
    Function:  set_data_insertion_delay_range
    Sets min_data_insertion_delay and max_data_insertion_delay of the transaction.
  */
  virtual function void set_data_insertion_delay_range(input xil_axi_uint         min,
                                             input xil_axi_uint         max);
    this.min_data_insertion_delay = min;
    this.max_data_insertion_delay = max;
  endfunction

  /*
    Function:  set_response_delay_range
    Sets min_response_delay and max_response_delay of the transaction.
  */
  virtual function void set_response_delay_range(input xil_axi_uint         min,
                                                input xil_axi_uint         max);
    this.min_response_delay = min;
    this.max_response_delay = max;
  endfunction

  /*
    Function:  get_allow_data_before_cmd_rang
    Returns min_allow_data_before_cmd and max_allow_data_before_cmd of the transaction.
  */
  function void get_allow_data_before_cmd_range(output xil_axi_uint         min,
                            output xil_axi_uint         max);
    min = this.min_allow_data_before_cmd;
    max = this.max_allow_data_before_cmd;
  endfunction

  /*
    Function:  set_allow_data_before_cmd_range
    Sets min_allow_data_before_cmd and max_allow_data_before_cmd of the transaction.
  */
  virtual function void set_allow_data_before_cmd_range(input xil_axi_uint         min,
                                             input xil_axi_uint         max);
    this.min_allow_data_before_cmd = min;
    this.max_allow_data_before_cmd = max;
  endfunction

  /*
    Function: get_beat_delay_range
    Returns min_beat_delay and max_beat_delay of the transaction.
  */
  function void get_beat_delay_range(output xil_axi_uint         min,
                            output xil_axi_uint         max);
    min = this.min_beat_delay;
    max = this.max_beat_delay;
  endfunction : get_beat_delay_range

  /*
    Function:  set_beat_delay_range
    Sets min_beat_delay and max_beat_delay of the transaction.
  */
  virtual function void set_beat_delay_range(input xil_axi_uint         min,
                                             input xil_axi_uint         max);
    this.min_beat_delay = min;
    this.max_beat_delay = max;
  endfunction : set_beat_delay_range


  /*
    Function: get_report_errors_number
    Returns report_errors_number of the transaction.
  */
  virtual function xil_axi_uint get_report_errors_number();
    return(this.report_errors_number);
  endfunction : get_report_errors_number
  
  /*
    Function: set_report_errors_number
    Sets report_errors_number of the transaction.
  */
  virtual function void set_report_errors_number(xil_axi_uint updated);
    this.report_errors_number = updated;
  endfunction : set_report_errors_number

  ///////////////////////////////////////////////////////////////////////////
  //Burst byte offset Calculations
  /*
    Function:  get_burst_byte_offset
    Returns burst byte offset of beat(index) of the transaction.
  */
  function xil_axi_uint get_burst_byte_offset(input xil_axi_uint index);
    xil_axi_uint         start_address;
    xil_axi_uint         number_bytes;
    xil_axi_uint         data_bus_bytes;
    xil_axi_uint         aligned_address;
    xil_axi_uint         burst_length;
    xil_axi_uint         address_n;
    xil_axi_uint         wrap_boundary;
    xil_axi_uint         lower_byte_lane;
    xil_axi_uint         upper_byte_lane;

    start_address = this.get_addr();
    number_bytes = xil_pow2(this.get_size());
    burst_length = this.get_len() + 1;
    aligned_address = (start_address/number_bytes) * number_bytes;
    wrap_boundary = (start_address/(number_bytes * burst_length)) * (number_bytes * burst_length);
    data_bus_bytes = this.get_data_width() / 8;
    if (index == 0) begin
      address_n = start_address;
      lower_byte_lane = aligned_address - (aligned_address/data_bus_bytes) * data_bus_bytes;
      upper_byte_lane = aligned_address + (number_bytes - 1) - (address_n/data_bus_bytes) * data_bus_bytes;
    end else begin
      case (this.get_burst())
        XIL_AXI_BURST_TYPE_WRAP : begin
          address_n = aligned_address+index*number_bytes;
          if (address_n >= wrap_boundary + (number_bytes*burst_length)) begin
            address_n = wrap_boundary + (address_n - wrap_boundary - (number_bytes*burst_length));
          end
        end
        XIL_AXI_BURST_TYPE_FIXED: begin
          address_n = aligned_address;
        end
        XIL_AXI_BURST_TYPE_INCR : begin
          address_n = aligned_address+index*number_bytes;
        end
      endcase
      lower_byte_lane = address_n - (address_n/data_bus_bytes) * data_bus_bytes;
      upper_byte_lane = lower_byte_lane + (number_bytes - 1);
    end
    return(lower_byte_lane);
  endfunction : get_burst_byte_offset

  /*
    Function:  get_transfer_byte_count
    Returns total number of bytes of one transfer
  */
  virtual function xil_axi_uint get_transfer_byte_count();
    return((1 << this.size)* (this.len+1));
  endfunction : get_transfer_byte_count

  /*
    Function:  clr_strb_array
    Sets all strobe bits of the transaction to 0
  */
  virtual function void clr_strb_array();
    for (xil_axi_uint i = 0; i < this.strb.size(); i++) begin
      this.strb[i] = 0;
    end
  endfunction : clr_strb_array

  /*
    Function:  set_strb_array
    Sets all strobe bits of the transaction to 1 
  */
  virtual function void set_strb_array();
    for (xil_axi_uint i = 0; i < this.strb.size(); i++) begin
      this.strb[i] = 1;
    end
  endfunction : set_strb_array

  protected virtual function void create_data_array(
    input xil_axi_uint bc,
    input bit      resize = 0
    );
    if (bc > 4096) begin
      `xil_fatal(this.get_name(), $sformatf("Attempted to generate a DATA array greater than 4K in size (%d)", bc))
    end
    if ((bc > this.data.size()) || resize) begin
      this.data = new[bc] (this.data);
    end
  endfunction : create_data_array

  /*
    Function:  clr_data_array
    Sets data to unknown and strobe to be unknown for write transaction 
  */
  virtual function void clr_data_array();
    for (xil_axi_uint i = 0; i < this.data.size(); i++) begin
      this.data[i] = 8'hxx;
      if (this.get_cmd_type() == XIL_AXI_WRITE) begin
        this.strb[i] = 1'bx;
      end
    end
  endfunction : clr_data_array

  protected virtual function void size_data();
    this.create_data_array(this.get_transfer_byte_count(), (this.data.size() > this.get_transfer_byte_count()));
  endfunction

  protected virtual function void create_strb_array(
    input xil_axi_uint bc,
    input bit      resize = 0
    );
    if (bc > 4096) begin
      `xil_fatal(this.get_name(), $sformatf("Attempted to generate a STRB array greater than 4K in size (%d)", bc))
    end
    if ((bc > this.strb.size()) || resize) begin
      this.strb = new[bc](this.strb);
    end
  endfunction

  protected virtual function void size_strb();
    this.create_strb_array(this.get_transfer_byte_count(),(this.strb.size() > this.get_transfer_byte_count()));
  endfunction

  protected virtual function void create_rresp_array(
    input xil_axi_uint bc,
    input bit      resize = 0
    );
    if (bc > 256) begin
      `xil_fatal(this.get_name(), $sformatf("Attempted to generate a RRESP array greater than 256 in size (%d)", bc))
    end
    if ((bc > this.rresp.size()) || resize) begin
      this.rresp = new[bc](this.rresp);
    end
  endfunction

  protected virtual function void size_rresp();
    this.create_rresp_array((this.get_len()+1),(this.rresp.size() > this.get_len()));
  endfunction

  protected virtual function void create_user_array(
    input xil_axi_uint  bc
  );
    xil_axi_uint  num_elements;
    num_elements = ((bc + XIL_AXI_USER_ELEMENT_WIDTH - 1)/XIL_AXI_USER_ELEMENT_WIDTH) * (this.get_len + 1);
    if (num_elements != this.user.size()) begin
      this.user = new[num_elements](this.user);
    end
  endfunction

  protected virtual function void size_ruser();
    this.create_user_array(this.get_ruser_width());
  endfunction

  protected virtual function void create_beat_delay_array(
    input xil_axi_uint bc,
    input bit      resize = 0
    );
    if (bc > 256) begin
      `xil_fatal(this.get_name(), $sformatf("Attempted to generate a beat delay array greater than 256 in size (%d)", bc))
    end
    if ((bc > this.beat_delay.size()) || resize) begin
      this.beat_delay = new[bc] (this.beat_delay);
    end
  endfunction

  protected virtual function void size_beat_delay();
    this.create_beat_delay_array((this.get_len()+1),(this.beat_delay.size() > this.get_len()));
  endfunction

  protected virtual function void size_wuser();
    this.create_user_array(this.get_wuser_width());
  endfunction

  /*
    Function: size_wr_beats
    Sets data,strobe and wuser(if WUSER_WIDTH>0),beat_delay of write transaction
  */
  virtual function void size_wr_beats();
    this.size_data();
    this.size_strb();
    this.size_beat_delay();
    if (this.get_wuser_width() > 0) begin
      this.size_wuser();
    end
  endfunction

  /*
    Function: size_rd_beats
    Sets data,rresp and ruser(if RUSER_WIDTH>0),beat_delay of read transaction
  */
  virtual function void size_rd_beats();
    this.size_data();
    this.size_beat_delay();
    this.size_rresp();
    if (this.get_ruser_width() > 0) begin
      this.size_ruser();
    end
  endfunction


  ///////////////////////////////////////////////////////////////////////////
  //General constraints
  ///////////////////////////////////////////////////////////////////////////
  //Constrain the size of the array based on the size/len
  constraint c_array_size {
    data.size() == ((1 << size) * (len+1));
    strb.size() == ((1 << size) * (len+1));
    beat_delay.size() == (len+1);
    if ((cmd == XIL_AXI_WRITE) && (wuser_width > 0)) {
      user.size() == ((wuser_width + XIL_AXI_USER_ELEMENT_WIDTH - 1) / XIL_AXI_USER_ELEMENT_WIDTH) * (len+1);
    } else if ((cmd == XIL_AXI_READ) && (ruser_width > 0)) {
      user.size() == ((ruser_width + XIL_AXI_USER_ELEMENT_WIDTH - 1) / XIL_AXI_USER_ELEMENT_WIDTH) * (len+1);
    } else {
      user.size() == 0;
    }
    rresp.size() == (len+1);
  }

  constraint c_strb_setting {
    if ((xfer_alignment != XIL_AXI_XFER_SPARSE) || (has_wstrb == XIL_AXI_FALSE)) {
      foreach (strb[i])
        strb[i] == 1;
    }
  }

  constraint c_addr_delay {
    addr_delay inside {[min_addr_delay:max_addr_delay]};
  }

  constraint c_data_insertion_delay {
    data_insertion_delay inside {[min_data_insertion_delay:max_data_insertion_delay]};
  }

  constraint c_response_delay {
    response_delay inside {[min_response_delay:max_response_delay]};
  }

   constraint c_allow_data_before_cmd {
    `ifndef XILINX_SIMULATOR
       solve len before allow_data_before_cmd;
    `endif
    if (xfer_wrcmd_order == XIL_AXI_WRCMD_ORDER_DATA_BEFORE_CMD) {
      if(max_allow_data_before_cmd <= len+1) {
        allow_data_before_cmd inside {[min_allow_data_before_cmd:max_allow_data_before_cmd]};
      }
      else {
        allow_data_before_cmd inside {[min_allow_data_before_cmd:len+1]};
      }
    } else {
      allow_data_before_cmd == 0;
    }
  }

  constraint c_xfer_preemptive_probability {
    xfer_preemptive_probability <= 100;
  }

  constraint c_beat_delay {
    foreach (beat_delay[i])
      beat_delay[i] inside {[min_beat_delay:max_beat_delay]};
  }

  ///////////////////////////////////////////////////////////////////////////
  constraint c_bresp_value {
    if(axi_version != XIL_VERSION_LITE) {
      if (exclude_resp_exokay == XIL_AXI_TRUE) {
        bresp inside {XIL_AXI_RESP_OKAY, XIL_AXI_RESP_DECERR, XIL_AXI_RESP_SLVERR};
      } else {
        bresp <= XIL_AXI_RESP_DECERR;
      }
    } else {
      bresp inside {XIL_AXI_RESP_OKAY, XIL_AXI_RESP_DECERR, XIL_AXI_RESP_SLVERR};
    }
  }

  constraint c_rresp_value {
    if(axi_version != XIL_VERSION_LITE) {
      foreach (rresp[i])
        if (exclude_resp_exokay == XIL_AXI_TRUE) {
          rresp[i] inside {XIL_AXI_RESP_OKAY, XIL_AXI_RESP_DECERR, XIL_AXI_RESP_SLVERR};
        } else {
          rresp[i] <= XIL_AXI_RESP_DECERR;
        }
    } else {foreach (rresp[i])
      rresp[i] inside {XIL_AXI_RESP_OKAY,XIL_AXI_RESP_SLVERR,XIL_AXI_RESP_DECERR};
    }
  }

  constraint c_burst {
    if ((axi_version == XIL_VERSION_LITE) || (has_burst == XIL_AXI_FALSE)) {
      burst == XIL_AXI_BURST_TYPE_INCR;
    } else {
      burst inside { XIL_AXI_BURST_TYPE_FIXED, XIL_AXI_BURST_TYPE_INCR, XIL_AXI_BURST_TYPE_WRAP };
    }
  }

  constraint c_wrap_len {
    if (burst == XIL_AXI_BURST_TYPE_WRAP) {
      len inside { 1, 3, 7, 15 };
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  //WIDTH constraints
  constraint c_id_max_width {
    if (axi_version != XIL_VERSION_LITE) {
      id inside {[0: (1 << id_width)-1]};
    } else {
      id == 0;
    }
  }

  constraint c_addr_max_width { addr inside {[0: (1 << addr_width)-1]}; }
  ///////////////////////////////////////////////////////////////////////////
  //Transfers cannot exceed the physical size of the bus
  constraint c_size {
    if ((axi_version == XIL_VERSION_LITE) || (supports_narrow == XIL_AXI_FALSE)) {
      size == (xil_clog2(data_width/8));
    } else {
      size <= (xil_clog2(data_width/8));
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  //Transfer length cannot 4096
  constraint c_4k_bytes {
    `ifndef XILINX_SIMULATOR
      solve size before len;
    `endif
    ((1<<size) * (len + 1)) <= 4096;
  }

  //protocol related constraints
  constraint c_cache_setting {
    if(axi_version == XIL_VERSION_AXI4) {
      if (cmd == XIL_AXI_WRITE) {
        cache inside {XIL_AXI_CACHE_DEVICE_NONBUFFERABLE,
                      XIL_AXI_CACHE_DEVICE_BUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_NONBUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_BUFFERABLE,
                      XIL_AXI_CACHE_WR_WRITETHROUGH_NOALLOC,
                      XIL_AXI_CACHE_WR_WRITETHROUGH_WRALLOC,
                      XIL_AXI_CACHE_WR_WRITEBACK_NOALLOC,
                      XIL_AXI_CACHE_WR_WRITEBACK_WRALLOC};
      } else {
        cache inside {XIL_AXI_CACHE_DEVICE_NONBUFFERABLE,
                      XIL_AXI_CACHE_DEVICE_BUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_NONBUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_BUFFERABLE,
                      XIL_AXI_CACHE_RD_WRITETHROUGH_NOALLOC,
                      XIL_AXI_CACHE_RD_WRITETHROUGH_RDALLOC,
                      XIL_AXI_CACHE_RD_WRITEBACK_NOALLOC,
                      XIL_AXI_CACHE_RD_WRITEBACK_RDALLOC};
      }
    } if (axi_version == XIL_VERSION_AXI3) {
      if (cmd == XIL_AXI_WRITE) {
        cache inside {XIL_AXI_CACHE_DEVICE_NONBUFFERABLE,
                      XIL_AXI_CACHE_DEVICE_BUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_NONBUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_BUFFERABLE,
                      XIL_AXI_CACHE_WR_WRITETHROUGH_NOALLOC,
                      XIL_AXI_CACHE_WRAXI3_WRITETHROUGH_WRALLOC,
                      XIL_AXI_CACHE_WR_WRITEBACK_NOALLOC,
                      XIL_AXI_CACHE_WRAXI3_WRITEBACK_WRALLOC};
      } else {
        cache inside {XIL_AXI_CACHE_DEVICE_NONBUFFERABLE,
                      XIL_AXI_CACHE_DEVICE_BUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_NONBUFFERABLE,
                      XIL_AXI_CACHE_NORM_NONCACHEABLE_BUFFERABLE,
                      XIL_AXI_CACHE_RD_WRITETHROUGH_NOALLOC,
                      XIL_AXI_CACHE_RDAXI3_WRITETHROUGH_RDALLOC,
                      XIL_AXI_CACHE_RD_WRITEBACK_NOALLOC,
                      XIL_AXI_CACHE_RDAXI3_WRITEBACK_RDALLOC};
      }
    } else {
      cache == XIL_AXI_CACHE_DEVICE_NONBUFFERABLE;
    }
  }

  constraint c_len {
    if(axi_version == XIL_VERSION_LITE) {
      len == 0;
    } else if ( axi_version == XIL_VERSION_AXI3) {
      len < 16;
    } else {
      if (burst != XIL_AXI_BURST_TYPE_INCR) {
       len < 16;
      }
    }
  }

   constraint c_region_setting {
     if(axi_version == XIL_VERSION_AXI4) {
       region inside {[min_region:max_region]};
     } else {
       region ==0;
     }
   }

  constraint c_user_width {
    if (axi_version == XIL_VERSION_LITE) {
      buser == 0;
      axuser == 0;
      user.size() == 0;
    }
  }

  /*
    Function:  adjust_head_strb
    Adjust strobe bit of unaligned head to be 0
  */
  function void adjust_head_strb();
    xil_axi_uint          strb_adjust;
    strb_adjust = this.get_addr() & ~(aligned_size_mask(this.get_size()));
    for (int i = 0; i < strb_adjust; i++) begin
      this.strb[i] = 0;
    end
  endfunction : adjust_head_strb

  /*
    Function: post_randomize
    Sets final value of region,prot,qos,cache,address,bresp,rresp,strobe of transaction 
  */
  function void post_randomize();
    xil_axi_uint          strb_adjust;
    xil_axi_uint          tail_adjust;
    xil_axi_uint          addr_offset;
    xil_axi_uint          adjust_strb_position;

    ///////////////////////////////////////////////////////////////////////////
    //Address alignements must be figured out here.
    // Aligned Head will shape the Address to alligned transfer
    if ((burst == XIL_AXI_BURST_TYPE_WRAP) ||
        (this.xfer_alignment == XIL_AXI_XFER_CONT_ALIGNED) ||
        (this.xfer_alignment == XIL_AXI_XFER_CONT_ALIGNED_HEAD)) begin
      if (size == XIL_AXI_SIZE_1BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_1BYTE)));
      end else if (size == XIL_AXI_SIZE_2BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_2BYTE)));
      end else if (size == XIL_AXI_SIZE_4BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_4BYTE)));
      end else if (size == XIL_AXI_SIZE_8BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_8BYTE)));
      end else if (size == XIL_AXI_SIZE_16BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_16BYTE)));
      end else if (size == XIL_AXI_SIZE_32BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_32BYTE)));
      end else if (size == XIL_AXI_SIZE_64BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_64BYTE)));
      end else if (size == XIL_AXI_SIZE_128BYTE) begin
        addr = (addr & (aligned_size_mask(XIL_AXI_SIZE_128BYTE)));
      end
    end

    ///////////////////////////////////////////////////////////////////////////
    //Adjust address for length and size for INCR transfers only.
    if ((burst == XIL_AXI_BURST_TYPE_INCR) && (((addr & ~((1<<size)-1)) + ((1 << size) * (len+1))) > ((addr & aligned_4k_mask()) + 'h1000))) begin
      addr = ((addr & aligned_4k_mask()) + 'h1000) - ((1 << size) * (len+1));
    end

    if (this.cmd == XIL_AXI_WRITE) begin
      ///////////////////////////////////////////////////////////////////////////
      // Force BRESP to OKAY when  the all_resp_okay property is set or HAS_NO_BRESP is false
      if ((this.all_resp_okay == XIL_AXI_TRUE) || (this.get_has_bresp() == XIL_AXI_FALSE)) begin
        bresp = XIL_AXI_RESP_OKAY;
      end

      foreach (rresp[i]) begin
        rresp[i] = XIL_AXI_RESP_DECERR;
      end

      ///////////////////////////////////////////////////////////////////////////
      //When HAS_WSTRB is low, the transaction cannot have an unaligned address.
      if (this.get_has_wstrb() == XIL_AXI_FALSE) begin
        if ((this.get_xfer_alignment() == XIL_AXI_XFER_CONT_UNALIGNED) ||
            (this.get_xfer_alignment() == XIL_AXI_XFER_CONT_UNALIGNED_NULL) ||
            (this.get_xfer_alignment() == XIL_AXI_XFER_SPARSE)) begin
          `xil_warning(this.get_name(), "Randomization error: When HAS_WSTRB is 0, the transaction transfer alignement cannot be *UNALIGNED*")
        end
        addr = this.get_addr() & aligned_size_mask(convert_dw_to_axi_size(this.get_data_width()));
      end else begin
      ///////////////////////////////////////////////////////////////////////////
      //The Driver will correctly zero out the head of the transfer however, if should
      // be correct out of the sequencer.
        case (this.xfer_alignment)
          XIL_AXI_XFER_CONT_UNALIGNED,
          XIL_AXI_XFER_CONT_UNALIGNED_NULL,
          XIL_AXI_XFER_SPARSE: begin
            adjust_head_strb();
          end
        endcase
      end

      addr_offset = (this.get_addr() & ~(aligned_size_mask(this.get_size())));

      ///////////////////////////////////////////////////////////////////////////
      //Special considerations must be applied if the transfer is FIXED
      if (this.get_burst() == XIL_AXI_BURST_TYPE_FIXED) begin
        ///////////////////////////////////////////////////////////////////////////
        //Fixed transfers must have the same address, thus the BE's must remain constant.
        for(int i = 1; i < (this.get_len() + 1);i++) begin
          for (int j = 0; j < addr_offset; j++) begin
            this.strb[i*xil_pow2(this.get_size()) + j] = 0;
          end
        end
      end else begin

        ///////////////////////////////////////////////////////////////////////////
        //Determine if the head/tail should be adjusted?
        if (this.get_has_wstrb() == XIL_AXI_TRUE) begin
          randcase
            1 : adjust_strb_position = 1;
            2 : adjust_strb_position = 0;
          endcase
        end else begin
          adjust_strb_position = 0;
        end
        ///////////////////////////////////////////////////////////////////////////
        //If the randcase is true then allow for adjustment of the strobes.
        if (adjust_strb_position) begin
          ///////////////////////////////////////////////////////////////////////////
          // Transaction only needs to be touched here only if the transfer is the following policies.
          if ((this.get_xfer_alignment() == XIL_AXI_XFER_CONT_ALIGNED_HEAD) ||
              (this.get_xfer_alignment() == XIL_AXI_XFER_CONT_UNALIGNED_NULL) ||
              (this.get_xfer_alignment() == XIL_AXI_XFER_CONT_UNALIGNED)) begin
            ///////////////////////////////////////////////////////////////////////////
            //Deal with single beat special case
            if (this.len == 0) begin
              case (this.xfer_alignment)
                XIL_AXI_XFER_CONT_UNALIGNED: begin
                  ///////////////////////////////////////////////////////////////////////////
                  //Is there more than one byte in the transfer?
                  if ((xil_pow2(this.get_size()) - 1) != addr_offset) begin
                    ///////////////////////////////////////////////////////////////////////////
                    //Choose a number between the addr_offset and (xil_pow2(this.size)
                    AXI_CONT_XFER_SINGLE_HEADADJ_FAIL: assert(rnd_num.randomize() with {
                      num >= addr_offset;
                      num < xil_pow2(size);
                      });
                    strb_adjust = rnd_num.num;
                    ///////////////////////////////////////////////////////////////////////////
                    //Adjust the HEAD
                    for (int i = addr_offset; i < strb_adjust; i++) begin
                      this.strb[i] = 0;
                    end
                    if ((xil_pow2(this.size) - 1) > strb_adjust) begin
                      AXI_CONT_XFER_SINGLE_TAILADJ_FAIL: assert(rnd_num.randomize() with {
                        num > strb_adjust;
                        num <= xil_pow2(size);
                        });
                      tail_adjust = rnd_num.num;
                      ///////////////////////////////////////////////////////////////////////////
                      //Adjust the TAIL
                      for (int i = tail_adjust; i < xil_pow2(this.size); i++) begin
                        this.strb[i] = 0;
                      end
                    end
                  end
                end
                XIL_AXI_XFER_CONT_UNALIGNED_NULL: begin
                  AXI_CONT_XFER_SINGLE_NULL_STRBADJ_FAIL: assert(rnd_num.randomize() with {
                      num >= 0;
                      num <= (xil_pow2(size) - addr_offset);
                    });
                  strb_adjust = rnd_num.num;
                  for (int i = 0; i < strb_adjust; i++) begin
                    this.strb[i+addr_offset] = 0;
                  end
                end
              endcase
            end else begin
              ///////////////////////////////////////////////////////////////////////////
              //Adjust the first beat of the list
              case (this.xfer_alignment)
                XIL_AXI_XFER_CONT_UNALIGNED: begin
                  ///////////////////////////////////////////////////////////////////////////
                  //Get a number between the address offset and the largest size.
                  // Clear the strb's for those bytes, however, there will always be
                  // at least one active strobe.
                  if ((xil_pow2(this.get_size()) - 1) != addr_offset) begin
                    AXI_CONT_XFER_STRBADJ_FAIL: assert(rnd_num.randomize() with {
                      num >= 0;
                      num < (xil_pow2(size) - addr_offset);
                      });
                    strb_adjust = rnd_num.num;
                  end
                end
                XIL_AXI_XFER_CONT_UNALIGNED_NULL: begin
                  ///////////////////////////////////////////////////////////////////////////
                  //Get a number between the address offset and the largest size + 1.
                  // Clear the strb's for those bytes, however, there does not need to be
                  // at least one active strobe.
                  AXI_CONT_XFER_NULL_STRBADJ_FAIL: assert(rnd_num.randomize() with {
                      num >= 0;
                      num <= (xil_pow2(size) - addr_offset);
                    });
                  strb_adjust = rnd_num.num;
                end
                default : strb_adjust = 0;
              endcase
              for (int i = 0; i < strb_adjust; i++) begin
                this.strb[i+addr_offset] = 0;
              end
              ///////////////////////////////////////////////////////////////////////////
              //Adjust the last beat of the list
              case (this.xfer_alignment)
                XIL_AXI_XFER_CONT_UNALIGNED,
                XIL_AXI_XFER_CONT_ALIGNED_HEAD: begin
                  XIL_AXI_XFER_STRBADJ_FAIL: assert(rnd_num.randomize() with {
                    num >= 0;
                    num < (xil_pow2(size));
                    });
                  strb_adjust = rnd_num.num;
                end
                XIL_AXI_XFER_CONT_UNALIGNED_NULL: begin
                  XIL_AXI_XFER_NULL_STRBADJ_FAIL: assert(rnd_num.randomize() with {
                    num >= 0;
                    num <= (xil_pow2(size));
                    });
                  strb_adjust = rnd_num.num;
                end
                default : strb_adjust = 0;
              endcase
              for (int i = this.get_num_bytes_in_transaction() - strb_adjust;
                       i < this.get_num_bytes_in_transaction();i++) begin
                this.strb[i] = 0;
              end
            end
          end
        end
      end
    end else begin
      bresp = XIL_AXI_RESP_DECERR;
      ///////////////////////////////////////////////////////////////////////////
      // Set all the RRESP to OKAY when the property all_resp_okay is true or HAS_NO_RRESP is false
      if ((this.all_resp_okay == XIL_AXI_TRUE) || (this.get_has_rresp() == XIL_AXI_FALSE)) begin
        foreach (rresp[i]) begin
          rresp[i] = XIL_AXI_RESP_OKAY;
        end
      end
    end

    ///////////////////////////////////////////////////////////////////////////
    // HAS_NO_REGION
    if (this.get_has_region() == XIL_AXI_FALSE) begin
        this.region = 0;
    end
    ///////////////////////////////////////////////////////////////////////////
    // HAS_NO_PROT
    if (this.get_has_prot() == XIL_AXI_FALSE) begin
      this.prot = 0;
    end
    ///////////////////////////////////////////////////////////////////////////
    // HAS_NO_QOS
    if (this.get_has_qos() == XIL_AXI_FALSE) begin
      this.qos = 0;
    end
    ///////////////////////////////////////////////////////////////////////////
    // HAS_NO_CACHE
    if (this.get_has_cache() == XIL_AXI_FALSE) begin
      this.cache = XIL_AXI_CACHE_DEVICE_NONBUFFERABLE;
    end
  endfunction

  /*
    Function: set_beat_delay
    Assign the inter-beat delay of the specified beat.
  */
  virtual function void set_beat_delay(
    input xil_axi_uint index,
    input xil_axi_uint updated
    );
    this.create_beat_delay_array(index+1);
    this.beat_delay[index] = updated;
  endfunction

  /*
    Function: get_beat_delay
    Returns the inter-beat delay of the specified beat.
  */
  virtual function xil_axi_uint get_beat_delay(
    input xil_axi_uint index
    );
    if (index <= this.beat_delay.size()) begin
      return(this.beat_delay[index]);
    end else begin
      `xil_fatal(get_name(), $sformatf("Index (%d) exceeds beat_delay array size %d",
                      index, this.beat_delay.size()))
      return(0);
    end
  endfunction

  protected function bit check_strbs(
    input xil_axi_uint  index
  );
    xil_axi_strb_1byte tmp_strb;
    xil_axi_uint addr_offset;
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      ////////////////////////////////////////////////////////////////////////////////////////////
      //The strobes must match the address or there will be violations
      addr_offset = this.get_addr() & (1 << this.get_size() - 1);
      if (index == 0) begin
        for (xil_axi_uint bitc = 0; bitc < addr_offset; bitc++) begin
          tmp_strb = this.strb[bitc];
          if ( tmp_strb == 1) begin
            `xil_error(get_name(), $sformatf("Illegal STRB: Beat (%d) Bits of STRB are asserted (Bit %d) are asserted outsize starting address (0x%0x)", index, bitc, this.get_addr()))
            return(1);
          end
        end
      end
      if (this.get_burst() == XIL_AXI_BURST_TYPE_FIXED) begin
        for (xil_axi_uint bitc = 0; bitc < addr_offset;bitc++) begin
          tmp_strb = this.strb[(index <<this.get_size())+bitc];
          if (tmp_strb== 1) begin
            `xil_error(get_name(), $sformatf("Illegal FIXED STRB: Beat (%d) must have STRB bits deasserted to match Starting Address offset(0x%0x) found bit (%d) of STRB asserted", index, this.get_addr(), bitc))
            return(1);
          end
        end
      end
    end
    return(0);
  endfunction: check_strbs

  /*
    Function: set_data_beat
    Convenience function that will assign the value of the specified beat.
  */
  virtual function void set_data_beat(
    input xil_axi_uint      index,
    input xil_axi_data_beat new_data,
    input xil_axi_uint      new_beat_delay = 0,
    input xil_axi_strb_beat new_strb = {128{1'b1}}
  );
    xil_axi_uint  offset = 0;
    ////////////////////////////////////////////////////////////////////////////////////////////
    //Check index.
    if (index > this.get_len()) begin
      `xil_fatal(get_name(), $sformatf("Trying to set beat %d of a transaction that is %d beats long.", index, this.get_len()))
    end
    ////////////////////////////////////////////////////////////////////////////////////////////
    //Set the beat delay
    this.set_beat_delay(index,new_beat_delay);
    offset = index << this.get_size();
    ////////////////////////////////////////////////////////////////////////////////////////////
    //Check to make sure that the internal data array can fit the inbound data
    if (this.data.size() < (offset + (1 << this.get_size()))) begin
      `xil_fatal(get_name(), $sformatf("Could not set data beat. Allocated size %d is too small for beat (%d)",this.data.size(), index))
    end
    ////////////////////////////////////////////////////////////////////////////////////////////
    //Take only the SIZE
    for (xil_axi_uint i = 0; i < (1 << this.get_size());i++) begin
      this.data[i+offset] = new_data[i*8+:8];
    end
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      this.set_strb_beat(index, new_strb);
    end
  endfunction : set_data_beat

  /*
    Function: set_data_block
    Convenience function that will assign the data payload for the complete transaction.
  */
  virtual function void set_data_block(
    input bit [8*4096-1:0]  block
  );
    xil_axi_data_beat dbeat;
    for (xil_axi_uint beat = 0; beat < this.get_len()+1;beat++) begin
      dbeat = 'h0;
      for (xil_axi_uint bytecnt = 0; bytecnt < (1 << this.get_size()); bytecnt++) begin
        dbeat[bytecnt*8+:8] = block[(8 * beat * (1 << this.get_size())) + (bytecnt * 8) +:8];
      end
      ///////////////////////////////////////////////////////////////////////////
      //This will be the byte array of the data
      this.set_data_beat(beat, dbeat);
    end
  endfunction : set_data_block

  /*
    Function: set_strb_beat
    Convenience function that will assign the value STRB of the specified beat.
  */
  virtual function void set_strb_beat(
    input xil_axi_uint      index,
    input xil_axi_strb_beat new_strb = {128{1'b1}}
  );
    xil_axi_ulong lower_addr;
    xil_axi_uint  offset = 0;
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      ////////////////////////////////////////////////////////////////////////////////////////////
      //Check index.
      if (index > this.get_len()) begin
        `xil_fatal(get_name(), $sformatf("Trying to set strb %d of a transaction that is %d beats long.", index, this.get_len()))
      end
      offset = index << this.get_size();
      ////////////////////////////////////////////////////////////////////////////////////////////
      //Adjust the first beat's leading strbs based on the starting address.
      //Fixed transfers must have the same address, thus the BE's must remain constant.
      if ((index == 0) || (this.get_burst == XIL_AXI_BURST_TYPE_FIXED)) begin
        lower_addr = this.get_addr() & ~(aligned_size_mask(this.get_size()));
        for (xil_axi_uint i = 0; i < lower_addr;i++) begin
          new_strb[i] = 0;
        end
      end
      ////////////////////////////////////////////////////////////////////////////////////////////
      //Check to make sure that the internal strb array can fit the inbound strb
      if (this.strb.size() < (offset + (1 << this.get_size()))) begin
        `xil_fatal(get_name(), $sformatf("Could not set strb beat. Allocated size %d is too small for beat (%d)",this.data.size(), index))
      end
      ////////////////////////////////////////////////////////////////////////////////////////////
      //Take only the SIZE
      for (xil_axi_uint i = 0; i < (1 << this.get_size());i++) begin
        this.strb[i+offset] = new_strb[i];
      end
      ////////////////////////////////////////////////////////////////////////////////////////////
      //Check for protocol issues.
      if (this.check_strbs(index)) begin
        `xil_error(this.get_name(), "Transaction STRB's are not within protocol specification")
      end
    end
  endfunction : set_strb_beat

  /*
    Function: get_data_beat
    Returns the value of the specified beat. This is NOT always the RDATA/WDATA representation.
    It will align the signification bytes to the lower bytes and set the unused bytes to zeros.
  */
  virtual function xil_axi_data_beat get_data_beat(input xil_axi_uint index);
    xil_axi_data_beat ret;
    xil_axi_uint      offset;
    xil_axi_uint      width;
    /////////////////////////////////////////////////////////////////////////////////
    //Zero out the return
    ret = 'h0;
    offset = index << this.get_size();
    if (index > this.get_len()) begin
      `xil_fatal(get_name(), $sformatf("data beat index exceeds length (len: %d - index %d)", this.get_len()+1, index))
    end
    for (xil_axi_uint i = 0;i < (1 << this.get_size()); i++) begin
      ret[i*8+:8] = this.data[offset + i];
    end
    return(ret);
  endfunction

  /*
    Function: get_data_block
    Returns the 4K bytes of the payload for the transaction. This is NOT always the RDATA/WDATA representation.
    It will align the signification bytes to the lower bytes and set the unused bytes to zeros.
  */
  virtual function bit [8*4096-1:0] get_data_block();
    bit [8*4096-1:0]    block;
    xil_axi_data_beat   dbeat;
    block = 'h0;
    for (xil_axi_uint beat = 0; beat < this.get_len()+1;beat++) begin
      dbeat = this.get_data_beat(beat);
      for (xil_axi_uint bytecnt = 0; bytecnt < (1 << this.get_size()); bytecnt++) begin
        block[(8 * beat * (1 << this.get_size())) + (bytecnt * 8) +:8] = dbeat[(bytecnt * 8)+:8];
      end
    end
    return(block);
  endfunction : get_data_block

  /*
    Function: get_strb_beat
    Returns the value of the specified beat. This is NOT always the WSTRB representation.
    It will align the signification strobes to the lower bytes and set the unused strobes to zeros.
  */
  virtual function xil_axi_strb_beat get_strb_beat(input xil_axi_uint index);
    xil_axi_strb_beat ret;
    xil_axi_uint      offset;
    xil_axi_uint      width;
    /////////////////////////////////////////////////////////////////////////////////
    //Zero out the return
    ret = 'h0;
    offset = index << this.get_size();
    if (index > this.get_len()) begin
      `xil_fatal(get_name(), $sformatf("strb beat index exceeds length (len: %d - index %d)", this.get_len()+1, index))
    end
    for (xil_axi_uint i = 0;i < (1<<this.get_size()); i++) begin
      ret[i] = this.strb[offset + i];
    end
    return(ret);
  endfunction

  /*
    Function:  set_user_beat
    Sets user value of one beat
  */
  virtual function void set_user_beat(
    input xil_axi_uint      index,
    input xil_axi_user_beat updated
  );
    /////////////////////////////////////////////////////////////////////////////////
    //Fill in the USER array
    xil_axi_uint  offset;
    xil_axi_uint  width;
    xil_axi_uint  element_width;
    if (this.get_cmd_type() == XIL_AXI_READ) begin
      width = this.get_ruser_width();
      this.size_ruser();
    end else begin
      width = this.get_wuser_width();
      this.size_wuser();
    end
    element_width = ((width + XIL_AXI_USER_ELEMENT_WIDTH - 1)/XIL_AXI_USER_ELEMENT_WIDTH);
    offset = index * element_width;

    for (xil_axi_uint i = 0; i < element_width; i++) begin
      this.user[i+offset] = updated[i*XIL_AXI_USER_ELEMENT_WIDTH+:XIL_AXI_USER_ELEMENT_WIDTH];
    end
  endfunction

  /*
    Function: set_ruser
    Sets the value of the RUSER for the beat specified
  */
  virtual function void set_ruser(
    input xil_axi_uint      index,
    input xil_axi_user_beat updated
  );
    if (this.get_cmd_type() == XIL_AXI_READ) begin
      this.set_user_beat(index, updated);
    end
  endfunction

  /*
    Function: set_wuser
    Sets the value of the WUSER for the beat specified
  */
  virtual function void set_wuser(
    input xil_axi_uint      index,
    input xil_axi_user_beat updated
  );
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      this.set_user_beat(index, updated);
    end
  endfunction

  /*
    Function: set_rresp
    Sets the value of the RRESP for the beat specified
  */
  virtual function void set_rresp(input xil_axi_uint    index,
                                  input xil_axi_resp_t  resp);
    if (this.get_cmd_type() == XIL_AXI_READ) begin
      this.create_rresp_array(index+1);
      this.rresp[index] = resp;
    end
  endfunction

  /*
    Function: get_rresp
    Returns the value of the RRESP for the beat specified
  */
  virtual function xil_axi_resp_t get_rresp(input xil_axi_uint index);
    if (index > this.get_len()) begin
      `xil_fatal(get_name(), $sformatf("RRESP beat index exceeds length (len: %d - index %d)", this.get_len()+1, index))
    end
    return(this.rresp[index]);
  endfunction

  /*
    Function: get_rresp_name
    Returns the name of the RRESP for the beat specified
  */
  virtual function string get_rresp_name(input xil_axi_uint index);
    if (index > this.get_len()) begin
      `xil_fatal(get_name(), $sformatf("RRESP beat index exceeds length (len: %d - index %d)", this.get_len()+1, index))
    end
    return(this.rresp[index].name());
  endfunction

  /*
    Function: get_user_beat
    Returns the value of the xUSER beat at the index provided of the transaction.
  */
  virtual function xil_axi_user_beat get_user_beat(input xil_axi_uint index);
    xil_axi_user_beat ret;
    xil_axi_uint      offset;
    xil_axi_uint      width;
    xil_axi_uint      element_width;
    /////////////////////////////////////////////////////////////////////////////////
    //Zero out the return
    ret = 'h0;
    if (this.get_cmd_type() == XIL_AXI_READ) begin
      width = this.get_ruser_width();
    end else begin
      width = this.get_wuser_width();
    end
    element_width = (width + XIL_AXI_USER_ELEMENT_WIDTH - 1)/XIL_AXI_USER_ELEMENT_WIDTH;
    offset = index * element_width;
    if (width == 0) begin
      return(ret);
    end else begin
      if (index > (this.get_len() + 1)) begin
        `xil_fatal(get_name(), $sformatf("wuser index exceeds length (len: %d - index %d)", this.get_len()+1, index))
      end
      for (xil_axi_uint i = 0;i < element_width; i++) begin
        ret[i*XIL_AXI_USER_ELEMENT_WIDTH+:XIL_AXI_USER_ELEMENT_WIDTH] = this.user[offset + i];
      end
      return(ret);
    end
  endfunction

  /*
    Function: get_wuser
    Returns the value of the WUSER for the beat specified
  */
  virtual function xil_axi_user_beat get_wuser(input xil_axi_uint index);
    if (index > this.get_len()) begin
      `xil_fatal(get_name(), $sformatf("WUSER beat index exceeds length (len: %d - index %d)", this.get_len()+1, index))
    end
    return(this.get_user_beat(index));
  endfunction

  /*
    Function: get_ruser
    Returns the value of the RUSER for the beat specified
  */
  virtual function xil_axi_user_beat get_ruser(input xil_axi_uint index);
    if (index > this.get_len()) begin
      `xil_fatal(get_name(), $sformatf("RUSER beat index exceeds length (len: %d - index %d)", this.get_len()+1, index))
    end
    return(this.get_user_beat(index));
  endfunction

  protected virtual function void get_dyn_payload(
    inout xil_axi_payload_byte  payload [],
    input xil_axi_uint          src_offset = 0,
    input xil_axi_uint          src_length = 0,
    input xil_axi_uint          dest_offset = 0
    );
    if ((src_offset+src_length) > data.size()) begin
      `xil_fatal(get_name(), $sformatf("offset+length (%d)+(%d) exceeds data payload size %d",
                            src_offset, src_length, data.size()))
    end else if (src_length == 0) begin
      `xil_warning(get_name(), $sformatf("src copy length is 0. Nothing done"))
    end else if ((src_length + dest_offset) > payload.size()) begin
      `xil_fatal(get_name(), $sformatf("src_length+dest_offset (%d)+(%d) exceeds dest payload size %d",
                            src_length, dest_offset, payload.size()))
    end else begin
      for (xil_axi_uint i = 0; i < src_length; i++) begin
        payload[i+dest_offset] = this.data[i+src_offset];
      end
    end
  endfunction

  protected virtual function void get_dyn_strb(
    inout bit                   payload [],
    input xil_axi_uint          src_offset = 0,
    input xil_axi_uint          src_length = 0,
    input xil_axi_uint          dest_offset = 0
    );
    if ((src_offset+src_length) > data.size()) begin
      `xil_fatal(get_name(), $sformatf("offset+length (%d)+(%d) exceeds strb size %d",
                            src_offset, src_length, data.size()))
    end else if (src_length == 0) begin
      `xil_warning(get_name(), $sformatf("src copy length is 0. Nothing done"))
    end else if ((src_length + dest_offset) > payload.size()) begin
      `xil_fatal(get_name(), $sformatf("src_length+dest_offset (%d)+(%d) exceeds dest strb size %d",
                            src_length, dest_offset, payload.size()))
    end else begin
      for (xil_axi_uint i = 0; i < src_length; i++) begin
        payload[i+dest_offset] = this.strb[i+src_offset];
      end
    end
  endfunction

  protected virtual function void get_dyn_rresp(
    inout xil_axi_resp_t        payload [],
    input xil_axi_uint          src_offset = 0,
    input xil_axi_uint          src_length = 0,
    input xil_axi_uint          dest_offset = 0
    );
    if ((src_offset+src_length) > rresp.size()) begin
      `xil_fatal(get_name(), $sformatf("offset+length (%d)+(%d) exceeds data rresp size %d",
                            src_offset, src_length, rresp.size()))
    end else if (src_length == 0) begin
      `xil_warning(get_name(), $sformatf("src copy length is 0. Nothing done"))
    end else if ((src_length + dest_offset) > payload.size()) begin
      `xil_fatal(get_name(), $sformatf("src_length+dest_offset (%d)+(%d) exceeds dest rresp size %d",
                            src_length, dest_offset, payload.size()))
    end else begin
      for (xil_axi_uint i = 0; i < src_length; i++) begin
        payload[i+dest_offset] = this.rresp[i+src_offset];
      end
    end
  endfunction

///////////////////////////////////////////////////////////////////////////
//WRAP to INCR conversion routines
  /*
    Function: convert_addr_wrap_to_incr
    Returns the INCR address of the WRAP transaction. The returned INCR address will be aligned to the AxSIZE of the transaction.
  */
  virtual function xil_axi_ulong convert_addr_wrap_to_incr();
    xil_axi_ulong ret_addr;
    ret_addr = this.get_addr() & ~(this.get_num_bytes_in_transaction() - 1);
    return(ret_addr);
  endfunction : convert_addr_wrap_to_incr

  /*
    Function: convert_wrap_to_incr
    Returns an axi_transaction based on the current transaction, however, converts the WRAP to INCR byte order.
    This function will change the resultant INCR transaction address to be aligned.
  */
  virtual function axi_transaction convert_wrap_to_incr();
    axi_transaction   trans;
    xil_axi_uint      wrap_boundary;
    xil_axi_uint      beat_offset;

    if (this.get_burst() != XIL_AXI_BURST_TYPE_WRAP) begin
      `xil_fatal(get_name(), $sformatf("Current transaction is not a WRAP it is %s.", this.get_burst_name()))
    end else if (!(this.get_len() == 1 || this.get_len() == 3  || this.get_len() == 7 || this.get_len() == 15  ))begin
      `xil_fatal(get_name(), $sformatf("Current transaction length(%d) is not in range for WRAP",this.get_len()))
    end else begin
      ///////////////////////////////////////////////////////////////////////////
      //create a clone of the transaction
      trans = this.my_clone();
      ///////////////////////////////////////////////////////////////////////////
      //Change the burst type.
      trans.set_burst(XIL_AXI_BURST_TYPE_INCR);
      ///////////////////////////////////////////////////////////////////////////
      //Align the INCR address.
      trans.set_addr(this.convert_addr_wrap_to_incr());
      wrap_boundary = this.get_num_bytes_in_transaction();
      beat_offset = (this.get_addr() & (wrap_boundary - 1)) >> this.get_size();
      for (xil_axi_uint l = 0; l < this.get_len() + 1; l++) begin
        ///////////////////////////////////////////////////////////////////////////
        //Extract the payload
        trans.set_data_beat(beat_offset,this.get_data_beat(l),this.get_beat_delay(l), this.get_strb_beat(l));
        if (this.get_cmd_type() == XIL_AXI_READ) begin
          ///////////////////////////////////////////////////////////////////////////
          //Extract the RRESP
          trans.set_rresp(beat_offset, this.get_rresp(l));
          ///////////////////////////////////////////////////////////////////////////
          //Extract the RUSER
          trans.set_ruser(beat_offset, this.get_ruser(l));
        end else begin
          ///////////////////////////////////////////////////////////////////////////
          //Extract the WUSER
          trans.set_wuser(beat_offset, this.get_wuser(l));
        end
        beat_offset++;
        if (beat_offset > this.get_len()) begin
          beat_offset = 0;
        end
      end
      return(trans);
    end
  endfunction : convert_wrap_to_incr

  ///////////////////////////////////////////////////////////////////////////
  //Convert INCR to WRAP. This is used in the case where the transaction was
  // originally a INCR and they want to convert it to a WRAP
  /*
    Function: convert_incr_to_wrap
    Returns an axi_transaction based on the current transaction, however, converts the INCR to WRAP byte order.
    This function requires the WRAP offset to correctly return the target word.
  */
  virtual function axi_transaction convert_incr_to_wrap(
    input [10:0] wrap_offset
  );
    axi_transaction   trans;
    xil_axi_uint      wrap_boundary;
    xil_axi_uint      beat_offset;

    wrap_boundary = this.get_num_bytes_in_transaction();
    if (this.get_burst() != XIL_AXI_BURST_TYPE_INCR) begin
      `xil_fatal(get_name(), $sformatf("Current transaction is not a INCR it is %s", this.get_burst_name()))
    end else if ((this.get_addr() % wrap_boundary) !=0) begin
      `xil_fatal(get_name(), $sformatf("Current transaction address %h is not aligned", this.get_addr()))
    end else if (!(this.get_len() == 1 || this.get_len() == 3 || this.get_len() == 7 || this.get_len() == 15))begin
      `xil_fatal(get_name(), $sformatf("Current transaction length(%d) is not in range for WRAP",this.get_len()))
    end else if (wrap_offset > wrap_boundary) begin
     `xil_fatal(get_name(), $sformatf("Wrap offset 0x%0x is out of range 0x%0x is not in range",wrap_offset, wrap_boundary))
    end else if ((wrap_offset % (1<<this.get_size())) != 0) begin
     `xil_fatal(get_name(), "Wrap address is not aligned address")
    end else begin
      ///////////////////////////////////////////////////////////////////////////
      //create a clone of the transaction
      trans = this.my_clone();
      ///////////////////////////////////////////////////////////////////////////
      //Change the burst type.
      trans.set_burst(XIL_AXI_BURST_TYPE_WRAP);
      ///////////////////////////////////////////////////////////////////////////
      //Align the INCR address.
      trans.set_addr(this.get_addr()+wrap_offset);

      beat_offset = wrap_offset >> this.get_size();
      for (xil_axi_uint l = 0; l < this.get_len() + 1; l++) begin
        ///////////////////////////////////////////////////////////////////////////
        //Extract the payload
        //Extract the WSTRB
        trans.set_data_beat(l,this.get_data_beat(beat_offset),this.get_beat_delay(beat_offset), this.get_strb_beat(beat_offset));
        if (this.get_cmd_type() == XIL_AXI_READ) begin
          ///////////////////////////////////////////////////////////////////////////
          //Extract the RRESP
          trans.set_rresp(l, this.get_rresp(beat_offset));
          ///////////////////////////////////////////////////////////////////////////
          //Extract the RUSER
          trans.set_ruser(l, this.get_ruser(beat_offset));
        end else begin
          ///////////////////////////////////////////////////////////////////////////
          //Extract the WUSER
          trans.set_wuser(l, this.get_wuser(beat_offset));
        end
        beat_offset++;
        if (beat_offset > this.get_len()) begin
          beat_offset = 0;
        end
      end
      return(trans);
    end
  endfunction : convert_incr_to_wrap

  protected virtual function void set_dyn_strb(
    inout bit             payload []
  );
    this.strb = new[payload.size()] (payload);
  endfunction : set_dyn_strb

  protected virtual function void set_dyn_data(
    inout xil_axi_payload_byte  payload []
  );
    this.data = new[payload.size()] (payload);
  endfunction : set_dyn_data

  protected virtual function void set_dyn_rresp(
    inout xil_axi_resp_t  payload []
  );
    this.rresp = new[payload.size()] (payload);
  endfunction : set_dyn_rresp

  protected virtual function void set_dyn_user(
    inout xil_axi_user_beat  payload []
  );
    if (payload.size() > (this.get_len() + 1)) begin
      `xil_warning(get_name(), $sformatf("Attempted to set more RUSER beats (%d) than transaction length (%d). Only sending transaction length", payload.size(), this.get_len()))
    end else if (payload.size() < (this.get_len() + 1)) begin
      `xil_fatal(get_name(), $sformatf("Attempted to set fewer RUSER beats (%d) than transaction length (%d).", payload.size(), this.get_len()))
    end

    for (xil_axi_uint i = 0; i < this.get_len() + 1;i++) begin
      this.set_user_beat(i, payload[i]);
    end
  endfunction : set_dyn_user

  protected virtual function void set_dyn_ruser(
    inout xil_axi_user_beat  payload []
  );
    this.set_dyn_user(payload);
  endfunction : set_dyn_ruser

  protected virtual function void set_dyn_wuser(
    inout xil_axi_user_beat  payload []
  );
    this.set_dyn_user(payload);
  endfunction : set_dyn_wuser

  /*
    Function:   import_data_beat_fields
    Sets data,strobe,wuser of write beat
  */
  virtual function void import_data_beat_fields(
   inout xil_axi_write_beat write_beat
  );
    xil_axi_payload_byte        beat [];
    bit                         strb [];
    xil_axi_uint                byte_lane;

    ///////////////////////////////////////////////////////////////////////////
    //Create array of bytes
    beat = new[(1 << this.get_size())];
    strb = new[(1 << this.get_size())];

    ///////////////////////////////////////////////////////////////////////////
    // copy WUSER from W channel to transfer
    if (this.get_wuser_width() > 0) begin
      this.set_wuser(this.get_beat_index(), write_beat.get_user());
    end

    byte_lane = this.get_burst_byte_offset(this.get_beat_index());

    for (int j=(beat.size()-1);j >= 0; j--) begin
      beat[j] = write_beat.data[byte_lane+j];
      strb[j] = write_beat.strb[byte_lane+j];
    end
    this.set_data_beat_unpacked(this.get_beat_index(),beat);
    this.set_strb_beat_unpacked(this.get_beat_index(),strb);
    this.increment_beat_index();
  endfunction

  /*
    Function:  import_cmd_fields
    Sets addr, cmd, len,size,burst,lock,cache,prot,region,qos,data and beat_delay of cmd beat
    For write command, set awuser(if AWUSER_WIDTH>0),wuser(if WUSER_WIDTH>0),
    For read command, set aruser(if ARUSER_WIDTH>0),ruser(if RUSER_WIDTH>0).
  */
  virtual function void import_cmd_fields (
   inout xil_axi_cmd_beat cmd
    );
    this.set_addr(cmd.addr);
    this.set_id(cmd.id);
    this.set_len(cmd.len);
    this.set_size(cmd.size);
    this.set_burst(cmd.burst);
    this.set_lock(cmd.lock);
    this.set_cache(cmd.cache);
    this.set_prot(cmd.prot);
    this.set_region(cmd.region);
    this.set_qos(cmd.qos);
    this.size_data();
    this.size_beat_delay();
    if (this.cmd == XIL_AXI_WRITE) begin
      this.size_strb();
      if (this.get_awuser_width() > 0) begin
        this.set_awuser(cmd.get_user());
      end
      if (this.get_wuser_width() > 0) begin
        this.size_wuser();
      end
    end else begin
      this.size_rresp();
      if (this.get_aruser_width() > 0) begin
        this.set_aruser(cmd.get_user());
      end
      if (this.get_ruser_width() > 0) begin
        this.size_ruser();
      end
    end
  endfunction : import_cmd_fields

  /*
    Function:  import_rd_beat
    Sets data, ruser(if RUSER_WIDTH>0),rresp of read beat
  */
  virtual function void import_rd_beat(
   inout  xil_axi_read_beat beat
  );
    this.store_rdata(beat);
    ///////////////////////////////////////////////////////////////////////////
    // copy RUSER from R channel to transfer
    if (this.get_ruser_width() > 0) begin
      this.set_ruser(this.get_beat_index(), beat.get_user());
    end
    ///////////////////////////////////////////////////////////////////////////
    // copy RRESP from R channel to transfer
    this.set_rresp(this.get_beat_index(), beat.resp);
  endfunction : import_rd_beat

  ///////////////////////////////////////////////////////////////////////////
  //Store the payload into the transfer.
  protected virtual function void store_rdata (inout xil_axi_read_beat rdata);
    xil_axi_payload_byte beat [];
    xil_axi_uint byte_lane;

    ///////////////////////////////////////////////////////////////////////////
    //Create array of bytes
    beat = new[(1 << this.get_size())];
    ///////////////////////////////////////////////////////////////////////////
    // calculate which byte-lanes to start transfer with (see AXI spec chapter 4.5 on page 4-8)
    byte_lane = this.get_burst_byte_offset(this.get_beat_index());

    for (int j=(beat.size()-1);j >= 0; j--) begin
      beat[j] = rdata.data[byte_lane + j];
    end
    this.set_data_beat_unpacked(this.get_beat_index(),beat);

  endfunction : store_rdata

  /*
    Function: auto_fill_transaction
    Fill the transaction with different patterns based on the data_pat/strb_pat selected. When the data_pat is NOT set to XIL_AXI_DATA_FILL_NOTOUCH,
    The values of the strb's will all be set even if the strb_pat is set to XIL_AXI_DATA_FILL_NOTOUCH.
  */
  function void auto_fill_transaction(
    input xil_axi_data_fill_t     data_pat,
    input xil_axi_strb_fill_t     strb_pat = XIL_AXI_STRB_FILL_NOTOUCH,
    input xil_axi_data_beat       data_fill = 'h0
  );
    xil_axi_data_beat rdata;
    xil_axi_strb_beat rstrb;
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      this.size_wr_beats();
    end else begin
      this.size_rd_beats();
    end
    case (data_pat)
      XIL_AXI_DATA_FILL_CONSTANT: begin
        for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
          this.set_data_beat(i, data_fill);
        end
      end
      XIL_AXI_DATA_FILL_RANDOM: begin
        for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
          `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
            RDDATA_RAND_FAILED: assert(std::randomize(rdata));
          `else
            for (xil_axi_uint w = 0; w < XIL_AXI_MAX_DATA_WIDTH/32;w++) begin
              rdata = rdata << 32;
              rdata[31:0] = $urandom();
            end
          `endif
          this.set_data_beat(i, rdata);
        end
      end
      XIL_AXI_DATA_FILL_ADDR_AS_DATA: begin
        rdata = 'h0;
        rdata += this.get_addr();
        for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
          this.set_data_beat(i, rdata);
        end
      end
      XIL_AXI_DATA_FILL_WALKING_1: begin
        rdata ='h1;
        for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
          this.set_data_beat(i, rdata);
          rdata = rdata << 1;
        end
      end
      XIL_AXI_DATA_FILL_WALKING_0: begin
        rdata = 'h1;
        rdata = ~rdata;
        for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
          this.set_data_beat(i, rdata);
          rdata = rdata << 1;
        end
      end
      XIL_AXI_DATA_FILL_HAMMER: begin
        rdata = {XIL_AXI_MAX_DATA_WIDTH{1'b1}};
        for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
          this.set_data_beat(i, rdata);
          rdata = ~rdata;
        end
      end
      XIL_AXI_DATA_FILL_NEIGHBOUR: begin
        xil_axi_data_beat tmp_data;
        tmp_data = 'h1;
        for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
          if (i%2) begin
            rdata = 'h0;
          end else begin
            rdata = ~tmp_data;
            tmp_data = tmp_data << 1;
          end
          this.set_data_beat(i, rdata);
        end
      end
    endcase
    if (this.get_cmd_type() == XIL_AXI_WRITE) begin
      case (strb_pat)
        XIL_AXI_STRB_FILL_RANDOM: begin
          for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
            `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
              RSTRB_RAND_FAILED: assert(std::randomize(rstrb));
            `else
              for (xil_axi_uint w = 0; w < (XIL_AXI_MAX_DATA_WIDTH/8)/32;w++) begin
                rstrb = rstrb << 32;
                rstrb[31:0] = $urandom();
              end
            `endif
            this.set_strb_beat(i, rstrb);
          end
          this.adjust_head_strb();
        end
        XIL_AXI_STRB_FILL_ALL_VALID: begin
          for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
            this.set_strb_beat(i, {XIL_AXI_MAX_DATA_WIDTH/8{1'b1}});
          end
          this.adjust_head_strb();
        end
        XIL_AXI_STRB_FILL_ALT_VALID: begin
          bit alt_strb;
          `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
            ALT_STRB_RAND_FAILED: assert(std::randomize(alt_strb));
          `else
            alt_strb = $urandom() % 1;
          `endif
          if (alt_strb) begin
            rstrb = {XIL_AXI_MAX_DATA_WIDTH/4{2'b01}};
          end else begin
            rstrb = {XIL_AXI_MAX_DATA_WIDTH/4{2'b10}};
          end
          for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
            this.set_strb_beat(i, rstrb);
          end
          this.adjust_head_strb();
        end
        XIL_AXI_STRB_FILL_NO_VALID: begin
          for (xil_axi_uint i = 0; i <= this.get_len();i++) begin
            this.set_strb_beat(i, {XIL_AXI_MAX_DATA_WIDTH/8{1'b0}});
          end
        end
      endcase
    end
  endfunction : auto_fill_transaction

endclass : axi_transaction

/*
  Class: axi_monitor_transaction
  AXI Monitor Transaction Object
*/
class axi_monitor_transaction extends axi_transaction;
  time            addr_ready_assert_time = 0;
  time            addr_valid_assert_time = 0;
  xil_axi_ulong   addr_ready_assert_cycle = 0;
  xil_axi_ulong   addr_valid_assert_cycle = 0;
  xil_axi_int     addr_accepted_cycles = 0;
  time            resp_ready_assert_time = 0;
  time            resp_valid_assert_time = 0;
  xil_axi_ulong   resp_ready_assert_cycle = 0;
  xil_axi_ulong   resp_valid_assert_cycle = 0;
  xil_axi_int     resp_accepted_cycles = 0;
  time            addr_phase_start = 0;
  time            addr_phase_end = 0;
  xil_axi_ulong   addr_phase_end_cycle = 0;
  time            data_phase_start = 0;
  time            data_phase_end = 0;
  time            bresp_phase_start = 0;
  time            bresp_phase_end = 0;
  time            transaction_phase_start = 0;
  time            transaction_phase_end = 0;
  time            data_ready_assert_time[];
  time            data_valid_assert_time[];
  xil_axi_ulong   data_ready_assert_cycle[];
  xil_axi_ulong   data_valid_assert_cycle[];
  time            data_beat_accepted[];
  xil_axi_int     data_beat_accepted_cycles[];
  protected xil_axi_boolean_t monitor_print_times = XIL_AXI_FALSE;

  ///////////////////////////////////////////////////////////////////////////
  // constructor

  /*
    Function: new
    Constructor to create a new AXI monitor transaction.
  */
  function new(input string name = "unnamed_axi_monitor_transaction",
                     xil_axi_uint   protocol=0,
                     xil_axi_uint   addrw=32,
                     xil_axi_uint   dataw=32,
                     xil_axi_uint   idw=0,
                     xil_axi_uint   awusrw=0,
                     xil_axi_uint   wusrw=0,
                     xil_axi_uint   busrw=0,
                     xil_axi_uint   arusrw=0,
                     xil_axi_uint   rusrw=0,
                     xil_axi_uint   supports_narrow =1,
                     xil_axi_uint   has_burst =1,
                     xil_axi_uint   has_lock =1,
                     xil_axi_uint   has_cache =1,
                     xil_axi_uint   has_region =1,
                     xil_axi_uint   has_prot =1,
                     xil_axi_uint   has_qos =1,
                     xil_axi_uint   has_wstrb =1,
                     xil_axi_uint   has_bresp =1,
                     xil_axi_uint   has_rresp =1
  );
    super.new(name,
      protocol,
      addrw,
      dataw,
      idw,
      awusrw,
      wusrw,
      busrw,
      arusrw,
      rusrw,
      supports_narrow,
      has_burst,
      has_lock,
      has_cache,
      has_region,
      has_prot,
      has_qos,
      has_wstrb,
      has_bresp,
      has_rresp
    );
  endfunction

  /*
    Function:  get_addr_phase_start
    Returns addr_phase_start of the monitor transaction
  */
  virtual function xil_axi_ulong get_addr_phase_start();
    return(this.addr_phase_start);
  endfunction

  /*
    Function:  set_monitor_print_times
    Sets monitor_print_times to be TRUE
  */
  virtual function void set_monitor_print_times();
    monitor_print_times = XIL_AXI_TRUE;
  endfunction

  /*
    Function:  clr_monitor_print_times
    Sets monitor_print_times to be FALSE
  */
  virtual function void clr_monitor_print_times();
    monitor_print_times = XIL_AXI_FALSE;
  endfunction

  /*
    Function: get_monitor_print_times
    Returns monitor_print_times of the monitor transaction
  */
  virtual function xil_axi_boolean_t get_monitor_print_times();
    return(monitor_print_times);
  endfunction

  /*
    Function:  trigger_addr_phase_end
    Sets addr_phase_end,addr_phase_end_cycle,addr_ready_assert_time,addr_valid_assert_time,addr_ready_assert_cycle,
     addr_valid_assert_cycle,addr_phase_start,addr_accepted_cycles
  */
  virtual function void trigger_addr_phase_end(
    input time          ready_time,
    input time          valid_time,
    input xil_axi_ulong ready_cycle,
    input xil_axi_ulong valid_cycle,
    input xil_axi_ulong now
  );
    this.addr_phase_end = $time;
    this.addr_phase_end_cycle = now;
    this.addr_ready_assert_time = ready_time;
    this.addr_valid_assert_time = valid_time;
    this.addr_ready_assert_cycle = ready_cycle;
    this.addr_valid_assert_cycle = valid_cycle;
    if (this.addr_valid_assert_time >= this.addr_ready_assert_time) begin
      this.addr_phase_start = this.addr_ready_assert_time;
      this.addr_accepted_cycles = -1*(valid_cycle - ready_cycle);
    end else begin
      this.addr_phase_start = this.addr_valid_assert_time;
      this.addr_accepted_cycles = 1*(ready_cycle - valid_cycle);
    end
  endfunction

  /*
    Function:   get_addr_phase_end
    Returns addr_phase_end of the monitor transaction
  */
  virtual function time get_addr_phase_end();
    return(this.addr_phase_end);
  endfunction

  /*
    Function:  trigger_data_phase_start
    Sets data_phase_start of the monitor transaction to be current time
  */
  virtual function void trigger_data_phase_start();
    this.data_phase_start = $time;
  endfunction

  /*
    Function:  get_data_phase_start
    Returns data_phase_start of the monitor transaction
  */
  virtual function time get_data_phase_start();
    return(this.data_phase_start);
  endfunction

  /*
    Function:   trigger_data_phase_end
    Sets data_phase_end of the monitor transaction to be current time
  */
  virtual function void trigger_data_phase_end();
    this.data_phase_end = $time;
  endfunction

  /*
    Function:  get_data_phase_end
    Returns data_phase_end of the monitor transaction
  */
  virtual function time get_data_phase_end();
    return(this.data_phase_end);
  endfunction

  /*
    Function:  get_bresp_phase_start
    Returns bresp_phase_start of the monitor transaction
  */
  virtual function time get_bresp_phase_start();
    return(this.bresp_phase_start);
  endfunction

  /*
    Function:   trigger_bresp_phase_end
    Sets bresp_phase_end,resp_ready_assert_time,resp_valid_assert_time,resp_ready_assert_cycle, 
    resp_ready_assert_cycle,resp_valid_assert_cycle,bresp_phase_start,resp_accepted_cycles, 
    bresp_phase_start,resp_accepted_cycles
  */
  virtual function void trigger_bresp_phase_end(
    input time          ready_time,
    input time          valid_time,
    input xil_axi_ulong ready_cycle,
    input xil_axi_ulong valid_cycle
  );
    this.bresp_phase_end = $time;
    this.resp_ready_assert_time = ready_time;
    this.resp_valid_assert_time = valid_time;
    this.resp_ready_assert_cycle = ready_cycle;
    this.resp_valid_assert_cycle = valid_cycle;
    if (this.addr_phase_end > this.resp_ready_assert_time) begin
      this.bresp_phase_start = this.addr_phase_end;
      this.resp_accepted_cycles = -1*(valid_cycle - this.addr_phase_end_cycle);
    end else if (this.resp_valid_assert_time >= this.resp_ready_assert_time) begin
      this.bresp_phase_start = this.resp_ready_assert_time;
      this.resp_accepted_cycles = -1*(valid_cycle - ready_cycle);
    end else begin
      this.bresp_phase_start = this.resp_valid_assert_time;
      this.resp_accepted_cycles = (ready_cycle - valid_cycle);
    end

  endfunction

  /*
    Function:   get_bresp_phase_end
    Returns bresp_phase_end of the monitor transaction
  */
  virtual function time get_bresp_phase_end();
    return(this.bresp_phase_end);
  endfunction

  /*
    Function:  trigger_transaction_phase_start
    Sets transaction_phase_start of the monitor transaction to current time
  */
  virtual function void trigger_transaction_phase_start();
    this.transaction_phase_start = $time;
  endfunction

  /*
    Function:  get_transaction_phase_start
    Returns transaction_phase_start of the monitor transaction
  */
  virtual function time get_transaction_phase_start();
    return(this.transaction_phase_start);
  endfunction

  /*
    Function:  trigger_transaction_phase_end
    Sets transaction_phase_end of the monitor transaction to current time
  */
  virtual function void trigger_transaction_phase_end();
    this.transaction_phase_end = $time;
  endfunction

  /*
    Function:  get_transaction_phase_end
    Returns transaction_phase_end of the monitor transaction
  */
  virtual function time get_transaction_phase_end();
    return(this.transaction_phase_end);
  endfunction

  /*
    Function:  set_data_beat_time_fields
    Sets data_ready_assert_time,data_valid_assert_time,data_beat_accepted,data_beat_accepted_cycles
  */
  virtual function void set_data_beat_time_fields(
    input xil_axi_ulong data_ready_assert_time,
    input xil_axi_ulong data_valid_assert_time,
    input xil_axi_ulong data_beat_accepted,
    input xil_axi_int   data_beat_accepted_cycles,
    input xil_axi_ulong now = 0
    );
    if (data_ready_assert_time == 0) begin
      data_ready_assert_time = now;
    end
    if (data_valid_assert_time == 0) begin
      data_valid_assert_time = now;
    end
    if (data_beat_accepted == 0) begin
      data_beat_accepted = now;
    end
    this.data_beat_accepted = new[this.data_beat_accepted.size()+1](this.data_beat_accepted);
    this.data_ready_assert_time = new[this.data_ready_assert_time.size()+1](this.data_ready_assert_time);
    this.data_valid_assert_time = new[this.data_valid_assert_time.size()+1](this.data_valid_assert_time);
    this.data_beat_accepted_cycles = new[this.data_valid_assert_time.size()+1](this.data_beat_accepted_cycles);

    this.data_beat_accepted[this.beat_index] = data_beat_accepted;
    this.data_ready_assert_time[this.beat_index] = data_ready_assert_time;
    this.data_valid_assert_time[this.beat_index] = data_valid_assert_time;
    this.data_beat_accepted_cycles[this.beat_index] = data_beat_accepted_cycles;
  endfunction

  /*
    Function:  import_data_beat_fields
    Sets transaction_phase_start,data_phase_end,data_ready_assert_time,
    data_valid_assert_time,data_beat_accepted,data_beat_accepted_cycles, data, stobe, wuser(if WUSER_WIDTH>0) 
  */
  virtual function void import_data_beat_fields(
    inout xil_axi_write_beat      write_beat
  );
    ///////////////////////////////////////////////////////////////////////////
    //Set the transaction characteristics
    // If this is the first beat then this is the start of the data_phase.
    // The transaction time is measured from this point if the address phase
    // starts later.
    if (this.get_beat_index() == 0) begin
      this.data_phase_start = write_beat.data_valid_assert_time;
      if (this.get_transaction_phase_start() > this.data_phase_start) begin
        this.transaction_phase_start = this.data_phase_start;
      end
    end
    if (write_beat.last == 1'b1) begin
      this.data_phase_end = write_beat.accepted;
    end
    this.set_data_beat_time_fields(
      .data_ready_assert_time     (write_beat.data_ready_assert_time),
      .data_valid_assert_time     (write_beat.data_valid_assert_time),
      .data_beat_accepted         (write_beat.accepted),
      .data_beat_accepted_cycles  (write_beat.data_beat_accepted_cycles),
      .now                        (0)
      );
    super.import_data_beat_fields(write_beat);
  endfunction

  /*
    Function:  trigger_data_beat_accepted
    Sets data beat monitor characterics of data_beat_accepted,data_ready_assert_time,
    data_valid_assert_time,data_ready_assert_cycle,data_valid_assert_cycle,data_beat_accepted_cycles,
    data_beat_accepted
  */
  virtual function void trigger_data_beat_accepted(
    input time          ready_time,
    input time          valid_time,
    input xil_axi_ulong ready_cycle,
    input xil_axi_ulong valid_cycle
  );
    ///////////////////////////////////////////////////////////////////////////
    //Because WDATA can lead AWADDR, we may not know the number of beats until
    //it is over. We will expand the array on every trigger.
    this.data_beat_accepted = new[this.data_beat_accepted.size()+1](this.data_beat_accepted);
    this.data_ready_assert_time = new[this.data_ready_assert_time.size()+1](this.data_ready_assert_time);
    this.data_valid_assert_time = new[this.data_valid_assert_time.size()+1](this.data_valid_assert_time);
    this.data_ready_assert_cycle = new[this.data_ready_assert_cycle.size()+1](this.data_ready_assert_cycle);
    this.data_valid_assert_cycle = new[this.data_valid_assert_cycle.size()+1](this.data_valid_assert_cycle);
    this.data_beat_accepted_cycles = new[this.data_valid_assert_cycle.size()+1](this.data_beat_accepted_cycles);
    this.data_beat_accepted[this.beat_index] = $time;
    this.data_ready_assert_time[this.beat_index] = ready_time;
    this.data_valid_assert_time[this.beat_index] = valid_time;
    this.data_ready_assert_cycle[this.beat_index] = ready_cycle;
    this.data_valid_assert_cycle[this.beat_index] = valid_cycle;

    if (valid_cycle >= ready_cycle) begin
      this.data_beat_accepted_cycles[this.beat_index] = -1*(valid_cycle - ready_cycle);
    end else begin
      this.data_beat_accepted_cycles[this.beat_index] = (ready_cycle - valid_cycle);
    end

  endfunction

  /*
    Function:  get_data_beat_accepted
    Returns data_beat_accepted of current beat 
  */
  virtual function xil_axi_ulong get_data_beat_accepted();
    return(this.data_beat_accepted[this.beat_index]);
  endfunction

  /*
    Function:  get_data_ready_assert_time
    Returns data_ready_assert_time of current beat
  */
  virtual function xil_axi_ulong get_data_ready_assert_time();
    return(this.data_ready_assert_time[this.beat_index]);
  endfunction

  /*
    Function:  get_data_valid_assert_time
    Returns data_valid_assert_time of current beat
  */
  virtual function xil_axi_ulong get_data_valid_assert_time();
    return(this.data_valid_assert_time[this.beat_index]);
  endfunction

  /*
    Function:  copy
    Copies the contents of the input monitor transaction to the current monitor transaction
  */
  function void copy(axi_monitor_transaction rhs);
    super.copy(rhs);
    this.addr_ready_assert_time     = rhs.addr_ready_assert_time ;
    this.addr_valid_assert_time     = rhs.addr_valid_assert_time ;
    this.addr_ready_assert_cycle    = rhs.addr_ready_assert_cycle;
    this.addr_valid_assert_cycle    = rhs.addr_valid_assert_cycle;
    this.addr_accepted_cycles       = rhs.addr_accepted_cycles   ;
    this.resp_ready_assert_time     = rhs.resp_ready_assert_time ;
    this.resp_valid_assert_time     = rhs.resp_valid_assert_time ;
    this.resp_ready_assert_cycle    = rhs.resp_ready_assert_cycle;
    this.resp_valid_assert_cycle    = rhs.resp_valid_assert_cycle;
    this.resp_accepted_cycles       = rhs.resp_accepted_cycles   ;
    this.addr_phase_start           = rhs.addr_phase_start       ;
    this.addr_phase_end             = rhs.addr_phase_end         ;
    this.addr_phase_end_cycle       = rhs.addr_phase_end_cycle   ;
    this.data_phase_start           = rhs.data_phase_start       ;
    this.data_phase_end             = rhs.data_phase_end         ;
    this.bresp_phase_start          = rhs.bresp_phase_start      ;
    this.bresp_phase_end            = rhs.bresp_phase_end        ;
    this.transaction_phase_start    = rhs.transaction_phase_start;
    this.transaction_phase_end      = rhs.transaction_phase_end  ;      
    this.data_ready_assert_time     = new[rhs.data_ready_assert_time.size()]    (rhs.data_ready_assert_time   );
    this.data_valid_assert_time     = new[rhs.data_valid_assert_time.size()]    (rhs.data_valid_assert_time   );
    this.data_ready_assert_cycle    = new[rhs.data_ready_assert_cycle.size()]   (rhs.data_ready_assert_cycle  );
    this.data_valid_assert_cycle    = new[rhs.data_valid_assert_cycle.size()]   (rhs.data_valid_assert_cycle  );
    this.data_beat_accepted         = new[rhs.data_beat_accepted.size()]        (rhs.data_beat_accepted       );
    this.data_beat_accepted_cycles  = new[rhs.data_beat_accepted_cycles.size()] (rhs.data_beat_accepted_cycles);
  endfunction : copy

  /*
    Function:  my_clone
    Clones the current monitor transaction and returns a handle to the new monitor transaction.
  */
  virtual function axi_monitor_transaction my_clone ();
    axi_monitor_transaction           my_obj;
    my_obj = new(this.get_name(),
               this.get_protocol(),
               this.get_addr_width(),
               this.get_data_width(),
               this.get_id_width(),
               this.get_awuser_width(),
               this.get_wuser_width(),
               this.get_buser_width(),
               this.get_aruser_width(),
               this.get_ruser_width(),
               this.get_supports_narrow(),
               this.get_has_burst(),
               this.get_has_lock(),
               this.get_has_cache(),
               this.get_has_region(),
               this.get_has_prot(),
               this.get_has_qos(),
               this.get_has_wstrb(),
               this.get_has_bresp(),
               this.get_has_rresp()

    );
    my_obj.set_id_info(this);
    my_obj.copy(this);
    return(my_obj);
  endfunction

  /*
    Function:  do_print
    Prints out monitor transaction information 
  */
  virtual function void do_print(xil_printer printer);
    string sout;

    ///////////////////////////////////////////////////////////////////////////
    //Print Times?
    if (this.get_monitor_print_times() != XIL_AXI_TRUE) begin
      super.do_print(printer);
    end else begin
      printer.print_string("addr_ready_assert_time", $sformatf("%t",addr_ready_assert_time));
      printer.print_string("addr_valid_assert_time", $sformatf("%t", addr_valid_assert_time));
      printer.print_string("addr_accepted_cycles", $sformatf("%d", addr_accepted_cycles));
      printer.print_string("resp_ready_assert_time", $sformatf("%t", resp_ready_assert_time));
      printer.print_string("resp_valid_assert_time", $sformatf("%t", resp_valid_assert_time));
      printer.print_string("resp_accepted_cycles", $sformatf("%d", resp_accepted_cycles));
      printer.print_string("addr_phase_start", $sformatf("%t", addr_phase_start));
      printer.print_string("addr_phase_end", $sformatf("%t", addr_phase_end));
      printer.print_string("data_phase_start", $sformatf("%t", data_phase_start));
      printer.print_string("data_phase_end", $sformatf("%t", data_phase_end));
      printer.print_string("bresp_phase_start", $sformatf("%t", bresp_phase_start));
      printer.print_string("bresp_phase_end", $sformatf("%t", bresp_phase_end));
      printer.print_string("transaction_phase_start", $sformatf("%t", transaction_phase_start));
      printer.print_string("transaction_phase_end", $sformatf("%t", transaction_phase_end));
    

      printer.print_array_header("TIMES", data_beat_accepted.size());
      for(int i=0; i<(this.get_len()+1); i++) begin
        printer.print_string($sformatf("T[%d]",i), $sformatf("%t %t %t %d",data_beat_accepted[i],data_valid_assert_time[i],data_ready_assert_time[i], data_beat_accepted_cycles[i]));
      end
      printer.print_array_footer(1);
    end
  endfunction : do_print

endclass : axi_monitor_transaction

/*
  Class : axi_scoreboard_transaction
  AXI Scoreboard Transaction Object
*/
class axi_scoreboard_transaction extends axi_monitor_transaction;

  ///////////////////////////////////////////////////////////////////////////
  // constructor ////////////////////////////////////////////////////////////
  /*
    Function: new
    Constructor to create a new AXI scoreboard transaction.
  */
  function new(input string name = "unnamed_axi_scoreboard_transaction");
    super.new(name);
  endfunction // new

endclass : axi_scoreboard_transaction


typedef axi_transaction                                       axi_transaction_t;
typedef axi_monitor_transaction                               axi_monitor_transaction_t;
typedef axi_scoreboard_transaction                            axi_scoreboard_transaction_t;

///////////////////////////////////////////////////////////////////////////
//Comprises the
/*
  Class : axi_write_transfer
  AXI write transfer Object
*/
class axi_write_transfer #(type T = axi_transaction) extends xil_axi_transaction_state;
  typedef  xil_axi_generic_queue_container  #(xil_axi_write_beat)  wr_xfer_beat_q_t;
  T                   transfer;
  wr_xfer_beat_q_t    beat_q;
  xil_axi_uint        p_id;
  xil_axi_boolean_t   reactive_sent = XIL_AXI_FALSE;

  /*
    Function: new
    Constructor to create a new AXI write transfer with initial settings
  */
  function new(input xil_axi_uint id = 0);
    ///////////////////////////////////////////////////////////////////////////
    //Create the SUPER
    super.new();
    this.p_id = id;
    ///////////////////////////////////////////////////////////////////////////
    //Create empty beat Q
    this.beat_q = new;
    ///////////////////////////////////////////////////////////////////////////
    //Create new transfer
    this.transfer = new($sformatf("AXI_WXFER%0d", this.p_id));
    this.transfer.set_cmd_type(XIL_AXI_WRITE);
    this.reactive_sent = XIL_AXI_FALSE;
  endfunction

  /*
   Function: set_reactive_sent
   Sets reactive_sent of the axi write transfer to be true
  */
  function void set_reactive_sent();
    this.reactive_sent = XIL_AXI_TRUE;
  endfunction

  /*
   Function: get_reactive_sent
   Returns reactive_sent of the axi write transfer
  */
  function xil_axi_boolean_t get_reactive_sent();
    return(this.reactive_sent);
  endfunction

  /*
   Function: set_beat_q
   Sets beat_q of the axi write transfer
  */
  function void set_beat_q(input wr_xfer_beat_q_t update);
    this.beat_q = update;
  endfunction

  /*
   Function: get_beat_q
   Returns beat_q of the axi write transfer
  */
  function wr_xfer_beat_q_t get_beat_q();
    return(this.beat_q);
  endfunction

  /*
   Function: clean
   Cleans beat_q of the axi write transfer
  */
  function void clean();
    beat_q.clean();
  endfunction

  /*
   Function: free
   Frees beat_q of the axi write transfer
  */
  function void free();
    beat_q.free();
  endfunction

  /*
   Function: get_transfer
   Returns transfer of the axi write transfer
  */
  function T get_transfer();
    return(transfer);
  endfunction

  /*
   Function: set_transfer
   Sets transfer of the axi write transfer
  */
  function void set_transfer(input T new_xfer);
    this.transfer = new_xfer;
  endfunction

  protected function void push_beat (input xil_axi_write_beat beat);
    ///////////////////////////////////////////////////////////////////////////
    //Take the beat and push it onto the queue
    this.beat_q.push_back(beat);
  endfunction

 protected function xil_axi_write_beat pop_beat();
    xil_axi_write_beat beat;
    beat = this.beat_q.pop_front();
    return(beat);
  endfunction

  /*
   Function: get_num_entries
   Returns the number of entries of beat_q of the axi write transfer
  */
  function xil_axi_uint get_num_entries();
    return(this.beat_q.get_num_entries());
  endfunction

  /*
   Function: sprint
   Returns string with p_id,state and beat_q information of the axi write transfer
  */
  function string sprint();
    return($sformatf("ID=0x%x - ST 0b%b\nBQ: %s\nCMD: %s\n",this.p_id, this.get_state(), beat_q.sprint(), this.transfer.cmd_sprintf()));
  endfunction

  /*
   Function: set_id
   Sets p_id of the axi write transfer
  */
  function void set_id(input xil_axi_uint new_id);
    this.p_id = new_id;
  endfunction

  /*
   Function: get_id
   Returns p_id of axi write transfer
  */
  function xil_axi_uint get_id();
    return(this.p_id);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  //Store the payload into the transfer.
  /*
  Function: store_wdata
  Stores the payload into the transfer 
  */
  function void store_wdata ();
    xil_axi_write_beat  write_beat;

    transfer.clr_beat_index();
    ///////////////////////////////////////////////////////////////////////////
    //Loop through the beats
    while (beat_q.get_num_entries() > 0) begin
      write_beat = beat_q.pop_front();
      transfer.import_data_beat_fields(write_beat);
    end
    transfer.clr_beat_index();
  endfunction


endclass : axi_write_transfer

/*
 Class: axi_generic_write_transaction_queue
 AXI Genric Write Transaction Queue Object
*/
class axi_generic_write_transaction_queue #(type T = axi_transaction);
  typedef axi_write_transfer#(T)        axi_gen_write_transfer_t;
  xil_axi_generic_queue_container #(axi_gen_write_transfer_t)   xfer_q;
  xil_axi_uint                                                  p_id;


  /*
    Function: new
    Constructor to set p_id and construct a class of xil_axi_generic_queue_container 
  */
  function new(input xil_axi_uint         id = 0);
    ///////////////////////////////////////////////////////////////////////////
    //Create queue container
    this.p_id = id;
    xfer_q = new;
  endfunction

 /*
  Function: clean
  Clean xfer_q of AXI Generic write transaction queue
 */
  function void clean();
    xfer_q.clean();
  endfunction

 /*
  Function: free
  Free xfer_q of AXI Generic write transaction queue
 */
  function void free();
    xfer_q.free();
  endfunction

  protected function axi_gen_write_transfer_t get_first_no_data_phase();
    axi_gen_write_transfer_t td;
    ///////////////////////////////////////////////////////////////////////////
    //Look through the QUEUE for
    for (int i = 0; i < this.xfer_q.get_num_entries(); i++) begin
      td = this.xfer_q.q[i];
      if (td.is_data_phase_complete() == 1'b0) begin
        return(td);
      end
    end
    ///////////////////////////////////////////////////////////////////////////
    //If you got here all of the transactions are in the address phase.
    ///////////////////////////////////////////////////////////////////////////
    //Create transaction descriptor
    td = new(this.p_id);
    ///////////////////////////////////////////////////////////////////////////
    //Push the newly created TD on the transfer queue
    xfer_q.push_back(td);
    return(td);
  endfunction

  /*
   Function: get_first_no_resp_phase
   Returns the first transfer with transaction state is P_WRT_RESP_PHASE_COMPLETE
  */
  function axi_gen_write_transfer_t get_first_no_resp_phase();
    integer i;
    axi_gen_write_transfer_t td;
    ///////////////////////////////////////////////////////////////////////////
    //Look through the QUEUE for
    for (i = 0; i < this.xfer_q.get_num_entries(); i++) begin
      td = this.xfer_q.q[i];
      if (td.is_resp_phase_complete() == 1'b0) begin
        return(td);
      end
    end
    assert(i == this.xfer_q.get_num_entries()) else begin
      `xil_fatal("AXI_WRITE_XFER", $sformatf("ID=0x%x with no RESP Phase", this.p_id))
    end
    return(td);
  endfunction

  /*
   Function: get_first_no_resp_inflight
   Returns the first transfer with transaction state is P_WRT_RESP_INFLIGHT
  */
  function axi_gen_write_transfer_t get_first_no_resp_inflight();
    integer i;
    axi_gen_write_transfer_t td;
    ///////////////////////////////////////////////////////////////////////////
    //Look through the QUEUE for
    for (i = 0; i < this.xfer_q.get_num_entries(); i++) begin
      td = this.xfer_q.q[i];
      if (td.is_resp_inflight() == 1'b0) begin
        return(td);
      end
    end
    assert(i == this.xfer_q.get_num_entries()) else begin
      `xil_fatal("AXI_WRITE_XFER", $sformatf("ID=0x%x with no ADDR Phase", this.p_id))
    end
    return(td);
  endfunction


  /*
   Function: get_first_no_addr_phase
   Returns the first transfer with transaction state is P_WRT_ADDR_PHASE_COMPLETE
  */
  function axi_gen_write_transfer_t get_first_no_addr_phase();
    axi_gen_write_transfer_t td;
    ///////////////////////////////////////////////////////////////////////////
    //Look through the QUEUE for
    for (int i = 0; i < this.xfer_q.get_num_entries(); i++) begin
      td = this.xfer_q.q[i];
      if (td.is_addr_phase_complete() == 1'b0) begin
        return(td);
      end
    end
    ///////////////////////////////////////////////////////////////////////////
    //If you got here all of the transactions are in the address phase.
    ///////////////////////////////////////////////////////////////////////////
    //Create transaction descriptor
    td = new(this.p_id);
    ///////////////////////////////////////////////////////////////////////////
    //Push the newly created TD on the transfer queue
    xfer_q.push_back(td);
    return(td);
  endfunction

  /*
   Function: push_back
   Push axi_gen_write_transfer_t item into xfer_q of AXI Generic write transaction queue
  */
  function void push_back(input axi_gen_write_transfer_t item);
    xfer_q.push_back(item);
  endfunction

  /*
   Function: pop_front
   Returns the first axi_gen_write_transfer_t item from xfer_q of AXI Generic write transaction queue
  */
  function axi_gen_write_transfer_t pop_front();
    axi_gen_write_transfer_t td;
    td = this.xfer_q.pop_front();
    return(td);
  endfunction

  /*
   Function: get_num_entries
   Returns number of entries of xfer_q of AXI Generic write transaction queue
  */
  function xil_axi_uint         get_num_entries();
    return(this.xfer_q.get_num_entries());
  endfunction

endclass : axi_generic_write_transaction_queue

/*
  Class: axi_ready_gen
  AXI Ready generation object
*/
///////////////////////////////////////////////////////////////////////////
//Ready generation class
class axi_ready_gen extends xil_sequence_item;
  protected xil_axi_uint                      max_low_time = 5;
  protected xil_axi_uint                      min_low_time = 0;
  protected xil_axi_uint                      low_time = 2;
  rand xil_axi_uint                           rand_low_time = 2;

  protected xil_axi_uint                      max_high_time = 5;
  protected xil_axi_uint                      min_high_time = 0;
  protected xil_axi_uint                      high_time = 5;
  rand xil_axi_uint                           rand_high_time = 5;

  protected xil_axi_uint                      max_event_count = 1;
  protected xil_axi_uint                      min_event_count = 1;
  protected xil_axi_uint                      event_count = 1;
  rand xil_axi_uint                           rand_event_count = 1;

  protected xil_axi_uint                      event_cycle_count_reset = 2000;
  protected xil_axi_ready_gen_policy_t        ready_policy = XIL_AXI_READY_GEN_SINGLE;
  rand xil_axi_ready_rand_policy_t            ready_rand_policy = XIL_AXI_READY_RAND_SINGLE;
  protected xil_axi_boolean_t                 use_variable_ranges = XIL_AXI_FALSE;

  ///////////////////////////////////////////////////////////////////////////
  //Constructor
  /*
    Function: new
    Constructor to create a new AXI ready generation
  */
  function new(input string name = "unnamed_axi_ready_gen");
    super.new(name);
  endfunction : new

  /*
   Function: reset_to_defaults
   Reset all variables in ready generation to default value
  */
  virtual function void reset_to_defaults();
    this.max_low_time = 5;
    this.min_low_time = 0;

    this.max_high_time = 5;
    this.min_high_time = 0;

    this.max_event_count = 1;
    this.min_event_count = 1;

    this.event_cycle_count_reset = 2000;
    this.ready_policy = XIL_AXI_READY_GEN_SINGLE;
    this.ready_rand_policy = XIL_AXI_READY_RAND_SINGLE;
    this.event_count = 1;
    this.high_time = 5;
    this.low_time = 2;
    this.rand_event_count = 1;
    this.rand_high_time = 5;
    this.rand_low_time = 1;
    this.use_variable_ranges = XIL_AXI_FALSE;
  endfunction : reset_to_defaults

  /*
    Function:  copy
    Copies the contents of the input ready generation to the current ready generation
  */
  function void copy(axi_ready_gen rhs);
    this.max_low_time             =  rhs.max_low_time           ;
    this.min_low_time             =  rhs.min_low_time           ;
    this.max_high_time            =  rhs.max_high_time          ;
    this.min_high_time            =  rhs.min_high_time          ;
    this.max_event_count          =  rhs.max_event_count        ;
    this.min_event_count          =  rhs.min_event_count        ;
    this.event_cycle_count_reset  =  rhs.event_cycle_count_reset;
    this.ready_policy             =  rhs.ready_policy           ;
    this.low_time                 =  rhs.low_time               ;
    this.high_time                =  rhs.high_time              ;
    this.event_count              =  rhs.event_count            ;
    this.ready_rand_policy        =  rhs.ready_rand_policy      ;
    this.rand_event_count         =  rhs.rand_event_count       ;
    this.rand_high_time           =  rhs.rand_high_time         ;
    this.rand_low_time            =  rhs.rand_low_time          ;
    if (rhs.get_use_variable_ranges() == XIL_AXI_TRUE) begin
      this.set_use_variable_ranges();
    end else begin
      this.clr_use_variable_ranges();
    end
  endfunction : copy

  /*
    Function: my_clone
    Clones the current ready generation and returns a handle to the new generation
  */
  virtual function axi_ready_gen my_clone ();
    axi_ready_gen           my_obj;
    my_obj = new( this.get_name());

    my_obj.set_id_info(this);
    my_obj.copy(this);
    return(my_obj);
  endfunction : my_clone

  /*
    Function: do_print
    Print Ready information of the ready generation
  */
  virtual function void do_print(xil_printer printer);
    super.do_print(printer);
    printer.print_string("Policy",  $sformatf("%s", this.ready_policy.name()));
    if (this.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM) begin
      printer.print_string("Random Policy",  $sformatf("%s", this.ready_rand_policy.name()));
    end
    printer.print_string("Use Variable Ranges",  $sformatf("%s", this.use_variable_ranges.name()));

    printer.print_string("Max Low Time",  $sformatf("%d", this.max_low_time));
    printer.print_string("Min Low Time",  $sformatf("%d", this.min_low_time));
    printer.print_string("Max High Time",  $sformatf("%d", this.max_high_time));
    printer.print_string("Min High Time",  $sformatf("%d", this.min_high_time));
    printer.print_string("Max Event Count",  $sformatf("%d", this.max_event_count));
    printer.print_string("Min Event Count",  $sformatf("%d", this.min_event_count));
    printer.print_string("Event Cycle Count Reset",  $sformatf("%d", this.event_cycle_count_reset));
    printer.print_string("Low Time",  $sformatf("%d", this.get_low_time()));
    printer.print_string("High Time",  $sformatf("%d", this.get_high_time()));
    printer.print_string("Event Count",  $sformatf("%d", this.get_event_count()));
  endfunction : do_print

  /*
    Function: set_use_variable_ranges
    Sets the use of the variable ranges when the policy of ready generation is not RANDOM
  */
  virtual function void set_use_variable_ranges();
    this.use_variable_ranges = XIL_AXI_TRUE;
  endfunction : set_use_variable_ranges

  /*
    Function: set_use_variable_ranges
    Clears the use of the variable ranges when the policy of ready generation is not RANDOM
  */
  virtual function void clr_use_variable_ranges();
    this.use_variable_ranges = XIL_AXI_FALSE;
  endfunction : clr_use_variable_ranges

  /*
    Function: get_use_variable_ranges
    Returns the current state of the variable range use feature.
  */
  virtual function xil_axi_boolean_t get_use_variable_ranges();
    return(this.use_variable_ranges);
  endfunction :get_use_variable_ranges

  /*
    Function: set_ready_policy
    Sets the policy of ready generation
  */
  virtual function void set_ready_policy(input xil_axi_ready_gen_policy_t value);
    this.ready_policy = value;
  endfunction : set_ready_policy

  /*
    Function: get_ready_policy
    Returns the current ready generation policy of the ready generation
  */
  virtual function xil_axi_ready_gen_policy_t get_ready_policy();
    return(this.ready_policy);
  endfunction :get_ready_policy

  /*
   Function: set_event_cycle_count_reset
   Sets event_cycle_count_reset value of ready generation
  */
  virtual function void set_event_cycle_count_reset(input xil_axi_uint value);
    this.event_cycle_count_reset = value;
  endfunction

  /*
   Function: get_event_cycle_count_reset
   Returns the current event_cycle_count_reset of the ready generation
  */
  virtual function xil_axi_uint get_event_cycle_count_reset();
    return this.event_cycle_count_reset;
  endfunction

  /*
    Function: get_low_time_range
    Returns min_low_time and max_low_time of the ready generation
  */
  virtual function void get_low_time_range(
    output xil_axi_uint min,
    output xil_axi_uint max
  );
    min = this.min_low_time;
    max = this.max_low_time;
  endfunction : get_low_time_range

  /*
    Function: set_low_time_range
    Sets min_low_time and max_low_time of the ready generation
  */
  virtual function void set_low_time_range(
    input xil_axi_uint min,
    input xil_axi_uint max
  );
    if (min > max) begin
      `xil_fatal(this.get_name(), $sformatf("LOW_TIME: Attempted to set the max (%d) value lower than the min (%d)", max, min))
    end
    this.min_low_time = min;
    this.max_low_time = max;
  endfunction : set_low_time_range

  /*
    Function: get_low_time
    Returns low time of the current ready generation
  */
  virtual function xil_axi_uint get_low_time();
    if ((this.get_use_variable_ranges() == XIL_AXI_TRUE) || (this.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM)) begin
      return (this.rand_low_time);
    end else begin
      return (this.low_time);
    end
  endfunction : get_low_time

  /*
    Function: set_low_time
    Sets the low time of the ready generation
  */
  virtual function void set_low_time(input xil_axi_uint updated);
    this.low_time = updated;
  endfunction : set_low_time

  /*
    Function: get_high_time_range
    Returns min_high_time and max_high_time of the ready generation
  */
  virtual function void get_high_time_range(output xil_axi_uint min,
                           output xil_axi_uint max);
    min = this.min_high_time;
    max = this.max_high_time;
  endfunction : get_high_time_range

  /*
    Function: set_high_time_range
    Sets min_high_time and max_high_time of the ready generation
  */
  virtual function void set_high_time_range(input xil_axi_uint min,
                                   input xil_axi_uint max);
    if (min <1) begin
      `xil_fatal(this.get_name(), $sformatf("HIGH_TIME: Attempted to set the min(%d) value smaller than 1",min))
    end else if (min > max) begin
      `xil_fatal(this.get_name(), $sformatf("HIGH_TIME: Attempted to set the max (%d) value lower than the min (%d)", max, min))
    end else begin   
      this.min_high_time = min;
      this.max_high_time = max;
    end  
  endfunction : set_high_time_range

  /*
    Function: get_high_time
    Returns high time of the ready generation
  */
  virtual function xil_axi_uint get_high_time();
    if ((this.get_use_variable_ranges() == XIL_AXI_TRUE) || (this.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM)) begin
      return (this.rand_high_time);
    end else begin
      return (this.high_time);
    end
  endfunction : get_high_time

  /*
    Function: set_high_time
    Sets the high time of the ready generation
  */
  virtual function void set_high_time(input xil_axi_uint updated);
    if (updated <1) begin
      `xil_fatal(this.get_name(), $sformatf("HIGH_TIME: Attempted to set high time (%d) smaller than 1",updated))
    end else begin  
      this.high_time = updated;
    end  
  endfunction : set_high_time

  /*
    Function: get_event_count_range
    Returns min_event_count and max_event_count of the ready generation
  */
  virtual function void get_event_count_range(output xil_axi_uint min,
                             output xil_axi_uint max);
    min = this.min_event_count;
    max = this.max_event_count;
  endfunction

   /*
    Function: set_event_count_range
    Sets min_event_count and max_event_count of the ready generation
  */
  virtual function void set_event_count_range(input xil_axi_uint min,
                                      input xil_axi_uint max);
    if (min <1) begin
      `xil_fatal(this.get_name(), $sformatf("EVENT_COUNT: Attempted to set the min(%d) event smaller than 1",min))
    end else if (min > max) begin
      `xil_fatal(this.get_name(), $sformatf("EVENT_COUNT: Attempted to set the max (%d) event lower than the min (%d)", max, min))
    end else begin   
      this.min_event_count = min;
      this.max_event_count = max;
    end   
  endfunction

  /*
    Function: get_event_count
    Returns event_count of the ready generation
  */
  virtual function xil_axi_uint get_event_count();
    if ((this.get_use_variable_ranges() == XIL_AXI_TRUE) || (this.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM)) begin
      return (this.rand_event_count);
    end else begin
      return (this.event_count);
    end
  endfunction : get_event_count

  /*
    Function: set_event_count
    Sets the number of events that ready stays at high
  */
  virtual function void set_event_count(input xil_axi_uint in);
    if (in <1) begin
      `xil_fatal(this.get_name(), $sformatf("EVENT_COUNT: Attempted to set event count (%d) smaller than 1",in))
    end else begin  
      this.event_count = in;
    end  
  endfunction : set_event_count

/*
  Function : get_ready_rand_policy
  Returns ready_rand_policy of the ready generation
  
*/
  virtual function xil_axi_ready_rand_policy_t get_ready_rand_policy();
    return(this.ready_rand_policy);
  endfunction : get_ready_rand_policy

  constraint c_low_time { rand_low_time inside {[min_low_time:max_low_time]};}
  constraint c_high_time { rand_high_time inside {[min_high_time:max_high_time]};}
  constraint c_event_count { rand_event_count inside {[min_event_count:max_event_count]};}

  constraint c_rand_policy {
    ready_rand_policy dist {
      XIL_AXI_READY_RAND_SINGLE              :/ 30,
      XIL_AXI_READY_RAND_OSC                 :/ 15,
      XIL_AXI_READY_RAND_EVENTS              :/ 10,
      XIL_AXI_READY_RAND_AFTER_VALID_SINGLE  :/ 20,
      XIL_AXI_READY_RAND_AFTER_VALID_OSC     :/ 15,
      XIL_AXI_READY_RAND_AFTER_VALID_EVENTS  :/ 10
    };
  }
  /*
   Function: cheap_random
   Generate simplified randomization of ready class when user define XIL_DO_NOT_USE_ADV_RANDOMIZATION
  */
  virtual function void cheap_random();
    xil_axi_uint dice;
    if ((this.get_use_variable_ranges() == XIL_AXI_TRUE) || (this.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM)) begin
      if (this.max_event_count == this.min_event_count) begin
        this.rand_event_count = this.min_event_count;
      end else begin
        this.rand_event_count = ($urandom() % (this.max_event_count - this.min_event_count)) + this.min_event_count;
      end
      if (this.max_low_time == this.min_low_time) begin
        this.rand_low_time = this.min_low_time;
      end else begin
        this.rand_low_time = ($urandom() % (this.max_low_time - this.min_low_time)) + this.min_low_time;
      end
      if (this.max_low_time == this.min_low_time) begin
        this.rand_high_time = this.min_high_time;
      end else begin
        this.rand_high_time = ($urandom() % (this.max_high_time - this.min_high_time)) + this.min_high_time;
      end
      dice = ($urandom() % 6);
      case (dice)
        0: this.ready_rand_policy = XIL_AXI_READY_RAND_SINGLE;
        1: this.ready_rand_policy = XIL_AXI_READY_RAND_OSC;
        2: this.ready_rand_policy = XIL_AXI_READY_RAND_AFTER_VALID_SINGLE;
        3: this.ready_rand_policy = XIL_AXI_READY_RAND_AFTER_VALID_OSC;
        4: this.ready_rand_policy = XIL_AXI_READY_RAND_AFTER_VALID_EVENTS;
        5: this.ready_rand_policy = XIL_AXI_READY_RAND_EVENTS;
      endcase
    end
  endfunction : cheap_random

endclass : axi_ready_gen

typedef axi_ready_gen         axi_ready_gen_t;

/*
  Class: axi_vif_mem_proxy
  AXI VIF Proxy object
*/
class axi_vif_mem_proxy `AXI_PARAM_DECL extends xil_component;

  ///////////////////////////////////////////////////////////////////////////
  // AXI interface -- call assign_vi to connect
  virtual interface axi_vip_v1_0_1_if `AXI_PARAM_ORDER m_vif ;
  protected xil_axi_vif_dummy_drive_t   dummy_drive_type = XIL_AXI_VIF_DRIVE_NONE;
  protected xil_axi_vif_axi_version_t   axi_version = XIL_VERSION_AXI4;
  time                                  hold_time = 1ps;
  protected xil_axi_uint                clk_edge_counter = 0;
  protected time                        clk_edge_time;

  rand xil_axi_ulong                    xaddr;
  rand xil_axi_uint                     xid;
  rand xil_axi_len_t                    xlen;
  rand xil_axi_size_t                   xsize;
  rand xil_axi_burst_t                  xburst;
  rand xil_axi_lock_t                   xlock;
  rand xil_axi_cache_t                  xcache;
  rand xil_axi_prot_t                   xprot;
  rand xil_axi_region_t                 xregion;
  rand xil_axi_qos_t                    xqos;
  rand xil_axi_resp_t                   xresp;
  rand bit  [C_AXI_RDATA_WIDTH-1:0]     xrdata;
  rand bit  [C_AXI_WDATA_WIDTH-1:0]     xwdata;
  rand bit  [(C_AXI_WDATA_WIDTH/8)-1:0] xstrb;
  rand bit                              xlast;

  /*
   Function: wait_aclks
   Waits specified amount of posedge of aclk
  */
  virtual task wait_aclks(input xil_axi_uint cnt);
    if (cnt > 0) begin
      repeat (cnt) wait_posedge_aclk;
    end
  endtask

`ifdef XILINX_SIMULATOR
  /*
   Function: wait_posedge_aclks
   Waits posedge of ACLK of m_vif 
  */
  virtual task wait_posedge_aclk();
    @(posedge m_vif.ACLK iff (m_vif.ACLKEN_O));
  endtask

  /*
   Function: wait_posedge_aclk_with_hold
   Waits posedge of ACLK of m_vif and then wait hold_time 
  */
  virtual task wait_posedge_aclk_with_hold();
    @(posedge m_vif.ACLK iff (m_vif.ACLKEN_O));
    #this.hold_time;
  endtask

  /*
   Function: wait_negedge_aclk
   Waits negedge of ACLK of m_vif 
  */
  virtual task wait_negedge_aclk();
    @(negedge m_vif.ACLK iff (m_vif.ACLKEN_O));
  endtask

  /*
   Function: wait_areset_deassert
   Waits areset to be deasserted
  */
  virtual task wait_areset_deassert();
    if (m_vif.ARESET_N == 1'b0) begin
      @(posedge m_vif.ARESET_N_O);
    end
  endtask

`else
  virtual task wait_posedge_aclk();
    @(m_vif.cb iff (m_vif.cb.ACLKEN));
  endtask

  virtual task wait_posedge_aclk_with_hold();
    @(m_vif.cb iff (m_vif.cb.ACLKEN));
    #this.hold_time;
  endtask

  virtual task wait_negedge_aclk();
    @(negedge m_vif.ACLK iff (m_vif.cb.ACLKEN));
  endtask

  virtual task wait_areset_deassert();
    if (m_vif.ARESET_N == 1'b0) begin
      @(posedge m_vif.cb.ARESET_N);
    end
  endtask
`endif

  /*
   Function: is_aclk_high
   Returns TRUE if the aclk is in the HIGH phase of the cycle. It does not look at the ACLKEN to determine if this an active clock.
  */
  virtual function xil_axi_boolean_t is_aclk_high();
    return((m_vif.ACLK == 1) ? XIL_AXI_TRUE : XIL_AXI_FALSE);
  endfunction : is_aclk_high

  /*
   Function: is_aclk_low
   Returns TRUE if the aclk is in the LOW phase of the cycle. It does not look at the ACLKEN to determine if this an active clock.
  */
  virtual function xil_axi_boolean_t is_aclk_low();
    return((m_vif.ACLK == 0) ? XIL_AXI_TRUE : XIL_AXI_FALSE);
  endfunction : is_aclk_low

  /*
   Function:  get_drive_x
   Returns 1 if dummy_drive_type is XIL_AXI_VIF_DRIVE_X, else returns 0
  */
  virtual function xil_axi_boolean_t get_drive_x();
    return((this.dummy_drive_type == XIL_AXI_VIF_DRIVE_X) ? XIL_AXI_TRUE : XIL_AXI_FALSE);
  endfunction

  /*
   Function: cheap_random
   Generate simplified randomization of transaction when user defines XIL_DO_NOT_USE_ADV_RANDOMIZATION
  */
  virtual function void cheap_random();
    for (xil_axi_uint i = 0; i < 2; i++) begin
      xaddr = xaddr << 32;
      xaddr[31:0] = $urandom();
    end
    xid = $urandom();
    xlen = xil_axi_len_t'($urandom());
    xsize = xil_axi_size_t'($urandom());
    xburst = xil_axi_burst_t'($urandom());
    xlock = xil_axi_lock_t'($urandom());
    xcache = xil_axi_cache_t'($urandom());
    xprot = xil_axi_prot_t'($urandom());
    xregion = xil_axi_region_t'($urandom());
    xqos = xil_axi_qos_t'($urandom());
    xresp = xil_axi_resp_t'($urandom());
    xlast = bit'($urandom());
    for (xil_axi_uint i = 0; i < C_AXI_RDATA_WIDTH/32; i++) begin
      xrdata = xrdata << 32;
      xrdata[31:0] = $urandom();
    end
    for (xil_axi_uint i = 0; i < C_AXI_WDATA_WIDTH/32; i++) begin
      xwdata = xwdata << 32;
      xwdata[31:0] = $urandom();
    end
    for (xil_axi_uint i = 0; i < ((C_AXI_WDATA_WIDTH/8)+31)/32; i++) begin
      xstrb = xstrb << 32;
      xstrb = $urandom();
    end
  endfunction : cheap_random

  /*
   Function:   get_dummy_drive_type
   Returns dummy_drive_type of m_vif
 */
  virtual function xil_axi_vif_dummy_drive_t get_dummy_drive_type(input xil_axi_cmd_t d);
    xil_axi_vif_dummy_drive_t temp;
    xil_axi_uint              choice;
    if (((d == XIL_AXI_READ) && (m_vif.supports_read == 0)) || ((d == XIL_AXI_WRITE) && (m_vif.supports_write == 0))) begin
      return(XIL_AXI_VIF_DRIVE_Z);
    end else if (this.dummy_drive_type == XIL_AXI_VIF_DRIVE_NOISE) begin
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        randcase
          50 : temp = XIL_AXI_VIF_DRIVE_NOISE;
          40 : temp = XIL_AXI_VIF_DRIVE_X;
          10 : temp = XIL_AXI_VIF_DRIVE_Z;
        endcase
     `else
        choice = $urandom() % 3;
        case(choice)
          0 : temp = XIL_AXI_VIF_DRIVE_NOISE;
          1 : temp = XIL_AXI_VIF_DRIVE_X;
          2 : temp = XIL_AXI_VIF_DRIVE_Z;
        endcase
      `endif
      return(temp);
    end else begin
      return(this.dummy_drive_type);
    end
  endfunction

  /*
   Function: put_rdata
   Puts specified beat into READ data Channel
  */
  virtual task put_rdata(inout axi_transaction transfer, input xil_axi_uint beat_num);
    xil_axi_payload_byte payload [];
    reg   [C_AXI_RDATA_WIDTH-1:0] data;
    reg   [C_AXI_RUSER_WIDTH-1:0] user;
    xil_axi_uint beat_aligned_offset;

    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      VIF_DRIVE_NOISE: assert(this.randomize());
    `else
      this.cheap_random();
    `endif
    ///////////////////////////////////////////////////////////////////////////
    //Get the beat
    transfer.get_data_beat_unpacked(transfer.get_beat_index(), payload);

    beat_aligned_offset = transfer.get_burst_byte_offset(beat_num);
    if (this.get_axi_version() != XIL_VERSION_LITE) begin
      if (C_AXI_RUSER_WIDTH == 0) begin
        m_vif.ruser <= 1'bz;
      end else begin
        user = transfer.get_ruser(transfer.get_beat_index());
        m_vif.ruser <= user;
      end
      m_vif.rlast <= (beat_num == transfer.get_len());
      if (C_AXI_RID_WIDTH > 0) begin
        m_vif.rid <= transfer.get_id();
      end
    end
    m_vif.rresp <= transfer.get_rresp(transfer.get_beat_index());
    case(this.get_dummy_drive_type(XIL_AXI_READ))
      XIL_AXI_VIF_DRIVE_NONE : begin
        data = {C_AXI_RDATA_WIDTH{1'b0}};
      end
      XIL_AXI_VIF_DRIVE_X : begin
        data = {C_AXI_RDATA_WIDTH{1'bx}};
      end
      XIL_AXI_VIF_DRIVE_Z : begin
        data = {C_AXI_RDATA_WIDTH{1'bz}};
      end
      XIL_AXI_VIF_DRIVE_NOISE : begin
        data = xrdata;
      end
    endcase
    for (int j=(payload.size()-1);j >= 0; j--) begin
      data[beat_aligned_offset*8 + ((j+1)*8) -1 -: 8] = payload[j];
    end
    m_vif.rdata <= data;
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Disassemble the beat and drive it onto the WDATA bus.
  /*
   Function: put_wdata
   Puts specified beat into Write Data Channel
  */
  virtual task put_wdata(inout axi_transaction transfer, input xil_axi_uint beat_num);
    xil_axi_write_beat beat;
    xil_axi_payload_byte payload [];
    reg   [C_AXI_WDATA_WIDTH-1:0]    drv_data;
    reg   [C_AXI_WDATA_WIDTH/8-1:0]  drv_strb;
    bit strb [];
    xil_axi_uint beat_aligned_offset;
    xil_axi_uint byte_offset;
    reg   [C_AXI_WUSER_WIDTH-1:0]    user;
    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      VIF_DRIVE_NOISE: assert(this.randomize());
    `else
      this.cheap_random();
    `endif

    beat = new;

    ///////////////////////////////////////////////////////////////////////////
    //Get the beat
    transfer.get_strb_beat_unpacked(transfer.get_beat_index(), strb);
    transfer.get_data_beat_unpacked(transfer.get_beat_index(), payload);

    beat_aligned_offset = transfer.get_burst_byte_offset(beat_num);
    beat.data = new[payload.size()] (payload);
    beat.strb = new[strb.size()] (strb);
    ///////////////////////////////////////////////////////////////////////////
    //Only drive if not LITE
    if (this.get_axi_version() != XIL_VERSION_LITE) begin
      if (C_AXI_WUSER_WIDTH == 0) begin
        m_vif.wuser <= 1'bz;
      end else begin
        user = transfer.get_wuser(transfer.get_beat_index());
        m_vif.wuser <= user;
      end

      if (beat_num == transfer.get_len()) begin
        m_vif.wlast <= 1;
      end else begin
        m_vif.wlast <= 0;
      end
    end
    if ((this.get_axi_version() == XIL_VERSION_AXI3) && (C_AXI_WID_WIDTH > 0)) begin
      m_vif.wid <= transfer.get_id();
    end

    case(this.get_dummy_drive_type(XIL_AXI_WRITE))
      XIL_AXI_VIF_DRIVE_NONE : begin
        drv_data = {C_AXI_WDATA_WIDTH{1'b0}};
      end
      XIL_AXI_VIF_DRIVE_X : begin
        drv_data = {C_AXI_WDATA_WIDTH{1'bx}};
      end
      XIL_AXI_VIF_DRIVE_Z : begin
        drv_data = {C_AXI_WDATA_WIDTH{1'bz}};
      end
      XIL_AXI_VIF_DRIVE_NOISE : begin
        drv_data = xwdata;
      end
    endcase
    drv_strb = {C_AXI_WDATA_WIDTH/8{1'b0}};
    for (int j=(beat.data.size()-1);j >= 0; j--) begin
      drv_data[beat_aligned_offset*8 + ((j+1)*8) -1 -: 8] = beat.data[j];
      drv_strb[beat_aligned_offset + j -: 1] = beat.strb[j];
    end
    m_vif.wdata <= drv_data;
    m_vif.wstrb <= drv_strb;
  endtask

  /*
    Function: new
    Constructor to create a new axi vif proxy and set protocol version
  */
  function new(string name = "unnamed_axi_vif_mem_proxy");
    super.new(name);
    if (C_AXI_PROTOCOL == 0) begin
      this.set_axi_version(XIL_VERSION_AXI4);
    end else if (C_AXI_PROTOCOL == 1) begin
      this.set_axi_version(XIL_VERSION_AXI3);
    end else if(C_AXI_PROTOCOL == 2) begin
      this.set_axi_version(XIL_VERSION_LITE);
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("PROTOCOL =%0d is out of range ", C_AXI_PROTOCOL))
    end
  endfunction // new

  /*
   Function:  get_axi_version
   Returns axi_version
 */
  virtual function xil_axi_vif_axi_version_t get_axi_version();
    return(this.axi_version);
  endfunction

  /*
   Function:  set_axi_version
   Sets axi_version]
  */
  virtual function void set_axi_version(input xil_axi_vif_axi_version_t update);
    this.axi_version = update;
  endfunction

  /*
   Function:  get_axi_version_name
   Returns axi_version's name
  */
  virtual function string get_axi_version_name();
    return(this.axi_version.name());
  endfunction

   /*
    Function: set_drive_x
   Sets dummy_drive_type to be XIL_AXI_VIF_DRIVE_X
  */
  virtual function void set_drive_x();
    this.dummy_drive_type = XIL_AXI_VIF_DRIVE_X;
  endfunction

  /*
   Function: set_dummy_drive_type
   Sets dummy_drive_type
  */
  virtual function void set_dummy_drive_type(input xil_axi_vif_dummy_drive_t inp);
    this.dummy_drive_type = inp;
  endfunction

  /*
   Function: assign_vi
   Assigns m_vif 
  */
  function void assign_vi (virtual interface axi_vip_v1_0_1_if `AXI_PARAM_ORDER vif) ;
    this.m_vif = vif ;
  endfunction

  /*
    Function: run_phase
    Start control processes for operation
  */
  task run_phase();
    if (this.get_is_active() == XIL_AXI_FALSE) begin
      this.set_is_active();
      forever begin : CLK
        this.wait_posedge_aclk();
        this.clk_edge_counter++;
        this.clk_edge_time = $time;
      end
    end
  endtask : run_phase

  /*
    Function: get_current_clk_count
    Returns clk_edge_counter
  */
  function xil_axi_uint get_current_clk_count();
    return(this.clk_edge_counter);
  endfunction : get_current_clk_count

  /*
    Function: get_current_edge_time
    Returns clk_edge_time
  */
  function time get_current_edge_time();
    return(this.clk_edge_time);
  endfunction : get_current_edge_time

  /*
    Function:   put_aw_noise
    Puts noise on Write command channel
  */
  virtual function void put_aw_noise();
    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      VIF_DRIVE_NOISE: assert(this.randomize());
    `else
      this.cheap_random();
    `endif
    case(this.get_dummy_drive_type(XIL_AXI_WRITE))
      XIL_AXI_VIF_DRIVE_NONE : begin
        m_vif.awaddr <= {C_AXI_ADDR_WIDTH{1'b0}};
        m_vif.awprot <= XIL_AXI_PROT_NORMAL_ACCESS_MASK;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.awid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'b0}};
          m_vif.awlen <= 8'h00;
          m_vif.awsize <= 3'h0;
          m_vif.awburst <= 2'h0;
          m_vif.awlock <= XIL_AXI_ALOCK_NOLOCK;
          m_vif.awcache <= XIL_AXI_CACHE_DEVICE_NONBUFFERABLE;
          m_vif.awregion <= 4'h0;
          m_vif.awqos <= 4'h0;
          m_vif.awuser <= (C_AXI_AWUSER_WIDTH == 0) ? 1'bz : {((C_AXI_AWUSER_WIDTH == 0) ? 1 : C_AXI_AWUSER_WIDTH){1'b0}};
        end
      end
      XIL_AXI_VIF_DRIVE_X : begin
        m_vif.awaddr <= {C_AXI_ADDR_WIDTH{1'bx}};
        m_vif.awprot <= 'hx;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.awid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'bx}};
          m_vif.awlen <= 8'hxx;
          m_vif.awsize <= 3'hx;
          m_vif.awburst <= 2'hx;
          m_vif.awlock <= 2'bxx;
          m_vif.awcache <= 'hx;
          m_vif.awregion <= 4'hx;
          m_vif.awqos <= 4'hx;
          m_vif.awuser <= (C_AXI_AWUSER_WIDTH == 0) ? 1'bz : {((C_AXI_AWUSER_WIDTH == 0) ? 1 : C_AXI_AWUSER_WIDTH){1'bx}};
        end
      end
      XIL_AXI_VIF_DRIVE_Z : begin
        m_vif.awaddr <= {C_AXI_ADDR_WIDTH{1'bz}};
        m_vif.awprot <= 'hz;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.awid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'bz}};
          m_vif.awlen <= 8'hzz;
          m_vif.awsize <= 3'hz;
          m_vif.awburst <= 2'hz;
          m_vif.awlock <= 2'bzz;
          m_vif.awcache <= 'hz;
          m_vif.awregion <= 4'hz;
          m_vif.awqos <= 4'hz;
          m_vif.awuser <= (C_AXI_AWUSER_WIDTH == 0) ? 1'bz : {((C_AXI_AWUSER_WIDTH == 0) ? 1 : C_AXI_AWUSER_WIDTH){1'bz}};
        end
      end
      XIL_AXI_VIF_DRIVE_NOISE : begin
        m_vif.awaddr <= xaddr;
        m_vif.awprot <= xprot;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.awid <= xid;
          m_vif.awlen <= xlen;
          m_vif.awsize <= xsize;
          m_vif.awburst <= xburst;
          m_vif.awlock <= xlock;
          m_vif.awcache <= xcache;
          m_vif.awregion <= xregion;
          m_vif.awqos <= xqos;
          m_vif.awuser <= (C_AXI_AWUSER_WIDTH == 0) ? 1'bz : {((C_AXI_AWUSER_WIDTH == 0) ? 1 : C_AXI_AWUSER_WIDTH){1'bx}};
        end
      end
    endcase
  endfunction

  /*
    Function: put_ar_noise
    Puts noise on read command channel
  */
  virtual function void put_ar_noise();
    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      VIF_DRIVE_NOISE: assert(this.randomize());
    `else
      this.cheap_random();
    `endif
    case(this.get_dummy_drive_type(XIL_AXI_READ))
      XIL_AXI_VIF_DRIVE_NONE : begin
        m_vif.araddr <= {C_AXI_ADDR_WIDTH{1'b0}};
        m_vif.arprot <= XIL_AXI_PROT_NORMAL_ACCESS_MASK;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.arid <= (C_AXI_RID_WIDTH == 0) ? 1'bz : {((C_AXI_RID_WIDTH == 0) ? 1 : C_AXI_RID_WIDTH){1'b0}};
          m_vif.arlen <= 8'h00;
          m_vif.arsize <= 3'h0;
          m_vif.arburst <= 2'h0;
          m_vif.arlock <= XIL_AXI_ALOCK_NOLOCK;
          m_vif.arcache <= XIL_AXI_CACHE_DEVICE_NONBUFFERABLE;
          m_vif.arregion <= 4'h0;
          m_vif.arqos <= 4'h0;
          m_vif.aruser <= (C_AXI_ARUSER_WIDTH == 0) ? 1'bz : {((C_AXI_ARUSER_WIDTH == 0) ? 1 : C_AXI_ARUSER_WIDTH){1'b0}};
        end
      end
      XIL_AXI_VIF_DRIVE_X : begin
        m_vif.araddr <= {C_AXI_ADDR_WIDTH{1'bx}};
        m_vif.arprot <= 'hx;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.arid <= (C_AXI_RID_WIDTH == 0) ? 1'bz : {((C_AXI_RID_WIDTH == 0) ? 1 : C_AXI_RID_WIDTH){1'bx}};
          m_vif.arlen <= 8'hxx;
          m_vif.arsize <= 3'hx;
          m_vif.arburst <= 2'hx;
          m_vif.arlock <= 2'bxx;
          m_vif.arcache <= 'hx;
          m_vif.arregion <= 4'hx;
          m_vif.arqos <= 4'hx;
          m_vif.aruser <= (C_AXI_ARUSER_WIDTH == 0) ? 1'bz : {((C_AXI_ARUSER_WIDTH == 0) ? 1 : C_AXI_ARUSER_WIDTH){1'bx}};
        end
      end
      XIL_AXI_VIF_DRIVE_Z : begin
        m_vif.araddr <= {C_AXI_ADDR_WIDTH{1'bz}};
        m_vif.arprot <= 'hz;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.arid <= (C_AXI_RID_WIDTH == 0) ? 1'bz : {((C_AXI_RID_WIDTH == 0) ? 1 : C_AXI_RID_WIDTH){1'bz}};
          m_vif.arlen <= 8'hzz;
          m_vif.arsize <= 3'hz;
          m_vif.arburst <= 2'hz;
          m_vif.arlock <= 2'bzz;
          m_vif.arcache <= 'hz;
          m_vif.arregion <= 4'hz;
          m_vif.arqos <= 4'hz;
          m_vif.aruser <= (C_AXI_ARUSER_WIDTH == 0) ? 1'bz : {((C_AXI_ARUSER_WIDTH == 0) ? 1 : C_AXI_ARUSER_WIDTH){1'bz}};
        end
      end
      XIL_AXI_VIF_DRIVE_NOISE : begin
        m_vif.araddr <= xaddr;
        m_vif.arprot <= xprot;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.arid <= xid;
          m_vif.arlen <= xlen;
          m_vif.arsize <= xsize;
          m_vif.arburst <= xburst;
          m_vif.arlock <= xlock;
          m_vif.arcache <= xcache;
          m_vif.arregion <= xregion;
          m_vif.arqos <= xqos;
          m_vif.aruser <= (C_AXI_ARUSER_WIDTH == 0) ? 1'bz : {((C_AXI_ARUSER_WIDTH == 0) ? 1 : C_AXI_ARUSER_WIDTH){1'bx}};
        end
      end
    endcase
  endfunction

  /*
    Function: put_w_noise
    Puts noise on write data channel
  */
  virtual function void put_w_noise();
    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      VIF_DRIVE_NOISE: assert(this.randomize());
    `else
      this.cheap_random();
    `endif
    case(this.get_dummy_drive_type(XIL_AXI_WRITE))
      XIL_AXI_VIF_DRIVE_NONE : begin
        m_vif.wdata <= {C_AXI_WDATA_WIDTH{1'b0}};
        m_vif.wstrb <= {(C_AXI_WDATA_WIDTH/8){1'b0}};
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.wlast <= 1'b0;
          m_vif.wuser <= (C_AXI_WUSER_WIDTH == 0) ? 1'bz : {((C_AXI_WUSER_WIDTH == 0) ? 1 : C_AXI_WUSER_WIDTH){1'b0}};
        end
        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          m_vif.wid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'b0}};
        end
      end
      XIL_AXI_VIF_DRIVE_X : begin
        m_vif.wdata <= {C_AXI_WDATA_WIDTH{1'bx}};
        m_vif.wstrb <= {(C_AXI_WDATA_WIDTH/8){1'bx}};
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.wlast <= 1'bx;
          m_vif.wuser <= (C_AXI_WUSER_WIDTH == 0) ? 1'bz : {((C_AXI_WUSER_WIDTH == 0) ? 1 : C_AXI_WUSER_WIDTH){1'bx}};
        end
        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          m_vif.wid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'bx}};
        end
      end
      XIL_AXI_VIF_DRIVE_Z : begin
        m_vif.wdata <= {C_AXI_WDATA_WIDTH{1'bz}};
        m_vif.wstrb <= {(C_AXI_WDATA_WIDTH/8){1'bz}};
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.wlast <= 1'bz;
          m_vif.wuser <= (C_AXI_WUSER_WIDTH == 0) ? 1'bz : {((C_AXI_WUSER_WIDTH == 0) ? 1 : C_AXI_WUSER_WIDTH){1'bz}};
        end
        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          m_vif.wid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'bz}};
        end
      end
      XIL_AXI_VIF_DRIVE_NOISE : begin
        m_vif.wdata <= xwdata;
        m_vif.wstrb <= xstrb;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.wlast <= xlast;
          m_vif.wuser <= (C_AXI_WUSER_WIDTH == 0) ? 1'bz : {((C_AXI_WUSER_WIDTH == 0) ? 1 : C_AXI_WUSER_WIDTH){1'bx}};
        end
        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          m_vif.wid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'bx}};
        end
      end
    endcase
  endfunction

  /*
    Function: put_r_noise
    Puts noise on Read data channel
  */
  virtual function void put_r_noise();
    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      VIF_DRIVE_NOISE: assert(this.randomize());
    `else
      this.cheap_random();
    `endif
    case(this.get_dummy_drive_type(XIL_AXI_READ))
      XIL_AXI_VIF_DRIVE_NONE : begin
        m_vif.rdata <= {C_AXI_RDATA_WIDTH{1'b0}};
        m_vif.rresp <= 2'b00;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.rid <= (C_AXI_RID_WIDTH == 0) ? 1'bz : {((C_AXI_RID_WIDTH == 0) ? 1 : C_AXI_RID_WIDTH){1'b0}};
          m_vif.rlast <= 1'b0;
          m_vif.ruser <= (C_AXI_RUSER_WIDTH == 0) ? 1'bz : {((C_AXI_RUSER_WIDTH == 0) ? 1 : C_AXI_RUSER_WIDTH){1'b0}};
        end
      end
      XIL_AXI_VIF_DRIVE_X : begin
        m_vif.rdata <= {C_AXI_RDATA_WIDTH{1'bx}};
        m_vif.rresp <= 2'bxx;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.rid <= (C_AXI_RID_WIDTH == 0) ? 1'bz : {((C_AXI_RID_WIDTH == 0) ? 1 : C_AXI_RID_WIDTH){1'bx}};
          m_vif.rlast <= 1'bx;
          m_vif.ruser <= (C_AXI_RUSER_WIDTH == 0) ? 1'bz : {((C_AXI_RUSER_WIDTH == 0) ? 1 : C_AXI_RUSER_WIDTH){1'bx}};
        end
      end
      XIL_AXI_VIF_DRIVE_Z : begin
        m_vif.rdata <= {C_AXI_RDATA_WIDTH{1'bz}};
        m_vif.rresp <= 2'bzz;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.rid <= (C_AXI_RID_WIDTH == 0) ? 1'bz : {((C_AXI_RID_WIDTH == 0) ? 1 : C_AXI_RID_WIDTH){1'bz}};
          m_vif.rlast <= 1'bz;
          m_vif.ruser <= (C_AXI_RUSER_WIDTH == 0) ? 1'bz : {((C_AXI_RUSER_WIDTH == 0) ? 1 : C_AXI_RUSER_WIDTH){1'bz}};
        end
      end
      XIL_AXI_VIF_DRIVE_NOISE : begin
        m_vif.rdata <= xrdata;
        m_vif.rresp <= xresp;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.rid <= xid;
          m_vif.rlast <= xlast;
          m_vif.ruser <= (C_AXI_RUSER_WIDTH == 0) ? 1'bz : {((C_AXI_RUSER_WIDTH == 0) ? 1 : C_AXI_RUSER_WIDTH){1'bx}};
        end
      end
    endcase
  endfunction

  /*
    Function: put_b_noise
    Puts noise on Bresp channel
  */
  virtual function void put_b_noise();
    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      VIF_DRIVE_NOISE: assert(this.randomize());
    `else
      this.cheap_random();
    `endif
    case(this.get_dummy_drive_type(XIL_AXI_WRITE))
      XIL_AXI_VIF_DRIVE_NONE : begin
        m_vif.bresp <= 2'b00;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.bid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'b0}};
          m_vif.buser <= (C_AXI_BUSER_WIDTH == 0) ? 1'bz : {((C_AXI_BUSER_WIDTH == 0) ? 1 : C_AXI_BUSER_WIDTH){1'b0}};
        end
      end
      XIL_AXI_VIF_DRIVE_X : begin
        m_vif.bresp <= 2'bxx;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.bid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'bx}};
          m_vif.buser <= (C_AXI_BUSER_WIDTH == 0) ? 1'bz : {((C_AXI_BUSER_WIDTH == 0) ? 1 : C_AXI_BUSER_WIDTH){1'bx}};
        end
      end
      XIL_AXI_VIF_DRIVE_Z : begin
        m_vif.bresp <= 2'bzz;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.bid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : {((C_AXI_WID_WIDTH == 0) ? 1 : C_AXI_WID_WIDTH){1'bz}};
          m_vif.buser <= (C_AXI_BUSER_WIDTH == 0) ? 1'bz : {((C_AXI_BUSER_WIDTH == 0) ? 1 : C_AXI_BUSER_WIDTH){1'bz}};
        end
      end
      XIL_AXI_VIF_DRIVE_NOISE : begin
        m_vif.bresp <= xresp;
        if (this.get_axi_version() != XIL_VERSION_LITE) begin
          m_vif.bid <= xid;
          m_vif.buser <= (C_AXI_BUSER_WIDTH == 0) ? 1'bz : {((C_AXI_BUSER_WIDTH == 0) ? 1 : C_AXI_BUSER_WIDTH){1'bx}};
        end
      end
    endcase
  endfunction

  /*
    Function: reset_aw
    Reset AW channel
  */
  virtual function void reset_aw();
    clr_awvalid();
    put_aw_noise();
  endfunction

  /*
    Function: reset_ar
    Resets AR channel
  */
  virtual function void reset_ar();
    clr_arvalid();
    put_ar_noise();
  endfunction

  /*
    Function: reset_w
    Resets W channel
  */
  virtual function void reset_w();
    clr_wvalid();
    put_w_noise();
  endfunction

  /*
    Function: reset_r
    Resets R channel
  */
  virtual function void reset_r();
    clr_rvalid();
    put_r_noise();
  endfunction

  /*
    Function: reset_b
    Resets B channel
  */
  virtual function void reset_b();
    clr_bvalid();
    put_b_noise();
  endfunction

  /*
    Function:  put_cmd
    Puts write/read commands on Write/Read commands Channel
  */
  virtual function void put_cmd(inout axi_transaction transfer);
    reg   [C_AXI_ARUSER_WIDTH-1:0]  aruser;
    reg   [C_AXI_AWUSER_WIDTH-1:0]  awuser;
    if (transfer.get_cmd_type() == XIL_AXI_READ) begin
      m_vif.araddr   <= transfer.get_addr();
      m_vif.arprot   <= transfer.get_prot();
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        m_vif.arid     <= (C_AXI_RID_WIDTH == 0) ? 1'bz : transfer.get_id();
        m_vif.arlen    <= transfer.get_len();
        m_vif.arsize   <= transfer.get_size();
        m_vif.arburst  <= transfer.get_burst();
        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          m_vif.arlock   <= transfer.get_lock();
        end else begin
          if (transfer.get_lock() == XIL_AXI_ALOCK_NOLOCK) begin
            m_vif.arlock   <= XIL_AXI_ALOCK_NOLOCK;
          end else begin
            m_vif.arlock   <= XIL_AXI_ALOCK_EXCL;
          end
        end
        m_vif.arcache  <= transfer.get_cache();
        m_vif.arregion <= transfer.get_region();
        m_vif.arqos    <= transfer.get_qos();
        if (C_AXI_ARUSER_WIDTH == 0) begin
          m_vif.aruser <= 1'bz;
        end else begin
          aruser = transfer.get_aruser();
          m_vif.aruser <= aruser;
        end
      end
    end else begin
      m_vif.awaddr   <= transfer.get_addr();
      m_vif.awprot   <= transfer.get_prot();
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        m_vif.awid     <= (C_AXI_WID_WIDTH == 0) ? 1'bz : transfer.get_id();
        m_vif.awlen    <= transfer.get_len();
        m_vif.awsize   <= transfer.get_size();
        m_vif.awburst  <= transfer.get_burst();

        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          m_vif.awlock   <= transfer.get_lock();
        end else begin
          if (transfer.get_lock() == XIL_AXI_ALOCK_NOLOCK) begin
            m_vif.awlock   <= XIL_AXI_ALOCK_NOLOCK;
          end else begin
            m_vif.awlock   <= XIL_AXI_ALOCK_EXCL;
          end
        end

        m_vif.awcache  <= transfer.get_cache();
        m_vif.awregion <= transfer.get_region();
        m_vif.awqos    <= transfer.get_qos();
        if (C_AXI_AWUSER_WIDTH == 0) begin
          m_vif.awuser <= 1'bz;
        end else begin
          awuser = transfer.get_awuser();
          m_vif.awuser <= awuser;
        end
      end
    end
  endfunction

  /*
    Function: put_bresp
    Puts transaction information onto BRESP channel
  */
  virtual function void put_bresp(axi_transaction transfer);
    reg   [C_AXI_BUSER_WIDTH-1:0] user;
    m_vif.bresp <= transfer.get_bresp();
    if (this.get_axi_version() != XIL_VERSION_LITE) begin
      m_vif.bid <= (C_AXI_WID_WIDTH == 0) ? 1'bz : transfer.get_id();
      if (C_AXI_BUSER_WIDTH == 0) begin
        m_vif.buser <= 1'bz;
      end else begin
        user = transfer.get_buser();
        m_vif.buser <= user;
      end
    end
  endfunction


  `ifdef XILINX_SIMULATOR
    virtual function xil_axi_cmd_beat get_awcmd();
      xil_axi_cmd_beat cmd;
      cmd = new;
      cmd.dir = XIL_AXI_WRITE;
      cmd.addr = m_vif.AWADDR;
      cmd.prot = m_vif.AWPROT;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_WID_WIDTH == 0) begin
          cmd.id = 1'b0;
        end else begin
          cmd.id = m_vif.AWID;
        end

        cmd.len = m_vif.AWLEN;
        cmd.size = xil_axi_size_t'(m_vif.AWSIZE);
          cmd.burst = xil_axi_burst_t'(m_vif.AWBURST);
        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          cmd.lock = xil_axi_lock_t'(m_vif.AWLOCK);
        end else begin
          if (m_vif.AWLOCK[0] == 1'b0) begin
            cmd.lock = XIL_AXI_ALOCK_NOLOCK;
          end else begin
            cmd.lock = XIL_AXI_ALOCK_EXCL;
          end
        end
        cmd.cache = m_vif.AWCACHE;
        if (C_AXI_AWUSER_WIDTH > 0) begin
          cmd.set_user(C_AXI_AWUSER_WIDTH, m_vif.AWUSER);
        end else begin
          cmd.set_user(0,0);
        end
        cmd.region = m_vif.AWREGION;
        cmd.qos = m_vif.AWQOS;
      end else begin
        cmd.id = 0;
        cmd.len = 0;
        cmd.size = convert_dw_to_axi_size(C_AXI_WDATA_WIDTH);
        cmd.burst = XIL_AXI_BURST_TYPE_INCR;
        cmd.lock = XIL_AXI_ALOCK_NOLOCK;
        cmd.cache = 4'h0;
        cmd.region = 4'h0;
        cmd.qos = 4'h0;
        cmd.set_user(0,1'b0);
      end
      cmd.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(cmd);
    endfunction

    virtual function xil_axi_cmd_beat get_arcmd();
      xil_axi_cmd_beat cmd;
      cmd = new;
      cmd.dir = XIL_AXI_READ;
      cmd.addr = m_vif.ARADDR;
      cmd.prot = m_vif.ARPROT;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_RID_WIDTH == 0) begin
          cmd.id = 1'b0;
        end else begin
          cmd.id = m_vif.ARID;
        end
        cmd.len = m_vif.ARLEN;
        cmd.size = xil_axi_size_t'(m_vif.ARSIZE);
        cmd.burst = xil_axi_burst_t'(m_vif.ARBURST);

        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          cmd.lock = xil_axi_lock_t'(m_vif.ARLOCK);
        end else begin
          if (m_vif.ARLOCK[0] == 1'b0) begin
            cmd.lock = XIL_AXI_ALOCK_NOLOCK;
          end else begin
            cmd.lock = XIL_AXI_ALOCK_EXCL;
          end
        end

        cmd.cache = m_vif.ARCACHE;
        if (C_AXI_ARUSER_WIDTH > 0) begin
          cmd.set_user(C_AXI_ARUSER_WIDTH, m_vif.ARUSER);
        end else begin
          cmd.set_user(0,1'b0);
        end
        cmd.region = m_vif.ARREGION;
        cmd.qos = m_vif.ARQOS;
      end else begin
        cmd.id = 0;
        cmd.len = 0;
        cmd.region = 4'h0;
        cmd.size = convert_dw_to_axi_size(C_AXI_RDATA_WIDTH);
        cmd.burst = XIL_AXI_BURST_TYPE_INCR;
        cmd.lock = XIL_AXI_ALOCK_NOLOCK;
        cmd.cache = 4'h0;
        cmd.qos = 4'h0;
        cmd.set_user(0,1'b0);
      end
      cmd.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(cmd);
    endfunction

    virtual function xil_axi_resp_beat get_bresp();
      xil_axi_resp_beat b;
      b = new;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_WID_WIDTH == 0) begin
          b.id = 1'b0;
        end else begin
          b.id = m_vif.BID;
        end
        if (C_AXI_BUSER_WIDTH > 0) begin
          b.set_user(C_AXI_BUSER_WIDTH, m_vif.BUSER);
        end else begin
          b.set_user(0,0);
        end
      end else begin
        b.id = 0;
        b.set_user(0,0);
      end
      b.resp = xil_axi_resp_t'(m_vif.BRESP);
      b.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(b);
    endfunction

   virtual function xil_axi_read_beat get_rdata();
      xil_axi_read_beat r;
      r = new;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_RUSER_WIDTH > 0) begin
          r.set_user(C_AXI_RUSER_WIDTH, m_vif.RUSER);
        end else begin
          r.set_user(0,0);
        end
        r.last = m_vif.RLAST;
        if (C_AXI_RID_WIDTH == 0) begin
          r.id = 1'b0;
        end else begin
          r.id = m_vif.RID;
        end
      end else begin
        r.last = 1;
        r.id = 0;
        r.set_user(0,0);
      end
      r.resp = xil_axi_resp_t'(m_vif.RRESP);
      r.data = new[C_AXI_RDATA_WIDTH/8];
      for (int j=(r.data.size()-1);j >= 0; j--) begin
        r.data[j] = m_vif.RDATA[((j+1)*8) -1 -: 8];
      end
      r.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(r);
    endfunction

    virtual function xil_axi_write_beat get_wdata();
      xil_axi_write_beat w;
      w = new;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_WUSER_WIDTH > 0) begin
          w.set_user(C_AXI_WUSER_WIDTH, m_vif.WUSER);
        end else begin
          w.set_user(0,0);
        end
        w.last = m_vif.WLAST;
      end else begin
        w.last = 1;
        w.set_user(0,0);
      end
      w.data = new[C_AXI_WDATA_WIDTH/8];
      w.strb = new[C_AXI_WDATA_WIDTH/8];
      for (int j=(w.data.size()-1);j >= 0; j--) begin
        w.strb[j] = m_vif.WSTRB[((j+1)*1) -1 -: 1];
        w.data[j] = m_vif.WDATA[((j+1)*8) -1 -: 8];
      end
      w.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(w);
    endfunction
  `else
  /*
    Function: get_awcmd
    Collects write command channel info from IF and returns it to write command beat
  */
    virtual function xil_axi_cmd_beat get_awcmd();
      xil_axi_cmd_beat cmd;
      cmd = new;
      cmd.dir = XIL_AXI_WRITE;
      cmd.addr = m_vif.cb.AWADDR;
      cmd.prot = m_vif.cb.AWPROT;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_WID_WIDTH == 0) begin
          cmd.id = 1'b0;
        end else begin
          cmd.id = m_vif.cb.AWID;
        end

        cmd.len = m_vif.cb.AWLEN;
        cmd.size = xil_axi_size_t'(m_vif.cb.AWSIZE);
        cmd.burst = xil_axi_burst_t'(m_vif.cb.AWBURST);
        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          cmd.lock = xil_axi_lock_t'(m_vif.cb.AWLOCK);
        end else begin
          if (m_vif.cb.AWLOCK[0] == 1'b0) begin
            cmd.lock = XIL_AXI_ALOCK_NOLOCK;
          end else begin
            cmd.lock = XIL_AXI_ALOCK_EXCL;
          end
        end
        cmd.cache = m_vif.cb.AWCACHE;
        if (C_AXI_AWUSER_WIDTH > 0) begin
          cmd.set_user(C_AXI_AWUSER_WIDTH, m_vif.cb.AWUSER);
        end else begin
          cmd.set_user(0,0);
        end
        cmd.region = m_vif.cb.AWREGION;
        cmd.qos = m_vif.cb.AWQOS;
      end else begin
        cmd.id = 0;
        cmd.len = 0;
        cmd.size = convert_dw_to_axi_size(C_AXI_WDATA_WIDTH);
        cmd.burst = XIL_AXI_BURST_TYPE_INCR;
        cmd.lock = XIL_AXI_ALOCK_NOLOCK;
        cmd.cache = 4'h0;
        cmd.region = 4'h0;
        cmd.qos = 4'h0;
        cmd.set_user(0,1'b0);
      end
      cmd.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(cmd);
    endfunction

  /*
    Function: get_arcmd
    Collects read command channel info from IF and returns it to read command beat
  */
    virtual function xil_axi_cmd_beat get_arcmd();
      xil_axi_cmd_beat cmd;
      cmd = new;
      cmd.dir = XIL_AXI_READ;
      cmd.addr = m_vif.cb.ARADDR;
      cmd.prot = m_vif.cb.ARPROT;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_RID_WIDTH == 0) begin
          cmd.id = 1'b0;
        end else begin
          cmd.id = m_vif.cb.ARID;
        end
        cmd.len = m_vif.cb.ARLEN;
        cmd.size = xil_axi_size_t'(m_vif.cb.ARSIZE);
        cmd.burst = xil_axi_burst_t'(m_vif.cb.ARBURST);

        if (this.get_axi_version() == XIL_VERSION_AXI3) begin
          cmd.lock = xil_axi_lock_t'(m_vif.cb.ARLOCK);
        end else begin
          if (m_vif.cb.ARLOCK[0] == 1'b0) begin
            cmd.lock = XIL_AXI_ALOCK_NOLOCK;
          end else begin
            cmd.lock = XIL_AXI_ALOCK_EXCL;
          end
        end

        cmd.cache = m_vif.cb.ARCACHE;
        if (C_AXI_ARUSER_WIDTH > 0) begin
          cmd.set_user(C_AXI_ARUSER_WIDTH, m_vif.cb.ARUSER);
        end else begin
          cmd.set_user(0,1'b0);
        end
        cmd.region = m_vif.cb.ARREGION;
        cmd.qos = m_vif.cb.ARQOS;
      end else begin
        cmd.id = 0;
        cmd.len = 0;
        cmd.region = 4'h0;
        cmd.size = convert_dw_to_axi_size(C_AXI_RDATA_WIDTH);
        cmd.burst = XIL_AXI_BURST_TYPE_INCR;
        cmd.lock = XIL_AXI_ALOCK_NOLOCK;
        cmd.cache = 4'h0;
        cmd.qos = 4'h0;
        cmd.set_user(0,1'b0);
      end
      cmd.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(cmd);
    endfunction

  /*
    Function: get_bresp
    Collects bresp channel info from IF and returns it to bresp beat
  */
    virtual function xil_axi_resp_beat get_bresp();
      xil_axi_resp_beat b;
      b = new;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_WID_WIDTH == 0) begin
          b.id = 1'b0;
        end else begin
          b.id = m_vif.cb.BID;
        end
        if (C_AXI_BUSER_WIDTH > 0) begin
          b.set_user(C_AXI_BUSER_WIDTH, m_vif.cb.BUSER);
        end else begin
          b.set_user(0,0);
        end
      end else begin
        b.id = 0;
        b.set_user(0,0);
      end
      b.resp = xil_axi_resp_t'(m_vif.cb.BRESP);
      b.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(b);
    endfunction

  /*
    Function: get_rdata
    Collects read data channel info from IF and returns it to read data beat
  */
   virtual function xil_axi_read_beat get_rdata();
      xil_axi_read_beat r;
      r = new;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_RUSER_WIDTH > 0) begin
          r.set_user(C_AXI_RUSER_WIDTH, m_vif.cb.RUSER);
        end else begin
          r.set_user(0,0);
        end
        r.last = m_vif.cb.RLAST;
        if (C_AXI_RID_WIDTH == 0) begin
          r.id = 1'b0;
        end else begin
          r.id = m_vif.cb.RID;
        end
      end else begin
        r.last = 1;
        r.id = 0;
        r.set_user(0,0);
      end
      r.resp = xil_axi_resp_t'(m_vif.cb.RRESP);
      r.data = new[C_AXI_RDATA_WIDTH/8];
      for (int j=(r.data.size()-1);j >= 0; j--) begin
        r.data[j] = m_vif.cb.RDATA[((j+1)*8) -1 -: 8];
      end
      r.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(r);
    endfunction

  /*
    Function:  get_wdata
    Collects write data channel info from IF and returns it to write data beat
  */
    virtual function xil_axi_write_beat get_wdata();
      xil_axi_write_beat w;
      w = new;
      if (this.get_axi_version() != XIL_VERSION_LITE) begin
        if (C_AXI_WUSER_WIDTH > 0) begin
          w.set_user(C_AXI_WUSER_WIDTH, m_vif.cb.WUSER);
        end else begin
          w.set_user(0,0);
        end
        w.last = m_vif.cb.WLAST;
      end else begin
        w.last = 1;
        w.set_user(0,0);
      end
      w.data = new[C_AXI_WDATA_WIDTH/8];
      w.strb = new[C_AXI_WDATA_WIDTH/8];
      for (int j=(w.data.size()-1);j >= 0; j--) begin
        w.strb[j] = m_vif.cb.WSTRB[((j+1)*1) -1 -: 1];
        w.data[j] = m_vif.cb.WDATA[((j+1)*8) -1 -: 8];
      end
      w.trigger_accepted(.now(this.get_current_edge_time()), .now_cycle(this.get_current_clk_count()));
      return(w);
    endfunction
  `endif

  /*
    Function: set_awvalid
    Sets awvalid of m_vif to be 1
  */
  virtual function void set_awvalid();
    if (m_vif.supports_write == 1) begin
      m_vif.awvalid <= 1'b1;
    end
  endfunction

  /*
    Function: set_arvalid
    Sets arvalid of m_vif to be 1
  */
  virtual function void set_arvalid();
    if (m_vif.supports_read == 1) m_vif.arvalid <= 1'b1;
  endfunction

  /*
    Function: clr_awvalid
    Sets awvalid of m_vif to be 0
  */
  virtual function void clr_awvalid();
    if (m_vif.supports_write == 1) m_vif.awvalid <= 1'b0;
  endfunction

  /*
    Function: clr_arvalid
    Sets arvalid of m_vif to be 0
  */
  virtual function void clr_arvalid();
    if (m_vif.supports_read == 1) m_vif.arvalid <= 1'b0;
  endfunction

  /*
    Function: set_bvalid
    Sets bvalid of m_vif to be 1
  */
  virtual function void set_bvalid();
    if (m_vif.supports_write == 1) m_vif.bvalid <= 1'b1;
  endfunction

  /*
    Function: clr_bvalid
    Sets bvalid of m_vif to be 0
  */
  virtual function void clr_bvalid();
    if (m_vif.supports_write == 1) m_vif.bvalid <= 1'b0;
  endfunction

  /*
   Function: set_rvalid
   Sets rvalid of m_vif to be 1
  */
  virtual function void set_rvalid();
    if (m_vif.supports_read == 1) m_vif.rvalid <= 1'b1;
  endfunction

  /*
   Function: clr_rvalid
   Sets rvalid of m_vif to be 0
  */
  virtual function void clr_rvalid();
    if (m_vif.supports_read == 1) m_vif.rvalid <= 1'b0;
  endfunction

  /*
   Function: set_wvalid
   Sets wvalid of m_vif to be 1
  */
  virtual function void set_wvalid();
    if (m_vif.supports_write == 1) m_vif.wvalid <= 1'b1;
  endfunction

  /*
   Function: clr_wvalid
   Sets wvalid of m_vif to be 0
  */
  virtual function void clr_wvalid();
    if (m_vif.supports_write == 1) m_vif.wvalid <= 1'b0;
  endfunction

  /*
   Function: set_awready
   Sets awready of m_vif to be 1
  */
  virtual function void set_awready();
    if (m_vif.supports_write == 1) m_vif.awready <= 1'b1;
  endfunction

  /*
   Function: set_arready
   Sets arready of m_vif to be 1
  */
  virtual function void set_arready();
    if (m_vif.supports_read == 1) m_vif.arready <= 1'b1;
  endfunction

  /*
   Function: clr_awready
   Sets awready of m_vif to be 0
  */
  virtual function void clr_awready();
    if (m_vif.supports_write == 1) m_vif.awready <= 1'b0;
  endfunction

  /*
   Function: clr_arready
   Sets arready of m_vif to be 0
  */
  virtual function void clr_arready();
    if (m_vif.supports_read == 1) m_vif.arready <= 1'b0;
  endfunction

  /*
   Function: set_bready
   Sets bready of m_vif to be 1
  */
  virtual function void set_bready();
    if (m_vif.supports_write == 1) m_vif.bready <= 1'b1;
  endfunction

  /*
   Function: clr_bready
   Sets bready of m_vif to be 0
  */
  virtual function void clr_bready();
    if (m_vif.supports_write == 1) m_vif.bready <= 1'b0;
  endfunction

  /*
   Function: set_rready
   Sets rready of m_vif to be 1
  */
  virtual function void set_rready();
    if (m_vif.supports_read == 1) m_vif.rready <= 1'b1;
  endfunction

  /*
   Function: clr_rready
   Sets rready of m_vif to be 0
  */
  virtual function void clr_rready();
    if (m_vif.supports_read == 1) m_vif.rready <= 1'b0;
  endfunction

  /*
   Function: set_wready
   Sets wready of m_vif to be 1
  */
  virtual function void set_wready();
    if (m_vif.supports_write == 1) m_vif.wready <= 1'b1;
  endfunction

  /*
   Function: clr_wready
   Sets wready of m_vif to be 0
  */
  virtual function void clr_wready();
    if (m_vif.supports_write == 1) m_vif.wready <= 1'b0;
  endfunction

`ifdef XILINX_SIMULATOR

  /*
   Function: is_awready_asserted
   Returns 1 if AWREADY of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_awready_asserted();
    return(m_vif.AWREADY == 1);
  endfunction

  /*
   Function: is_arready_asserted
   Returns 1 if ARREADY of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_arready_asserted();
    return(m_vif.ARREADY== 1);
  endfunction

  /*
   Function: is_wready_asserted
   Returns 1 if WREADY of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_wready_asserted();
    return(m_vif.WREADY == 1);
  endfunction

  /*
   Function: is_rready_asserted
   Returns 1 if RREADY of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_rready_asserted();
    return(m_vif.RREADY == 1);
  endfunction

  /*
   Function: is_bready_asserted
   Returns 1 if BREADY of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_bready_asserted();
    return(m_vif.BREADY == 1);
  endfunction

  /*
   Function: is_awvalid_asserted
   Returns 1 if AWVALID of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_awvalid_asserted();
    return(m_vif.AWVALID == 1);
  endfunction

  /*
   Function: is_arvalid_asserted
   Returns 1 if ARVALID of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_arvalid_asserted();
    return(m_vif.ARVALID == 1);
  endfunction

  /*
   Function: is_wvalid_asserted
   Returns 1 if WVALID of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_wvalid_asserted();
    return(m_vif.WVALID == 1);
  endfunction

  /*
   Function: is_rvalid_asserted
   Returns 1 if RVALID of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_rvalid_asserted();
    return(m_vif.RVALID == 1);
  endfunction

  /*
   Function: is_bvalid_asserted
   Returns 1 if BVALID of clock block in m_vif is 1, else returns 0
  */
  virtual function bit is_bvalid_asserted();
    return(m_vif.BVALID == 1);
  endfunction

`else
  virtual function bit is_awready_asserted();
    return(m_vif.cb.AWREADY == 1);
  endfunction

  virtual function bit is_arready_asserted();
    return(m_vif.cb.ARREADY == 1);
  endfunction

  virtual function bit is_wready_asserted();
    return(m_vif.cb.WREADY == 1);
  endfunction

  virtual function bit is_rready_asserted();
    return(m_vif.cb.RREADY == 1);
  endfunction

  virtual function bit is_bready_asserted();
    return(m_vif.cb.BREADY == 1);
  endfunction

  virtual function bit is_awvalid_asserted();
    return(m_vif.cb.AWVALID == 1);
  endfunction

  virtual function bit is_arvalid_asserted();
    return(m_vif.cb.ARVALID == 1);
  endfunction

  virtual function bit is_wvalid_asserted();
    return(m_vif.cb.WVALID == 1);
  endfunction

  virtual function bit is_rvalid_asserted();
    return(m_vif.cb.RVALID == 1);
  endfunction

  virtual function bit is_bvalid_asserted();
    return(m_vif.cb.BVALID == 1);
  endfunction

`endif
  ///////////////////////////////////////////////////////////////////////////////////
  //Live monitoring
  /*
   Function: is_live_awvalid_asserted
   Returns 1 if AWVALID of m_vif is 1, else returns 0
  */
  virtual function bit is_live_awvalid_asserted();
    return(m_vif.AWVALID == 1);
  endfunction

  /*
   Function: is_live_arvalid_asserted
   Returns 1 if ARVALID of m_vif is 1, else returns 0
  */
  virtual function bit is_live_arvalid_asserted();
    return(m_vif.ARVALID == 1);
  endfunction

  /*
   Function: is_live_wvalid_asserted
   Returns 1 if WVALID of m_vif is 1, else returns 0
  */
  virtual function bit is_live_wvalid_asserted();
    return(m_vif.WVALID == 1);
  endfunction

  /*
   Function: is_live_rvalid_asserted
   Returns 1 if RVALID of m_vif is 1, else returns 0
  */
  virtual function bit is_live_rvalid_asserted();
    return(m_vif.RVALID == 1);
  endfunction

  /*
   Function: is_live_bvalid_asserted
   Returns 1 if BVALID of m_vif is 1, else returns 0
  */
  virtual function bit is_live_bvalid_asserted();
    return(m_vif.BVALID == 1);
  endfunction

 `ifdef XILINX_SIMULATOR
  virtual task wait_live_awvalid_asserted();
    if (m_vif.AWVALID == 1'b0 ) begin
      @(posedge m_vif.AWVALID);
    end
  endtask

  virtual task wait_live_arvalid_asserted();
    if (m_vif.ARVALID == 1'b0 ) begin
      @(posedge m_vif.ARVALID);
    end
  endtask

  virtual task wait_live_wvalid_asserted();
    if (m_vif.WVALID == 1'b0 ) begin
      @(posedge m_vif.WVALID);
    end
  endtask

  virtual task wait_live_rvalid_asserted();
    if (m_vif.RVALID == 1'b0 ) begin
      @(posedge m_vif.RVALID);
    end
  endtask

  virtual task wait_live_bvalid_asserted();
    if (m_vif.BVALID == 1'b0 ) begin
      @(posedge m_vif.BVALID);
    end
  endtask
  `else
  /*
   Function: wait_live_awvalid_asserted
   Wait AWVALID of m_vif is 1
  */
  virtual task wait_live_awvalid_asserted();
    wait(m_vif.AWVALID == 1);
  endtask

  /*
   Function: wait_live_arvalid_asserted
   Wait ARVALID of m_vif is 1
  */
  virtual task wait_live_arvalid_asserted();
    wait(m_vif.ARVALID == 1);
  endtask

  /*
   Function: wait_live_arvalid_asserted
   Wait WALID of m_vif is 1
  */
  virtual task wait_live_wvalid_asserted();
    wait(m_vif.WVALID == 1);
  endtask

  /*
   Function: wait_live_rvalid_asserted
   Wait RVALID of m_vif is 1
  */
  virtual task wait_live_rvalid_asserted();
    wait(m_vif.RVALID == 1);
  endtask

  /*
   Function: wait_live_bvalid_asserted
   Wait BVALID of m_vif is 1
  */
  virtual task wait_live_bvalid_asserted();
    wait(m_vif.BVALID == 1);
  endtask
  `endif

  /*
   Function: wait_areset_asserted
   Waits areset to be asserted
  */
  virtual task wait_areset_asserted();
    if (m_vif.ARESET_N == 1'b1) begin
      @(negedge m_vif.ARESET_N);
    end
  endtask

`ifdef XILINX_SIMULATOR
  virtual task wait_wvalid_sampled();
    @(posedge m_vif.ACLK iff (m_vif.WVALID == 1 && (m_vif.ACLKEN == 1)));
  endtask

  virtual task wait_aw_accepted();
    @(posedge m_vif.ACLK iff ((m_vif.AWREADY == 1) && ( m_vif.AWVALID == 1) && (m_vif.ARESET_N == 1) && (m_vif.ACLKEN == 1)));
  endtask

  virtual task wait_ar_accepted();
    @(posedge m_vif.ACLK iff ((m_vif.ARREADY == 1) && ( m_vif.ARVALID == 1) && (m_vif.ARESET_N_O == 1) && (m_vif.ACLKEN_O == 1)));
  endtask

  virtual task wait_r_accepted();
    @(posedge m_vif.ACLK iff ((m_vif.RREADY == 1) && ( m_vif.RVALID == 1) && (m_vif.ARESET_N_O == 1) && (m_vif.ACLKEN_O == 1)));
  endtask

  virtual task wait_w_accepted();
    @(posedge m_vif.ACLK iff ((m_vif.WREADY == 1) && ( m_vif.WVALID == 1) && (m_vif.ARESET_N_O == 1) && (m_vif.ACLKEN_O == 1)));
  endtask

  virtual task wait_b_accepted();
    @(posedge m_vif.ACLK iff ((m_vif.BREADY == 1) && ( m_vif.BVALID == 1) && (m_vif.ARESET_N_O == 1) && (m_vif.ACLKEN_O == 1)));
  endtask

  virtual function bit is_aw_accepted();
    return((m_vif.AWREADY == 1) && ( m_vif.AWVALID == 1) && (m_vif.ACLKEN_O == 1));
  endfunction

  virtual function bit is_ar_accepted();
    return((m_vif.ARREADY == 1) && ( m_vif.ARVALID == 1) && (m_vif.ACLKEN_O == 1));
  endfunction

  virtual function bit is_r_accepted();
    return((m_vif.RREADY == 1) && ( m_vif.RVALID == 1) && (m_vif.ACLKEN_O == 1));
  endfunction

  virtual function bit is_w_accepted();
    return((m_vif.WREADY == 1) && ( m_vif.WVALID == 1) && (m_vif.ACLKEN_O == 1));
  endfunction

  virtual function bit is_b_accepted();
    return((m_vif.BREADY == 1) && ( m_vif.BVALID == 1) && (m_vif.ACLKEN_O == 1));
  endfunction

`else
  /*
   Function: wait_wvalid_sampled
   Wait till WVALID is sampled 
  */
  virtual task wait_wvalid_sampled();
    @(m_vif.cb iff (m_vif.cb.WVALID == 1 && (m_vif.cb.ACLKEN == 1)));
  endtask

  /*
   Function:  wait_aw_accepted
   Waits till AWREADY/AWVALID handshake occurs
  */
  virtual task wait_aw_accepted();
    @(m_vif.cb iff ((m_vif.cb.AWREADY == 1) && ( m_vif.cb.AWVALID == 1) && (m_vif.cb.ARESET_N == 1) && (m_vif.cb.ACLKEN == 1)));
  endtask

  /*
   Function:  wait_ar_accepted
   Waits till ARREADY/ARVALID handshake occurs
  */
  virtual task wait_ar_accepted();
    @(m_vif.cb iff ((m_vif.cb.ARREADY == 1) && ( m_vif.cb.ARVALID == 1) && (m_vif.cb.ARESET_N == 1) && (m_vif.cb.ACLKEN == 1)));
  endtask

  /*
   Function:  wait_r_accepted
   Waits till RREADY/RVALID handshake occurs
  */
  virtual task wait_r_accepted();
    @(m_vif.cb iff ((m_vif.cb.RREADY == 1) && ( m_vif.cb.RVALID == 1) && (m_vif.cb.ARESET_N == 1) && (m_vif.cb.ACLKEN == 1)));
  endtask

  /*
   Function:  wait_w_accepted
   Waits till WREADY/WVALID handshake occurs
  */
  virtual task wait_w_accepted();
    @(m_vif.cb iff ((m_vif.cb.WREADY == 1) && ( m_vif.cb.WVALID == 1) && (m_vif.cb.ARESET_N == 1) && (m_vif.cb.ACLKEN == 1)));
  endtask

  /*
   Function:  wait_b_accepted
   Waits till BREADY/BVALID handshake occurs
  */
  virtual task wait_b_accepted();
    @(m_vif.cb iff ((m_vif.cb.BREADY == 1) && ( m_vif.cb.BVALID == 1) && (m_vif.cb.ARESET_N == 1) && (m_vif.cb.ACLKEN == 1)));
  endtask

  /*
   Function: is_aw_accepted
   Returns 1 if AWREADY/AWVALID handshake occurs
  */
  virtual function bit is_aw_accepted();
    return((m_vif.cb.AWREADY == 1) && ( m_vif.cb.AWVALID == 1) && (m_vif.cb.ACLKEN == 1));
  endfunction

  /*
   Function: is_ar_accepted
   Returns 1 if ARREADY/ARVALID handshake occurs
  */
  virtual function bit is_ar_accepted();
    return((m_vif.cb.ARREADY == 1) && ( m_vif.cb.ARVALID == 1) && (m_vif.cb.ACLKEN == 1));
  endfunction

  /*
   Function: is_r_accepted
   Returns 1 if RREADY/RVALID handshake occurs
  */
  virtual function bit is_r_accepted();
    return((m_vif.cb.RREADY == 1) && ( m_vif.cb.RVALID == 1) && (m_vif.cb.ACLKEN == 1));
  endfunction

  /*
   Function: is_w_accepted
   Returns 1 if WREADY/WVALID handshake occurs
  */
  virtual function bit is_w_accepted();
    return((m_vif.cb.WREADY == 1) && ( m_vif.cb.WVALID == 1) && (m_vif.cb.ACLKEN == 1));
  endfunction

  /*
   Function: is_b_accepted
   Returns 1 if BREADY/BVALID handshake occurs
  */
  virtual function bit is_b_accepted();
    return((m_vif.cb.BREADY == 1) && ( m_vif.cb.BVALID == 1) && (m_vif.cb.ACLKEN == 1));
  endfunction
`endif
endclass : axi_vif_mem_proxy

///////////////////////////////////////////////////////////////////////////
//MONITOR
/*
  Class: axi_monitor
  When active the AXI Monitor will record transactions that are presented on the virtual interface.
*/
class axi_monitor `AXI_PARAM_DECL extends xil_monitor;

  ///////////////////////////////////////////////////////////////////////////
  //Get the library

  typedef axi_write_transfer#(axi_monitor_transaction)                    mon_axi_write_transfer_t;
  typedef axi_generic_write_transaction_queue#(axi_monitor_transaction)   mon_axi_inbound_write_queue_t;
  typedef xil_axi_generic_queue_container #(axi_monitor_transaction)      mon_transaction_q_t;
  typedef xil_axi_generic_queue_container #(xil_axi_write_beat)           mon_beat_q_t;

  protected xil_axi_vif_axi_version_t               axi_version = XIL_VERSION_AXI4;
  protected xil_axi_uint                            rd_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint                            wr_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint                            transaction_depth_checks_enabled = 1;

  ///////////////////////////////////////////////////////////////////////////
  // The following two bits are used to control whether checks and coverage are
  // done both in the monitor class and the interface.

  xil_analysis_port #(axi_monitor_transaction)      item_collected_port;
  xil_analysis_port #(xil_axi_cmd_beat)             axi_cmd_port;
  xil_analysis_port #(xil_axi_cmd_beat)             axi_rd_cmd_port;
  xil_analysis_port #(xil_axi_cmd_beat)             axi_wr_cmd_port;
  xil_analysis_port #(xil_axi_resp_beat)            axi_bresp_port;
  xil_analysis_port #(xil_axi_write_beat)           axi_wr_beat_port;
  xil_analysis_port #(xil_axi_read_beat)            axi_rd_beat_port;

  ///////////////////////////////////////////////////////////////////////////
  //Tracking for Write and read transactions
  mon_axi_inbound_write_queue_t                     incoming_write  [xil_axi_uint];
  mon_transaction_q_t                               incoming_read   [xil_axi_uint];

  ///////////////////////////////////////////////////////////////////////////
  // internal channel queues
  protected axi_monitor_transaction                           done_q[$];
  protected xil_axi_uint                                      done_q_entries;

  protected mon_axi_write_transfer_t                          reconcile_q[$];
  protected mon_beat_q_t                                      reconcile_data_q[$];
  protected xil_axi_uint                                      reconcile_q_entries;
  protected xil_axi_uint                                      reconcile_data_q_entries;

  ///////////////////////////////////////////////////////////////////////////
  //Count the number of outstanding read/write transactions
  protected xil_axi_uint                                      num_inflight_rd_transactions;
  protected xil_axi_uint                                      num_inflight_wr_transactions;

  ///////////////////////////////////////////////////////////////////////////
  // internal events
  event                                                       done_q_entries_event ;
  event                                                       reconcile_q_entries_event ;
  event                                                       reconcile_data_q_entries_event ;

  ///////////////////////////////////////////////////////////////////////////
  //Time stamps
  protected time                                              ar_ready_assert_time = 0;
  protected time                                              ar_valid_assert_time = 0;
  protected time                                              aw_ready_assert_time = 0;
  protected time                                              aw_valid_assert_time = 0;
  protected time                                              w_ready_assert_time = 0;
  protected time                                              w_valid_assert_time = 0;
  protected time                                              b_ready_assert_time = 0;
  protected time                                              b_valid_assert_time = 0;
  protected time                                              r_ready_assert_time = 0;
  protected time                                              r_valid_assert_time = 0;
  protected xil_axi_ulong                                     ar_ready_assert_cycle = 0;
  protected xil_axi_ulong                                     ar_valid_assert_cycle = 0;
  protected xil_axi_ulong                                     aw_ready_assert_cycle = 0;
  protected xil_axi_ulong                                     aw_valid_assert_cycle = 0;
  protected xil_axi_ulong                                     w_ready_assert_cycle = 0;
  protected xil_axi_ulong                                     w_valid_assert_cycle = 0;
  protected xil_axi_ulong                                     b_ready_assert_cycle = 0;
  protected xil_axi_ulong                                     b_valid_assert_cycle = 0;
  protected xil_axi_ulong                                     r_ready_assert_cycle = 0;
  protected xil_axi_ulong                                     r_valid_assert_cycle = 0;

  ///////////////////////////////////////////////////////////////////////////
  // AXI interface
  axi_vif_mem_proxy `AXI_PARAM_ORDER vif_proxy;

  ///////////////////////////////////////////////////////////////////////////
  // new - constructor
  /*
    Function: new
    Constructor to create a new monitor transaction
  */
  function new (string name);
    super.new(name);
    this.done_q_entries = 0;
    this.reconcile_q_entries = 0;
    this.reconcile_data_q_entries = 0;
    this.set_rd_transaction_depth(XIL_AXI_DEFAULT_TRANSACTION_DEPTH);
    this.set_wr_transaction_depth(XIL_AXI_DEFAULT_TRANSACTION_DEPTH);
    num_inflight_rd_transactions = 0;
    num_inflight_wr_transactions = 0;
    item_collected_port = new("item_collected_port");
    this.item_collected_port.set_enabled();
    axi_cmd_port = new("axi_cmd_port");
    axi_rd_cmd_port = new("axi_rd_cmd_port");
    axi_wr_cmd_port = new("axi_wr_cmd_port");
    axi_bresp_port = new("axi_bresp_port");
    axi_wr_beat_port = new("axi_wr_beat_port");
    axi_rd_beat_port = new("axi_rd_beat_port");
  endfunction : new

  /*
    Function: set_vif
    Assigns the virtual interface of the driver.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    this.vif_proxy = vif;
    this.axi_version = this.vif_proxy.get_axi_version();
  endfunction : set_vif

  /*
    Function: get_axi_version
    Returns the value of AXI version of the transaction.
  */
  virtual function xil_axi_vif_axi_version_t get_axi_version();
    return(this.axi_version);
  endfunction

  /*
    Function: get_axi_version_name
    Returns the name of AXI version of the transaction.
  */
  virtual function string get_axi_version_name();
    return(this.axi_version.name());
  endfunction

  protected function void clear_bresp_assert_times();
    b_valid_assert_time = 0;
    b_ready_assert_time = 0;
    b_valid_assert_cycle = 0;
    b_ready_assert_cycle = 0;
  endfunction

  protected function void clear_aw_assert_times();
    aw_valid_assert_time = 0;
    aw_ready_assert_time = 0;
    aw_valid_assert_cycle = 0;
    aw_ready_assert_cycle = 0;
  endfunction

  protected function void clear_ar_assert_times();
    ar_valid_assert_time = 0;
    ar_ready_assert_time = 0;
    ar_valid_assert_cycle = 0;
    ar_ready_assert_cycle = 0;
  endfunction

  protected function void clear_w_assert_times();
    w_valid_assert_time = 0;
    w_ready_assert_time = 0;
    w_valid_assert_cycle = 0;
    w_ready_assert_cycle = 0;
  endfunction

  protected function void clear_r_assert_times();
    r_valid_assert_time = 0;
    r_ready_assert_time = 0;
    r_valid_assert_cycle = 0;
    r_ready_assert_cycle = 0;
  endfunction

  /*
    Function: set_wr_transaction_depth
    Sets the number of WRITE transactions that the Driver will have in flight at one time.
  */
  function void set_wr_transaction_depth(input xil_axi_uint update);
    if (update == 0) begin
      `xil_warning(this.get_tag(), "Setting the WRITE transaction Depth to 0. No transactions will be issued")
    end
    this.wr_transaction_depth = update;
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Driver will have in flight at one time.
  */
  function xil_axi_uint get_wr_transaction_depth();
    return(this.wr_transaction_depth);
  endfunction

  /*
    Function: set_rd_transaction_depth
    Sets the number of READ transactions that the Driver will have in flight at one time.
  */
  function void set_rd_transaction_depth(input xil_axi_uint update);
    if (update == 0) begin
      `xil_warning(this.get_tag(), "Setting the READ transaction Depth to 0. No transactions will be issued")
    end
    this.rd_transaction_depth = update;
  endfunction

  /*
    Function: get_rd_transaction_depth
    Returns the maximum number of READ transactions that the Driver will have in flight at one time.
  */
  function xil_axi_uint get_rd_transaction_depth();
    return(this.rd_transaction_depth);
  endfunction

  /*
    Function: enable_transaction_depth_checks
    Turn on current agent's transaction depth check and its monitor's enable_transaction_depth_checks
  */
  function void enable_transaction_depth_checks();
    transaction_depth_checks_enabled = 1;
  endfunction

  /*
    Function: disable_transaction_depth_checks
    Turn off current agent's transaction depth check and its monitor's enable_transaction_depth_checks
  */
  function void disable_transaction_depth_checks();
    transaction_depth_checks_enabled = 0;
  endfunction

 /*
  Function: get_transaction_depth_check_status
  Returns transaction_depth_checks_enabled 
 */
  function xil_axi_uint get_transaction_depth_check_status();
    return(transaction_depth_checks_enabled);
  endfunction

  /*
   Function: get_num_rd_transactions_inflight
   Returns number of read transaction in flight 
  */
  function xil_axi_uint get_num_rd_transactions_inflight();
    return(num_inflight_rd_transactions);
  endfunction

  /*
   Function: get_num_wr_transactions_inflight
   Returns number of write transaction in flight
  */
  function xil_axi_uint get_num_wr_transactions_inflight();
    return(num_inflight_wr_transactions);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  // run phase
  /*
    Function: run_phase
    Start control processes for operation
  */
  virtual task run_phase();
    if (!this.get_is_active()) begin
      this.set_is_active();
      this.stop_triggered_event = 0;
      if (this.vif_proxy == null) begin
        `xil_fatal(this.get_tag(), $sformatf("Attempted to start %s without assigned Interface", this.get_name()))
      end
      ///////////////////////////////////////////////////////////////////////////
      //Start the clock counters
      fork
        vif_proxy.run_phase();
      join_none
      vif_proxy.wait_posedge_aclk();
      vif_proxy.wait_areset_deassert();
      while (this.stop_triggered_event == 0) begin
        fork
          begin
            `xil_info(this.get_tag(), "run()",this.verbosity)
            run_active();
          end
          begin
            vif_proxy.wait_areset_asserted();
          end
          begin : STOP
            @(posedge this.stop_triggered_event);
            `xil_info(this.get_tag(), "Stop event triggered. All traffic is being terminated.",this.verbosity)
          end
        join_any
        disable fork;
        clean_reconcile_q();
        clean_reconcile_data_q();
        clean_incoming_write();
        clean_incoming_read();
        if (this.stop_triggered_event == 0) begin
          `xil_info(this.get_tag(), $sformatf("RESET DETECTED"),this.verbosity)
          vif_proxy.wait_areset_deassert();
          `xil_info(this.get_tag(), $sformatf("RESET Released"),this.verbosity)
        end
      end
      this.clr_is_active();
    end
  endtask : run_phase

  ///////////////////////////////////////////////////////////////////////////
  //Stop the active processes.
  /*
    Function: stop_phase
    Stops all control processes.
  */
  virtual task stop_phase();
    this.stop_triggered_event = 1;
  endtask : stop_phase

  ///////////////////////////////////////////////////////////////////////////
  //Fork off the active processes.
  protected task run_active();
    num_inflight_rd_transactions = 0;
    num_inflight_wr_transactions = 0;
    fork
      r_channel();
      ar_channel();
      aw_channel();
      b_channel();
      w_channel();
      trap_events();
      service_reconcile_q();
      service_done_q();
    join
  endtask

///////////////////////////////////////////////////////////////////////////
  //QUEUE management
  protected task push_done_q(inout axi_monitor_transaction transfer);
    done_q.push_back(transfer);
    done_q_entries++;
    ->done_q_entries_event ;
  endtask

  protected task pop_done_q(inout axi_monitor_transaction transfer);
    while(done_q.size() == 0) begin
      @(done_q_entries_event);
    end
    transfer = done_q.pop_front();
    done_q_entries--;
  endtask

  protected task clean_done_q();
    while (done_q.size() > 0) begin
      done_q.delete(0);
    end
    done_q_entries = 0;
    ->done_q_entries_event ;
  endtask

  protected task push_reconcile_data_q(inout mon_beat_q_t xfer);
    reconcile_data_q.push_back(xfer);
    reconcile_data_q_entries++;
    ->reconcile_data_q_entries_event ;
  endtask

  protected task push_reconcile_q(inout mon_axi_write_transfer_t xfer);
    reconcile_q.push_back(xfer);
    reconcile_q_entries++;
    ->reconcile_q_entries_event ;
  endtask

  protected task pop_reconcile_q(inout mon_axi_write_transfer_t xfer);
    while(reconcile_q.size() == 0) begin
      @(reconcile_q_entries_event);
    end
    xfer = reconcile_q.pop_front();
    reconcile_q_entries--;
  endtask

  protected task pop_reconcile_data_q(inout mon_beat_q_t xfer);
    while(reconcile_data_q.size() == 0) begin
      @(reconcile_data_q_entries_event);
    end
    xfer = reconcile_data_q.pop_front();
    reconcile_data_q_entries--;
    ->reconcile_data_q_entries_event ;
  endtask

  protected task clean_reconcile_q();
    while (reconcile_q.size() > 0) begin
      reconcile_q.delete(0);
    end
    reconcile_q_entries = 0;
    ->reconcile_q_entries_event ;
  endtask

  protected task clean_reconcile_data_q();
    while (reconcile_data_q.size() > 0) begin
      reconcile_data_q.delete(0);
    end
    reconcile_data_q_entries = 0;
    ->reconcile_data_q_entries_event ;
  endtask

  protected task clean_incoming_write();
    mon_axi_inbound_write_queue_t temp;
    xil_axi_uint                      index;
    foreach (incoming_write[index]) begin : CLEAN
      temp = incoming_write[index];
      temp.clean();
      incoming_write.delete(index);
    end
  endtask

  protected task clean_incoming_read();
    mon_transaction_q_t    temp;
    xil_axi_uint               index;
    foreach (incoming_read[index] ) begin : CLEAN
      temp = incoming_read[index];
      temp.clean();
      incoming_read.delete(index);
    end
  endtask


  ///////////////////////////////////////////////////////////////////////////
  //Once the Packet has been completed send the completed transfer back to the
  // sequencer in the RESPONSE TLM channel
  protected task service_done_q ();
    axi_monitor_transaction transfer;

    forever begin : SERVICE_DONE_Q
      pop_done_q(transfer);
      item_collected_port.write(transfer);
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Now that all phases of the write transfer has been completed we need to
  // merge the write beats into the transfer in the xfer
  protected task service_reconcile_q ();
    axi_monitor_transaction       transfer;
    mon_axi_write_transfer_t      addr_xfer;
    mon_beat_q_t                  data_xfer;
    mon_axi_inbound_write_queue_t inbound_q;

    forever begin : SERVICE_RECONCILE_Q
      ///////////////////////////////////////////////////////////////////////////
      //Pop the first address and the first data. Since there is no reordering
      // these are same transaction.
      pop_reconcile_q(addr_xfer);
      transfer = addr_xfer.get_transfer();

      pop_reconcile_data_q(data_xfer);
      ///////////////////////////////////////////////////////////////////////////
      //Check that the number of beats is the correct number
      // INDEX:        - XIL_AXI_WLAST_VIOLATION
      // =====
      // This will fire in one of the following situations:
      // 1) Write data arrives and WLAST set and WDATA count is not equal to AWLEN
      // 2) Write data arrives and WLAST not set and WDATA count is equal to AWLEN
      // 3) ADDR arrives, WLAST already received and WDATA count not equal to AWLEN
      XIL_AXI_WLAST_VIOLATION: assert ((transfer.get_len() + 1) == data_xfer.get_num_entries()) else begin
        `xil_error(this.get_tag(),
          $sformatf("XIL_AXI_WLAST_VIOLATION. The number of write data items must match AWLEN for the corresponding address. Spec: section A3.4.1."))
        `xil_error(this.get_tag(),
          $sformatf("Write transfer ID=0x%x did not receive correct number of beats Exp %d got %d", transfer.get_id(), (transfer.get_len() + 1),data_xfer.get_num_entries()))
      end
      addr_xfer.set_beat_q(data_xfer);
      addr_xfer.set_data_phase_complete();
      ///////////////////////////////////////////////////////////////////////////
      //If the BRESP has completed then push to the done queue
      if (addr_xfer.all_phase_complete()) begin

        check_burst(transfer, data_xfer);
        addr_xfer.store_wdata();
        ///////////////////////////////////////////////////////////////////////////
        //Get the queue for that ID
        inbound_q = incoming_write[transfer.get_id()];
        addr_xfer = inbound_q.pop_front();
        transfer.trigger_transaction_phase_end();
        ///////////////////////////////////////////////////////////////////////////
        //Are there any more pending transfers for this ID? if not tear down the
        // entries.
        if (inbound_q.get_num_entries() == 0) begin
          incoming_write.delete(transfer.get_id());
        end
        ///////////////////////////////////////////////////////////////////////////
        //Pass the transfer to the done queue for reconcilation
        num_inflight_wr_transactions--;
        push_done_q(transfer);
      end
    end
  endtask


  ///////////////////////////////////////////////////////////////////////////
  //Event handling
  protected task trap_events ();
    forever begin : TRAP
      vif_proxy.wait_posedge_aclk();
      #0ps;
      ///////////////////////////////////////////////////////////////////////////
      //Assertion Times for Handshakes
      if (vif_proxy.is_awready_asserted()) begin
        if (aw_ready_assert_time == 0) begin
          aw_ready_assert_time = this.vif_proxy.get_current_edge_time();
          aw_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        aw_ready_assert_time = 0;
        aw_ready_assert_cycle = 0;
      end
      if (vif_proxy.is_arready_asserted()) begin
        if (ar_ready_assert_time == 0) begin
          ar_ready_assert_time = this.vif_proxy.get_current_edge_time();
          ar_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        ar_ready_assert_time = 0;
        ar_ready_assert_cycle = 0;
      end
      if (vif_proxy.is_wready_asserted()) begin
        if (w_ready_assert_time == 0) begin
          w_ready_assert_time = this.vif_proxy.get_current_edge_time();
          w_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        w_ready_assert_time = 0;
        w_ready_assert_cycle = 0;
      end
      if (vif_proxy.is_bready_asserted()) begin
        if (b_ready_assert_time == 0) begin
          b_ready_assert_time = this.vif_proxy.get_current_edge_time();
          b_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        b_ready_assert_time = 0;
        b_ready_assert_cycle = 0;
      end
      if (vif_proxy.is_rready_asserted()) begin
        if (r_ready_assert_time == 0) begin
          r_ready_assert_time = this.vif_proxy.get_current_edge_time();
          r_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        r_ready_assert_time = 0;
        r_ready_assert_cycle = 0;
      end
      if (vif_proxy.is_awvalid_asserted()) begin
        if (aw_valid_assert_time == 0) begin
          aw_valid_assert_time = this.vif_proxy.get_current_edge_time();
          aw_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        aw_valid_assert_time = 0;
        aw_valid_assert_cycle = 0;
      end
      if (vif_proxy.is_arvalid_asserted()) begin
        if (ar_valid_assert_time == 0) begin
          ar_valid_assert_time = this.vif_proxy.get_current_edge_time();
          ar_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        ar_valid_assert_time = 0;
        ar_valid_assert_cycle = 0;
      end
      if (vif_proxy.is_wvalid_asserted()) begin
        if (w_valid_assert_time == 0) begin
          w_valid_assert_time = this.vif_proxy.get_current_edge_time();
          w_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        w_valid_assert_time = 0;
        w_valid_assert_cycle = 0;
      end
      if (vif_proxy.is_bvalid_asserted()) begin
        if (b_valid_assert_time == 0) begin
          b_valid_assert_time = this.vif_proxy.get_current_edge_time();
          b_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        b_valid_assert_time = 0;
        b_valid_assert_cycle = 0;
      end
      if (vif_proxy.is_rvalid_asserted()) begin
        if (r_valid_assert_time == 0) begin
          r_valid_assert_time = this.vif_proxy.get_current_edge_time();
          r_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
      end else begin
        r_valid_assert_time = 0;
        r_valid_assert_cycle = 0;
      end
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //WRITE ADDRESS Channel
  protected task aw_channel ();
    axi_monitor_transaction         transfer;
    xil_axi_uint                    p_id;
    mon_axi_inbound_write_queue_t   inbound_q;
    mon_axi_write_transfer_t        write_xfer;
    xil_axi_cmd_beat                cmd;
    xil_object                      cloned;
    xil_axi_cmd_beat                cmd_clone;

    forever begin : AW_LOOP
      ///////////////////////////////////////////////////////////////////////////
      //Everything kicks off when an event is triggered
      vif_proxy.wait_aw_accepted();
      num_inflight_wr_transactions++;
      ///////////////////////////////////////////////////////////////////////////
      //Determine if the devive has accepted more commands than it should have!!
      if (this.transaction_depth_checks_enabled == 1) begin
        AXI_MON_WR_TRANSACTION_DEPTH_EXCEEDED: assert(this.num_inflight_wr_transactions <= this.get_wr_transaction_depth()) else begin
          `xil_warning(this.get_tag(),
            $sformatf("AXI_MON_WR_TRANSACTION_DEPTH_EXCEEDED: Inflight %d, max depth %d ",
              num_inflight_wr_transactions, this.get_wr_transaction_depth()))
        end
      end
      cmd = vif_proxy.get_awcmd();

      AXI_MON_AWID_UNKNOWN : assert(!($isunknown(cmd.id))) else begin
        `xil_error(this.get_tag(), "Unknown value found on AWID... Bad things WILL happend")
        cmd.id = 0;
      end
      ///////////////////////////////////////////////////////////////////////////
      //Send copies to the analysis ports
      cmd_clone = cmd.my_clone();
      axi_cmd_port.write(cmd_clone);
      cmd_clone = cmd.my_clone();
      axi_wr_cmd_port.write(cmd_clone);
      p_id = cmd.id;
      ///////////////////////////////////////////////////////////////////////////
      //Is there a currently active transaction with the same ID.
      if (!incoming_write.exists(p_id)) begin
        ///////////////////////////////////////////////////////////////////////////
        //No. Create a new transaction queue and link it upto the ID array
        inbound_q = new(p_id);
        incoming_write[p_id] = inbound_q;
      end else begin
        ///////////////////////////////////////////////////////////////////////////
        //Yes. Get the transaction queue for that ID
        inbound_q = incoming_write[p_id];
      end

      ///////////////////////////////////////////////////////////////////////////
      //Get the first element for the ID where the ADDR phase has not been completed
      write_xfer = inbound_q.get_first_no_addr_phase();
      ///////////////////////////////////////////////////////////////////////////
      //Get the transfer from the element
      transfer = write_xfer.get_transfer();
      transfer.set_name($sformatf("AXI_WMON%0d_%0d", p_id, transfer.get_cmd_id()));
      transfer.set_axi_version(this.get_axi_version());
      transfer.set_data_width(C_AXI_WDATA_WIDTH);
      transfer.set_addr_width(C_AXI_ADDR_WIDTH);
      transfer.set_awuser_width(C_AXI_AWUSER_WIDTH);
      transfer.set_wuser_width(C_AXI_WUSER_WIDTH);
      transfer.set_buser_width(C_AXI_BUSER_WIDTH);
      transfer.set_id_width(C_AXI_WID_WIDTH);
      transfer.set_supports_narrow(C_AXI_SUPPORTS_NARROW);
      transfer.set_has_burst(C_AXI_HAS_BURST);
      transfer.set_has_lock(C_AXI_HAS_LOCK);
      transfer.set_has_cache(C_AXI_HAS_CACHE);
      transfer.set_has_region(C_AXI_HAS_REGION);
      transfer.set_has_prot(C_AXI_HAS_PROT);
      transfer.set_has_qos(C_AXI_HAS_QOS);
      transfer.set_has_wstrb(C_AXI_HAS_WSTRB);
      transfer.set_has_bresp(C_AXI_HAS_BRESP);
      transfer.set_has_rresp(C_AXI_HAS_RRESP);

      transfer.import_cmd_fields(cmd);

      if (aw_ready_assert_time == 0) begin
        aw_ready_assert_time = this.vif_proxy.get_current_edge_time();
        aw_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
      end
      if (aw_valid_assert_time == 0) begin
        aw_valid_assert_time = this.vif_proxy.get_current_edge_time();
        aw_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
      end
      transfer.trigger_addr_phase_end(
        .ready_time(aw_ready_assert_time), 
        .valid_time(aw_valid_assert_time),
        .ready_cycle(aw_ready_assert_cycle), 
        .valid_cycle(aw_valid_assert_cycle),
        .now(this.vif_proxy.get_current_clk_count())
      );

      clear_aw_assert_times();
      transfer.trigger_transaction_phase_start();
      ///////////////////////////////////////////////////////////////////////////
      //Set the status of the write xfer to indicated that it is complete
      write_xfer.set_addr_phase_complete();
      this.push_reconcile_q(write_xfer);
    end //forever begin
  endtask : aw_channel

  protected task w_channel ();
    xil_axi_write_beat                  beat;
    mon_beat_q_t                    w_channel_beat_q;
    bit                             found_last;
    xil_axi_write_beat                  beat_clone;
    forever begin : W_LOOP
      found_last = 0;
      w_channel_beat_q = new;
      ///////////////////////////////////////////////////////////////////////////
      //Create a beat queue to collect all incomming beats. When the LAST is detected
      // move the entire beat queue to the reconcile queue.
      while (!found_last) begin
        ///////////////////////////////////////////////////////////////////////////
        //Constant driver
        vif_proxy.wait_w_accepted();
        beat = vif_proxy.get_wdata();
        beat_clone = beat.my_clone();
        axi_wr_beat_port.write(beat_clone);

        if (w_ready_assert_time == 0) begin
          w_ready_assert_time = this.vif_proxy.get_current_edge_time();
          w_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
        end
        if (w_valid_assert_time == 0) begin
          w_valid_assert_time = this.vif_proxy.get_current_edge_time();
          w_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
        end

        beat.trigger_data_beat_accepted(
          .ready_time(w_ready_assert_time), 
          .valid_time(w_valid_assert_time), 
          .ready_cycle(w_ready_assert_cycle), 
          .valid_cycle(w_valid_assert_cycle)
        );
        clear_w_assert_times();
        w_channel_beat_q.push_back(beat);
        if (beat.last == 1'b1) begin
          found_last = 1;
        end
      end
      ///////////////////////////////////////////////////////////////////////////
      //Pass the transfer to the done queue for reconcilation
      push_reconcile_data_q(w_channel_beat_q);
    end //forever begin
  endtask : w_channel

  protected task b_channel ();
    xil_axi_uint                        p_id;
    axi_monitor_transaction         transfer;
    mon_axi_write_transfer_t        write_xfer;
    mon_axi_inbound_write_queue_t   inbound_q;
    xil_axi_resp_beat                   bresp;
    mon_beat_q_t                    data_xfer;
    forever begin : B_LOOP
      ///////////////////////////////////////////////////////////////////////////
      //Constant driver
      vif_proxy.wait_b_accepted();
      bresp = vif_proxy.get_bresp();

      axi_bresp_port.write(bresp);
      bresp = vif_proxy.get_bresp();
      p_id = bresp.id;
      ///////////////////////////////////////////////////////////////////////////
      //Since this is the RESP, there must be an ID look up for it!
      AXI_ERRS_BRESP: assert(incoming_write.exists(p_id)) else begin
        `xil_fatal(this.get_tag(),
          $sformatf("AXI_ERRS_BRESP. A slave must only give a write response after the last write data item is transferred. Spec: section 3.3 on page 3-7, and figure 3-5 on page 3-8. BID=0x%x no ID Found", p_id))
      end
      ///////////////////////////////////////////////////////////////////////////
      //Get the queue for that ID
      inbound_q = incoming_write[p_id];
      ///////////////////////////////////////////////////////////////////////////
      //Get the first xfer on the list for this ID that has not completed the
      // Response phase.
      write_xfer = inbound_q.get_first_no_resp_phase();
      transfer = write_xfer.get_transfer();
      ///////////////////////////////////////////////////////////////////////////
      //Update the response
      transfer.set_bresp(bresp.resp);
      if (C_AXI_BUSER_WIDTH > 0) begin
        transfer.set_buser(bresp.get_user());
      end
      if (b_ready_assert_time == 0) begin
        b_ready_assert_time = this.vif_proxy.get_current_edge_time();
        b_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
      end
      if (b_valid_assert_time == 0) begin
        b_valid_assert_time = this.vif_proxy.get_current_edge_time();
        b_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
      end
      transfer.trigger_bresp_phase_end(
        .ready_time(b_ready_assert_time), 
        .valid_time(b_valid_assert_time),
        .ready_cycle(b_ready_assert_cycle), 
        .valid_cycle(b_valid_assert_cycle)
      );
      clear_bresp_assert_times();
      write_xfer.set_resp_inflight();
      write_xfer.set_resp_phase_complete();

      ///////////////////////////////////////////////////////////////////////////
      //Assertion Checking
      // INDEX:        - AXI_ERRS_BRESP_EXOKAY
      if (transfer.get_lock() == XIL_AXI_ALOCK_EXCL) begin
        AXI_ERRS_BRESP_EXOKAY : assert ((bresp.resp == XIL_AXI_RESP_EXOKAY) || (bresp.resp == XIL_AXI_RESP_OKAY)) else begin
          `xil_error(this.get_tag(),"AXI4_ERRS_BRESP_EXOKAY: An EXOKAY write response can only be given to an exclusive write access. Spec: section A7.2.")
        end
      end else begin
        AXI_ILLEGAL_RESPONSE_NORMAL_WRITE : assert (!(bresp.resp == XIL_AXI_RESP_EXOKAY)) else begin
          `xil_error(this.get_tag(),"AXI_ILLEGAL_RESPONSE_NORMAL_WRITE. An EXOKAY response should not be returned for a normal (nonexclusive) write operation.")
        end
      end

      ///////////////////////////////////////////////////////////////////////////
      //if all the phases are complete (AW/W/B) then the transfer is done and pass
      // it to the done queue. The completed write_xfer must be at the head of the queue!
      if (write_xfer.all_phase_complete()) begin
        write_xfer = inbound_q.pop_front();
        data_xfer = write_xfer.get_beat_q();
        this.check_burst(transfer, data_xfer);
        write_xfer.store_wdata();
        transfer.trigger_transaction_phase_end();
        ///////////////////////////////////////////////////////////////////////////
        //Are there any more pending transfers for this ID? if not tear down the
        // entries.
        if (inbound_q.get_num_entries() == 0) begin
          incoming_write.delete(p_id);
        end
        ///////////////////////////////////////////////////////////////////////////
        //Decrement the number of inflight writes
        num_inflight_wr_transactions--;
        ///////////////////////////////////////////////////////////////////////////
        //Pass the transfer to the done queue for reconcilation
        push_done_q(transfer);
      end else begin
        ///////////////////////////////////////////////////////////////////////////
        //BRESP cannot be received early
        AXI_WRITE_RESPONSE_WITHOUT_DATA:
          assert (0) else begin
          `xil_error(this.get_tag(),
            "AXI_WRITE_RESPONSE_WITHOUT_DATA: Write response should not be sent before the corresponding write data burst is completed.")
        end
      end
    end //forever begin
  endtask : b_channel

  /*
   Function:  create_transaction
   Returns an AXI monitor transaction class that has been "newed" 
  */
  virtual function axi_monitor_transaction create_transaction (string name = "unnamed_transaction", xil_axi_cmd_t dir);
    axi_monitor_transaction item = new(name);
    item.set_cmd_type(dir);
    item.set_protocol(C_AXI_PROTOCOL);
    item.set_addr_width(C_AXI_ADDR_WIDTH );
    if (dir == XIL_AXI_READ) begin
      item.set_data_width(C_AXI_RDATA_WIDTH);
      item.set_id_width(C_AXI_RID_WIDTH);
      item.set_aruser_width(C_AXI_ARUSER_WIDTH);
      item.set_ruser_width(C_AXI_RUSER_WIDTH);
    end else begin
      item.set_data_width(C_AXI_WDATA_WIDTH);
      item.set_id_width(C_AXI_WID_WIDTH);
      item.set_awuser_width(C_AXI_AWUSER_WIDTH);
      item.set_wuser_width(C_AXI_WUSER_WIDTH);
      item.set_buser_width(C_AXI_BUSER_WIDTH);
    end
    item.set_supports_narrow(C_AXI_SUPPORTS_NARROW);
    if (C_AXI_SUPPORTS_NARROW == 0) begin
      item.set_size(item.get_dw_size());
    end
    item.set_has_burst(C_AXI_HAS_BURST);
    if (C_AXI_HAS_BURST == 0) begin
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
    end
    item.set_has_lock(C_AXI_HAS_LOCK);
    if (C_AXI_HAS_LOCK == 0) begin
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
    end
    item.set_has_cache(C_AXI_HAS_CACHE);
    item.set_has_region(C_AXI_HAS_REGION);
    if (C_AXI_HAS_REGION == 0) begin
      item.set_region(0);
    end
    item.set_has_prot(C_AXI_HAS_PROT);
    if (C_AXI_HAS_PROT == 0) begin
      item.set_prot(0);
    end
    item.set_has_qos(C_AXI_HAS_QOS);
    if (C_AXI_HAS_QOS == 0) begin
      item.set_qos(0);
    end
    item.set_has_wstrb(C_AXI_HAS_WSTRB);
    item.set_has_bresp(C_AXI_HAS_BRESP);
    item.set_has_rresp(C_AXI_HAS_RRESP);
    item.clr_beat_index();
    if (item.get_axi_version() == XIL_VERSION_LITE) begin
      item.set_id(0);
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
      item.set_size(item.get_dw_size());
      item.set_len(0);
      item.set_qos(0);
      item.set_region(0);
    end
    return(item);
  endfunction :create_transaction

  protected task ar_channel ();
    axi_monitor_transaction   transfer;
    xil_axi_uint              p_id;
    mon_transaction_q_t       inbound_q;
    xil_axi_cmd_beat          cmd;
    xil_object                cloned;
    xil_axi_cmd_beat          cmd_clone;

    num_inflight_rd_transactions = 0;
    forever begin : AR_LOOP
      ///////////////////////////////////////////////////////////////////////////
      //Constant driver
      vif_proxy.wait_ar_accepted();
      num_inflight_rd_transactions++;
      ///////////////////////////////////////////////////////////////////////////
      //Determine if the devive has accepted more commands than it should have!!
      if (transaction_depth_checks_enabled) begin
        AXI_MON_RD_TRANSACTION_DEPTH_EXCEEDED: assert(num_inflight_rd_transactions <= rd_transaction_depth) else begin
          `xil_warning(this.get_tag(),
            $sformatf("AXI_MON_RD_TRANSACTION_DEPTH_EXCEEDED: Inflight %d, max depth %d ",
              num_inflight_rd_transactions, rd_transaction_depth))
        end
      end
      cmd = vif_proxy.get_arcmd();
      AXI_MON_ARID_UNKNOWN : assert(!($isunknown(cmd.id))) else begin
        `xil_error(this.get_tag(), "Unknown value found on ARID... Bad things will happend")
        cmd.id = 0;
      end

      ///////////////////////////////////////////////////////////////////////////
      //Send copies to the analysis ports
      cmd_clone = cmd.my_clone();
      axi_cmd_port.write(cmd_clone);
      cmd_clone = cmd.my_clone();
      axi_rd_cmd_port.write(cmd_clone);

      p_id = cmd.id;
      ///////////////////////////////////////////////////////////////////////////
      //Does the ID exist? If it does fine, else create one.
      if (!incoming_read.exists(p_id)) begin
        inbound_q = new();
        incoming_read[p_id] = inbound_q;
      end else begin
        inbound_q = incoming_read[p_id];
      end
      transfer = this.create_transaction($sformatf("AXI_RMON%0d", p_id), XIL_AXI_READ);
      transfer.set_name($sformatf("%s_%0d", transfer.get_name(), transfer.get_cmd_id()));
      inbound_q.push_back(transfer);

      transfer.import_cmd_fields(cmd);

      if (ar_ready_assert_time == 0) begin
        ar_ready_assert_time = this.vif_proxy.get_current_edge_time();
        ar_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
      end
      if (ar_valid_assert_time == 0) begin
        ar_valid_assert_time = this.vif_proxy.get_current_edge_time();
        ar_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
      end
      transfer.trigger_addr_phase_end(
        .ready_time(ar_ready_assert_time), 
        .valid_time(ar_valid_assert_time),
        .ready_cycle(ar_ready_assert_cycle), 
        .valid_cycle(ar_valid_assert_cycle),
        .now(this.vif_proxy.get_current_clk_count())
      );
      clear_ar_assert_times();
      transfer.trigger_data_phase_start();
      ///////////////////////////////////////////////////////////////////////////
      //Set the status of the write xfer to indicated that it is complete
      transfer.trigger_transaction_phase_start();
    end //forever begin
  endtask : ar_channel

  protected task r_channel ();
    axi_monitor_transaction   transfer;
    xil_axi_uint              p_id;
    mon_transaction_q_t       inbound_q;
    xil_axi_read_beat         beat;
    xil_axi_read_beat         beat_clone;
    forever begin : R_LOOP
      ///////////////////////////////////////////////////////////////////////////
      //Constant driver
      vif_proxy.wait_r_accepted();;
      beat = vif_proxy.get_rdata();
      beat_clone = beat.my_clone();
      axi_rd_beat_port.write(beat_clone);
      p_id = beat.id;
      AXI_READ_DATA_BEFORE_ADDRESS : assert(incoming_read.exists(p_id)) else begin
        `xil_fatal(this.get_tag(),
          $sformatf("AXI_READ_DATA_BEFORE_ADDRESS: Read data transfer should not be performed before the corresponding read address. RID=0x%x with no ADDR Phase", p_id))
      end
      ///////////////////////////////////////////////////////////////////////////
      //Get the head of the ID list
      inbound_q = incoming_read[p_id];
      transfer = inbound_q.peek_front();

      transfer.import_rd_beat(beat);

      // wait for next data beat or notify transaction completion
      if (this.r_ready_assert_time == 0) begin
        r_ready_assert_time = this.vif_proxy.get_current_edge_time();
        r_ready_assert_cycle = this.vif_proxy.get_current_clk_count();
      end
      if (this.r_valid_assert_time == 0) begin
        r_valid_assert_time = this.vif_proxy.get_current_edge_time();
        r_valid_assert_cycle = this.vif_proxy.get_current_clk_count();
      end

      transfer.trigger_data_beat_accepted(
        .ready_time(r_ready_assert_time), 
        .valid_time(r_valid_assert_time),
        .ready_cycle(r_ready_assert_cycle), 
        .valid_cycle(r_valid_assert_cycle)
      );
      clear_r_assert_times();
      if (beat.last == 0) begin
        transfer.increment_beat_index();
      end else begin
        transfer.trigger_data_phase_end();
        transfer.trigger_transaction_phase_end();
        num_inflight_rd_transactions--;
        push_done_q(transfer);
        ///////////////////////////////////////////////////////////////////////////
        //Are there more than one read pending for this ID?
        if (inbound_q.get_num_entries() > 1) begin
          transfer = inbound_q.pop_front();
        end else begin
          incoming_read.delete(p_id);
        end
      end
    end //forever begin
  endtask : r_channel

  protected function void check_burst(
    inout axi_monitor_transaction transfer,
    inout mon_beat_q_t            data_xfer
    );

    bit [6:0]     strb_addr;        // address used to check WSTRB
    bit [9:0]     wrap_mask_wide;   // address mask for wrapping bursts
    bit [6:0]     wrap_mask;        // relevant bits WrapMaskWide
    xil_axi_uint      num_bytes;        // number of bytes in the burst

    strb_addr = transfer.get_addr();
    num_bytes = transfer.get_num_bytes_in_transaction();

    if (C_AXI_HAS_WSTRB == 1) begin : WITH_WSTRB
      ///////////////////////////////////////////////////////////////////////////
      //Check each entry in the transfer
      if ((transfer.get_len() + 1) == data_xfer.get_num_entries()) begin
        for(xil_axi_uint loop = 0; loop <= transfer.get_len(); loop++) begin
          AXI_WRITE_STROBE_ON_INVALID_BYTE_LANES : assert (check_strb(strb_addr, transfer.get_size(), data_xfer.peek_index(loop))) else begin
            `xil_error(this.get_tag(), "AXI_WRITE_STROBE_ON_INVALID_BYTE_LANES: Write strobes must only be asserted for the correct byte lanes as determined from start address, transfer size and beat number. Spec: section A3.4.3.")
          end
          ///////////////////////////////////////////////////////////////////////////
          // Increment aligned strb_addr
          // fixed bursts don't increment or align the address
          if (transfer.get_burst() != XIL_AXI_BURST_TYPE_FIXED) begin
            ///////////////////////////////////////////////////////////////////////////
            // align and increment address,
            // Address is incremented from an aligned version
            // align to size
            strb_addr = strb_addr & (7'b111_1111 - (7'h01 << transfer.get_size()) + 7'h01);
            ///////////////////////////////////////////////////////////////////////////
            // increment
            strb_addr = strb_addr + (7'h01 << transfer.get_size());
            if (transfer.get_burst() == XIL_AXI_BURST_TYPE_WRAP) begin
              ///////////////////////////////////////////////////////////////////////////
              // To wrap the address, need 10 bits
              wrap_mask_wide = (10'b11_1111_1111 - num_bytes + 10'h001);
              ///////////////////////////////////////////////////////////////////////////
              // Only 7 bits of address are necessary to calculate strobe
              wrap_mask = wrap_mask_wide[6:0];
              ///////////////////////////////////////////////////////////////////////////
              // upper bits remain stable for wrapping bursts depending on the
              // number of bytes in the burst
              strb_addr = (transfer.get_addr() & wrap_mask) | (strb_addr & ~wrap_mask);
            end
          end
        end
      end
    end else begin : NO_STRB
      AXI_UNALIGNED_ADDRESS_WITH_NO_STRB : assert ((transfer.get_addr() & ((1 << convert_dw_to_axi_size(transfer.get_data_width())) - 1)) == 0) else begin
        `xil_error(this.get_tag(), $sformatf("AXI Address (0x%0x) cannot be unaligned when HAS_STRB is 0", transfer.get_addr()))
      end
    end
  endfunction


///////////////////////////////////////////////////////////////////////////
// INDEX:        - CheckStrb
// =====
  protected function bit check_strb(
    input bit [6:0]       strb_addr,
    input xil_axi_size_t      strb_size,
    input xil_axi_write_beat  beat
    );
    logic [(C_AXI_WDATA_WIDTH/8)-1:0]  strb_mask;
    xil_axi_uint  error_cnt;


    ///////////////////////////////////////////////////////////////////////////
    // The basic strobe for an aligned address
    strb_mask = ({{(C_AXI_WDATA_WIDTH/8)-1{1'b0}}, 1'b1} << ({{(C_AXI_WDATA_WIDTH/8)-1{1'b0}}, 1'b1} << strb_size)) - {{(C_AXI_WDATA_WIDTH/8)-1{1'b0}}, 1'b1};
    ///////////////////////////////////////////////////////////////////////////
    // Zero the unaligned byte lanes
    // Note: the number of unaligned byte lanes is given by:
    // (strb_addr & ((1 << strb_size) - 1)), i.e. the unaligned part of the
    // address with respect to the transfer size
    //
    // Note! {{(C_AXI_WDATA_WIDTH/8)-1{1'b0}}, 1'b1} gives 1 in the correct vector length
    // Mask off unaligned byte lanes shift the strb mask left by the number of unaligned byte lanes
    strb_mask = strb_mask & (strb_mask <<
        (strb_addr & (({{(C_AXI_WDATA_WIDTH/8)-1{1'b0}}, 1'b1} << strb_size) -  {{(C_AXI_WDATA_WIDTH/8)-1{1'b0}}, 1'b1})));

    ///////////////////////////////////////////////////////////////////////////
    // Shift mask into correct byte lanes
    // Note: ((C_AXI_WDATA_WIDTH/8)-1 << strb_size) & (C_AXI_WDATA_WIDTH/8)-1 is used as a mask on the address
    // to pick out the bits significant bits, with respect to the bus width and
    // transfer size, for shifting the mask to the correct byte lanes.
    strb_mask = strb_mask << (strb_addr & (((C_AXI_WDATA_WIDTH/8)-1 << strb_size) & (C_AXI_WDATA_WIDTH/8)-1));

    ///////////////////////////////////////////////////////////////////////////
    // check for strobe error
    error_cnt = 0;
    for (xil_axi_uint bit_cnt = 0; bit_cnt < (C_AXI_WDATA_WIDTH/8); bit_cnt++) begin
      if (beat.strb[bit_cnt] & ~strb_mask[bit_cnt]) begin
        error_cnt++;
      end
    end
    return(!(error_cnt > 0));
  endfunction


endclass : axi_monitor

/*
 Class: axi_transaction_container
 AXI transaction container object
*/
class axi_transaction_container extends xil_axi_transaction_state;
  axi_transaction       trans;

  /*
   Function: new
   Constructor to create a new axi transaction container and also sets its transaction.
  */
  function new(axi_transaction trans);
    super.new();
    this.set_trans(trans);
  endfunction

  /*
   Function: get_trans
   Returns the transaction of axi transaction container
  */
  function axi_transaction get_trans();
    return(this.trans);
  endfunction

  /*
   Function: set_trans
   Sets the transaction of axi transaction container
  */
  function void set_trans(
    axi_transaction   trans
  );
    this.trans = trans;
  endfunction

endclass : axi_transaction_container

/*
  Class: axi_mst_wr_driver
  AXI Master Write Driver object. The Driver will issue drive on the commands on the AW channel and payload on the
  W channel. It will declare the transaction as complete when the B channel is acknowledge with the same ID.
*/
class axi_mst_wr_driver `AXI_PARAM_DECL extends xil_driver #(axi_transaction,axi_transaction);

  ///////////////////////////////////////////////////////////////////////////
  // user configurable parameters
  protected xil_axi_uint                wr_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected axi_ready_gen_t             bready_gen;
  protected axi_ready_gen_t             bready_gen_q[$];
  protected xil_axi_uint                awaddr_watchdog_delay = 100;
  protected xil_axi_uint                num_transactions_inflight = 0;
  protected xil_axi_int                 num_active_awrequests = 0;
  protected xil_axi_uint                driver_imposed_min_beat_delay = 0;
  protected xil_axi_ulong               current_beat_submit_cycle;
  protected xil_axi_uint                waiting_valid_timeout_value = 500000;
  protected xil_axi_uint                forward_progress_timeout_value = 50000;
  protected xil_axi_boolean_t           adjust_addr_delay_enabled = XIL_AXI_TRUE;
  protected xil_axi_boolean_t           adjust_data_beat_delay_enabled = XIL_AXI_TRUE;
  protected xil_axi_boolean_t           halted_state = XIL_AXI_FALSE;

  ///////////////////////////////////////////////////////////////////////////
  // AXI interface
  axi_vif_mem_proxy `AXI_PARAM_ORDER vif_proxy;
  xil_seq_item_pull_port #(axi_ready_gen, axi_ready_gen) bready_seq_item_port;
  xil_seq_item_pull_port #(axi_transaction, axi_transaction) return_seq_item_port;

  ///////////////////////////////////////////////////////////////////////////
  // internal channel queues
  protected axi_transaction_container       aw_q[$];
  protected axi_transaction_container       w_q[$];
  protected axi_transaction_container       b_q[$];
  protected axi_transaction_container       done_q[$];
  protected xil_axi_uint                    aw_q_entries;
  protected xil_axi_uint                    w_q_entries;
  protected xil_axi_uint                    b_q_entries;
  protected xil_axi_uint                    done_q_entries;

  ///////////////////////////////////////////////////////////////////////////
  // internal events
  event                                     done_q_entries_event ;
  event                                     b_q_entries_event ;
  event                                     num_transactions_inflight_event ;
  event                                     aw_q_entries_event ;
  event                                     w_q_entries_event ;
  event                                     num_active_awrequests_event ;

  mailbox #(xil_axi_uint)                   mbx_data_before_cmd;
  mailbox #(xil_axi_uint)                   mbx_cmd_before_data;

  /*
    Function: new
    Constructor to create a new AXI master write driver
  */
  function new(string name = "unnamed_axi_mst_wr_driver");
    super.new(name);
    this.aw_q_entries = 0;
    this.w_q_entries = 0;
    this.b_q_entries = 0;
    this.done_q_entries = 0;
    this.num_transactions_inflight = 0;
    this.num_active_awrequests = 0;
    mbx_data_before_cmd = new ();
    mbx_cmd_before_data = new ();
    bready_seq_item_port = new("bready_seq_item_port");
    this.bready_gen = new("bready_gen");
    this.clr_halted_state();
  endfunction

  /*
    Function: set_vif
    Assigns the virtual interface of the driver.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    this.vif_proxy = vif;
  endfunction : set_vif

  ///////////////////////////////////////////////////////////////////////////
  //Configuration knobs
  /*
    Function:  set_bready_gen
    Sets bready_gen of the AXI master write driver
  */
  function void set_bready_gen(input axi_ready_gen_t new_gen);
    this.bready_gen = new_gen;
  endfunction

  /*
    Function: get_bready_gen
    Returns bready_gen of the AXI master write driver
  */
  function axi_ready_gen_t get_bready_gen();
    return(this.bready_gen);
  endfunction

  /*
    Function: set_forward_progress_timeout_value
    Sets forward_progress_timeout_value of the Driver
  */
  function void set_forward_progress_timeout_value (input xil_axi_uint new_timeout);
    this.forward_progress_timeout_value  = new_timeout;
  endfunction

  /*
   Function: get_forward_progress_timeout_value
   Returns forward_progress_timeout_value of the Driver
  */
  function xil_axi_uint get_forward_progress_timeout_value ();
    return(this.forward_progress_timeout_value );
  endfunction

  protected function xil_axi_boolean_t get_halted_state();
    return(this.halted_state);
  endfunction : get_halted_state

  protected function void set_halted_state();
    this.halted_state = XIL_AXI_TRUE;
  endfunction : set_halted_state

  protected function void clr_halted_state();
    this.halted_state = XIL_AXI_FALSE;
  endfunction : clr_halted_state

  /*
    Function: set_wr_transaction_depth
    Sets the number of WRITE transactions that the Driver will have in flight at one time.
  */
  function void set_transaction_depth(input xil_axi_uint new_depth);
    if (new_depth == 0) begin
      `xil_warning(this.get_tag(), "Setting the WRITE transaction Depth to 0. No transactions will be issued")
    end
    this.wr_transaction_depth = new_depth;
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Driver will have in flight at one time.
  */
  function xil_axi_uint get_transaction_depth();
    if (this.get_halted_state() == XIL_AXI_TRUE) begin
      return(0);
    end else begin
      return(this.wr_transaction_depth);
    end
  endfunction

  /*
    Function: set_awaddr_watchdog_delay
    Sets awaddr_watchdog_delay of the Driver
  */
  function void set_awaddr_watchdog_delay(input xil_axi_uint new_depth);
    this.awaddr_watchdog_delay = new_depth;
  endfunction

  /*
    Function: get_awaddr_watchdog_delay
    Returns awaddr_watchdog_delay of the Driver
  */
  function xil_axi_uint get_awaddr_watchdog_delay();
    return(this.awaddr_watchdog_delay);
  endfunction

  protected function void set_next_cmd_submit_time(input xil_axi_ulong now);
    if (aw_q_entries > 0) begin
      aw_q[0].trans.set_submit_time($time);
      aw_q[0].trans.set_submit_cycle(now);
    end
  endfunction

  /*
    Function: get_adjust_addr_delay_enabled
    Returns the current state of adjust_addr_delay_enabled.
  */
  virtual function xil_axi_boolean_t get_adjust_addr_delay_enabled();
    return(this.adjust_addr_delay_enabled);
  endfunction: get_adjust_addr_delay_enabled

  /*
    Function: set_adjust_addr_delay_enabled
    Sets the value of adjust_addr_delay_enabled of the transaction.
  */
  virtual function void set_adjust_addr_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_addr_delay_enabled = update;
  endfunction: set_adjust_addr_delay_enabled

  /*
    Function: get_adjust_data_beat_delay_enabled
    Returns the current state of adjust_data_beat_delay_enabled.
  */
  virtual function xil_axi_boolean_t get_adjust_data_beat_delay_enabled();
    return(this.adjust_data_beat_delay_enabled);
  endfunction: get_adjust_data_beat_delay_enabled

  /*
    Function: set_adjust_data_beat_delay_enabled
    Sets the value of adjust_data_beat_delay_enabled of the transaction.
  */
  virtual function void set_adjust_data_beat_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_data_beat_delay_enabled = update;
  endfunction: set_adjust_data_beat_delay_enabled

  protected function void adjust_current_beat_delay(axi_transaction transfer);
    xil_axi_uint  delta_cycles;
    if (this.get_adjust_addr_delay_enabled() == XIL_AXI_TRUE) begin
      delta_cycles = this.vif_proxy.get_current_clk_count() - current_beat_submit_cycle;
      ///////////////////////////////////////////////////////////////////////////
      //Insert imposed beat delay to be applied at every beat.
      if (delta_cycles >= transfer.get_beat_index_delay()) begin
        transfer.set_beat_index_delay(driver_imposed_min_beat_delay);
      end else begin
        transfer.set_beat_index_delay(transfer.get_beat_index_delay() - delta_cycles + driver_imposed_min_beat_delay);
      end
    end
  endfunction

  /*
   Function: is_driver_idle
   Returns TRUE if driver is idle, else FALSE
  */
  function xil_axi_boolean_t is_driver_idle();
    if ((aw_q_entries + w_q_entries + b_q_entries + done_q_entries) > 0) begin
      return(XIL_AXI_FALSE);
    end else begin
      return(XIL_AXI_TRUE);
    end
  endfunction

  /*
    Function: get_num_transactions_inflight
    Returns number of transactions in flight
  */
  function xil_axi_uint get_num_transactions_inflight();
    return(this.num_transactions_inflight);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  // Main definition enabling all the channels.
  /*
    Function: run_phase
    Start control processes for operation
  */
  task run_phase();
    if (!this.get_is_active()) begin
      this.set_is_active();
      this.stop_triggered_event = 0;
      this.num_active_awrequests = 0;
      if (this.vif_proxy == null) begin
        `xil_fatal(this.get_tag(), $sformatf("Attempted to start %s without assigned Interface", this.get_name()))
      end
      this.vif_proxy.clr_bready();
      this.vif_proxy.reset_aw();
      this.vif_proxy.reset_w();
      this.vif_proxy.wait_posedge_aclk();
      this.vif_proxy.wait_areset_deassert();
      while (this.stop_triggered_event == 0) begin
        fork
          begin
            `xil_info(this.get_tag(), "run()", this.verbosity)
            this.run_active();
          end
          begin
            this.vif_proxy.wait_areset_asserted();
          end
          begin : STOP
            @(posedge this.stop_triggered_event);
            `xil_info(this.get_tag(), "Stop event triggered. All traffic is being terminated.",this.verbosity)
          end
        join_any
        disable fork;
        this.clr_halted_state();
        this.clean_aw_q;
        this.clean_w_q;
        this.clean_b_q;
        this.vif_proxy.reset_aw();
        this.vif_proxy.reset_w();
        this.vif_proxy.clr_bready();
        if (this.stop_triggered_event == 0) begin
          `xil_info(this.get_tag(), $sformatf("RESET DETECTED"),this.verbosity)
          this.vif_proxy.wait_areset_deassert();
          `xil_info(this.get_tag(), $sformatf("RESET Released"),this.verbosity)
        end
      end
      this.clr_is_active();
    end else begin
      `xil_warning(this.get_tag(), $sformatf("%s is already active.", this.get_name()))
    end
  endtask : run_phase

  ///////////////////////////////////////////////////////////////////////////
  //Stop the active processes.
  /*
    Function: stop_phase
    Stops all control processes.
  */
  virtual task stop_phase();
    this.stop_triggered_event = 1;
  endtask : stop_phase

  ///////////////////////////////////////////////////////////////////////////
  //Halt the active processes.
  /*
    Function: halt_phase
    Allows for all inflight transactions to complete and no new transaction will be serviced. All other transactions
    will halt.
  */
  virtual task halt_phase();
    this.set_halted_state();
    `xil_info(this.get_tag(), "HALT has been requested. Waiting for inflight transactions to complete.", XIL_AXI_VERBOSITY_NONE)
    while (this.num_transactions_inflight > 0) begin
      @(num_transactions_inflight_event);
    end
    `xil_info(this.get_tag(), "All Inflight transactions are complete.", XIL_AXI_VERBOSITY_NONE)
  endtask : halt_phase

  ///////////////////////////////////////////////////////////////////////////
  //Resume the active processes.
  /*
    Function: resume_phase
    Resumes processing of the pending transactions.
  */
  virtual task resume_phase();
    this.clr_halted_state();
    ->num_transactions_inflight_event;
    `xil_info(this.get_tag(), "RESUME has been requested. Transactions will now be processed.", XIL_AXI_VERBOSITY_NONE)
  endtask : resume_phase

  ///////////////////////////////////////////////////////////////////////////
  //Fork off the active processes.
  protected task run_active();
    fork
      this.get_and_drive();
      this.aw_channel();
      this.w_channel();
      this.b_channel();
      this.get_next_ready_item();
      this.bready_generation();
      this.service_done_q();
      this.bvalid_watchdog();
    join
  endtask

  protected task bvalid_watchdog();
    xil_axi_uint    cycle_count;
    forever begin : VALID_WATCHDOG
      while (b_q_entries == 0) begin
        @(b_q_entries_event);
      end
      cycle_count = 0;
      fork
        begin
          while (b_q_entries > 0) begin
            @(b_q_entries_event);
          end
        end
        begin
          forever begin
            vif_proxy.wait_b_accepted();
            cycle_count = 0;
          end
        end
        begin
          cycle_count = 0;
          while (cycle_count < waiting_valid_timeout_value) begin
            vif_proxy.wait_posedge_aclk();
            cycle_count++;
          end
          `xil_fatal(this.get_tag(), "No activity on B channel with pending transactions")
        end
      join_any
      disable fork;
    end
  endtask : bvalid_watchdog

   ///////////////////////////////////////////////////////////////////////////
  //Interaction thread with the sequencer.
  protected task get_and_drive();
    axi_transaction           next_item;
    axi_transaction           item;
    axi_transaction_container tc;
    ///////////////////////////////////////////////////////////////////////////
    //Continuous process getting the items from the sequencer and passing them
    // to the QUEUES
    this.num_transactions_inflight = 0;
    this.num_active_awrequests = 0;
    forever begin : GET_AND_DRIVE
      while (num_transactions_inflight >= this.get_transaction_depth()) begin
        @(num_transactions_inflight_event);
      end

      seq_item_port.get_next_item(next_item);
      item = next_item.my_clone();
      if (item.get_cmd_type() == XIL_AXI_WRITE) begin
        num_transactions_inflight++;
        ->num_transactions_inflight_event ;
        `xil_info(this.get_tag(), $sformatf("Sending transaction: \n%s",item.sprint()),verbosity)
        item.set_trans_state(XIL_AXI_TRANS_STATE_ACTIVE);
        tc = new(item);
        fork
          push_aw_q(tc);
          push_w_q(tc);
          push_b_q(tc);
        join
      end else begin
        `xil_error(this.get_tag(), "Nothing good can come from driving a READ on a WRITE channel")
      end
      seq_item_port.item_done();
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Connections to ready sequencer
  protected task get_next_ready_item();
    axi_ready_gen             next_item;
    forever begin : GNI
      bready_seq_item_port.get_next_item(next_item);
      bready_gen = next_item.my_clone();
      bready_gen_q.push_back(bready_gen);
      bready_seq_item_port.item_done();
      if (bready_gen_q.size() > 500) begin
        `xil_error(this.get_tag(), "Too many outstanding Ready objects pending.")
      end
    end : GNI
  endtask : get_next_ready_item

  ///////////////////////////////////////////////////////////////////////////
  //QUEUE management
  protected task push_aw_q(inout axi_transaction_container transfer);
    aw_q.push_back(transfer);
    aw_q_entries++;
    ->aw_q_entries_event ;
  endtask

  protected task push_w_q (inout axi_transaction_container transfer);
    w_q.push_back(transfer);
    w_q_entries++;
      ->w_q_entries_event ;
  endtask


  protected task push_b_q (inout axi_transaction_container transfer);
    b_q.push_back(transfer);
    b_q_entries++;
    ->b_q_entries_event ;
  endtask

  protected function void display_b_q_entries();
    if (b_q_entries > 0) begin
      for (xil_axi_uint i = 0; i < b_q_entries; i++) begin
        `xil_info(this.get_tag(), $sformatf("BQ(%d) %s", i, b_q[i].trans.sprint()), verbosity)
      end
    end
  endfunction

  protected task push_done_q(inout axi_transaction_container transfer);
    done_q.push_back(transfer);
    done_q_entries++;
    ->done_q_entries_event ;
  endtask

  protected task pop_aw_q (output axi_transaction_container transfer);
    while(aw_q_entries == 0) begin
      @(aw_q_entries_event);
      vif_proxy.wait_posedge_aclk_with_hold();
    end
    transfer = aw_q.pop_front();
    if (this.get_adjust_addr_delay_enabled() == XIL_AXI_TRUE) begin
      transfer.trans.adjust_addr_delay(this.vif_proxy.get_current_clk_count());
    end
    aw_q_entries--;
    ->aw_q_entries_event;
  endtask

  protected task pop_w_q (inout axi_transaction_container ret_transfer);
    axi_transaction_container transfer;
    xil_axi_uint                  mbx_entry;
    while(w_q.size() == 0) begin
      @(w_q_entries_event);
      vif_proxy.wait_posedge_aclk_with_hold();
    end
    ret_transfer = w_q.pop_front();
    w_q_entries--;
      ->w_q_entries_event ;
  endtask

  protected task pop_b_q (inout axi_transaction_container transfer);
    while(b_q.size() == 0) begin
      @(b_q_entries_event);
    end
    transfer = b_q.pop_front();
    b_q_entries--;
    ->b_q_entries_event ;
  endtask

  protected task pop_done_q(inout axi_transaction_container transfer);
    while(done_q.size() == 0) begin
      @(done_q_entries_event);
    end
    transfer = done_q.pop_front();
    done_q_entries--;
  endtask

  protected task clean_aw_q();
    axi_transaction_container tc;
    axi_transaction           transfer;
    while (aw_q_entries > 0) begin
      if (aw_q.size() > 0) begin
        tc = aw_q.pop_front();
        transfer = tc.trans;
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
          transfer.set_driver_return_item_policy(XIL_AXI_NO_RETURN);
        end
      end
      aw_q_entries--;
      ->aw_q_entries_event;
    end
  endtask

  protected task clean_w_q();
    axi_transaction_container tc;
    axi_transaction           transfer;
    while (w_q_entries > 0) begin
      if (w_q.size() > 0) begin
        tc = w_q.pop_front();
        transfer = tc.trans;
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
          transfer.set_driver_return_item_policy(XIL_AXI_NO_RETURN);
        end
      end
      w_q_entries--;
      ->w_q_entries_event ;
    end
  endtask

  protected task clean_b_q();
    axi_transaction_container tc;
    axi_transaction           transfer;
    while (b_q_entries > 0) begin
      if (b_q.size() > 0) begin
        tc = b_q.pop_front();
        transfer = tc.trans;
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
          transfer.set_driver_return_item_policy(XIL_AXI_NO_RETURN);
        end
      end
      b_q_entries--;
    ->b_q_entries_event ;
    end
  endtask

  protected task return_item_to_sequence(axi_transaction transfer);
    axi_transaction transfer_clone;
    transfer_clone = transfer.my_clone();
    this.seq_item_port.put_rsp(transfer_clone);
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Once the Packet has been completed send the completed transfer back to the
  // sequencer in the RESPONSE TLM channel
  protected task service_done_q ();
    axi_transaction_container tc;
    axi_transaction transfer;
    forever begin : SERVICE_DONE_Q
      pop_done_q(tc);
      transfer = tc.trans;
      `xil_info(this.get_tag(), $sformatf("SERVICE_DONE_Q: %s",transfer.cmd_sprintf()),verbosity)
      transfer.set_trans_state(XIL_AXI_TRANS_STATE_COMPLETED_MASTER);
      if ((transfer.get_driver_return_item_policy() == XIL_AXI_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_WLAST_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_WLAST_PAYLOAD_RETURN)) begin
        return_item_to_sequence(transfer);
      end
      this.num_transactions_inflight--;
        ->num_transactions_inflight_event ;
    end
  endtask

  ////////////////////////////////////////////////////////////////////////////
  //Main AW channel process
  protected task aw_channel();
    axi_transaction             transfer;
    axi_transaction_container   tc;
    xil_axi_uint                    beat_count;
    beat_count = 0;
    forever begin : AW_CHANNEL
      vif_proxy.reset_aw();

      ///////////////////////////////////////////////////////////////////////////
      // get next transaction out of AW channel queue. This call will block if
      // there are no transactions posted in the queue.
      pop_aw_q(tc);
      transfer = tc.trans;

      ///////////////////////////////////////////////////////////////////////////
      // There is a side effect of a back to back write with get_allow_data_before_cmd set.
      // If the first transfer's number of beats is greater than the get_allow_data_before_cmd value
      // A second transfer will actually count the beats from the first transaction.
      if ((transfer.get_xfer_wrcmd_order() == XIL_AXI_WRCMD_ORDER_DATA_BEFORE_CMD) && (transfer.get_allow_data_before_cmd() > 0)) begin
        AXI_WR_MST_ORDER_DATA_BEFORE_CMD_CONFIG: assert(transfer.get_allow_data_before_cmd() <= (transfer.get_len() + 1)) else begin
          `xil_fatal(this.get_tag(), $sformatf("XIL_AXI_WRCMD_ORDER_DATA_BEFORE_CMD: transaction incorrectly configured: waiting %d but len is %d",
            transfer.get_allow_data_before_cmd(), (transfer.get_len() + 1)))
        end
        ///////////////////////////////////////////////////////////////////////////
        //Blocking get. When the mail box has been received then proceed.
        fork
          begin
            mbx_data_before_cmd.get(beat_count);
          end
          begin
            vif_proxy.wait_aclks(get_awaddr_watchdog_delay());
            `xil_warning(this.get_tag(), $sformatf("AXI_WR_MST_ORDER_DATA_BEFORE_CMD WATCHDOG fired. Beats requested %d", transfer.get_allow_data_before_cmd()))
            transfer.set_xfer_wrcmd_order(XIL_AXI_WRCMD_ORDER_ERROR);
          end
        join_any
        disable fork;
      end
      ///////////////////////////////////////////////////////////////////////////
      // apply read request wait states. We need to not cut short the delay, so
      // we must wait until the ACLK is high.
      if (transfer.get_addr_delay() > 0) begin
        for (xil_axi_uint acnt = 0; acnt < transfer.get_addr_delay(); acnt++) begin
          fork
            vif_proxy.wait_posedge_aclk_with_hold();
            vif_proxy.put_aw_noise();
          join
        end
      end

      ///////////////////////////////////////////////////////////////////////////
      // DRIVE AW channel
      vif_proxy.put_cmd(transfer);
      ///////////////////////////////////////////////////////////////////////////
      // DRIVE valid
      vif_proxy.set_awvalid();
      this.set_next_cmd_submit_time(this.vif_proxy.get_current_clk_count());

      ///////////////////////////////////////////////////////////////////////////
      // wait for AWREADY (may have been high already)
      fork
        begin
          vif_proxy.wait_aw_accepted();
        end
        begin
          vif_proxy.wait_aclks(waiting_valid_timeout_value);
          `xil_fatal(this.get_tag(), $sformatf("AW CHANNEL never serviced (id=0x%x)", transfer.get_id()))
        end
      join_any
      disable fork;
      if (transfer.get_xfer_wrcmd_order() == XIL_AXI_WRCMD_ORDER_CMD_BEFORE_DATA) begin
        mbx_cmd_before_data.put(beat_count);
      end
      this.num_active_awrequests++;
       ->num_active_awrequests_event ;
      if ((transfer.get_driver_return_item_policy() == XIL_AXI_CMD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_WLAST_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_WLAST_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_PAYLOAD_RETURN)) begin
        return_item_to_sequence(transfer);
      end

      ///////////////////////////////////////////////////////////////////////////
      //If the WADDR is accepted before the WDATA go from ACTIVE->ADDR_COMPLETE
      tc.set_addr_phase_complete();

      transfer = null;
      #this.vif_proxy.hold_time;
    end //forever begin
  endtask : aw_channel


  protected task w_channel();
    axi_transaction           transfer;
    axi_transaction_container tc;
    xil_axi_ulong             w_channel_idle_time;
    xil_axi_uint              mbx_value;
    w_channel_idle_time = 0;
    mbx_value = 0;
    forever begin : W_CHANNEL
      vif_proxy.reset_w();

      ///////////////////////////////////////////////////////////////////////////
      // get next transaction
      pop_w_q(tc);
      transfer = tc.trans;

      ///////////////////////////////////////////////////////////////////////////
      //The transaction states that the ADDR must precede the DATA.
      // The transaction must wait until the CMD has been sent. To avoid possible
      // deadlock conditions, the watchdog_delay will be used to continue forward
      // progress.
      if (transfer.get_xfer_wrcmd_order() == XIL_AXI_WRCMD_ORDER_CMD_BEFORE_DATA) begin
        fork
          begin
            mbx_cmd_before_data.get(mbx_value);
          end
          begin
            vif_proxy.wait_aclks(get_awaddr_watchdog_delay());
            `xil_warning(this.get_tag(), "AXI_WR_MST_CMD_BEFORE_DATA_DEADLOCK : WATCHDOG fired, forward progress forced")
            transfer.set_xfer_wrcmd_order(XIL_AXI_WRCMD_ORDER_ERROR);
          end
        join_any
        disable fork;
      end

      ///////////////////////////////////////////////////////////////////////////
      // Delay the whole transfer by the data_insertion_delay.
      // ONLY if the policy is INSERTION_ALWAYS
      if ((transfer.get_xfer_wrdata_insertion_policy() == XIL_AXI_WRCMD_INSERTION_ALWAYS) || (this.vif_proxy.get_current_clk_count() > w_channel_idle_time)) begin
        if (transfer.get_data_insertion_delay() > 0) begin
          for (xil_axi_uint acnt = 0; acnt < transfer.get_data_insertion_delay(); acnt++) begin
            fork
              vif_proxy.wait_posedge_aclk_with_hold();
              vif_proxy.put_w_noise();
            join
          end
        end
      end

      current_beat_submit_cycle = this.vif_proxy.get_current_clk_count();
      ///////////////////////////////////////////////////////////////////////////
      //Drive each beat on the bus
      for (xil_axi_uint i = 0; i < (transfer.get_len() + 1); i++) begin
        vif_proxy.reset_w();

        this.adjust_current_beat_delay(transfer);
        ///////////////////////////////////////////////////////////////////////////
        //Insert the beat delay
        if (transfer.get_beat_index_delay() > 0) begin
          for (xil_axi_uint acnt = 0; acnt < transfer.get_beat_index_delay(); acnt++) begin
            fork
              vif_proxy.wait_posedge_aclk_with_hold();
              vif_proxy.put_w_noise();
            join
          end
        end

        ///////////////////////////////////////////////////////////////////////////
        // send data out on write channel
        vif_proxy.put_wdata(transfer,i);
        vif_proxy.set_wvalid();
        ///////////////////////////////////////////////////////////////////////////
        //Update the beat delay for the next beat (if applicable) based on the back pressure from the current beat.
        current_beat_submit_cycle = this.vif_proxy.get_current_clk_count();
        ///////////////////////////////////////////////////////////////////////////
        // wait for WREADY (may have been high already)
        fork
          begin
            vif_proxy.wait_w_accepted();
          end
          begin
            vif_proxy.wait_aclks(waiting_valid_timeout_value);
            `xil_fatal(this.get_tag(), $sformatf("W CHANNEL never serviced (id=0x%x)", transfer.get_id()))
          end
        join_any
        disable fork;
        if ((transfer.get_xfer_wrcmd_order() == XIL_AXI_WRCMD_ORDER_DATA_BEFORE_CMD) &&
            (transfer.get_allow_data_before_cmd() > 0) &&
            ((i + 1) == transfer.get_allow_data_before_cmd())) begin
          mbx_data_before_cmd.put(i);
        end
        ///////////////////////////////////////////////////////////////////////////
        //Increment the beat index
        transfer.increment_beat_index();
        if (i == transfer.get_len()) begin
          ///////////////////////////////////////////////////////////////////////////
          //If the WADDR is accepted after the WDATA go from ACTIVE->DATA_COMPLETE
          tc.set_data_phase_complete();
          `xil_info(this.get_tag(), $sformatf("WREADY+WLAST (%d) id=0x%x", i, transfer.get_id()),verbosity)

          ///////////////////////////////////////////////////////////////////////////
          //Return the transaction to the sequence
          if ((transfer.get_driver_return_item_policy() == XIL_AXI_CMD_WLAST_RETURN) ||
              (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_WLAST_PAYLOAD_RETURN) ||
              (transfer.get_driver_return_item_policy() == XIL_AXI_WLAST_RETURN) ||
              (transfer.get_driver_return_item_policy() == XIL_AXI_WLAST_PAYLOAD_RETURN)) begin
            return_item_to_sequence(transfer);
          end

          ///////////////////////////////////////////////////////////////////////////
          //If the wrdata insertion policy is XIL_AXI_WRCMD_INSERTION_FROM_IDLE then we must determine if there are any
          // pending
          w_channel_idle_time = this.vif_proxy.get_current_clk_count();
        end else begin
          `xil_info(this.get_tag(), $sformatf("WREADY (%d) id=0x%x", i, transfer.get_id()),verbosity)
        end
        #this.vif_proxy.hold_time;
      end
      transfer = null;
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Depending on the BREADY algorithm
  protected task bready_generation();
    ///////////////////////////////////////////////////////////////////////////
    // deassert signals
    forever begin : BREADY_GENERATION
      if (this.bready_gen_q.size()>0) begin
        this.bready_gen = this.bready_gen_q.pop_front();
      end
      ///////////////////////////////////////////////////////////////////////////
      //Get random values
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        AXI_WR_MST_BREADY_GEN: assert(this.bready_gen.randomize());
      `else
        this.bready_gen.cheap_random();
      `endif

      ///////////////////////////////////////////////////////////////////////////
      //If the ready algorithm is to wait until after VALID has been asserted, then
      // check to see if VALID is asserted, if not wait until it is sampled asserted.
      if ((this.bready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_SINGLE) ||
          (this.bready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_EVENTS) ||
          (this.bready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_OSC) ||
          ((this.bready_gen.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM) && (
            (this.bready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_SINGLE) ||
            (this.bready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_EVENTS) ||
            (this.bready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_OSC)))) begin
        vif_proxy.clr_bready();
        vif_proxy.wait_negedge_aclk();
        ///////////////////////////////////////////////////////////////////////////
        //If the valid is not asserted then wait until the posedge
        if (vif_proxy.is_live_bvalid_asserted() == 0) begin
          vif_proxy.wait_live_bvalid_asserted();
        end
      end

      ///////////////////////////////////////////////////////////////////////////
      //Wait low time then assert for one handshake
      if (this.bready_gen.get_low_time() > 0) begin
        vif_proxy.clr_bready();
        vif_proxy.wait_aclks(this.bready_gen.get_low_time());
        #this.vif_proxy.hold_time;
      end

      vif_proxy.set_bready();

      case (this.bready_gen.get_ready_policy())
        XIL_AXI_READY_GEN_AFTER_VALID_OSC,
        XIL_AXI_READY_GEN_OSC: begin
          vif_proxy.wait_aclks(this.bready_gen.get_high_time());
        end
        XIL_AXI_READY_GEN_RANDOM: begin
          case(this.bready_gen.get_ready_rand_policy())
            XIL_AXI_READY_RAND_AFTER_VALID_OSC,
            XIL_AXI_READY_RAND_OSC: begin
              this.vif_proxy.wait_aclks(this.bready_gen.get_high_time());
            end
            default : begin
              this.vif_proxy.wait_b_accepted();
            end
          endcase
        end
        default: begin
          vif_proxy.wait_b_accepted();
        end
      endcase
      #this.vif_proxy.hold_time;
    end //forever begin
  endtask : bready_generation

  protected task b_channel();
    axi_transaction           transfer;
    axi_transaction_container tc;
    int unsigned found;
    bit [(C_AXI_WID_WIDTH==0? 1:C_AXI_WID_WIDTH) -1:0] p_id;
    xil_axi_resp_beat bbeat;

    forever begin : B_CHANNEL
      ///////////////////////////////////////////////////////////////////////////
      // wait for incoming BRESP
      vif_proxy.wait_b_accepted();
      bbeat = vif_proxy.get_bresp();
      found = 0;
      for (int i = 0; (found == 0) && (i < b_q.size()); i++) begin
        found = 0;
        tc = b_q[i];
        transfer = tc.trans;
        p_id = transfer.get_id();
        if (p_id == bbeat.id) begin
          found = 1;
          b_q.delete(i);
          b_q_entries--;
           ->b_q_entries_event ;
        end
      end

      AXI_WR_DRIVER_NO_MATCHING_ID: assert(found)
        else `xil_error(this.get_tag(), $sformatf("No matching transaction for write response id=0x%x in write channel queue.",  p_id))

      if (found == 1) begin
        ///////////////////////////////////////////////////////////////////////////
        // copy BRESP from B channel to transfer
        transfer.set_bresp(bbeat.resp);
        if (C_AXI_BUSER_WIDTH > 0) begin
          transfer.set_buser(bbeat.get_user());
        end

        push_done_q(tc);
      end
    end
  endtask : b_channel

  protected task forward_progress_watchdog();
    forever begin : PROGRESS
      ///////////////////////////////////////////////////////////////////////////
      //Wait until there is at least one transaction to be processed. This is here
      // to cover the case where there are not sequence items for the read channel
      while (num_transactions_inflight == 0) begin
        @(num_transactions_inflight_event);
      end
      fork
        ///////////////////////////////////////////////////////////////////////////
        //If you get an AW or W or B accepted then restart the fork
        begin
          vif_proxy.wait_aw_accepted();
        end
        begin
          vif_proxy.wait_w_accepted();
        end
        begin
          vif_proxy.wait_b_accepted();
        end
        ///////////////////////////////////////////////////////////////////////////
        //Timeout if there is no accepted beats within forward_progress_timeout_value cycles
        begin
          vif_proxy.wait_aclks(forward_progress_timeout_value);
          if (num_transactions_inflight > 0) begin
            `xil_fatal(this.get_tag(), $sformatf("No forward progess is occuring on all channels"))
          end
        end
      join_any
      disable fork;
      vif_proxy.wait_aclks(10);
    end
  endtask : forward_progress_watchdog
  /*
   Function: send
   Sends the AXI transaction to the driver  
  */
  task send(input axi_transaction t);
    if(this.get_is_active()) begin
      this.seq_item_port.put_item(t);
      this.seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send transaction when driver is not active"))
    end
  endtask  : send

  /*
   Function: wait_rsp
   This blocking function will not return until driver send back response transaction 
  */
  task wait_rsp(output axi_transaction t);
    this.seq_item_port.get_next_rsp(t);
    this.seq_item_port.rsp_done();
  endtask  : wait_rsp

  /*
   Function: create_transaction
   Returns an axi transaction class that has been "newed"
  */
  virtual function axi_transaction create_transaction (string name = "unnamed_transaction");
    axi_transaction item = new(name);
    item.set_cmd_type(XIL_AXI_WRITE);
    item.set_protocol(C_AXI_PROTOCOL);
    item.set_addr_width(C_AXI_ADDR_WIDTH );
    item.set_data_width(C_AXI_WDATA_WIDTH);
    item.set_id_width(C_AXI_WID_WIDTH);
    item.set_awuser_width(C_AXI_AWUSER_WIDTH);
    item.set_wuser_width(C_AXI_WUSER_WIDTH);
    item.set_buser_width(C_AXI_BUSER_WIDTH);
    item.set_aruser_width(C_AXI_ARUSER_WIDTH);
    item.set_ruser_width(C_AXI_RUSER_WIDTH);
    item.set_supports_narrow(C_AXI_SUPPORTS_NARROW);
    if (C_AXI_SUPPORTS_NARROW == 0) begin
      item.set_size(item.get_dw_size());
    end
    item.set_has_burst(C_AXI_HAS_BURST);
    if (C_AXI_HAS_BURST == 0) begin
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
    end
    item.set_has_lock(C_AXI_HAS_LOCK);
    if (C_AXI_HAS_LOCK == 0) begin
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
    end
    item.set_has_cache(C_AXI_HAS_CACHE);
    item.set_has_region(C_AXI_HAS_REGION);
    if (C_AXI_HAS_REGION == 0) begin
      item.set_region(0);
    end
    item.set_has_prot(C_AXI_HAS_PROT);
    if (C_AXI_HAS_PROT == 0) begin
      item.set_prot(0);
    end
    item.set_has_qos(C_AXI_HAS_QOS);
    if (C_AXI_HAS_QOS == 0) begin
      item.set_qos(0);
    end
    item.set_has_wstrb(C_AXI_HAS_WSTRB);
    item.set_has_bresp(C_AXI_HAS_BRESP);
    item.set_has_rresp(C_AXI_HAS_RRESP);
    item.clr_beat_index();
    if (item.get_axi_version() == XIL_VERSION_LITE) begin
      item.set_id(0);
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
      item.set_size(item.get_dw_size());
      item.set_len(0);
      item.set_qos(0);
      item.set_region(0);
    end
    return(item);
  endfunction :create_transaction

  ////////////////////////////////////////////////////////////////////////////
  //send ready and wait
  /*
   Function: send_bready
   Sends the ready structure to the driver for controlling the READY channel.
  */
  task send_bready(input axi_ready_gen t);
    if(this.get_is_active()) begin
      this.bready_seq_item_port.put_item(t);
      this.bready_seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send BREADY when driver is not active"))
    end
  endtask

  /*
   Function: create_ready
   Returns a ready class that has been "newed".
  */
  virtual function axi_ready_gen create_ready (string name = "unnamed_ready");
    axi_ready_gen    ready = new(name);
    return(ready);
  endfunction

  /*
   Function: wait_driver_idle
   This is a blocking task which will wait until there are no outstanding transactions in the driver. This means that
   all the transactions send to the driver have received a corresponding B channel response.
  */
  task wait_driver_idle();
    while (this.num_transactions_inflight != 0) begin
      @(num_transactions_inflight_event);
    end
  endtask : wait_driver_idle

endclass : axi_mst_wr_driver

/*
  Class: axi_mst_rd_driver
  AXI Master Read Driver object.
*/
class axi_mst_rd_driver `AXI_PARAM_DECL extends xil_driver #(axi_transaction,axi_transaction);

  ///////////////////////////////////////////////////////////////////////////
  // user configurable parameters
  protected xil_axi_uint                rd_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected axi_ready_gen_t             rready_gen;
  protected axi_ready_gen_t             rready_gen_q[$];
  protected xil_axi_uint                num_transactions_inflight = 0 ;
  protected xil_axi_uint                waiting_valid_timeout_value = 500000;
  protected xil_axi_uint                forward_progress_timeout_value = 50000;
  protected axi_transaction             ar_inflight;
  protected xil_axi_boolean_t           adjust_addr_delay_enabled = XIL_AXI_TRUE;
  protected xil_axi_boolean_t           adjust_data_beat_delay_enabled = XIL_AXI_TRUE;
  protected xil_axi_boolean_t           halted_state = XIL_AXI_FALSE;

  ///////////////////////////////////////////////////////////////////////////
  // AXI interface -- call assign_vi to connect
  axi_vif_mem_proxy `AXI_PARAM_ORDER                     vif_proxy;
  xil_seq_item_pull_port #(axi_ready_gen, axi_ready_gen) rready_seq_item_port;

  ///////////////////////////////////////////////////////////////////////////
  // internal channel queues
  protected axi_transaction             ar_q[$];
  protected axi_transaction             r_q[$];
  protected axi_transaction             done_q[$];
  protected xil_axi_uint                ar_q_entries;
  protected xil_axi_uint                r_q_entries;
  protected xil_axi_uint                done_q_entries;
  event                                 done_q_entries_event ;
  event                                 num_transactions_inflight_event ;
  event                                 r_q_entries_event ;
  event                                 ar_q_entries_event ;

  ///////////////////////////////////////////////////////////////////////////
  // internal events
  /*
    Function: new
    Constructor to create an AXI master read driver 
  */
  function new(string name = "unnamed_axi_mst_rd_driver");
    super.new(name);
    this.ar_q_entries = 0;
    this.r_q_entries = 0;
    this.done_q_entries = 0;
    this.num_transactions_inflight = 0;
    rready_seq_item_port = new("rready_seq_item_port");
    this.rready_gen = new("rready_gen");
    this.clr_halted_state();
  endfunction

  /*
    Function: set_vif
    Assigns the virtual interface of the driver.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    this.vif_proxy = vif;
  endfunction : set_vif

  ///////////////////////////////////////////////////////////////////////////
  //Configuration knobs
  /*
    Function:  set_rrready_gen
    Sets rready_gen of the AXI master read driver
  */
  function void set_rready_gen(input axi_ready_gen_t new_method);
    this.rready_gen = new_method;
  endfunction

  /*
    Function:  get_rrready_gen
    Returns rready_gen of the AXI master read driver
  */
  function axi_ready_gen_t get_rready_gen();
    get_rready_gen = this.rready_gen;
  endfunction

  /*
    Function: set_forward_progress_timeout_value
    Sets forward_progress_timeout_value of the Driver
  */
  function void set_forward_progress_timeout_value (input xil_axi_uint new_timeout);
    this.forward_progress_timeout_value  = new_timeout;
  endfunction

  /*
   Function: get_forward_progress_timeout_value
   Returns forward_progress_timeout_value of the Driver
  */
  function xil_axi_uint get_forward_progress_timeout_value ();
    return(this.forward_progress_timeout_value );
  endfunction

  protected function xil_axi_boolean_t get_halted_state();
    return(this.halted_state);
  endfunction : get_halted_state

  protected function void set_halted_state();
    this.halted_state = XIL_AXI_TRUE;
  endfunction : set_halted_state

  protected function void clr_halted_state();
    this.halted_state = XIL_AXI_FALSE;
  endfunction : clr_halted_state
  
  /*
    Function: set_wr_transaction_depth
    Sets the number of WRITE transactions that the Driver will have in flight at one time.
  */
  function void set_transaction_depth(input xil_axi_uint new_depth);
    this.rd_transaction_depth = new_depth;
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Driver will have in flight at one time.
  */
  function xil_axi_uint get_transaction_depth();
    if (this.get_halted_state() == XIL_AXI_TRUE) begin
      return(0);
    end else begin
      return(this.rd_transaction_depth);
    end
  endfunction : get_transaction_depth

  protected function void set_next_cmd_submit_time(input xil_axi_ulong now);
    if (ar_q_entries > 0) begin
      ar_q[0].set_submit_time($time);
      ar_q[0].set_submit_cycle(now);
    end
  endfunction

  /*
   Function: is_driver_idle
   Returns TRUE if driver is idle, else FALSE
  */
  function xil_axi_boolean_t is_driver_idle();
    if ((ar_q_entries + r_q_entries + done_q_entries) > 0) begin
      return(XIL_AXI_FALSE);
    end else begin
      return(XIL_AXI_TRUE);
    end
  endfunction

  /*
    Function: get_num_transactions_inflight
    Returns number of transactions in flight
  */
  function xil_axi_uint get_num_transactions_inflight();
    return(this.num_transactions_inflight);
  endfunction

  /*
    Function: get_adjust_addr_delay_enabled
    Returns the current state of adjust_addr_delay_enabled.
  */
  virtual function xil_axi_boolean_t get_adjust_addr_delay_enabled();
    return(this.adjust_addr_delay_enabled);
  endfunction: get_adjust_addr_delay_enabled

  /*
    Function: set_adjust_addr_delay_enabled
    Sets the value of adjust_addr_delay_enabled of the transaction.
  */
  virtual function void set_adjust_addr_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_addr_delay_enabled = update;
  endfunction: set_adjust_addr_delay_enabled

  /*
    Function: get_adjust_data_beat_delay_enabled
    Returns the current state of adjust_data_beat_delay_enabled.
  */
  virtual function xil_axi_boolean_t get_adjust_data_beat_delay_enabled();
    return(this.adjust_data_beat_delay_enabled);
  endfunction: get_adjust_data_beat_delay_enabled

  /*
    Function: set_adjust_data_beat_delay_enabled
    Sets the value of adjust_data_beat_delay_enabled of the transaction.
  */
  virtual function void set_adjust_data_beat_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_data_beat_delay_enabled = update;
  endfunction: set_adjust_data_beat_delay_enabled

  ///////////////////////////////////////////////////////////////////////////
  // Main definition enabling all the channels.
  /*
    Function: run_phase
    Start control processes for operation
  */
  task run_phase();
    if (!this.get_is_active()) begin
      this.set_is_active();
      this.stop_triggered_event = 0;
      if (this.vif_proxy == null) begin
        `xil_fatal(this.get_tag(), $sformatf("Attempted to start %s without assigned Interface", this.get_name()))
      end
      this.vif_proxy.reset_ar();
      this.vif_proxy.clr_rready();
      this.vif_proxy.wait_posedge_aclk();
      this.vif_proxy.wait_areset_deassert();
      while (this.stop_triggered_event == 0) begin
        fork
          begin
            `xil_info(this.get_tag(), "run()", verbosity)
            run_active();
          end
          begin
            vif_proxy.wait_areset_asserted();
          end
          begin : STOP
            @(posedge this.stop_triggered_event);
            `xil_info(this.get_tag(), "Stop event triggered. All traffic is being terminated.",this.verbosity)
          end
        join_any
        disable fork;
        this.clr_halted_state();
        this.clean_ar_q;
        this.clean_r_q;
        this.vif_proxy.clr_rready();
        this.vif_proxy.reset_ar();
        if (this.stop_triggered_event == 0) begin
          `xil_info(this.get_tag(), $sformatf("RESET DETECTED"),this.verbosity)
          this.vif_proxy.wait_areset_deassert();
          `xil_info(this.get_tag(), $sformatf("RESET Released"),this.verbosity)
        end
      end
      this.clr_is_active();
    end else begin
      `xil_warning(this.get_tag(), $sformatf("%s is already active.", this.get_name()))
    end
  endtask : run_phase

  ///////////////////////////////////////////////////////////////////////////
  //Stop the active processes.
  /*
    Function: stop_phase
    Stops all control processes.
  */
  virtual task stop_phase();
    this.stop_triggered_event = 1;
  endtask : stop_phase


  ///////////////////////////////////////////////////////////////////////////
  //Halt the active processes.
  /*
    Function: halt_phase
    Allows for all inflight transactions to complete and no new transaction will be serviced. All other transactions
    will halt.
  */
  virtual task halt_phase();
    this.set_halted_state();
    `xil_info(this.get_tag(), "HALT has been requested. Waiting for inflight transactions to complete.", XIL_AXI_VERBOSITY_NONE)
    while (this.num_transactions_inflight > 0) begin
      @(num_transactions_inflight_event);
    end
    `xil_info(this.get_tag(), "All Inflight transactions are complete.", XIL_AXI_VERBOSITY_NONE)
  endtask : halt_phase

  ///////////////////////////////////////////////////////////////////////////
  //Resume the active processes.
  /*
    Function: resume_phase
    Resumes processing pending transactions.
  */
  virtual task resume_phase();
    this.clr_halted_state();
    ->num_transactions_inflight_event;
    `xil_info(this.get_tag(), "RESUME has been requested. Transactions will now be processed.", XIL_AXI_VERBOSITY_NONE)
  endtask : resume_phase

  ///////////////////////////////////////////////////////////////////////////
  //Fork off the active processes.
  protected task run_active();
    fork
      this.get_and_drive();
      this.ar_channel();
      this.r_channel();
      this.get_next_ready_item();
      this.rready_generation();
      this.rvalid_watchdog();
      this.service_done_q();
      this.forward_progress_watchdog();
    join
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Triggered by the global_stop_request. When stop is triggered, we want to
  // wait until all transactions pending have been completed

  ///////////////////////////////////////////////////////////////////////////
  //Interaction thread with the sequencer.
  protected task get_and_drive();
    axi_transaction next_item;
    axi_transaction item;

    ///////////////////////////////////////////////////////////////////////////
    //Continuous process getting the items from the sequencer and passing them
    // to the QUEUES
    this.num_transactions_inflight = 0;
    forever begin : GET_AND_DRIVE
      ///////////////////////////////////////////////////////////////////////////
      //Only allow rd_transaction_depth transactions outstanding. Since the responses
      // dictate the number of transactions we monitor the number of entries in the
      // address queue.
      while (this.num_transactions_inflight >= this.get_transaction_depth()) begin
        @(this.num_transactions_inflight_event);
      end

      seq_item_port.get_next_item(next_item);
      item = next_item.my_clone();
      if (item.get_cmd_type() == XIL_AXI_READ) begin
        this.num_transactions_inflight++;
        ->num_transactions_inflight_event ;
        item.set_trans_state(XIL_AXI_TRANS_STATE_ACTIVE);
        this.push_ar_q(item);
      end else begin
        `xil_error(this.get_tag(), "Nothing good can come from driving a WRITE on a READ channel")
      end
      seq_item_port.item_done();
    end //forever begin
  endtask // get_and_drive

  ///////////////////////////////////////////////////////////////////////////
  //Connections to ready sequencer
  protected task get_next_ready_item();
    axi_ready_gen             next_item;
    forever begin : GNI
      rready_seq_item_port.get_next_item(next_item);
      rready_gen = next_item.my_clone();
      rready_gen_q.push_back(rready_gen);
      rready_seq_item_port.item_done();
      if (rready_gen_q.size() > 500) begin
        `xil_error(this.get_tag(), "Too many outstanding Ready objects pending.")
      end
    end : GNI
  endtask : get_next_ready_item

    ///////////////////////////////////////////////////////////////////////////
  //QUEUE management
  protected task push_ar_q(inout axi_transaction transfer);
    ar_q.push_back(transfer);
    ar_q_entries++;
    ->ar_q_entries_event ;
  endtask

  protected task push_r_q(inout axi_transaction transfer);
    r_q.push_back(transfer);
    r_q_entries++;
    ->r_q_entries_event ;
  endtask

  protected function void display_r_q_entries();
    if (r_q_entries > 0) begin
      for (xil_axi_uint i = 0; i < r_q_entries; i++) begin
        `xil_info(this.get_tag(), $sformatf("RQ(%d) %s", i, r_q[i].sprint()), verbosity)
      end
    end
  endfunction

  protected task push_done_q(inout axi_transaction transfer);
    done_q.push_back(transfer);
    done_q_entries++;
    ->done_q_entries_event ;
  endtask

  protected task pop_ar_q(inout axi_transaction transfer);
    while(ar_q_entries == 0) begin
      @(ar_q_entries_event);
      vif_proxy.wait_posedge_aclk_with_hold();
    end
    transfer = ar_q.pop_front();
    if (this.get_adjust_addr_delay_enabled() == XIL_AXI_TRUE) begin
      transfer.adjust_addr_delay(this.vif_proxy.get_current_clk_count());
    end
    ar_q_entries--;
    ->ar_q_entries_event ;
  endtask

  protected task pop_r_q(inout axi_transaction transfer);
    while(r_q_entries == 0) begin
      @(r_q_entries_event);
    end
    transfer = r_q.pop_front();
    r_q_entries--;
    ->r_q_entries_event ;
  endtask

  protected task pop_done_q(inout axi_transaction transfer);
    while(done_q_entries == 0) begin
      @(done_q_entries_event);
    end
    transfer = done_q.pop_front();
    done_q_entries--;
  endtask

  protected task clean_ar_q();
    axi_transaction transfer;
    while (ar_q_entries > 0) begin
      if (ar_q.size() > 0) begin
        transfer = ar_q.pop_front();
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
          transfer.set_driver_return_item_policy(XIL_AXI_NO_RETURN);
        end
      end
      ar_q_entries--;
    ->ar_q_entries_event ;
    end
    if (ar_inflight != null) begin
      if (ar_inflight.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
        return_item_to_sequence(ar_inflight);
        ar_inflight.set_driver_return_item_policy(XIL_AXI_NO_RETURN);
      end
    end
  endtask

  protected task clean_r_q();
    axi_transaction transfer;
    while (r_q_entries > 0) begin
      if (r_q.size() > 0) begin
        transfer = r_q.pop_front();
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
          transfer.set_driver_return_item_policy(XIL_AXI_NO_RETURN);
        end
      end
      r_q_entries--;
    ->r_q_entries_event ;
    end
  endtask

  protected task return_item_to_sequence(axi_transaction transfer);
    axi_transaction transfer_clone;
    transfer_clone = transfer.my_clone;
    this.seq_item_port.put_rsp(transfer_clone);
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Once the Packet has been completed send the completed transfer back to the
  // sequencer in the RESPONSE TLM channel
  protected task service_done_q ();
    axi_transaction transfer;
    forever begin : SERVICE_DONE_Q
      pop_done_q(transfer);
      transfer.set_trans_state(XIL_AXI_TRANS_STATE_COMPLETED_MASTER);
      if ((transfer.get_driver_return_item_policy() == XIL_AXI_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_PAYLOAD_RETURN)) begin
        return_item_to_sequence(transfer);
      end
      this.num_transactions_inflight--;
        ->num_transactions_inflight_event ;
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Main AR channel process
  protected task ar_channel();
    axi_transaction transfer;

    ///////////////////////////////////////////////////////////////////////////
    //Constant driver
    forever begin : AR_CHANNEL
      ///////////////////////////////////////////////////////////////////////////
      //Drive the AR bus
      vif_proxy.reset_ar();
      ///////////////////////////////////////////////////////////////////////////
      // get next transaction out of AR channel queue. This call will block if
      // there are no transactions posted in the queue.
      this.pop_ar_q(transfer);
      ar_inflight = transfer;

      ///////////////////////////////////////////////////////////////////////////
      // apply read request wait states. We need to not cut short the delay, so
      // we must wait until the ACLK is high.
      if (transfer.get_addr_delay() > 0) begin
        for (xil_axi_uint acnt = 0; acnt < transfer.get_addr_delay(); acnt++) begin
          fork
            vif_proxy.wait_posedge_aclk_with_hold();
            vif_proxy.put_ar_noise();
          join
        end
      end
      ///////////////////////////////////////////////////////////////////////////
      // Drive message
      vif_proxy.put_cmd(transfer);
      ///////////////////////////////////////////////////////////////////////////
      // send out request on read channel
      vif_proxy.set_arvalid();
      this.set_next_cmd_submit_time(this.vif_proxy.get_current_clk_count());

      `xil_info(this.get_tag(), $sformatf("ARVALID id=0x%x", transfer.get_id()),verbosity)

      ///////////////////////////////////////////////////////////////////////////
      // wait for ARREADY (may have been high already)
      fork
        begin
          vif_proxy.wait_ar_accepted();
        end
        begin
          vif_proxy.wait_aclks(waiting_valid_timeout_value);
          `xil_fatal(this.get_tag(), $sformatf("AR CHANNEL never serviced (id=0x%x)", transfer.get_id()))
        end
      join_any
      disable fork;

      if ((transfer.get_driver_return_item_policy() == XIL_AXI_CMD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_PAYLOAD_RETURN)) begin
        this.return_item_to_sequence(transfer);
      end

      ///////////////////////////////////////////////////////////////////////////
      //Since RDATA cannot precede the ARADDR Phase, it can now be handed off to
      // the Data channel
      this.push_r_q(transfer);
      ar_inflight = null;
      #this.vif_proxy.hold_time;
    end
  endtask : ar_channel

  ///////////////////////////////////////////////////////////////////////////
  //Depending on the RREADY algorithm
  protected task rready_generation();
    int unsigned  event_counter;
    forever begin : RREADY_GENERATION
      if(rready_gen_q.size()>0) begin
        this.rready_gen = rready_gen_q.pop_front();
      end
      ///////////////////////////////////////////////////////////////////////////
      //Get random values
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        AXI_RD_MST_RREADY_GEN: assert(this.rready_gen.randomize());
      `else
        this.rready_gen.cheap_random();
      `endif

      ///////////////////////////////////////////////////////////////////////////
      //If the ready algorithm is to wait until after VALID has been asserted, then
      // check to see if VALID is asserted, if not wait until it is sampled asserted.
      if ((this.rready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_SINGLE) ||
          (this.rready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_EVENTS) ||
          (this.rready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_OSC) ||
          ((this.rready_gen.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM) && (
            (this.rready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_SINGLE) ||
            (this.rready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_EVENTS) ||
            (this.rready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_OSC)))) begin
        vif_proxy.clr_rready();
        vif_proxy.wait_negedge_aclk();
        ///////////////////////////////////////////////////////////////////////////
        //If the valid is not asserted then wait until the posedge
        if (vif_proxy.is_live_rvalid_asserted() == 0) begin
          vif_proxy.wait_live_rvalid_asserted();
        end
      end

      ///////////////////////////////////////////////////////////////////////////
      //Wait low time then assert for one handshake
      if (this.rready_gen.get_low_time() > 0) begin
        ///////////////////////////////////////////////////////////////////////////
        // deassert signals
        vif_proxy.clr_rready();
        vif_proxy.wait_aclks(this.rready_gen.get_low_time());
        #this.vif_proxy.hold_time;
      end

      vif_proxy.set_rready();
      event_counter = 0;
      case (this.rready_gen.get_ready_policy())
        XIL_AXI_READY_GEN_AFTER_VALID_EVENTS,
        XIL_AXI_READY_GEN_EVENTS: begin
          fork
            begin
              while (this.rready_gen.get_event_count() > event_counter) begin
                vif_proxy.wait_r_accepted();
                event_counter++;
              end
            end
            begin
              forever begin
                vif_proxy.wait_aclks(this.rready_gen.get_event_cycle_count_reset());
                event_counter = 0;
              end
            end
          join_any
          disable fork;
        end
        XIL_AXI_READY_GEN_AFTER_VALID_OSC,
        XIL_AXI_READY_GEN_OSC: begin
          vif_proxy.wait_aclks(this.rready_gen.get_high_time());
        end
        XIL_AXI_READY_GEN_RANDOM: begin
          case(this.rready_gen.get_ready_rand_policy())
            XIL_AXI_READY_RAND_AFTER_VALID_OSC,
            XIL_AXI_READY_RAND_OSC: begin
              this.vif_proxy.wait_aclks(this.rready_gen.get_high_time());
            end
            XIL_AXI_READY_RAND_AFTER_VALID_EVENTS,
            XIL_AXI_READY_RAND_EVENTS: begin
              fork
                begin
                  while (this.rready_gen.get_event_count() > event_counter) begin
                    vif_proxy.wait_r_accepted();
                    event_counter++;
                  end
                end
                begin
                  forever begin
                    vif_proxy.wait_aclks(this.rready_gen.get_event_cycle_count_reset());
                    event_counter = 0;
                  end
                end
              join_any
              disable fork;
            end
            default: begin
              this.vif_proxy.wait_r_accepted();
            end
          endcase
        end
        default: begin
          vif_proxy.wait_r_accepted();
        end
      endcase
      #this.vif_proxy.hold_time;
    end
  endtask : rready_generation

  protected task rvalid_watchdog();
    xil_axi_uint    cycle_count;
    forever begin : VALID_WATCHDOG
      while (r_q_entries == 0) begin
        @(r_q_entries_event);
      end
      cycle_count = 0;
      fork
        begin
          while (r_q_entries > 0) begin
            @(r_q_entries_event);
          end
        end
        begin
          forever begin
            vif_proxy.wait_r_accepted();
            cycle_count = 0;
          end
        end
        begin
          cycle_count = 0;
          while (cycle_count < waiting_valid_timeout_value) begin
            vif_proxy.wait_posedge_aclk();
            cycle_count++;
          end
          ///////////////////////////////////////////////////////////////////////////
          //Which transactions are pending?
          display_r_q_entries();
          `xil_fatal(this.get_tag(), "No activity on R channel with pending transactions")
        end
      join_any
      disable fork;
    end
  endtask : rvalid_watchdog

  protected task r_channel();
    axi_transaction transfer;
    bit found;
    bit [(C_AXI_RID_WIDTH==0?1:C_AXI_RID_WIDTH)-1:0] p_id;
    xil_axi_read_beat beat;

    forever begin : R_CHANNEL
      ///////////////////////////////////////////////////////////////////////////
      // wait for incoming read data from the slave
      vif_proxy.wait_r_accepted();
      beat = vif_proxy.get_rdata();

      ///////////////////////////////////////////////////////////////////////////
      //Now that we have received a beat we now need to add it to the transfer.
      found = 0;
      for (int i = 0; (found == 0) && (i < r_q.size()); i++) begin
        ///////////////////////////////////////////////////////////////////////////
        //Search through the list of pending transactions
        transfer = r_q[i];
        p_id = transfer.get_id();
        if (p_id == beat.id) begin
          found = 1;
          if (beat.last == 1) begin
            r_q.delete(i);
            r_q_entries--;
             ->r_q_entries_event ;
          end
        end
      end

      ///////////////////////////////////////////////////////////////////////////
      //If there no transaction was found then assert and error.
      AXI_RD_MST_RID_MISMATCH: assert(found)
        else `xil_error(this.get_tag(), $sformatf("No matching transaction for RID in read channel queue."))

      if (found == 1) begin
        ///////////////////////////////////////////////////////////////////////////
        // copy RDATA from R channel to transfer
        transfer.import_rd_beat(beat);
        // wait for next data beat or notify transaction completion
        if (beat.last == 0) begin
          transfer.increment_beat_index();
        end else begin
          transfer.clr_beat_index();
          this.push_done_q(transfer);
        end
      end
    end // forever begin
  endtask : r_channel

  protected task forward_progress_watchdog();
    forever begin : PROGRESS
      ///////////////////////////////////////////////////////////////////////////
      //Wait until there is at least one transaction to be processed. This is here
      // to cover the case where there are not sequence items for the read channel
      while (num_transactions_inflight == 0) begin
        @(num_transactions_inflight_event);
      end
      fork
        ///////////////////////////////////////////////////////////////////////////
        //If you get an AR or R accepted then restart the fork
        begin
          vif_proxy.wait_ar_accepted();
        end
        begin
          vif_proxy.wait_r_accepted();
        end
        ///////////////////////////////////////////////////////////////////////////
        //Timeout if there is no accepted beats within forward_progress_timeout_value cycles
        begin
          vif_proxy.wait_aclks(forward_progress_timeout_value);
          if (num_transactions_inflight > 0) begin
            `xil_fatal(this.get_tag(), $sformatf("No forward progess is occuring on all channels"))
          end
        end
      join_any
      disable fork;
      vif_proxy.wait_aclks(10);
    end
  endtask : forward_progress_watchdog

  /*
   Function: send
   Sends the AXI transaction to the driver 
  */
  task send(input axi_transaction t);
    if(this.get_is_active()) begin
      this.seq_item_port.put_item(t);
      this.seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send transaction when driver is not active"))
    end
  endtask  : send

  /*
   Function: wait_rsp
   This blocking function will not return until driver send back response transaction 
  */
  task wait_rsp(output axi_transaction t);
    this.seq_item_port.get_next_rsp(t);
    this.seq_item_port.rsp_done();
  endtask  : wait_rsp

  /*
    Function: create_transaction
    Returns an AXI transaction class that has been "newed"
  */
  virtual function axi_transaction create_transaction (string name = "unnamed_transaction");
    axi_transaction item=new(name);
    item.set_cmd_type(XIL_AXI_READ);
    item.set_protocol(C_AXI_PROTOCOL);
    item.set_addr_width(C_AXI_ADDR_WIDTH );
    item.set_data_width(C_AXI_RDATA_WIDTH);
    item.set_id_width(C_AXI_RID_WIDTH);
    item.set_awuser_width(C_AXI_AWUSER_WIDTH);
    item.set_wuser_width(C_AXI_WUSER_WIDTH);
    item.set_buser_width(C_AXI_BUSER_WIDTH);
    item.set_aruser_width(C_AXI_ARUSER_WIDTH);
    item.set_ruser_width(C_AXI_RUSER_WIDTH);
    item.set_supports_narrow(C_AXI_SUPPORTS_NARROW);
    if (C_AXI_SUPPORTS_NARROW == 0) begin
      item.set_size(item.get_dw_size());
    end
    item.set_has_burst(C_AXI_HAS_BURST);
    if (C_AXI_HAS_BURST == 0) begin
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
    end
    item.set_has_lock(C_AXI_HAS_LOCK);
    if (C_AXI_HAS_LOCK == 0) begin
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
    end
    item.set_has_cache(C_AXI_HAS_CACHE);
    item.set_has_region(C_AXI_HAS_REGION);
    if (C_AXI_HAS_REGION == 0) begin
      item.set_region(0);
    end
    item.set_has_prot(C_AXI_HAS_PROT);
    if (C_AXI_HAS_PROT == 0) begin
      item.set_prot(0);
    end
    item.set_has_qos(C_AXI_HAS_QOS);
    if (C_AXI_HAS_QOS == 0) begin
      item.set_qos(0);
    end
    item.set_has_wstrb(C_AXI_HAS_WSTRB);
    item.set_has_bresp(C_AXI_HAS_BRESP);
    item.set_has_rresp(C_AXI_HAS_RRESP);
    item.clr_beat_index();
    if (item.get_axi_version() == XIL_VERSION_LITE) begin
      item.set_id(0);
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
      item.set_size(item.get_dw_size());
      item.set_len(0);
      item.set_qos(0);
      item.set_region(0);
    end
    return(item);
  endfunction :create_transaction

  ////////////////////////////////////////////////////////////////////////////
  //send rready and wait
  /*
   Function: send_rready
   Sends the ready structure to the driver for controlling the READY channel.
  */
  task send_rready(input axi_ready_gen t);
    if(this.get_is_active()) begin
      this.rready_seq_item_port.put_item(t);
      this.rready_seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send RREADY when driver is not active"))
    end
  endtask

  /*
   Function: create_ready
   Returns a ready class that has been "newed".
  */
  virtual function axi_ready_gen create_ready (string name = "unnamed_ready");
    axi_ready_gen    ready=new(name);
    return(ready);
  endfunction

  /*
   Function: wait_driver_idle
   This is a blocking task which will wait until there are no outstanding transactions in the driver. This means that
   all the transactions send to the driver have received a corresponding RLast response.
  */
  task wait_driver_idle();
    while (this.num_transactions_inflight != 0) begin
      @(num_transactions_inflight_event);
    end
  endtask : wait_driver_idle

endclass : axi_mst_rd_driver

/*
  Class: axi_mst_agent
  AXI Master Agent.
*/
class axi_mst_agent `AXI_PARAM_DECL extends xil_agent;

  protected xil_axi_uint              rd_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint              wr_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint              transaction_depth_checks_enabled = 1;

  ///////////////////////////////////////////////////////////////////////////
  // Monitor
  axi_monitor         `AXI_PARAM_ORDER monitor;

  ///////////////////////////////////////////////////////////////////////////
  // write driver
  axi_mst_wr_driver    `AXI_PARAM_ORDER wr_driver;

  ///////////////////////////////////////////////////////////////////////////
  // read driver
  axi_mst_rd_driver    `AXI_PARAM_ORDER rd_driver;

  ///////////////////////////////////////////////////////////////////////////
  // Proxy
  axi_vif_mem_proxy `AXI_PARAM_ORDER vif_proxy;

  /*
    Function: new
    Constructor to create an AXI Master Agent.
  */
  function new (string name = "unnamed_axi_mst_agent", virtual interface axi_vip_v1_0_1_if `AXI_PARAM_ORDER vif);
    super.new(name);
    this.monitor = new($sformatf("%s_monitor",name));
    this.wr_driver = new($sformatf("%s_wr_driver",name));
    this.rd_driver = new($sformatf("%s_rd_driver",name));
    this.vif_proxy = new($sformatf("%s_vif",name));
    this.vif_proxy.assign_vi(vif);
    this.set_vif(this.vif_proxy);
  endfunction : new

  /*
    Function: set_verbosity
    Sets the verbosity of the Agent and all sub classes.
  */
  virtual function void set_verbosity(xil_verbosity updated);
    if(updated >= XIL_AXI_VERBOSITY_FULL && this.TAG== "xil_object")
      `xil_warning(this.get_tag(), "Debug information for master agent is printed out, but set_agent_tag is not set,for easily debug, please set it up")
    this.verbosity = updated;
    this.monitor.set_verbosity(this.get_verbosity());
    this.wr_driver.set_verbosity(this.get_verbosity());
    this.rd_driver.set_verbosity(this.get_verbosity());
    this.vif_proxy.set_verbosity(this.get_verbosity());
  endfunction : set_verbosity

   /*
    Function: set_agent_tag
    Sets the tag of the Agent and all sub classes.
  */
  virtual function void set_agent_tag(string updated);
    this.TAG = updated;
    this.monitor.set_tag($sformatf("%s_monitor", this.get_tag()));
    this.wr_driver.set_tag($sformatf("%s_wr_driver", this.get_tag()));
    this.rd_driver.set_tag($sformatf("%s_rd_driver", this.get_tag()));
    this.vif_proxy.set_tag($sformatf("%s_vif", this.get_tag()));
  endfunction : set_agent_tag

  /*
    Function: set_vif
    Sets the Agent's virtual interface. This is the interface that will be monitored and/or driven.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    if(vif.m_vif.intf_is_slave ==1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign Slave top to Master agent"))
    end else begin
      `xil_info(this.get_tag(),$sformatf("Set VIF in Master mode"), XIL_AXI_VERBOSITY_NONE)
      this.wr_driver.set_vif(vif);
      `xil_info(this.get_tag(),$sformatf("Assigning VIF to Master VIP Write Driver"), XIL_AXI_VERBOSITY_NONE)
      this.rd_driver.set_vif(vif);
      `xil_info(this.get_tag(),$sformatf("Assigning VIF to Master VIP Read Driver"), XIL_AXI_VERBOSITY_NONE)
      this.monitor.set_vif(vif);
      `xil_info(this.get_tag(),$sformatf("Assigning VIF to Master VIP Monitor"), XIL_AXI_VERBOSITY_NONE)
    end  
  endfunction : set_vif

  /*
    Function: set_wr_transaction_depth
    Sets the number of WRITE transactions that the Agent will have in flight at one time.
  */
  function void set_wr_transaction_depth(input xil_axi_uint update);
    this.wr_transaction_depth = update;
    `xil_info(this.get_tag(),$sformatf("Setting WR Driver Transaction Depth to %d", this.get_wr_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.wr_driver.set_transaction_depth(this.get_wr_transaction_depth());
    `xil_info(this.get_tag(),$sformatf("Setting Monitor WR Transaction Depth to %d", this.get_wr_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.monitor.set_wr_transaction_depth(this.get_wr_transaction_depth());
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Agent will have in flight at one time.
  */
  function xil_axi_uint get_wr_transaction_depth();
    return(this.wr_transaction_depth);
  endfunction

  /*
    Function: set_rd_transaction_depth
    Sets the number of READ transactions that the Agent will have in flight at one time.
  */
  function void set_rd_transaction_depth(input xil_axi_uint update);
    this.rd_transaction_depth = update;
    `xil_info(this.get_tag(),$sformatf("Setting RD Driver Transaction Depth to %d", this.get_rd_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.rd_driver.set_transaction_depth(this.get_rd_transaction_depth());
    `xil_info(this.get_tag(),$sformatf("Setting Monitor RD Transaction Depth to %d", this.get_rd_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.monitor.set_rd_transaction_depth(this.get_rd_transaction_depth());
  endfunction

  /*
    Function: get_rd_transaction_depth
    Returns the maximum number of READ transactions that the Agent will have in flight at one time.
  */
  function xil_axi_uint get_rd_transaction_depth();
    return(this.rd_transaction_depth);
  endfunction

  /*
    Function: enable_transaction_depth_checks
    Turn on current agent's transaction depth checks and its monitor's enable_transaction_depth_checks
  */
  function void enable_transaction_depth_checks();
    this.transaction_depth_checks_enabled = 1;
    this.monitor.enable_transaction_depth_checks();
  endfunction

  /*
    Function: disable_transaction_depth_checks
    Turn off current agent's transaction depth check and its monitor's enable_transaction_depth_checks
  */
  function void disable_transaction_depth_checks();
    this.transaction_depth_checks_enabled = 0;
    this.monitor.enable_transaction_depth_checks();
  endfunction

  /*
    Function: start_monitor
    Enables the monitor in this agent to start collecting data.
  */
  virtual task start_monitor();
    fork
      this.monitor.run_phase();
    join_none
  endtask : start_monitor

  /*
    Function: start_master
    Enables the monitor, READ driver and WRITE Driver in this agent to start collecting data.
    The drivers will only issue transactions when the send functions are called.
  */
  virtual task start_master();
    fork
      this.start_monitor();
      this.wr_driver.run_phase();
      this.rd_driver.run_phase();
    join_none
    fork
      this.wr_driver.wait_enabled();
      this.rd_driver.wait_enabled();
    join
    if(vif_proxy.m_vif.intf_is_master !=1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign non-master VIF to master agent"))
    end
  endtask : start_master

  /*
    Function: stop_master
    Disables the READ and WRITE drivers. Once disabled, no further action will occur by the drivers.
  */
  virtual task stop_master();
    this.wr_driver.stop_phase();
    this.rd_driver.stop_phase();
  endtask : stop_master

  /*
    Function: halt_master
    Allows for all inflight transactions to complete and no new transaction will be serviced. All other transactions
    will halt.
  */
  virtual task halt_master();
    fork
      this.wr_driver.halt_phase();
      this.rd_driver.halt_phase();
    join
  endtask : halt_master

  /*
    Function: resume_master
    Resumes processing of the pending transactions.
  */
  virtual task resume_master();
    this.wr_driver.resume_phase();
    this.rd_driver.resume_phase();
  endtask : resume_master

  /*
    Function: stop_monitor
    Disables the monitor in this agent from start collecting data. . Once disabled, no further action will occur by the monitor.
  */
  virtual task stop_monitor();
    this.monitor.stop_phase();
  endtask : stop_monitor

  ///////////////////////////////////////////////////////////////////////////
  //Determine if there are outstanding transactions
  /*
   Function: wait_drivers_idle
   This blocking function will not return until all the downstream transactions have completed.
  */
  task wait_drivers_idle();
    fork
      this.wr_driver.wait_driver_idle();
      this.rd_driver.wait_driver_idle();
    join
  endtask : wait_drivers_idle

  ///////////////////////////////////////////////////////////////////////////
  //Simple repeating bursting generation
  /*
   Function: send_multi_wrbursts
   Convenience function to generate a series of same type of transactions.
  */
  virtual task send_multi_wrbursts(
    input xil_axi_uint    num_xfers,
    input xil_axi_ulong   start_addr = 'h0,
    input xil_axi_uint    myid = 0,
    input xil_axi_size_t  mysize = XIL_AXI_SIZE_4BYTE,
    input xil_axi_len_t   mylen = 15,
    input xil_axi_burst_t myburst = XIL_AXI_BURST_TYPE_INCR,
    input bit             no_xfer_delays = 0
  );
    axi_transaction t;
    xil_axi_ulong   myaddr;
    ///////////////////////////////////////////////////////////////////////////
    //Generate and send all the transactions
    myaddr = start_addr;
    for (xil_axi_uint i = 0; i < num_xfers; i++) begin
      t = this.wr_driver.create_transaction($sformatf("continuous_wrburst_%x", i));
      if (no_xfer_delays == 1) begin
        t.set_data_insertion_delay_range(0,0);
        t.set_addr_delay_range(0,0);
        t.set_beat_delay_range(0,0);
      end
      SEND_MULTI_WRBURSTS_GEN_FAILED: assert(t.randomize() with {
          addr == myaddr;
          id == myid;
          size == mysize;
          len == mylen;
          burst == myburst;
      });
      this.wr_driver.send(t);
      myaddr += t.get_num_bytes_in_transaction();
    end
    ///////////////////////////////////////////////////////////////////////////
    //Wait until all the writes have completed.
    this.wr_driver.wait_driver_idle();
  endtask : send_multi_wrbursts

  /*
   Function: send_multi_rand_wrbursts
   Convenience function to generate a series of random transactions.
  */
  virtual task send_multi_rand_wrbursts(
    input xil_axi_uint    num_xfers,
    input bit             no_xfer_delays = 0
  );
    axi_transaction t;
    ///////////////////////////////////////////////////////////////////////////
    //Generate and send all the transactions
    for (xil_axi_uint i = 0; i < num_xfers; i++) begin
      t = this.wr_driver.create_transaction($sformatf("rand_wrburst_%x", i));
      if (no_xfer_delays == 1) begin
        t.set_data_insertion_delay_range(0,0);
        t.set_addr_delay_range(0,0);
        t.set_beat_delay_range(0,0);
      end
      SEND_MULTI_RAND_WRBURSTS_GEN_FAILED: assert(t.randomize());
      this.wr_driver.send(t);
    end
    ///////////////////////////////////////////////////////////////////////////
    //Wait until all the writes have completed.
    this.wr_driver.wait_driver_idle();
  endtask : send_multi_rand_wrbursts

  /*
   Function: send_multi_rdbursts
   Convenience function to generate a series of same type of transactions transactions.
  */
  virtual task send_multi_rdbursts(
    input xil_axi_uint    num_xfers,
    input xil_axi_ulong   start_addr = 'h0,
    input xil_axi_uint    myid = 0,
    input xil_axi_size_t  mysize = XIL_AXI_SIZE_4BYTE,
    input xil_axi_len_t   mylen = 15,
    input xil_axi_burst_t myburst = XIL_AXI_BURST_TYPE_INCR,
    input bit             no_xfer_delays = 0
  );
    axi_transaction t;
    xil_axi_ulong   myaddr;
    ///////////////////////////////////////////////////////////////////////////
    //Generate and send all the transactions
    myaddr = start_addr;
    for (xil_axi_uint i = 0; i < num_xfers; i++) begin
      t = this.rd_driver.create_transaction($sformatf("continuous_rdburst_%x", i));
      if (no_xfer_delays == 1) begin
        t.set_data_insertion_delay_range(0,0);
        t.set_addr_delay_range(0,0);
        t.set_beat_delay_range(0,0);
      end
      SEND_MULTI_RDBURSTS_GEN_FAILED: assert(t.randomize() with {
          addr == myaddr;
          id == myid;
          size == mysize;
          len == mylen;
          burst == myburst;
      });
      this.rd_driver.send(t);
      myaddr += t.get_num_bytes_in_transaction();
    end
    ///////////////////////////////////////////////////////////////////////////
    //Wait until all the rdites have completed.
    this.rd_driver.wait_driver_idle();
  endtask : send_multi_rdbursts

  /*
   Function: send_multi_rand_rdbursts
   Convenience function to generate a series of random transactions.
  */
  virtual task send_multi_rand_rdbursts(
    input xil_axi_uint    num_xfers,
    input bit             no_xfer_delays = 0
  );
    axi_transaction t;
    ///////////////////////////////////////////////////////////////////////////
    //Generate and send all the transactions
    for (xil_axi_uint i = 0; i < num_xfers; i++) begin
      t = this.rd_driver.create_transaction($sformatf("rand_rdburst_%x", i));
      if (no_xfer_delays == 1) begin
        t.set_data_insertion_delay_range(0,0);
        t.set_addr_delay_range(0,0);
        t.set_beat_delay_range(0,0);
      end
      SEND_MULTI_RAND_RDBURSTS_GEN_FAILED: assert(t.randomize());
      this.rd_driver.send(t);
    end
    ///////////////////////////////////////////////////////////////////////////
    //Wait until all the writes have completed.
    this.rd_driver.wait_driver_idle();
  endtask : send_multi_rand_rdbursts

  ///////////////////////////////////////////////////////////////////////////
  //Channel level API's are not supported
  ///////////////////////////////////////////////////////////////////////////
  //Function Level API
    /*
    This task does a full read process. It is composed of a series of tasks and functions.
    It first creates transaction from master read driver,sets up the transaction, sends it
    and then waits till response back.
  */
  protected virtual task AXI4_READ_BURST_BLOCKING(
    input xil_axi_uint                id,
    input xil_axi_ulong               addr,
    input xil_axi_len_t               len,
    input xil_axi_size_t              size,
    input xil_axi_burst_t             burst,
    input xil_axi_lock_t              lock,
    input xil_axi_cache_t             cache,
    input xil_axi_prot_t              prot,
    input xil_axi_region_t            region,
    input xil_axi_qos_t               qos,
    input xil_axi_user_beat           aruser,
    output  bit [8*4096-1:0]          data,
    output  xil_axi_resp_t [255:0]    resp,
    output  xil_axi_data_beat [255:0] ruser
  );
    axi_transaction t;
    axi_transaction tout;
    xil_axi_data_beat ubeat;
    t = this.rd_driver.create_transaction("RD_BURST");
    t.set_read_cmd(
      addr,
      burst,
      id,
      len,
      size);
    t.set_prot(prot);
    t.set_lock(lock);
    t.set_cache(cache);
    t.set_region(region);
    t.set_qos(qos);
    t.set_aruser(aruser);
    t.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
    ///////////////////////////////////////////////////////////////////////////
    //Send the command to the driver
    this.rd_driver.send(t);
    ///////////////////////////////////////////////////////////////////////////
    //Block until the RRESP has finished
    this.rd_driver.wait_rsp(tout);
    ///////////////////////////////////////////////////////////////////////////
    //Extract the rresp and data
    data = tout.get_data_block();
    for (xil_axi_uint beat = 0; beat < tout.get_len()+1;beat++) begin
      resp[beat] = tout.get_rresp(beat);
      ///////////////////////////////////////////////////////////////////////////
      //This will be the byte array of the data
      ubeat = tout.get_user_beat(beat);
      ruser[beat] = ubeat;
    end
  endtask : AXI4_READ_BURST_BLOCKING

  /*
    Function: AXI4_READ_BURST
    This task does a full read process for AXI4. It is composed of the task AXI_READ_BURST_BLOCKING
    This task returns when the read transaction is complete.
  */
  virtual task AXI4_READ_BURST (
    input xil_axi_uint                id,
    input xil_axi_ulong               addr,
    input xil_axi_len_t               len,
    input xil_axi_size_t              size,
    input xil_axi_burst_t             burst,
    input xil_axi_lock_t              lock,
    input xil_axi_cache_t             cache,
    input xil_axi_prot_t              prot,
    input xil_axi_region_t            region,
    input xil_axi_qos_t               qos,
    input xil_axi_user_beat           aruser,
    output  bit [8*4096-1:0]          data,
    output  xil_axi_resp_t [255:0]    resp,
    output  xil_axi_data_beat [255:0] ruser
  );
    this.AXI4_READ_BURST_BLOCKING(
      id,
      addr,
      len,
      size,
      burst,
      lock,
      cache,
      prot,
      region,
      qos,
      aruser,
      data,
      resp,
      ruser
    );
  endtask : AXI4_READ_BURST

  /*
    Function: AXI3_READ_BURST
    This task does a full read process for AXI3. It is composed of the task AXI_READ_BURST_BLOCKING
    with inputs region, qos,aruser to be 0.This task returns when the read transaction is complete.
  */
  virtual task AXI3_READ_BURST (
    input xil_axi_uint                id,
    input xil_axi_ulong               addr,
    input xil_axi_len_t               len,
    input xil_axi_size_t              size,
    input xil_axi_burst_t             burst,
    input xil_axi_lock_t              lock,
    input xil_axi_cache_t             cache,
    input xil_axi_prot_t              prot,
    output  bit [8*2048-1:0]          data,
    output  xil_axi_resp_t [15:0]     resp
  );
    xil_axi_data_beat [255:0] ruser;
    this.AXI4_READ_BURST_BLOCKING(
      id,
      addr,
      len,
      size,
      burst,
      lock,
      cache,
      prot,
      'h0,
      'h0,
      'h0,
      data,
      resp,
      ruser
    );
  endtask : AXI3_READ_BURST

  /*
    Function: AXI4LITE_READ_BURST
    This task does a full read process for AXI4LITE. It is composed of the task AXI_READ_BURST_BLOCKING
    with only addr, prot,data and resp. all other inputs are set to be either 0 or AXI4LITE Value
    This task returns when the read transaction is complete.
  */
  virtual task AXI4LITE_READ_BURST (
    input xil_axi_ulong               addr,
    input xil_axi_prot_t              prot,
    output  bit [8*8-1:0]             data,
    output  xil_axi_resp_t            resp
  );
    xil_axi_data_beat [255:0] ruser;
    xil_axi_resp_t [255:0]    rresp;
    this.AXI4_READ_BURST_BLOCKING(
      0,
      addr,
      0,
      convert_dw_to_axi_size(C_AXI_RDATA_WIDTH),
      XIL_AXI_BURST_TYPE_INCR,
      XIL_AXI_ALOCK_NOLOCK,
      0,
      prot,
      'h0,
      'h0,
      'h0,
      data,
      rresp,
      ruser
    );
    resp = rresp[0];
  endtask : AXI4LITE_READ_BURST

  /*
    This task does a full write process. It is composed of a series of tasks and functions.
    It first creates transaction from master write driver,sets up the transaction, sends it
    and then waits till response back.
  */
  protected virtual task AXI4_WRITE_BURST_BLOCKING(
    input xil_axi_uint              id  = 0,
    input xil_axi_ulong             addr = 0,
    input xil_axi_len_t             len = 0,
    input xil_axi_size_t            size = XIL_AXI_SIZE_4BYTE,
    input xil_axi_burst_t           burst = XIL_AXI_BURST_TYPE_INCR,
    input xil_axi_lock_t            lock = XIL_AXI_ALOCK_NOLOCK,
    input xil_axi_cache_t           cache = 0,
    input xil_axi_prot_t            prot = 0,
    input xil_axi_region_t          region,
    input xil_axi_qos_t             qos,
    input xil_axi_user_beat         awuser,
    input bit [8*4096-1:0]          data = 'h0,
    input xil_axi_data_beat [255:0] wuser,
    output  xil_axi_resp_t          resp
  );
    axi_transaction t;
    xil_axi_data_beat dbeat;
    t = this.wr_driver.create_transaction("WR_BURST");
    t.set_write_cmd(
      addr,
      burst,
      id,
      len,
      size);
    t.set_prot(prot);
    t.set_lock(lock);
    t.set_cache(cache);
    t.set_region(region);
    t.set_qos(qos);
    t.set_awuser(awuser);
    t.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);

    t.set_data_block(data);
    ///////////////////////////////////////////////////////////////////////////
    //Load the payload
    for (xil_axi_uint beat = 0; beat < t.get_len()+1;beat++) begin
      ///////////////////////////////////////////////////////////////////////////
      //This will be the byte array of the data
      t.set_user_beat(beat, wuser[beat]);
    end

    ///////////////////////////////////////////////////////////////////////////
    //Send the command to the driver
    this.wr_driver.send(t);
    ///////////////////////////////////////////////////////////////////////////
    //Block until the BRESP has finished
    this.wr_driver.wait_rsp(t);
    resp = t.get_bresp();
  endtask : AXI4_WRITE_BURST_BLOCKING

  /*
    Function: AXI4_WRITE_BURST 
    This task does a full write process for AXI4. It is composed of AXI4_WRITE_BURST_BLOCKING with
    inputs suits for AXI4.This task returns when the complete write transaction is complete.
  */
  virtual task AXI4_WRITE_BURST (
    input xil_axi_uint              id,
    input xil_axi_ulong             addr,
    input xil_axi_len_t             len,
    input xil_axi_size_t            size,
    input xil_axi_burst_t           burst,
    input xil_axi_lock_t            lock,
    input xil_axi_cache_t           cache,
    input xil_axi_prot_t            prot,
    input xil_axi_region_t          region,
    input xil_axi_qos_t             qos,
    input xil_axi_user_beat         awuser,
    input bit [8*4096-1:0]          data,
    input xil_axi_data_beat [255:0] wuser,
    output  xil_axi_resp_t          resp
  );
    this.AXI4_WRITE_BURST_BLOCKING(
      id,
      addr,
      len,
      size,
      burst,
      lock,
      cache,
      prot,
      region,
      qos,
      awuser,
      data,
      wuser,
      resp
    );
  endtask : AXI4_WRITE_BURST

  /*
    Function:  AXI3_WRITE_BURST
    This task does a full write process for AXI3. It is composed of AXI4_WRITE_BURST_BLOCKING with
    inputs suits for AXI3.This task returns when the complete write transaction is complete.
  */
  virtual task AXI3_WRITE_BURST (
    input xil_axi_uint              id,
    input xil_axi_ulong             addr,
    input xil_axi_len_t             len,
    input xil_axi_size_t            size,
    input xil_axi_burst_t           burst,
    input xil_axi_lock_t            lock,
    input xil_axi_cache_t           cache,
    input xil_axi_prot_t            prot,
    input bit [8*2048-1:0]          data,
    output  xil_axi_resp_t          resp
  );
    this.AXI4_WRITE_BURST_BLOCKING(
      id,
      addr,
      len,
      size,
      burst,
      lock,
      cache,
      prot,
      'h0,
      'h0,
      'h0,
      data,
      'h0,
      resp
    );
  endtask : AXI3_WRITE_BURST

   /*
    Function:  AXI4LITE_WRITE_BURST
    This task does a full write process for AXI4LITE. It is composed of AXI4_WRITE_BURST_BLOCKING with
    inputs suits for AXI4LITE.This task returns when the complete write transaction is complete.
  */
  virtual task AXI4LITE_WRITE_BURST (
    input xil_axi_ulong             addr,
    input xil_axi_prot_t            prot,
    input bit [8*8-1:0]             data,
    output  xil_axi_resp_t          resp
  );
    this.AXI4_WRITE_BURST_BLOCKING(
      0,
      addr,
      0,
      convert_dw_to_axi_size(C_AXI_WDATA_WIDTH),
      XIL_AXI_BURST_TYPE_INCR,
      XIL_AXI_ALOCK_NOLOCK,
      'h0,
      prot,
      'h0,
      'h0,
      'h0,
      data,
      'h0,
      resp
    );
  endtask : AXI4LITE_WRITE_BURST

  /*
   Function: set_nobackpressure_readies
   Convenience function to set the RREADY/BREADY of the master to not apply any backpressure to the simulation.
  */
  virtual task set_nobackpressure_readies();
    axi_ready_gen rready;
    axi_ready_gen bready;
    rready = new("nobackpressure_rready");
    bready = new("nobackpressure_bready");

    rready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    rready.set_low_time_range(0,0);
    rready.set_high_time_range(100,100);
    this.rd_driver.set_rready_gen(rready);

    bready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    bready.set_low_time_range(0,0);
    bready.set_high_time_range(100,100);
    this.wr_driver.set_bready_gen(bready);
  endtask : set_nobackpressure_readies

endclass : axi_mst_agent

/*
  Class: axi_slv_wr_driver
  AXI Slave Write Driver object.
*/
class axi_slv_wr_driver `AXI_PARAM_DECL extends xil_driver #(axi_transaction,axi_transaction);

  ///////////////////////////////////////////////////////////////////////////
  //add some short names.
  typedef axi_write_transfer#(axi_transaction)                    slv_axi_write_transfer_t;
  typedef axi_generic_write_transaction_queue#(axi_transaction)   slv_axi_write_queue_t;
  typedef xil_axi_generic_queue_container #(xil_axi_write_beat)   slv_beat_q_t;
  typedef xil_axi_generic_queue_container #(axi_transaction)      slv_transaction_q_t;

  ///////////////////////////////////////////////////////////////////////////
  // user configurable parameters
  protected xil_axi_uint                    wr_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected axi_ready_gen_t                 awready_gen;
  protected axi_ready_gen_t                 wready_gen;
  protected axi_ready_gen_t                 awready_gen_q[$];
  protected axi_ready_gen_t                 wready_gen_q[$];
  protected xil_axi_uint                    awaddr_watchdog_delay = 100;
  protected xil_axi_reorder_ability_t       reorder_response_ability = XIL_AXI_NO_REORDER;
  protected xil_axi_xfer_wrcmd_order_t      wrcmd_order = XIL_AXI_WRCMD_ORDER_NONE;
  protected xil_axi_uint                    num_pending_cmds = 0;
  protected xil_axi_uint                    cmds_inflight = 0;
  protected xil_axi_uint                    num_pending_payloads = 0;
  protected xil_axi_uint                    num_active_awrequests = 0;
  protected xil_axi_uint                    inbound_fifo_depth = 0;
  protected xil_axi_uint                    reorder_min_backoff = 10;
  protected xil_axi_uint                    reorder_max_backoff = 50;
  protected xil_axi_uint                    waiting_valid_timeout_value = 500000;
  protected xil_axi_uint                    forward_progress_timeout_value = 50000;
  rand xil_axi_uint                         reorder_backoff;
  rand xil_axi_uint                         reorder_index;

  slv_axi_write_queue_t           incoming_write  [xil_axi_uint];
  slv_axi_write_queue_t           outbound_bresp  [xil_axi_uint];

  ///////////////////////////////////////////////////////////////////////////
  // AXI interface
  axi_vif_mem_proxy `AXI_PARAM_ORDER vif_proxy;
  xil_seq_item_pull_port #(axi_ready_gen, axi_ready_gen) awready_seq_item_port;
  xil_seq_item_pull_port #(axi_ready_gen, axi_ready_gen) wready_seq_item_port;

  ///////////////////////////////////////////////////////////////////////////
  // internal channel queues
  protected slv_axi_write_transfer_t  b_q [$];
  protected axi_transaction           reactive_q[$];
  protected axi_transaction           done_q[$];
  protected slv_axi_write_transfer_t  reconcile_q[$];
  protected slv_beat_q_t              reconcile_data_q[$];
  protected xil_axi_uint              reactive_q_entries = 0;
  protected xil_axi_uint              b_q_entries = 0; 
  protected xil_axi_uint              done_q_entries = 0;
  protected xil_axi_uint              reconcile_q_entries = 0;
  protected xil_axi_uint              reconcile_data_q_entries = 0;
  protected xil_axi_uint              wdata_beat_counter = 0;
  event                               b_q_entries_event ;
  event                               done_q_entries_event ;
  event                               reconcile_q_entries_event ;
  event                               reconcile_data_q_entries_event ;
  event                               reactive_q_entries_event ;
  event                               num_pending_cmds_event ;
  event                               num_pending_payloads_event ;
  event                               num_active_awrequests_event ;

  ///////////////////////////////////////////////////////////////////////////
  // internal events
  event   wchannel_beat_sampled_event;
  event   wready_policy_start;
  event   wready_policy_end;

  
  /*
    Function: new
    Constructor to create an AXI slave write driver 
  */
  function new(string name = "unnamed_axi_slv_wr_driver");
    super.new(name);
    this.b_q_entries = 0;
    this.reactive_q_entries = 0;
    this.done_q_entries = 0;
    this.reconcile_q_entries = 0;
    this.reconcile_data_q_entries = 0;
    this.set_inbound_fifo_depth(100);
    this.set_xfer_wrcmd_order(XIL_AXI_WRCMD_ORDER_NONE);
    this.reorder_response_ability = XIL_AXI_NO_REORDER;
    awready_seq_item_port = new("awready_seq_item_port");
    wready_seq_item_port = new("wready_seq_item_port");
    this.awready_gen =new("awready_gen");
    this.wready_gen = new("wready_gen");
  endfunction

  /*
    Function: set_vif
    Assigns the virtual interface of the driver.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    this.vif_proxy = vif;
  endfunction : set_vif

  ///////////////////////////////////////////////////////////////////////////
  //Configuration knobs
  /*
   Function: set_awready_gen
   Sets awready_gen
  */
  function void set_awready_gen(input axi_ready_gen_t new_gen);
    this.awready_gen = new_gen;
  endfunction

  /*
   Function: get_awready_gen
   Returns awready_gen
  */
  function axi_ready_gen_t get_awready_gen();
    return(this.awready_gen);
  endfunction

  /*
   Function: set_wready_gen
   Sets wready_gen
  */
  function void set_wready_gen(input axi_ready_gen_t new_gen);
    this.wready_gen = new_gen;
  endfunction

  /*
   Function: get_wready_gen
   Returns wready_gen
  */
  function axi_ready_gen_t get_wready_gen();
    return(this.wready_gen);
  endfunction

  /*
    Function: set_reorder_response_ability
    Sets reorder_response_ability of the Driver
  */
  function void set_reorder_response_ability (input xil_axi_reorder_ability_t value);
    if ((C_AXI_WID_WIDTH == 0) && (value != XIL_AXI_NO_REORDER)) begin
      `xil_warning(this.get_name(), $sformatf("Attempt to change reorder ability (%s) when there are no ID's. No change.", this.reorder_response_ability.name()))
    end else begin
      this.reorder_response_ability  = value;
    end
  endfunction : set_reorder_response_ability

  /*
   Function: get_reorder_response_ability
   Returns reorder_response_ability of the Driver
  */
  function xil_axi_reorder_ability_t get_reorder_response_ability ();
    return(this.reorder_response_ability );
  endfunction : get_reorder_response_ability

  /*
   Function: set_reorder_backoff_range
   Sets the reordering backoff timer range
  */
  function void set_reorder_backoff_range(
    input xil_axi_uint         min,
    input xil_axi_uint         max
  );
    if (min > max) begin
      `xil_fatal(this.get_name(), $sformatf("min (%d) number is greater than max(%d).", min, max))
    end
    this.reorder_min_backoff = min;
    this.reorder_max_backoff = max;
  endfunction : set_reorder_backoff_range

  /*
   Function: get_reorder_backoff_range
   Gets the reordering backoff timer range
  */
  function void get_reorder_backoff_range(
    output xil_axi_uint         min,
    output xil_axi_uint         max
  );
    min = this.reorder_min_backoff;
    max = this.reorder_max_backoff;
  endfunction : get_reorder_backoff_range

  /*
    Function: set_forward_progress_timeout_value
    Sets forward_progress_timeout_value of the Driver
  */
  function void set_forward_progress_timeout_value (input xil_axi_uint new_timeout);
    this.forward_progress_timeout_value  = new_timeout;
  endfunction

  /*
   Function: get_forward_progress_timeout_value
   Returns forward_progress_timeout_value of the Driver
  */
  function xil_axi_uint get_forward_progress_timeout_value ();
    return(this.forward_progress_timeout_value );
  endfunction

  /*
    Function: set_wr_transaction_depth
    Sets the number of WRITE transactions that the Driver will have in flight at one time.
  */
  function void set_transaction_depth(input xil_axi_uint new_depth);
    if (new_depth == 0) begin
      `xil_warning(this.get_tag(), "Setting the WRITE transaction Depth to 0. No transactions will be issued")
    end
    this.wr_transaction_depth = new_depth;
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Driver will have in flight at one time.
  */
  function xil_axi_uint get_transaction_depth();
    return(this.wr_transaction_depth);
  endfunction : get_transaction_depth

  /*
    Function: get_num_pending_cmds
    Returns number of commands in pending
  */
  function xil_axi_uint get_num_pending_cmds();
    return(this.num_pending_cmds);
  endfunction

  /*
    Function: get_cmds_inflight
    Returns number of commands in flight
  */
  function xil_axi_uint get_cmds_inflight();
    return(this.cmds_inflight);
  endfunction
  /*
    Function: set_xfer_wrcmd_order
    Sets wrcmd_order of the Driver
  */
  virtual function void set_xfer_wrcmd_order(input xil_axi_xfer_wrcmd_order_t update);
    this.wrcmd_order = update;
  endfunction

  /*
    Function: get_xfer_wrcmd_order
    Returns wrcmd_order of the Driver
  */
  virtual function xil_axi_xfer_wrcmd_order_t get_xfer_wrcmd_order();
    return(this.wrcmd_order);
  endfunction

  /*
    Function: set_inbound_fifo_depth
    Sets inbound_fifo_depth of the Driver
  */
  virtual function void set_inbound_fifo_depth(input xil_axi_uint update);
    this.inbound_fifo_depth = update;
  endfunction

  /*
    Function: get_inbound_fifo_depth
    Returns inbound_fifo_depth of the Driver
  */
  virtual function xil_axi_uint get_inbound_fifo_depth();
    if (get_xfer_wrcmd_order() == XIL_AXI_WRCMD_ORDER_CMD_BEFORE_DATA) begin
      return(0);
    end else begin
      return(this.inbound_fifo_depth);
    end
  endfunction

  /*
    Function: is_driver_idle
    Returns TRUE if the Driver is idle, else FALSE
  */
  function xil_axi_boolean_t is_driver_idle();
    if ((reactive_q_entries + b_q_entries + reconcile_q_entries + reconcile_data_q_entries +
          incoming_write.num() + outbound_bresp.num() + done_q_entries) > 0) begin
      return(XIL_AXI_FALSE);
    end else begin
      return(XIL_AXI_TRUE);
    end
  endfunction

  /*
    Function: set_awaddr_watchdog_delay
    Sets awaddr_watchdog_delay of the Driver
  */
  function void set_awaddr_watchdog_delay(input xil_axi_uint new_depth);
    this.awaddr_watchdog_delay = new_depth;
  endfunction

  /*
    Function: get_awaddr_watchdog_delay
    Returns awaddr_watchdog_delay of the Driver
  */
  function xil_axi_uint get_awaddr_watchdog_delay();
    return(this.awaddr_watchdog_delay);
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  // Main definition enabling all the channels.
  /*
    Function: run_phase
    Start control processes for operation
  */
  task run_phase();
    if (!this.get_is_active()) begin
      this.set_is_active();
      this.stop_triggered_event = 0;
      this.num_pending_cmds = 0;
      this.num_pending_payloads = 0;
      this.num_active_awrequests = 0;
      this.cmds_inflight = 0;
      if (this.vif_proxy == null) begin
        `xil_fatal(this.get_tag(), $sformatf("Attempted to start %s without assigned Interface", this.get_name()))
      end
      vif_proxy.reset_b();
      vif_proxy.clr_awready();
      vif_proxy.clr_wready();
      vif_proxy.wait_posedge_aclk();
      vif_proxy.wait_areset_deassert();
      while (this.stop_triggered_event == 0) begin
        fork
          begin
            this.num_pending_cmds = 0;
            this.num_pending_payloads = 0;
            this.num_active_awrequests = 0;
            `xil_info(this.get_tag(), "run()", verbosity)
            run_active();
          end
          begin
            vif_proxy.wait_areset_asserted();
          end
          begin : STOP
            @(posedge this.stop_triggered_event);
            `xil_info(this.get_tag(), "Stop event triggered. All traffic is being terminated.",this.verbosity)
          end
        join_any
        disable fork;
        vif_proxy.clr_awready();
        vif_proxy.clr_wready();
        this.clean_b_q();
        this.clean_reactive_q();
        this.clean_reconcile_q();
        this.clean_reconcile_data_q();
        this.clean_incoming_write();
        this.clean_outbound_bresp();
        vif_proxy.reset_b();
        if (this.stop_triggered_event == 0) begin
          `xil_info(this.get_tag(), $sformatf("RESET DETECTED"),this.verbosity)
          vif_proxy.wait_areset_deassert();
          `xil_info(this.get_tag(), $sformatf("RESET Released"),this.verbosity)
        end
        clean_inflight;
      end
      this.clr_is_active();
    end else begin
      `xil_warning(this.get_tag(), $sformatf("%s is already active.", this.get_name()))
    end
  endtask : run_phase

  ///////////////////////////////////////////////////////////////////////////
  //Stop the active processes.
  /*
    Function: stop_phase
    Stops all control processes.
  */
  virtual task stop_phase();
    this.stop_triggered_event = 1;
  endtask : stop_phase

  ///////////////////////////////////////////////////////////////////////////
  //Fork off the active processes.
  protected task run_active();
    fork
      get_and_drive();
      aw_channel();
      w_channel();
      b_channel();
      get_next_awready_item();
      get_next_wready_item();
      awready_generation();
      wready_generation();
      service_reconcile_q();
      forward_progress_watchdog();
      service_done_q();
    join
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Interaction thread with the sequencer.
  protected task get_and_drive();
    axi_transaction           get_cmd;
    slv_axi_write_queue_t     inbound_q;
    slv_axi_write_transfer_t  write_xfer;
    axi_transaction           cmd;

    ///////////////////////////////////////////////////////////////////////////
    //Continuous process getting the items from the sequencer and passing them
    // to the QUEUES
    forever begin : GET_AND_DRIVE
      seq_item_port.get_next_item(get_cmd);
      AXI_SLV_WR_INFLIGHT_CMD_MISMATCH : assert(this.cmds_inflight > 0) else begin
        `xil_fatal(this.get_tag(), "Number of commands inflight is not greater than 0. Driver & Sequencer problem.")
      end
      ///////////////////////////////////////////////////////////////////////////
      //Check the direction
      if (get_cmd.get_cmd_type() == XIL_AXI_WRITE) begin
        ///////////////////////////////////////////////////////////////////////////
        //Clone the command
        cmd = get_cmd.my_clone();

        `xil_info(this.get_tag(), $sformatf("GNI : %s",cmd.cmd_sprintf()),verbosity)
        ///////////////////////////////////////////////////////////////////////////
        //Since the sequencer will give use

        AXI_WR_SLV_NOID_INFLIGHT: assert(incoming_write.exists(cmd.get_id())) else begin
          `xil_fatal(this.get_tag(), $sformatf("No write found for ID=0x%x", cmd.get_id()))
        end

        ///////////////////////////////////////////////////////////////////////////
        //Get the queue for that ID
        inbound_q = incoming_write[cmd.get_id()];
        cmd.set_trans_state(XIL_AXI_TRANS_STATE_ACTIVE);

        ///////////////////////////////////////////////////////////////////////////
        //Get the first xfer on the list for this ID that has not completed the
        // Response phase.
        write_xfer = inbound_q.get_first_no_resp_inflight();
        write_xfer.set_resp_inflight();
        write_xfer.set_transfer(cmd);
        this.push_b_q(write_xfer);
        seq_item_port.item_done();
        this.cmds_inflight--;
      end
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Connections to ready sequencers
  protected task get_next_awready_item();
    axi_ready_gen_t           next_item;
    forever begin : GNI
      awready_seq_item_port.get_next_item(next_item);
      awready_gen= next_item.my_clone();
      awready_gen_q.push_back(awready_gen);
      awready_seq_item_port.item_done();
      if (awready_gen_q.size() > 500) begin
        `xil_error(this.get_tag(), "Too many outstanding Ready objects pending.")
      end
    end : GNI
  endtask : get_next_awready_item

  protected task get_next_wready_item();
    axi_ready_gen_t           next_item;
    forever begin : GNI
      wready_seq_item_port.get_next_item(next_item);
      wready_gen = next_item.my_clone();
      wready_gen_q.push_back(wready_gen);
      wready_seq_item_port.item_done();
      if (wready_gen_q.size() > 500) begin
        `xil_error(this.get_tag(), "Too many outstanding Ready objects pending.")
      end
    end : GNI
  endtask : get_next_wready_item

    ///////////////////////////////////////////////////////////////////////////
  //QUEUE management
  protected task push_b_q (inout slv_axi_write_transfer_t write_xfer);
    slv_axi_write_queue_t   outbound_q;
    if (this.get_reorder_response_ability() == XIL_AXI_REORDER_CAPABLE) begin
      if (!outbound_bresp.exists(write_xfer.get_id())) begin
        outbound_q = new(write_xfer.get_id());
        outbound_bresp[write_xfer.get_id()] = outbound_q;
      end else begin
        outbound_q = outbound_bresp[write_xfer.get_id()];
      end

      outbound_q.push_back(write_xfer);
    end else begin
      b_q.push_back(write_xfer);
    end

    `xil_info(this.get_tag(), $sformatf("B PUSH (%d) >>> %s <<<", b_q_entries, write_xfer.sprint()),verbosity)
    b_q_entries++;
    ->b_q_entries_event ;
  endtask

  protected task push_reactive_q (inout axi_transaction transfer);
    reactive_q.push_back(transfer);
    `xil_info(this.get_tag(), $sformatf("PUSH_REACTIVE_Q: PUSH (%d) >>> %s <<<", reactive_q_entries, transfer.cmd_sprintf()),verbosity)
    reactive_q_entries++;
    ->reactive_q_entries_event ;
  endtask

  protected task push_done_q(inout axi_transaction transfer);
    done_q.push_back(transfer);
    this.num_pending_payloads--;
    ->num_pending_payloads_event ;
    done_q_entries++;
    ->done_q_entries_event ;
  endtask

  protected task pop_reactive_q (inout axi_transaction transfer);
    while(reactive_q.size() == 0) begin
      @(reactive_q_entries_event);
    end
    transfer = reactive_q.pop_front();
    `xil_info(this.get_tag(), $sformatf("POP_REACTIVE_Q: (%d) >>> %s <<<", reactive_q_entries, transfer.cmd_sprintf()),verbosity)
    reactive_q_entries--;
    ->reactive_q_entries_event ;
  endtask

  protected task pop_b_q (inout slv_axi_write_transfer_t write_xfer);
    xil_axi_uint                outq_index;
    slv_axi_write_queue_t       outbound_q;
    xil_axi_uint                current_num_entries;

    while(b_q_entries == 0) begin
      @(b_q_entries_event);
      if (this.vif_proxy.is_aclk_high() == XIL_AXI_FALSE) begin 
        vif_proxy.wait_posedge_aclk_with_hold();
      end
    end
    if (this.get_reorder_response_ability() == XIL_AXI_REORDER_CAPABLE) begin
      ///////////////////////////////////////////////////////////////////////////
      //Since the slave may pop the BRESP quicker than one is available, if there is
      // only one entry then insert a backoff that will allow for some accumulation
      // of time so perhaps another BRESP will be ready to send.
      if (b_q_entries <= 1) begin
        ///////////////////////////////////////////////////////////////////////////
        //Get a backoff number
        `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
          AXI_WR_SLV_BORDER_FAIL: assert(this.randomize(reorder_backoff) with {reorder_backoff >= reorder_min_backoff; reorder_backoff <= reorder_max_backoff;});
        `else
          reorder_backoff = ($urandom() % (reorder_max_backoff - reorder_min_backoff)) + reorder_min_backoff;
        `endif
        vif_proxy.wait_aclks(reorder_backoff);
      end
      current_num_entries = outbound_bresp.num();
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        AXI_WR_SLV_BINDEX_FAIL: assert(this.randomize(reorder_index) with {reorder_index >= 0; reorder_index <= (current_num_entries-1);});
      `else
        reorder_index = $urandom() % (current_num_entries - 1);
      `endif

      for (int i = 0; i <= reorder_index; i++) begin
        if (i == 0) begin
          void'(outbound_bresp.first(outq_index));
        end else begin
          void'(outbound_bresp.next(outq_index));
        end
      end
      outbound_q = outbound_bresp[outq_index];
      write_xfer = outbound_q.pop_front();
      if (outbound_q.get_num_entries() == 0) begin
        outbound_q.free();
        outbound_bresp.delete(outq_index);
        `xil_info(this.get_tag(), $sformatf("B REMOVING (%d) %d", outq_index,outbound_q),verbosity)
      end
    end else begin
      write_xfer = b_q.pop_front();
    end
    ///////////////////////////////////////////////////////////////////////////
    //Depending on the number of entries in the b_q the reorder should be here
    b_q_entries--;
    ->b_q_entries_event ;
  endtask

  protected task pop_done_q(inout axi_transaction transfer);
    while(done_q_entries == 0) begin
      @(done_q_entries_event);
    end
    transfer = done_q.pop_front();
    done_q_entries--;
  endtask

  protected task clean_inflight();
    axi_transaction next_item;
    while (this.cmds_inflight > 0) begin
      seq_item_port.get_next_item(next_item);
      `xil_info(this.get_tag(), $sformatf("clean_inflight : %s", next_item.cmd_sprintf()), verbosity)
      seq_item_port.item_done();
      this.cmds_inflight--;
    end
  endtask

  protected task clean_b_q();
    slv_axi_write_transfer_t  wr_trans;
    axi_transaction           transfer;
    while (b_q_entries > 0) begin
      if (b_q.size() > 0) begin
        wr_trans = b_q.pop_front();
        transfer = wr_trans.get_transfer();
        `xil_info(this.get_tag(), $sformatf("Removing %s", transfer.cmd_sprintf()), verbosity)
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
        end
      end
      b_q_entries--;
    ->b_q_entries_event ;
    end
  endtask

  protected task clean_reactive_q();
    axi_transaction transfer;
    while (reactive_q_entries > 0) begin
      if (reactive_q.size() > 0) begin
        transfer = reactive_q.pop_front();
        `xil_info(this.get_tag(), $sformatf("Removing %s", transfer.cmd_sprintf()), verbosity)
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
        end
      end
      reactive_q_entries--;
    ->reactive_q_entries_event ;
    end
  endtask

  protected task push_reconcile_cmd_q(inout slv_axi_write_transfer_t xfer);
    reconcile_q.push_back(xfer);
    this.num_pending_cmds++;
    ->num_pending_cmds_event ;
    ///////////////////////////////////////////////////////////////////////////
    //In order to maintain an ordering of the command before the data, we need a
    // simple semaphore that will allow the wready_generation to know if if can
    // start sending the WREADY's.
    this.num_active_awrequests++;
      ->num_active_awrequests_event ;
    reconcile_q_entries++;
    ->reconcile_q_entries_event ;
  endtask

  protected task push_reconcile_data_q(inout slv_beat_q_t xfer);
    reconcile_data_q.push_back(xfer);
    this.num_pending_payloads++;
    ->num_pending_payloads_event ;
    ///////////////////////////////////////////////////////////////////////////
    //A full WDATA request has been serviced have the WREADY generation check
    this.num_active_awrequests--;
      ->num_active_awrequests_event ;
    reconcile_data_q_entries++;
    ->reconcile_data_q_entries_event ;
  endtask

  protected task pop_reconcile_cmd_q(inout slv_axi_write_transfer_t xfer);
    while(reconcile_q.size() == 0) begin
      @(reconcile_q_entries_event);
    end
    xfer = reconcile_q.pop_front();
    reconcile_q_entries--;
    ->reconcile_q_entries_event ;
  endtask

  protected task pop_reconcile_data_q(inout slv_beat_q_t xfer);
    while(reconcile_data_q.size() == 0) begin
      @(reconcile_data_q_entries_event);
    end
    xfer = reconcile_data_q.pop_front();
    reconcile_data_q_entries--;
    ->reconcile_data_q_entries_event ;
  endtask

  protected task clean_reconcile_data_q();
    slv_beat_q_t  xfer;
    while (reconcile_data_q_entries > 0) begin
      if (reconcile_data_q.size() > 0) begin
        xfer = reconcile_data_q.pop_front();
        xfer.clean();
      end
      reconcile_data_q_entries--;
    ->reconcile_data_q_entries_event ;
    end
  endtask

  protected task clean_reconcile_q();
    slv_axi_write_transfer_t  xfer;
    axi_transaction           transfer;
    while (reconcile_q_entries > 0) begin
      if (reconcile_q.size() > 0) begin
        xfer = reconcile_q.pop_front();
        transfer = xfer.get_transfer();
        transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
        if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
          return_item_to_sequence(transfer);
        end
      end
      reconcile_q_entries--;
    ->reconcile_q_entries_event ;
    end
  endtask

  protected task clean_incoming_write();
    slv_axi_write_queue_t     temp;
    xil_axi_uint              index;
    if ( incoming_write.first( index ) ) begin
      do begin
        temp = incoming_write[index];
        temp.clean();
        this.incoming_write.delete(index);
      end while ( this.incoming_write.next( index ) );
    end
  endtask

  protected task clean_outbound_bresp();
    slv_axi_write_queue_t   temp;
    xil_axi_uint                index;
    if ( outbound_bresp.first( index ) ) begin
      do begin
        temp = outbound_bresp[index];
        temp.clean();
        this.outbound_bresp.delete(index);
      end while ( this.outbound_bresp.next( index ) );
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Once the Packet has been completed send the completed transfer back to the
  // sequencer in the RESPONSE TLM channel
  protected task service_done_q ();
    axi_transaction transfer;
    forever begin : SERVICE_DONE_Q
      this.pop_done_q(transfer);
      `xil_info(this.get_tag(), $sformatf("SERVICE_DONE_Q: %s",transfer.cmd_sprintf()),verbosity)
      transfer.set_trans_state(XIL_AXI_TRANS_STATE_COMPLETED_SLAVE);
      if ((transfer.get_driver_return_item_policy() == XIL_AXI_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_WLAST_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_WLAST_PAYLOAD_RETURN)) begin
        this.return_item_to_sequence(transfer);
      end
    end
  endtask

  protected task return_item_to_sequence(axi_transaction transfer);
    axi_transaction transfer_clone;
    transfer_clone = transfer.my_clone();
    this.seq_item_port.put_rsp(transfer_clone);
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Now that all phases of the write transfer has been completed we need to
  // merge the write beats into the transfer in the xfer
  protected task service_reconcile_q ();
    axi_transaction               transfer;
    slv_axi_write_transfer_t      addr_xfer;
    slv_beat_q_t                  data_xfer;
    slv_axi_write_queue_t         inbound_q;

    forever begin : SERVICE_RECONCILE_Q
      pop_reconcile_cmd_q(addr_xfer);
      transfer = addr_xfer.get_transfer();

      pop_reconcile_data_q(data_xfer);

      addr_xfer.set_beat_q(data_xfer);
      ///////////////////////////////////////////////////////////////////////////
      //Check that the number of beats is the correct number
      AXI_WR_SLV_NUM_ENTRIES_MISMATCH: assert ((transfer.get_len() + 1) == data_xfer.get_num_entries()) else begin
        `xil_fatal(this.get_tag(),
              $sformatf("Write transfer ID=0x%x did not receive correct number of beats Exp %d got %d\n>>%s<<",
              transfer.get_id(),(transfer.get_len() + 1),data_xfer.get_num_entries(), addr_xfer.sprint()))
      end

      addr_xfer.set_data_phase_complete();
      if (addr_xfer.get_reactive_sent() == XIL_AXI_FALSE) begin
        addr_xfer.store_wdata();
        addr_xfer.set_reactive_sent();
        push_reactive_q(transfer);
      end
      ///////////////////////////////////////////////////////////////////////////
      //If the BRESP has completed then push to the done queue
      if (addr_xfer.all_phase_complete()) begin
        addr_xfer.store_wdata();
        ///////////////////////////////////////////////////////////////////////////
        //Get the queue for that ID
        inbound_q = incoming_write[transfer.get_id()];
        addr_xfer = inbound_q.pop_front();
        ///////////////////////////////////////////////////////////////////////////
        //Are there any more pending transfers for this ID? if not tear down the
        // entries.
        if (inbound_q.get_num_entries() == 0) begin
          `xil_info(this.get_tag(), $sformatf("SERVICE_RECONCILE_Q: REMOVING (%d) %d", transfer.get_id(),inbound_q),verbosity)
          inbound_q.free();
          incoming_write.delete(transfer.get_id());
        end
        ///////////////////////////////////////////////////////////////////////////
        //Pass the transfer to the done queue for reconcilation
        push_done_q(transfer);
      end
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Main AW channel process
  /*
    Function: get_wr_reactive
    Returns write reactive transaction
  */
  virtual task get_wr_reactive (output axi_transaction transfer);
    ///////////////////////////////////////////////////////////////////////////
    //Pop the AW transfer
    pop_reactive_q(transfer);
    this.cmds_inflight++;
  endtask : get_wr_reactive

   /*
    Function: create_transaction
    Returns an AXI transaction class that has been "newed"
  */
  virtual function axi_transaction create_transaction (string name = "unnamed_transaction");
    axi_transaction item=new(name);
    item.set_cmd_type(XIL_AXI_WRITE);
    item.set_protocol(C_AXI_PROTOCOL);
    item.set_addr_width(C_AXI_ADDR_WIDTH );
    item.set_data_width(C_AXI_WDATA_WIDTH);
    item.set_id_width(C_AXI_WID_WIDTH);
    item.set_awuser_width(C_AXI_AWUSER_WIDTH);
    item.set_wuser_width(C_AXI_WUSER_WIDTH);
    item.set_buser_width(C_AXI_BUSER_WIDTH);
    item.set_aruser_width(C_AXI_ARUSER_WIDTH);
    item.set_ruser_width(C_AXI_RUSER_WIDTH);
    item.set_supports_narrow(C_AXI_SUPPORTS_NARROW);
    if (C_AXI_SUPPORTS_NARROW == 0) begin
      item.set_size(item.get_dw_size());
    end
    item.set_has_burst(C_AXI_HAS_BURST);
    if (C_AXI_HAS_BURST == 0) begin
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
    end
    item.set_has_lock(C_AXI_HAS_LOCK);
    if (C_AXI_HAS_LOCK == 0) begin
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
    end
    item.set_has_cache(C_AXI_HAS_CACHE);
    item.set_has_region(C_AXI_HAS_REGION);
    if (C_AXI_HAS_REGION == 0) begin
      item.set_region(0);
    end
    item.set_has_prot(C_AXI_HAS_PROT);
    if (C_AXI_HAS_PROT == 0) begin
      item.set_prot(0);
    end
    item.set_has_qos(C_AXI_HAS_QOS);
    if (C_AXI_HAS_QOS == 0) begin
      item.set_qos(0);
    end
    item.set_has_wstrb(C_AXI_HAS_WSTRB);
    item.set_has_bresp(C_AXI_HAS_BRESP);
    item.set_has_rresp(C_AXI_HAS_RRESP);
    item.clr_beat_index();
    if (item.get_axi_version() == XIL_VERSION_LITE) begin
      item.set_id(0);
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
      item.set_size(item.get_dw_size());
      item.set_len(0);
      item.set_qos(0);
      item.set_region(0);
    end
    return(item);
  endfunction :create_transaction

  protected task aw_channel();
    xil_axi_cmd_beat                aw_beat;
    axi_transaction                 cmd;
    slv_axi_write_queue_t           inbound_q;
    slv_axi_write_transfer_t        write_xfer;

    forever begin : AW_CHANNEL
      ///////////////////////////////////////////////////////////////////////////
      //Constant driver
      vif_proxy.wait_aw_accepted();
      aw_beat = vif_proxy.get_awcmd();

      AXI_SLV_AWID_UNKNOWN : assert(!($isunknown(aw_beat.id))) else begin
        `xil_error(this.get_tag(), "Unknown value found on AWID... Bad things WILL happend")
        aw_beat.id = 0;
      end
      cmd = this.create_transaction($sformatf("AW_REACTIVE_%0d", aw_beat.id));

      cmd.import_cmd_fields(aw_beat);

      `xil_info(this.get_tag(), $sformatf("AWVALID >>>\n%s<<<", cmd.cmd_sprintf()),verbosity)
      ///////////////////////////////////////////////////////////////////////////
      //Is there a currently active transaction with the same ID.
      if (!incoming_write.exists(cmd.get_id())) begin
        ///////////////////////////////////////////////////////////////////////////
        //No. Create a new transaction queue and link it upto the ID array
        inbound_q = new(cmd.get_id());
        incoming_write[cmd.get_id()] = inbound_q;
      end else begin
        ///////////////////////////////////////////////////////////////////////////
        //Yes. Get the transaction queue for that ID
        inbound_q = incoming_write[cmd.get_id()];
      end
      ///////////////////////////////////////////////////////////////////////////
      //Get the first element for the ID where the ADDR phase has not been completed
      write_xfer = inbound_q.get_first_no_addr_phase();
      ///////////////////////////////////////////////////////////////////////////
      //Get the transfer from the element
      write_xfer.set_transfer(cmd);
      write_xfer.set_addr_phase_complete();
      ///////////////////////////////////////////////////////////////////////////
      //Responses cannot pass each other regardless of the bufferable mask
      // If there is more than one entry in the inbound_q, that means that there is
      // at least one other entry a head of this on.
      push_reconcile_cmd_q(write_xfer);
      aw_beat = null;
    end //forever begin
  endtask : aw_channel


  protected task awready_policy_generation();
    forever begin : AWREADY_POLICY_GENERATION
      if(awready_gen_q.size()>0) begin
        this.awready_gen = this.awready_gen_q.pop_front();
      end
      ///////////////////////////////////////////////////////////////////////////
      //Get random values
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        AXI_WR_SLV_AWPOLICY_GEN: assert(this.awready_gen.randomize());
      `else
        this.awready_gen.cheap_random();
      `endif
      ///////////////////////////////////////////////////////////////////////////
      //If the ready algorithm is to wait until after VALID has been asserted, then
      // check to see if VALID is asserted, if not wait until it is sampled asserted.
      if (get_xfer_wrcmd_order() == XIL_AXI_WRCMD_ORDER_DATA_BEFORE_CMD) begin
        fork
          begin
            vif_proxy.clr_awready();
            vif_proxy.wait_wvalid_sampled();
          end
          begin
            vif_proxy.wait_aclks(get_awaddr_watchdog_delay());
            AXI_WR_SLV_DATA_BEFORE_CMD_DEADLOCK : assert(0) begin
            end else begin
              `xil_error(this.get_tag(), "AXI_WR_SLV_DATA_BEFORE_CMD_DEADLOCK : WATCHDOG fired, forward progress forced")
            end
          end
        join_any
        disable fork;
      end else begin
        if ((this.awready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_SINGLE) ||
            (this.awready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_EVENTS) ||
            (this.awready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_OSC) ||
            ((this.awready_gen.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM) && (
              (this.awready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_SINGLE) ||
              (this.awready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_EVENTS) ||
              (this.awready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_OSC)))) begin
          vif_proxy.clr_awready();
          vif_proxy.wait_negedge_aclk();
          ///////////////////////////////////////////////////////////////////////////
          //If the valid is not asserted then wait until the posedge
          if (vif_proxy.is_live_awvalid_asserted() == 0) begin
            vif_proxy.wait_live_awvalid_asserted();
          end
        end
      end
      ///////////////////////////////////////////////////////////////////////////
      //Wait low time then assert for one handshake
      if (this.awready_gen.get_low_time() > 0) begin
        vif_proxy.clr_awready();
        vif_proxy.wait_aclks(this.awready_gen.get_low_time());
        #this.vif_proxy.hold_time;
      end

      vif_proxy.set_awready();
      case (this.awready_gen.get_ready_policy())
        XIL_AXI_READY_GEN_AFTER_VALID_OSC,
        XIL_AXI_READY_GEN_OSC: begin
          vif_proxy.wait_aclks(this.awready_gen.get_high_time());
        end
        XIL_AXI_READY_GEN_RANDOM: begin
          case(this.awready_gen.get_ready_rand_policy())
            XIL_AXI_READY_RAND_AFTER_VALID_OSC,
            XIL_AXI_READY_RAND_OSC: begin
              this.vif_proxy.wait_aclks(this.awready_gen.get_high_time());
            end
            default : begin
              this.vif_proxy.wait_aw_accepted();
            end
          endcase
        end
        default: begin
          vif_proxy.wait_aw_accepted();
        end
      endcase
      #this.vif_proxy.hold_time;
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Depending on the AWEADY algorithm
  protected task awready_generation();
    vif_proxy.clr_awready();
    vif_proxy.wait_posedge_aclk();
    forever begin : AWREADY_GENERATION
      ///////////////////////////////////////////////////////////////////////////
      // deassert signals
      fork
        begin
          ///////////////////////////////////////////////////////////////////////////
          //Only allow so many transactions to be processed at a time.
          while (this.num_pending_cmds < this.get_transaction_depth()) begin
            @(this.num_pending_cmds_event);
          end
          `xil_info(this.get_tag(),$sformatf("GUARD: num_pending_cmds:%d - transaction_depth:%d", this.num_pending_cmds,this.get_transaction_depth()), verbosity)
        end
        begin
          awready_policy_generation();
        end
      join_any
      disable fork;
      ///////////////////////////////////////////////////////////////////////////
      //Stop and clear the AWREADY
      vif_proxy.clr_awready();
      ///////////////////////////////////////////////////////////////////////////
      //Wait until there is space to continue
      while (this.num_pending_cmds >= this.get_transaction_depth()) begin
        @(this.num_pending_cmds_event);
      end
    end //forever begin
  endtask : awready_generation

  protected task wready_policy_generation();
    int unsigned  event_counter;
    forever begin : WREADY_POLICY_GENERATION
      if (this.wready_gen_q.size()>0) begin
        this.wready_gen = this.wready_gen_q.pop_front();
      end

      ///////////////////////////////////////////////////////////////////////////
      //Get random values
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        AXI_WR_SLV_WPOLICY_GEN: assert(this.wready_gen.randomize());
      `else
        this.wready_gen.cheap_random();
      `endif
      ///////////////////////////////////////////////////////////////////////////
      //If the ready algorithm is to wait until after VALID has been asserted, then
      // check to see if VALID is asserted, if not wait until it is sampled asserted.
      if ((this.wready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_SINGLE) ||
          (this.wready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_EVENTS) ||
          (this.wready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_OSC) ||
          ((this.wready_gen.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM) && (
            (this.wready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_SINGLE) ||
            (this.wready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_EVENTS) ||
            (this.wready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_OSC)))) begin
        vif_proxy.clr_wready();
        vif_proxy.wait_negedge_aclk();
        ///////////////////////////////////////////////////////////////////////////
        //If the valid is not asserted then wait until the posedge
        if (vif_proxy.is_live_wvalid_asserted() == 0) begin
          vif_proxy.wait_live_wvalid_asserted();
        end
      end

      ///////////////////////////////////////////////////////////////////////////
      //Wait low time then assert for one handshake
      if (this.wready_gen.get_low_time() > 0) begin
        vif_proxy.clr_wready();
        vif_proxy.wait_aclks(this.wready_gen.get_low_time());
        #this.vif_proxy.hold_time;
      end

      vif_proxy.set_wready();
      event_counter = 0;
      case (this.wready_gen.get_ready_policy())
        XIL_AXI_READY_GEN_AFTER_VALID_EVENTS,
        XIL_AXI_READY_GEN_EVENTS: begin
          fork
            begin
              while (this.wready_gen.get_event_count() > event_counter) begin
                vif_proxy.wait_w_accepted();
                event_counter++;
              end
            end
            begin
              forever begin
                vif_proxy.wait_aclks(this.wready_gen.get_event_cycle_count_reset());
                event_counter = 0;
              end
            end
          join_any
          disable fork;
        end
        XIL_AXI_READY_GEN_AFTER_VALID_OSC,
        XIL_AXI_READY_GEN_OSC: begin
          vif_proxy.wait_aclks(this.wready_gen.get_high_time());
        end
        XIL_AXI_READY_GEN_RANDOM: begin
          case(this.wready_gen.get_ready_rand_policy())
            XIL_AXI_READY_RAND_AFTER_VALID_OSC,
            XIL_AXI_READY_RAND_OSC: begin
              this.vif_proxy.wait_aclks(this.wready_gen.get_high_time());
            end
            XIL_AXI_READY_RAND_AFTER_VALID_EVENTS,
            XIL_AXI_READY_RAND_EVENTS: begin
              fork
                begin
                  while (this.wready_gen.get_event_count() > event_counter) begin
                    vif_proxy.wait_w_accepted();
                    event_counter++;
                  end
                end
                begin
                  forever begin
                    vif_proxy.wait_aclks(this.wready_gen.get_event_cycle_count_reset());
                    event_counter = 0;
                  end
                end
              join_any
              disable fork;
            end
            default : begin
              this.vif_proxy.wait_w_accepted();
            end
          endcase
        end
        default: begin
          vif_proxy.wait_w_accepted();
        end
      endcase
      #this.vif_proxy.hold_time;
    end //forever begin
  endtask : wready_policy_generation

  protected task wready_policy_gating();
    forever begin : WREADY_POLICY_GATING
      ///////////////////////////////////////////////////////////////////////////
      //Wait to start the policy generation
      @(wready_policy_start);
      fork
        begin
          ///////////////////////////////////////////////////////////////////////////
          //This is the actual call to the generation of the policy.
          wready_policy_generation();
        end
        begin
          ///////////////////////////////////////////////////////////////////////////
          //Stop the WREADY generation when triggered and clear wready.
          @(wready_policy_end);
        end
      join_any
      disable fork;
      vif_proxy.clr_wready();
      `xil_info(this.get_tag(), $sformatf("EXIT"),verbosity)
    end
  endtask

  protected task wready_transaction_guard();
    forever begin : TRANSACTION_GUARD
      ///////////////////////////////////////////////////////////////////////////
      //Continue to pulse WREADY while the number of pending frames is less than the transaction depth.
      while (num_pending_payloads < get_transaction_depth()) begin
        @(num_pending_payloads_event);
      end
      ///////////////////////////////////////////////////////////////////////////
      //We are greater than the transaction depth. Clear the WREADY
      -> wready_policy_end;

      ///////////////////////////////////////////////////////////////////////////
      //Wait until the number of pending frames is below our transaction depth
      while (num_pending_payloads >= get_transaction_depth()) begin
        @(num_pending_payloads_event);
      end
      -> wready_policy_start;
    end
  endtask

  protected task wready_fifo_guard();
    forever begin : FIFO_GUARD
      ///////////////////////////////////////////////////////////////////////////
      //If the fifo depth is 0 then a command MUST be accepted before WREADY is
      // Activated
      this.wdata_beat_counter = 0;
      ///////////////////////////////////////////////////////////////////////////
      //Mimic an inbound buffer of depth inbound_fifo_depth. Count the number of
      // beats. If this exceeds the depth then check if there are any outstanding
      // commands. If there are commands that have been already accepted, assume that the
      while ((this.wdata_beat_counter < get_inbound_fifo_depth())) begin
        @(wchannel_beat_sampled_event);
      end
      ///////////////////////////////////////////////////////////////////////////
      //If there are no pending requests, then stop the wready and wait until there
      // is at least one active request.
      if (num_active_awrequests <= 0) begin
        -> wready_policy_end;
        while (num_active_awrequests <= 0) begin
          @(num_active_awrequests_event);
        end
        -> wready_policy_start;
      end else begin
        @(num_active_awrequests_event);
      end
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Depending on the WREADY algorithm
  protected task wready_generation();
    vif_proxy.clr_wready();
    vif_proxy.wait_posedge_aclk();
    forever begin : WREADY_GENERATION
      ///////////////////////////////////////////////////////////////////////////
      // deassert signals
      fork
        begin
          wready_policy_gating();
        end
        begin
          this.wdata_beat_counter = 0;
          ///////////////////////////////////////////////////////////////////////////
          //Start the wready generation
          -> wready_policy_start;
          fork
            wready_transaction_guard();
            wready_fifo_guard();
          join
        end
      join
    end //forever begin
  endtask : wready_generation

  protected task w_channel();
    ///////////////////////////////////////////////////////////////////////////
    //Constant driver
    slv_beat_q_t                      w_channel_beat_q;
    xil_axi_write_beat                    beat;
    bit                               found_last;
    forever begin : W_CHANNEL
      vif_proxy.wait_areset_deassert();
      found_last = 0;
      this.wdata_beat_counter = 0;
      w_channel_beat_q = new;
      ///////////////////////////////////////////////////////////////////////////
      //Create a beat queue to collect all incomming beats. When the LAST is detected
      // move the entire beat queue to the reconcile queue.
      while (!found_last) begin
        ///////////////////////////////////////////////////////////////////////////
        //Constant driver
        vif_proxy.wait_w_accepted();
        beat = vif_proxy.get_wdata();
        w_channel_beat_q.push_back(beat);

        if (beat.last == 1'b1) begin
          `xil_info(this.get_tag(), $sformatf("W LAST -- %s",beat.convert2string()),verbosity)
          found_last = 1;
          this.wdata_beat_counter = 0;
        end else begin
          this.wdata_beat_counter++;
          `xil_info(this.get_tag(), $sformatf("W BEAT -- %s",beat.convert2string()),verbosity)
        end
        -> wchannel_beat_sampled_event;
      end
      ///////////////////////////////////////////////////////////////////////////
      //Pass the transfer to the done queue for reconcilation
      push_reconcile_data_q(w_channel_beat_q);
    end //forever begin
  endtask : w_channel

  ///////////////////////////////////////////////////////////////////////////
  //Main B channel process
  protected task b_channel();
    axi_transaction_t                 transfer;
    slv_axi_write_transfer_t          write_xfer;
    slv_axi_write_queue_t             inbound_q;
    xil_axi_resp_beat                     bresp;

    ///////////////////////////////////////////////////////////////////////////
    //Constant driver
    forever begin : B_CHANNEL
      ///////////////////////////////////////////////////////////////////////////
      //Drive the B bus
      vif_proxy.reset_b();
      ///////////////////////////////////////////////////////////////////////////
      // get next transaction out of AR channel queue. This call will block if
      // there are no transactions posted in the queue.
      this.pop_b_q(write_xfer);
      transfer = write_xfer.get_transfer();

      ///////////////////////////////////////////////////////////////////////////
      // apply read request wait states. We need to not cut short the delay, so
      // we must wait until the ACLK is high.
      if (transfer.get_response_delay() > 0) begin
        for (xil_axi_uint acnt = 0; acnt < transfer.get_response_delay(); acnt++) begin
          fork
            vif_proxy.wait_posedge_aclk_with_hold();
            vif_proxy.put_b_noise();
          join
        end
      end
      ///////////////////////////////////////////////////////////////////////////
      // send out request on response channel
      vif_proxy.put_bresp(transfer);
      vif_proxy.set_bvalid();

      ///////////////////////////////////////////////////////////////////////////
      // wait for BREADY (may have been high already)
      fork
        begin
          vif_proxy.wait_b_accepted();
        end
        begin
          vif_proxy.wait_aclks(waiting_valid_timeout_value);
          `xil_fatal(this.get_tag(), $sformatf("BREADY has not been received while BVALID is asserted. (id=0x%x)", transfer.get_id()))
        end
      join_any
      disable fork;

      ///////////////////////////////////////////////////////////////////////////
      //if all the phases are complete (AW/W/B) then the transfer is done and pass
      // it to the done queue. The completed write_xfer must be at the head of the queue!
      write_xfer.set_resp_phase_complete();
      this.num_pending_cmds--;
      ->num_pending_cmds_event ;

      if (write_xfer.all_phase_complete()) begin
        inbound_q = incoming_write[write_xfer.get_id()];
        write_xfer.store_wdata();
        write_xfer = inbound_q.pop_front();
        ///////////////////////////////////////////////////////////////////////////
        //Are there any more pending transfers for this ID? if not tear down the
        // entries.
        if (inbound_q.get_num_entries() == 0) begin
          inbound_q.free();
          incoming_write.delete(transfer.get_id());
        end
        ///////////////////////////////////////////////////////////////////////////
        //Pass the transfer to the done queue for reconcilation
        push_done_q(transfer);
      end
      #this.vif_proxy.hold_time;
    end //forever begin
  endtask : b_channel

  protected task forward_progress_watchdog();
    forever begin : PROGRESS
      ///////////////////////////////////////////////////////////////////////////
      //Wait until there is at least one transaction to be processed. This is here
      // to cover the case where there are not sequence items for the read channel
      while (num_pending_cmds == 0) begin
        @(num_pending_cmds_event);
      end
      fork
        ///////////////////////////////////////////////////////////////////////////
        //If you get an AW or W or B accepted then restart the fork
        begin
          vif_proxy.wait_aw_accepted();
        end
        begin
          vif_proxy.wait_w_accepted();
        end
        begin
          vif_proxy.wait_b_accepted();
        end
        ///////////////////////////////////////////////////////////////////////////
        //Timeout if there is no accepted beats within forward_progress_timeout_value cycles
        begin
          vif_proxy.wait_aclks(forward_progress_timeout_value);
          if (num_pending_cmds > 0) begin
            if (this.reactive_q_entries > 0) begin
              `xil_fatal(this.get_tag(), $sformatf("Reactive command queue has commands to be serviced (%d), but no servicing has occured with function get_wr_reactive. No forward progess.", this.reactive_q_entries))
            end else begin
              `xil_fatal(this.get_tag(), $sformatf("AW commands have been received (%d), but no correspoinding WDATA+WLAST has occured. No forward progess.", this.num_pending_cmds))
            end
          end
        end
      join_any
      disable fork;
      vif_proxy.wait_aclks(10);
    end
  endtask : forward_progress_watchdog


  ////////////////////////////////////////////////////////////////////////////
  //send wready and wait
  /*
   Function: send_wready
   Sends the ready structure to the driver for controlling the WREADY channel
  */
  task send_wready(input axi_ready_gen t);
    this.wready_seq_item_port.put_item(t);
    this.wready_seq_item_port.wait_for_item_done();
  endtask

  /*
   Function: create_ready
   Returns a ready class that has been "newed".
  */
  virtual function axi_ready_gen create_ready (string name = "unnamed_ready");
    axi_ready_gen    ready=new(name);
    return(ready);
  endfunction


  ////////////////////////////////////////////////////////////////////////////
  //send wready and wait
  /*
   Function: send_wready
   Sends the ready structure to the driver for controlling the AWREADY channel
  */
  task send_awready(input axi_ready_gen t);
    if(this.get_is_active()) begin
      this.awready_seq_item_port.put_item(t);
      this.awready_seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send AWREADY when driver is not active"))
    end
  endtask

  /*
   Function: send
   Sends the AXI transaction to the driver 
  */
  task send(input axi_transaction t);
    if(this.get_is_active()) begin
      this.seq_item_port.put_item(t);
      this.seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send transaction when driver is not active"))
    end
  endtask  : send
   
  /*  
   Function: wait_rsp
   This blocking function will not return until driver send back response transaction
  */
  task wait_rsp(output axi_transaction t);
    this.seq_item_port.get_next_rsp(t);
    this.seq_item_port.rsp_done();
  endtask  : wait_rsp

endclass : axi_slv_wr_driver

/*
  Class: axi_slv_rd_driver
  AXI Slave Read Driver object.
*/
class axi_slv_rd_driver `AXI_PARAM_DECL extends xil_driver #(axi_transaction,axi_transaction);

  ///////////////////////////////////////////////////////////////////////////
  //Typedef
  typedef xil_axi_generic_queue_container #(axi_transaction)  slv_axi_outbound_queue_t;

  ///////////////////////////////////////////////////////////////////////////
  // user configurable parameters
  protected xil_axi_uint                    rd_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected axi_ready_gen_t                 arready_gen;
  protected axi_ready_gen_t                 arready_gen_q[$];
  protected xil_axi_reorder_ability_t       reorder_data_ability = XIL_AXI_NO_REORDER;
  protected xil_axi_uint                    num_pending_cmds = 0;
  protected xil_axi_uint                    cmds_inflight = 0;
  protected xil_axi_uint                    driver_imposed_min_beat_delay = 0;
  protected xil_axi_ulong                   current_beat_submit_cycle = 0;
  protected xil_axi_uint                    waiting_valid_timeout_value = 500000;
  protected xil_axi_uint                    forward_progress_timeout_value = 50000;
  rand xil_axi_uint                         reorder_index;
  rand xil_axi_uint                         xfer_continue_probability;
  protected xil_axi_boolean_t               adjust_addr_delay_enabled = XIL_AXI_TRUE;
  protected xil_axi_boolean_t               adjust_data_beat_delay_enabled = XIL_AXI_TRUE;

  ///////////////////////////////////////////////////////////////////////////
  // AXI interface
  axi_vif_mem_proxy `AXI_PARAM_ORDER vif_proxy;
  xil_seq_item_pull_port #(axi_ready_gen, axi_ready_gen) arready_seq_item_port;

  ///////////////////////////////////////////////////////////////////////////
  // internal channel queues
  protected axi_transaction                 r_q[$];
  protected int                             verbosity = XIL_AXI_VERBOSITY_NONE;
  protected axi_transaction                 done_q[$];
  protected xil_axi_uint                    r_q_entries = 0;
  protected xil_axi_uint                    done_q_entries = 0;
  event                                     done_q_entries_event ;
  event                                     r_q_entries_event ;
  event                                     num_pending_cmds_event ;

  ///////////////////////////////////////////////////////////////////////////
  //Outbound array
  slv_axi_outbound_queue_t                  outbound_rdata  [xil_axi_uint];

  ///////////////////////////////////////////////////////////////////////////
  // internal events

  /*
    Function: new
    Constructor to create an AXI slave read driver 
  */
  function new(string name = "unnamed_axi_slv_rd_driver");
    super.new(name);
    this.r_q_entries = 0;
    this.done_q_entries = 0;
    arready_seq_item_port = new("arready_seq_item_port");
    this.arready_gen = new("arready_gen");
  endfunction

  protected virtual function xil_axi_boolean_t get_adjust_addr_delay_enabled();
    return(this.adjust_addr_delay_enabled);
  endfunction: get_adjust_addr_delay_enabled

  protected virtual function void set_adjust_addr_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_addr_delay_enabled = update;
  endfunction: set_adjust_addr_delay_enabled

  protected virtual function xil_axi_boolean_t get_adjust_data_beat_delay_enabled();
    return(this.adjust_data_beat_delay_enabled);
  endfunction: get_adjust_data_beat_delay_enabled

  protected virtual function void set_adjust_data_beat_delay_enabled(input xil_axi_boolean_t update);
    this.adjust_data_beat_delay_enabled = update;
  endfunction: set_adjust_data_beat_delay_enabled

  /*
    Function: set_reorder_data_ability
    Sets reorder_data_ability of the Driver
  */
  function void set_reorder_data_ability (input xil_axi_reorder_ability_t value);
    if ((C_AXI_RID_WIDTH == 0) && (value != XIL_AXI_NO_REORDER)) begin
      `xil_warning(this.get_name(), $sformatf("Attempt to change reorder ability (%s) when there are no ID's. No change.", this.reorder_data_ability.name()))
    end else begin
      this.reorder_data_ability  = value;
    end
  endfunction : set_reorder_data_ability

  /*
   Function: get_reorder_data_ability
   Returns reorder_data_ability of the Driver
  */
  function xil_axi_reorder_ability_t get_reorder_data_ability ();
    return(this.reorder_data_ability );
  endfunction : get_reorder_data_ability

  /*
    Function: set_vif
    Assigns the virtual interface of the driver.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    this.vif_proxy = vif;
  endfunction : set_vif

  ///////////////////////////////////////////////////////////////////////////
  //Configuration knobs
  function void set_arready_gen(input axi_ready_gen_t new_method);
    this.arready_gen = new_method;
  endfunction

  function axi_ready_gen_t get_arready_gen();
    get_arready_gen = this.arready_gen;
  endfunction

  /*
    Function: set_forward_progress_timeout_value
    Sets forward_progress_timeout_value of the Driver
  */
  function void set_forward_progress_timeout_value (input xil_axi_uint new_timeout);
    this.forward_progress_timeout_value  = new_timeout;
  endfunction

  /*
   Function: get_forward_progress_timeout_value
   Returns forward_progress_timeout_value of the Driver
  */
  function xil_axi_uint get_forward_progress_timeout_value ();
    return(this.forward_progress_timeout_value );
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Driver will have in flight at one time.
  */
  function void set_transaction_depth(input xil_axi_uint new_depth);
    if (new_depth == 0) begin
      `xil_warning(this.get_tag(), "Setting the READ transaction Depth to 0. No transactions will be issued")
    end
    this.rd_transaction_depth = new_depth;
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Driver will have in flight at one time.
  */
  function xil_axi_uint get_transaction_depth();
    return(this.rd_transaction_depth);
  endfunction

  /*
    Function: get_num_pending_cmds
    Returns number of commands in pending
  */
  function xil_axi_uint get_num_pending_cmds();
    return(this.num_pending_cmds);
  endfunction

  /*
    Function: get_cmds_inflight
    Returns number of commands in flight
  */
  function xil_axi_uint get_cmds_inflight();
    return(this.cmds_inflight);
  endfunction

  protected function void push_r_q(axi_transaction transfer);
    slv_axi_outbound_queue_t   id_queue;

    if (this.get_reorder_data_ability() == XIL_AXI_REORDER_CAPABLE) begin
      ///////////////////////////////////////////////////////////////////////////
      //Does an entry in the outbound_rdata if not create one.
      if (!outbound_rdata.exists(transfer.get_id())) begin
        id_queue = new;
        outbound_rdata[transfer.get_id()] = id_queue;
      end else begin
        id_queue = outbound_rdata[transfer.get_id()];
      end
      id_queue.push_back(transfer);
    end else begin
      r_q.push_back(transfer);
    end
    r_q_entries++;
    ->r_q_entries_event ;
  endfunction

  protected function void push_done_q(axi_transaction transfer);
    if (this.num_pending_cmds == 0) begin
      AXI_RD_SLV_NEG_PENDING: assert (0) else `xil_error(this.get_tag(), "Number of pending commands is zero")
    end else begin
      this.num_pending_cmds--;
      ->num_pending_cmds_event;
    end

    done_q.push_back(transfer);
    done_q_entries++;
    ->done_q_entries_event;
  endfunction

  protected function axi_transaction get_next_r_transfer();
    xil_axi_uint outq_index;
    axi_transaction transfer;
    slv_axi_outbound_queue_t   id_queue;
    xil_axi_uint  current_num_entries;
    ///////////////////////////////////////////////////////////////////////////
    //Select an and ID
    current_num_entries = outbound_rdata.num();
    `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
      AXI_RD_SLV_RINDEX_FAIL: assert(this.randomize(reorder_index) with {reorder_index >= 0; reorder_index <= current_num_entries-1;});
    `else
      reorder_index = $urandom() % (current_num_entries - 1);
    `endif

    ///////////////////////////////////////////////////////////////////////////
    //get the id_queue from the outbound_rdata list.
    for (int i = 0; i <= reorder_index; i++) begin
      if (i == 0) begin
        void'(outbound_rdata.first(outq_index));
      end else begin
        void'(outbound_rdata.next(outq_index));
      end
    end

    id_queue = outbound_rdata[outq_index];
    transfer = id_queue.peek_front();
    ///////////////////////////////////////////////////////////////////////////
    //Adjust the time applied to the insertion delay of the beat.
    if (this.get_adjust_data_beat_delay_enabled() == XIL_AXI_TRUE) begin
      transfer.adjust_data_insertion_delay(this.vif_proxy.get_current_clk_count());
    end
    return(transfer);
  endfunction

  protected function void remove_xfer_from_outbound(input xil_axi_uint pid);
    slv_axi_outbound_queue_t  id_queue;
    axi_transaction           item;
    ///////////////////////////////////////////////////////////////////////////
    //Does an element for this ID exist in the outbound queue? If it doesn't that
    // is bad news!
    if (!outbound_rdata.exists(pid)) begin
      `xil_fatal(this.get_tag(), $sformatf("ERROR: Entry in outboud_rdata does not exist for ID 0x%x", pid))
    end else begin
      ///////////////////////////////////////////////////////////////////////////
      //Get the ID element and pop the front of the queue.
      id_queue = outbound_rdata[pid];
      item = id_queue.pop_front();
      if (id_queue.get_num_entries() == 0) begin
        ///////////////////////////////////////////////////////////////////////////
        //This was the last one for this ID remove it.
        outbound_rdata.delete(pid);
      end
    end
    r_q_entries--;
    ->r_q_entries_event;
  endfunction

  protected function void adjust_current_beat_delay(axi_transaction transfer);
    xil_axi_uint  delta_cycles;
    if (this.get_adjust_data_beat_delay_enabled() == XIL_AXI_TRUE) begin
      delta_cycles = this.vif_proxy.get_current_clk_count() - current_beat_submit_cycle;
      ///////////////////////////////////////////////////////////////////////////
      //Insert imposed beat delay to be applied at every beat.
      if (delta_cycles >= transfer.get_beat_index_delay()) begin
        transfer.set_beat_index_delay(driver_imposed_min_beat_delay);
      end else begin
        transfer.set_beat_index_delay(transfer.get_beat_index_delay() - delta_cycles + driver_imposed_min_beat_delay);
      end
    end
  endfunction : adjust_current_beat_delay

  protected function xil_axi_boolean_t is_driver_idle();
    if ((r_q_entries + outbound_rdata.num() + done_q_entries) > 0) begin
      return(XIL_AXI_FALSE);
    end else begin
      return(XIL_AXI_TRUE);
    end
  endfunction

  ///////////////////////////////////////////////////////////////////////////
  // Main definition enabling all the channels.
  /*
    Function: run_phase
    Start control processes for operation
  */
  task run_phase();
    if (!this.get_is_active()) begin
      this.set_is_active();
      this.stop_triggered_event = 0;
      this.num_pending_cmds = 0;
      this.cmds_inflight = 0;
      if (this.vif_proxy == null) begin
        `xil_fatal(this.get_tag(), $sformatf("Attempted to start %s without assigned Interface", this.get_name()))
      end
      vif_proxy.reset_r();
      vif_proxy.clr_arready();
      vif_proxy.wait_posedge_aclk();
      vif_proxy.wait_areset_deassert();
      while (this.stop_triggered_event == 0) begin
        fork
          begin
            this.num_pending_cmds = 0;
            `xil_info(this.get_tag(), "run()", verbosity)
            run_active();
          end
          begin
            vif_proxy.wait_areset_asserted();
          end
          begin : STOP
            @(posedge this.stop_triggered_event);
            `xil_info(this.get_tag(), "Stop event triggered. All traffic is being terminated.",this.verbosity)
          end
        join_any
        disable fork;
        `xil_info(this.get_tag(), $sformatf("RESET DETECTED"),verbosity)
        vif_proxy.reset_r();
        vif_proxy.clr_arready();
        clean_r_q;
        if (this.stop_triggered_event == 0) begin
          vif_proxy.wait_areset_deassert();
          `xil_info(this.get_tag(), $sformatf("RESET Released"),verbosity)
        end
        clean_inflight;
      end
      this.clr_is_active();
    end else begin
      `xil_warning(this.get_tag(), $sformatf("%s is already active.", this.get_name()))
    end
  endtask : run_phase

  ///////////////////////////////////////////////////////////////////////////
  //Stop the active processes.
  /*
    Function: stop_phase
    Stops all control processes.
  */
  virtual task stop_phase();
    this.stop_triggered_event = 1;
  endtask : stop_phase

  ///////////////////////////////////////////////////////////////////////////
  //Fork off the active processes.
  protected task run_active();
    vif_proxy.wait_posedge_aclk();
    fork
      get_and_drive();
      r_channel();
      get_next_ready_item();
      arready_generation();
      forward_progress_watchdog();
      service_done_q();
    join
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Interaction thread with the sequencer.
  protected task get_and_drive();
    axi_transaction item;
    axi_transaction next_item;

    ///////////////////////////////////////////////////////////////////////////
    //Continuous process getting the items from the sequencer and passing them
    // to the QUEUES
    forever begin : GET_AND_DRIVE
      seq_item_port.get_next_item(next_item);
      AXI_SLV_INFLIGHT_CMD_MISMATCH : assert(this.cmds_inflight > 0) else begin
        `xil_fatal(this.get_tag(), "Number of commands inflight is not greater than 0. Driver & Sequencer problem.")
      end
      item = next_item.my_clone();
      if (item.get_cmd_type() == XIL_AXI_READ) begin
        item.set_trans_state(XIL_AXI_TRANS_STATE_ACTIVE);
        item.set_submit_time($time);
        item.set_submit_cycle(this.vif_proxy.get_current_clk_count());
        this.push_r_q(item);
        seq_item_port.item_done();
        this.cmds_inflight--;
      end
    end
  endtask // get_and_drive

  ///////////////////////////////////////////////////////////////////////////
  //Connections to ready sequencer
  protected task get_next_ready_item();
    axi_ready_gen             next_item;
    forever begin : GNI
      arready_seq_item_port.get_next_item(next_item);

      arready_gen = next_item.my_clone();
      arready_gen_q.push_back(arready_gen);
      arready_seq_item_port.item_done();
      if (arready_gen_q.size() > 500) begin
        `xil_error(this.get_tag(), "Too many outstanding Ready objects pending.")
      end
    end : GNI
  endtask : get_next_ready_item

  protected task pop_r_q(output axi_transaction transfer);
    while(r_q_entries == 0) begin
      @(r_q_entries_event);
    end
    transfer = r_q.pop_front();
    if (this.get_adjust_data_beat_delay_enabled() == XIL_AXI_TRUE) begin
      transfer.adjust_data_insertion_delay(this.vif_proxy.get_current_clk_count());
    end
    r_q_entries--;
    ->r_q_entries_event;
  endtask

  protected task pop_done_q(output axi_transaction transfer);
    while(done_q.size() == 0) begin
      @(done_q_entries_event);
    end
    transfer = done_q.pop_front();
    done_q_entries--;
    ->done_q_entries_event;
  endtask

  protected task clean_inflight();
    axi_transaction next_item;
    while (this.cmds_inflight > 0) begin
      seq_item_port.get_next_item(next_item);
      `xil_info(this.get_tag(), $sformatf("clean_inflight : %s", next_item.cmd_sprintf()), verbosity)
      seq_item_port.item_done();
      this.cmds_inflight--;
    end
  endtask

  protected task clean_r_q();
    axi_transaction           transfer;
    slv_axi_outbound_queue_t  temp;
    xil_axi_uint                  index;
    if (this.get_reorder_data_ability() == XIL_AXI_REORDER_CAPABLE) begin
      foreach (outbound_rdata[index] ) begin : CLEAN
        `xil_info(this.get_tag(), $sformatf("Removing INDEX(%d)", index),verbosity)
        temp = outbound_rdata[index];
        temp.clean();
        outbound_rdata.delete(index);
      end
    end else begin
      while (r_q_entries > 0) begin
        `xil_info(this.get_tag(), $sformatf("Removing R_Q_ENTRIES(%d)", r_q_entries),verbosity)
        if (r_q.size() > 0) begin
          transfer = r_q.pop_front();
          transfer.set_trans_state(XIL_AXI_TRANS_STATE_KILLED);
          if (transfer.get_driver_return_item_policy() != XIL_AXI_NO_RETURN) begin
            this.return_item_to_sequence(transfer);
          end
        end
        r_q_entries--;
        ->r_q_entries_event;
      end
    end
    r_q_entries = 0;
    ->r_q_entries_event;
  endtask

  ///////////////////////////////////////////////////////////////////////////
  //Once the Packet has been completed send the completed transfer back to the
  // sequencer in the RESPONSE TLM channel
  protected task service_done_q ();
    axi_transaction transfer;
    forever begin : SERVICE_DONE_Q
      pop_done_q(transfer);
      transfer.set_trans_state(XIL_AXI_TRANS_STATE_COMPLETED_SLAVE);
      if ((transfer.get_driver_return_item_policy() == XIL_AXI_PAYLOAD_RETURN) ||
          (transfer.get_driver_return_item_policy() == XIL_AXI_CMD_PAYLOAD_RETURN)) begin
        this.return_item_to_sequence(transfer);
      end
    end
  endtask

  protected task return_item_to_sequence(axi_transaction transfer);
    axi_transaction transfer_clone;
    transfer_clone = transfer.my_clone();
    this.seq_item_port.put_rsp(transfer_clone);
  endtask
  
  /*
   Function: create_transaction
   Returns an AXI transaction class that has been "newed" 
  */
  virtual function axi_transaction create_transaction (string name = "unnamed_transaction");
    axi_transaction item=new(name);
    item.set_cmd_type(XIL_AXI_READ);
    item.set_protocol(C_AXI_PROTOCOL);
    item.set_addr_width(C_AXI_ADDR_WIDTH );
    item.set_data_width(C_AXI_RDATA_WIDTH);
    item.set_id_width(C_AXI_RID_WIDTH);
    item.set_awuser_width(C_AXI_AWUSER_WIDTH);
    item.set_wuser_width(C_AXI_WUSER_WIDTH);
    item.set_buser_width(C_AXI_BUSER_WIDTH);
    item.set_aruser_width(C_AXI_ARUSER_WIDTH);
    item.set_ruser_width(C_AXI_RUSER_WIDTH);
    item.set_supports_narrow(C_AXI_SUPPORTS_NARROW);
    if (C_AXI_SUPPORTS_NARROW == 0) begin
      item.set_size(item.get_dw_size());
    end
    item.set_has_burst(C_AXI_HAS_BURST);
    if (C_AXI_HAS_BURST == 0) begin
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
    end
    item.set_has_lock(C_AXI_HAS_LOCK);
    if (C_AXI_HAS_LOCK == 0) begin
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
    end
    item.set_has_cache(C_AXI_HAS_CACHE);
    item.set_has_region(C_AXI_HAS_REGION);
    if (C_AXI_HAS_REGION == 0) begin
      item.set_region(0);
    end
    item.set_has_prot(C_AXI_HAS_PROT);
    if (C_AXI_HAS_PROT == 0) begin
      item.set_prot(0);
    end
    item.set_has_qos(C_AXI_HAS_QOS);
    if (C_AXI_HAS_QOS == 0) begin
      item.set_qos(0);
    end
    item.set_has_wstrb(C_AXI_HAS_WSTRB);
    item.set_has_bresp(C_AXI_HAS_BRESP);
    item.set_has_rresp(C_AXI_HAS_RRESP);
    item.clr_beat_index();
    if (item.get_axi_version() == XIL_VERSION_LITE) begin
      item.set_id(0);
      item.set_burst(XIL_AXI_BURST_TYPE_INCR);
      item.set_lock(XIL_AXI_ALOCK_NOLOCK);
      item.set_size(item.get_dw_size());
      item.set_len(0);
      item.set_qos(0);
      item.set_region(0);
    end
    return(item);
  endfunction :create_transaction

  ///////////////////////////////////////////////////////////////////////////
  //Main AR channel process
  /*
   Function: get_rd_reactive
   Returns Read reactive transaction 
  */
  task get_rd_reactive (output axi_transaction transfer);
    xil_axi_cmd_beat  cmd;
    ///////////////////////////////////////////////////////////////////////////
    //Constant driver
    vif_proxy.wait_ar_accepted();
    cmd = vif_proxy.get_arcmd();

    AXI_SLV_ARID_UNKNOWN : assert(!($isunknown(cmd.id))) else begin
      `xil_error(this.get_tag(), "Unknown value found on ARID... Bad things will happend")
      cmd.id = 0;
    end

    transfer = this.create_transaction($sformatf("AR_REACTIVE_%0d", cmd.id));
    transfer.import_cmd_fields(cmd);
    cmd = null;
    this.num_pending_cmds++;
    ->num_pending_cmds_event;
    this.cmds_inflight++;
  endtask : get_rd_reactive

  protected task arready_policy_generation();
    forever begin : ARREADY_POLICY_GENERATION
      if(arready_gen_q.size()>0) begin
        this.arready_gen =arready_gen_q.pop_front();
      end
      ///////////////////////////////////////////////////////////////////////////
      //Get random values
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        AXI_RD_SLV_ARPOLICY_GEN: assert(this.arready_gen.randomize());
      `else
        this.arready_gen.cheap_random();
      `endif

      ///////////////////////////////////////////////////////////////////////////
      //If the ready algorithm is to wait until after VALID has been asserted, then
      // check to see if VALID is asserted, if not wait until it is sampled asserted.
      if ((this.arready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_SINGLE) ||
          (this.arready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_EVENTS) ||
          (this.arready_gen.get_ready_policy() == XIL_AXI_READY_GEN_AFTER_VALID_OSC) ||
          ((this.arready_gen.get_ready_policy() == XIL_AXI_READY_GEN_RANDOM) && (
            (this.arready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_SINGLE) ||
            (this.arready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_EVENTS) ||
            (this.arready_gen.get_ready_rand_policy() == XIL_AXI_READY_RAND_AFTER_VALID_OSC)))) begin
        vif_proxy.clr_arready();
        vif_proxy.wait_negedge_aclk();
        ///////////////////////////////////////////////////////////////////////////
        //If the valid is not asserted then wait until the posedge
        if (vif_proxy.is_live_arvalid_asserted() == 0) begin
          vif_proxy.wait_live_arvalid_asserted();
        end
      end

      ///////////////////////////////////////////////////////////////////////////
      //Wait low time then assert for one handshake
      if (this.arready_gen.get_low_time() > 0) begin
        vif_proxy.clr_arready();
        vif_proxy.wait_aclks(this.arready_gen.get_low_time());
        #this.vif_proxy.hold_time;
      end
      vif_proxy.set_arready();
      case (this.arready_gen.get_ready_policy())
        XIL_AXI_READY_GEN_AFTER_VALID_OSC,
        XIL_AXI_READY_GEN_OSC: begin
          vif_proxy.wait_aclks(this.arready_gen.get_high_time());
        end
        XIL_AXI_READY_GEN_RANDOM: begin
          case(this.arready_gen.get_ready_rand_policy())
            XIL_AXI_READY_RAND_AFTER_VALID_OSC,
            XIL_AXI_READY_RAND_OSC: begin
              this.vif_proxy.wait_aclks(this.arready_gen.get_high_time());
            end
            default : begin
              this.vif_proxy.wait_ar_accepted();
            end
          endcase
        end
        default: begin
          vif_proxy.wait_ar_accepted();
        end
      endcase
      #this.vif_proxy.hold_time;
    end
  endtask


  ///////////////////////////////////////////////////////////////////////////
  //Depending on the AREADY algorithm
  protected task arready_generation();
    xil_axi_uint      event_counter;
    forever begin : ARREADY_GENERATION
      ///////////////////////////////////////////////////////////////////////////
      // deassert signals
      vif_proxy.clr_arready();
      vif_proxy.wait_posedge_aclk();
      fork
        begin
          ///////////////////////////////////////////////////////////////////////////
          //Only allow so many transactions to be processed at a time.
          while (this.num_pending_cmds < this.get_transaction_depth()) begin
            @(this.num_pending_cmds_event);
          end
          `xil_info(this.get_tag(),$sformatf("GUARD: num_pending_cmds:%d - transaction_depth:%d", this.num_pending_cmds,this.get_transaction_depth()), verbosity)
        end
        begin
          this.arready_policy_generation();
        end
      join_any
      disable fork;
      ///////////////////////////////////////////////////////////////////////////
      //Stop and clear the AWREADY
      vif_proxy.clr_arready();
      ///////////////////////////////////////////////////////////////////////////
      //Wait until there is space to continue
      while (num_pending_cmds >= this.get_transaction_depth()) begin
        @(this.num_pending_cmds_event);
      end
    end //forever begin
  endtask : arready_generation

  protected task drive_r_channel(axi_transaction transfer);
    bit error_flag;
    error_flag = 0;
    vif_proxy.reset_r();
    ///////////////////////////////////////////////////////////////////////////
    //Insert the beat delay
    if (this.get_adjust_data_beat_delay_enabled() == XIL_AXI_TRUE) begin
      this.adjust_current_beat_delay(transfer);
    end

    if (transfer.get_beat_index_delay() > 0) begin
      for (xil_axi_uint acnt = 0; acnt < transfer.get_beat_index_delay(); acnt++) begin
        fork
          vif_proxy.wait_posedge_aclk_with_hold();
          vif_proxy.put_r_noise();
        join
      end
    end

    ///////////////////////////////////////////////////////////////////////////
    // send data out on write channel
    vif_proxy.set_rvalid();
    vif_proxy.put_rdata(transfer,transfer.get_beat_index());
    current_beat_submit_cycle = this.vif_proxy.get_current_clk_count();
    `xil_info(this.get_tag(), $sformatf("RVALID (%d) id=0x%x, len %d", transfer.get_beat_index()-1, transfer.get_id(), transfer.get_len()),verbosity)

    ///////////////////////////////////////////////////////////////////////////
    // wait for RREADY (may have been high already)
    error_flag = 0;
    fork
      begin
        vif_proxy.wait_r_accepted();
      end
      begin
        vif_proxy.wait_aclks(waiting_valid_timeout_value);
        error_flag = 1;
      end
    join_any
    disable fork;
    if (error_flag == 1) begin
      `xil_fatal(this.get_tag(), $sformatf("R CHANNEL never serviced (id=0x%x)", transfer.get_id()))
    end
    transfer.increment_beat_index();
    #this.vif_proxy.hold_time;
  endtask

  protected task r_channel();
    axi_transaction transfer;
    forever begin : R_CHANNEL
      vif_proxy.reset_r();
      while (r_q_entries == 0) begin
        @(r_q_entries_event);
      end
      if (this.get_reorder_data_ability() == XIL_AXI_REORDER_CAPABLE) begin
        ///////////////////////////////////////////////////////////////////////////
        //Get the next transfer from the list
        transfer = get_next_r_transfer();
        xfer_continue_probability = 100;
        while (xfer_continue_probability >= transfer.get_xfer_preemptive_probability()) begin
          if (transfer.get_beat_index() == 0) begin
            ///////////////////////////////////////////////////////////////////////////
            // Delay the whole transfer by the data_insertion_delay
            for (xil_axi_uint acnt = 0; acnt < transfer.get_data_insertion_delay(); acnt++) begin
              fork
                vif_proxy.wait_posedge_aclk_with_hold();
                vif_proxy.put_r_noise();
              join
            end
            current_beat_submit_cycle = this.vif_proxy.get_current_clk_count();
          end
          ///////////////////////////////////////////////////////////////////////////
          //Send the one data beat
          this.drive_r_channel(transfer);
          if (transfer.get_beat_index() == (transfer.get_len() + 1)) begin
            remove_xfer_from_outbound(transfer.get_id());
            push_done_q(transfer);
            break;
          end else begin
            `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
              RCHANNEL_PROBABILITY_FAIL : assert(this.randomize(xfer_continue_probability) with {xfer_continue_probability >= 1; xfer_continue_probability <= 100;});
            `else
              xfer_continue_probability = ($urandom() % (100)) + 1;
            `endif
          end
        end
      end else begin
        ///////////////////////////////////////////////////////////////////////////
        // get next transaction
        pop_r_q(transfer);
        ///////////////////////////////////////////////////////////////////////////
        // Delay the whole transfer by the data_insertion_delay
        for (xil_axi_uint acnt = 0; acnt < transfer.get_data_insertion_delay(); acnt++) begin
          fork
            vif_proxy.wait_posedge_aclk_with_hold();
            vif_proxy.put_r_noise();
          join
        end

        current_beat_submit_cycle = this.vif_proxy.get_current_clk_count();

        ///////////////////////////////////////////////////////////////////////////
        //Drive each beat on the bus
        for (xil_axi_uint i = 0; i < (transfer.get_len() + 1); i++) begin
          this.drive_r_channel(transfer);
        end

        push_done_q(transfer);
      end
    end //forever begin
  endtask : r_channel

  protected task forward_progress_watchdog();
    forever begin : PROGRESS
      ///////////////////////////////////////////////////////////////////////////
      //Wait until there is at least one transaction to be processed. This is here
      // to cover the case where there are not sequence items for the read channel
      while (num_pending_cmds == 0) begin
        @(num_pending_cmds_event);
      end
      fork
        ///////////////////////////////////////////////////////////////////////////
        //If you get an AR or R accepted then restart the fork
        begin
          vif_proxy.wait_ar_accepted();
        end
        begin
          vif_proxy.wait_r_accepted();
        end
        ///////////////////////////////////////////////////////////////////////////
        //Timeout if there is no accepted beats within forward_progress_timeout_value cycles
        begin
          vif_proxy.wait_aclks(forward_progress_timeout_value);
          if (num_pending_cmds > 0) begin
            `xil_fatal(this.get_tag(), $sformatf("Pending AR commands (%d), however, RDATA+RLAST has not occured. No forward progess.", this.num_pending_cmds))
          end
        end
      join_any
      disable fork;
      vif_proxy.wait_aclks(10);
    end
  endtask : forward_progress_watchdog

  ////////////////////////////////////////////////////////////////////////////
  //send aready and wait
   /*
   Function: send_arready
   Sends the ready structure to the driver for controlling the ARREADY channel.
  */
  task send_arready(input axi_ready_gen t);
    if(this.get_is_active()) begin
      this.arready_seq_item_port.put_item(t);
      this.arready_seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send AREADY when driver is not active"))
    end
  endtask

  /*
   Function: create_ready
   Returns a ready class that has been "newed".
  */
  virtual function axi_ready_gen create_ready (string name = "unnamed_ready");
    axi_ready_gen    ready=new(name);
    return(ready);
  endfunction

  /*
   Function: send
   Sends the AXI transaction to the driver  
  */
  task send(input axi_transaction t);
    if(this.get_is_active()) begin
      this.seq_item_port.put_item(t);
      this.seq_item_port.wait_for_item_done();
    end else begin
      `xil_fatal(this.get_tag(), $sformatf("Trying to send transaction when driver is not active"))
    end
  endtask  : send

   /*
   Function: wait_rsp
   This blocking function will not return until driver send back response transaction 
  */
  task wait_rsp(output axi_transaction t);
    this.seq_item_port.put_rsp(t);
    this.seq_item_port.rsp_done();
  endtask  : wait_rsp

endclass : axi_slv_rd_driver


/*
  Class: xil_axi_slv_mem_model
  AXI Memory Model
*/
class xil_axi_slv_mem_model `AXI_PARAM_DECL extends xil_component;

  logic [C_AXI_WDATA_WIDTH-1:0]          default_memory_fixed_value = {C_AXI_WDATA_WIDTH/8{8'ha5}};
  xil_axi_memory_delay_policy_t          bresp_delay_policy = XIL_AXI_MEMORY_DELAY_RANDOM;
  xil_axi_memory_delay_policy_t          inter_beat_gap_delay_policy = XIL_AXI_MEMORY_DELAY_RANDOM;
  xil_axi_uint                           bresp_delay = 1;
  xil_axi_uint                           inter_beat_gap = 0;
  xil_axi_uint                           min_inter_beat_gap_range = 0;
  xil_axi_uint                           max_inter_beat_gap_range = 0;
  xil_axi_uint                           min_bresp_delay_range = 0;
  xil_axi_uint                           max_bresp_delay_range = 0;
  logic [C_AXI_WDATA_WIDTH-1:0]          data_mem[xil_axi_ulong];
  xil_axi_memory_fill_policy_t           memory_fill_policy = XIL_AXI_MEMORY_FILL_RANDOM;

  /*
    Function: new
    Constructor to create an AXI slave memory model 
  */
  function new(string name = "unnamed_xil_axi_slv_mem_model");
    super.new(name);
  endfunction: new

  /*
   Function: set_bresp_delay_policy
   Sets BRESP delay policy
  */
  virtual function void set_bresp_delay_policy(input xil_axi_memory_delay_policy_t in);
    this.bresp_delay_policy = in;
  endfunction :set_bresp_delay_policy

  /*
   Function: get_bresp_delay_policy
   Returns the current value of the BRESP delay policy
  */
  virtual function xil_axi_memory_delay_policy_t get_bresp_delay_policy();
    return(this.bresp_delay_policy);
  endfunction :get_bresp_delay_policy

  /*
   Function: set_inter_beat_gap_delay_policy
   Sets RDATA delay policy
  */
  virtual function void set_inter_beat_gap_delay_policy(input xil_axi_memory_delay_policy_t in);
    this.inter_beat_gap_delay_policy = in;
  endfunction :set_inter_beat_gap_delay_policy

  /*
   Function: get_inter_beat_gap_delay_policy
   Returns the current value of the RDATA delay policy
  */
  virtual function xil_axi_memory_delay_policy_t get_inter_beat_gap_delay_policy();
    return(this.inter_beat_gap_delay_policy);
  endfunction :get_inter_beat_gap_delay_policy

  /*
   Function: set_memory_fill_policy
   Sets default memory content fill type
  */
  virtual function void set_memory_fill_policy(input xil_axi_memory_fill_policy_t default_fill_type);
    this.memory_fill_policy = default_fill_type;
  endfunction :set_memory_fill_policy

  /*
   Function: get_memory_fill_policy
   Gets default memory content fill type
  */
  virtual function xil_axi_memory_fill_policy_t get_memory_fill_policy();
    return(this.memory_fill_policy);
  endfunction :get_memory_fill_policy

  /*
   Function: set_default_memory_value
   Sets default memory value
  */
  virtual function void set_default_memory_value(input logic [C_AXI_WDATA_WIDTH-1:0] value);
    if(this.get_memory_fill_policy() != XIL_AXI_MEMORY_FILL_FIXED) begin
      `xil_fatal(this.get_name(),"Trying to fill in memory with fixed value while default memory fill type is not Fixed")
    end else begin
      this.default_memory_fixed_value = value;
    end
  endfunction : set_default_memory_value

  /*
   Function: set_default_memory_value
   Sets default memory value
  */
  virtual function logic [C_AXI_WDATA_WIDTH-1:0] get_default_memory_value();
    return(this.default_memory_fixed_value);
  endfunction : get_default_memory_value

  /*
   Function: set_inter_beat_gap
   Sets inter beat gap value
  */
  function void set_inter_beat_gap(
    input xil_axi_uint         in
  );
    this.inter_beat_gap = in;
  endfunction : set_inter_beat_gap

  /*
   Function: get_inter_beat_gap
   Returns inter beat gap value
  */
  function xil_axi_uint get_inter_beat_gap();
    xil_axi_uint  rnd;
    if (this.get_inter_beat_gap_delay_policy() == XIL_AXI_MEMORY_DELAY_FIXED) begin
      return(this.inter_beat_gap);
    end else begin
      if (this.min_inter_beat_gap_range != this.max_inter_beat_gap_range) begin
        `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
          INTERBEAT_RAND_FAILED: assert(std::randomize(rnd) with {rnd >= this.min_inter_beat_gap_range;rnd <= this.max_inter_beat_gap_range;});
        `else
          rnd = ($urandom() % (this.max_inter_beat_gap_range - this.min_inter_beat_gap_range)) + this.min_inter_beat_gap_range;
        `endif
      end else begin
        rnd = this.min_inter_beat_gap_range;
      end
      return(rnd);
    end
  endfunction : get_inter_beat_gap

  /*
   Function: set_inter_beat_gap_range
   Sets inter beat gap range
  */
  function void set_inter_beat_gap_range(
    input xil_axi_uint         min,
    input xil_axi_uint         max
  );
    if (min > max) begin
      `xil_fatal(this.get_name(), $sformatf("min (%d) number is greater than max(%d).", min, max))
    end
    this.min_inter_beat_gap_range = min;
    this.max_inter_beat_gap_range = max;
  endfunction : set_inter_beat_gap_range

  /*
   Function: get_inter_beat_gap_range
   Gets inter beat gap range
  */
  function void get_inter_beat_gap_range(
    output xil_axi_uint         min,
    output xil_axi_uint         max
  );
    min = this.min_inter_beat_gap_range;
    max = this.max_inter_beat_gap_range;
  endfunction : get_inter_beat_gap_range

  /*
   Function: set_bresp_delay
   Sets BRESP delay value
  */
  function void set_bresp_delay(
    input xil_axi_uint         in
  );
    this.bresp_delay = in;
  endfunction : set_bresp_delay

  /*
   Function: get_bresp_delay
   Returns BRESP delay value
  */
  function xil_axi_uint get_bresp_delay();
    xil_axi_uint  rnd;
    if (this.get_bresp_delay_policy() == XIL_AXI_MEMORY_DELAY_FIXED) begin
      return(this.bresp_delay);
    end else begin
      if (this.max_bresp_delay_range != this.min_bresp_delay_range) begin
        `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
          BRESP_RAND_FAILED: assert(std::randomize(rnd) with {rnd >= this.min_bresp_delay_range;rnd <= this.max_bresp_delay_range;});
        `else
          rnd = ($urandom() % (this.max_bresp_delay_range - this.min_bresp_delay_range)) + this.min_bresp_delay_range;
        `endif
      end else begin
        rnd = this.min_bresp_delay_range;
      end
      return(rnd);
    end
  endfunction : get_bresp_delay

   /*
   Function: set_bresp_delay_range
   Sets BRESP delay range
   */
  function void set_bresp_delay_range(
    input xil_axi_uint         min,
    input xil_axi_uint         max
  );
    if (min > max) begin
      `xil_fatal(this.get_name(), $sformatf("min (%d) number is greater than max(%d).", min, max))
    end
    this.min_bresp_delay_range = min;
    this.max_bresp_delay_range = max;
  endfunction : set_bresp_delay_range

   /*
   Function: get_bresp_delay_range
   Gets BRESP delay range
   */
  function void get_bresp_delay_range(
    output xil_axi_uint         min,
    output xil_axi_uint         max
  );
    min = this.min_bresp_delay_range;
    max = this.max_bresp_delay_range;
  endfunction : get_bresp_delay_range

  /*
  Function: backdoor_memory_write
  Back door write data to memory
  */
  function void backdoor_memory_write(
    input xil_axi_ulong                   addr,
    input logic [C_AXI_WDATA_WIDTH-1:0]   payload,
    input logic [C_AXI_WDATA_WIDTH/8-1:0] strb = {C_AXI_WDATA_WIDTH/8{1'b1}}
  );
    bit[C_AXI_WDATA_WIDTH-1:0]    temp_payload;
    bit[C_AXI_WDATA_WIDTH-1:0]    tmp_beat;
    xil_axi_ulong                 quanta_start_addr;
    xil_axi_uint                  addr_offset;

    if(addr > ( (1 << C_AXI_ADDR_WIDTH)-1) ) begin
      `xil_warning(this.get_name(),$sformatf("Addr(0x%0x) is out of range(0x%0x). Address will be truncated.",addr,( (1 << C_AXI_ADDR_WIDTH)-1)))
      addr &= ( (1 << C_AXI_ADDR_WIDTH) - 1);
    end

    ///////////////////////////////////////////////////////////////////////////
    //convert byte address to quanta address
    temp_payload = this.backdoor_memory_read(addr);
    quanta_start_addr = addr >> $clog2(C_AXI_WDATA_WIDTH/8);
    addr_offset = addr & ((1 << ($clog2(C_AXI_WDATA_WIDTH/8)))-1);

    ///////////////////////////////////////////////////////////////////////////
    //Check lower bits of strb.
    if (strb & ((1 << addr_offset) - 1)) begin
      `xil_fatal(this.get_name(), $sformatf("Address offset (0x%0x) does not match strobes (0x%0x)", addr_offset, strb))
    end

    ///////////////////////////////////////////////////////////////////////////
    //byte address aligned with DW memory address
    for (xil_axi_uint byte_cnt = 0; byte_cnt < C_AXI_WDATA_WIDTH/8; byte_cnt++) begin
      if (strb[byte_cnt] == 1) begin
        temp_payload[byte_cnt*8+:8] = payload[byte_cnt*8+:8];
      end
    end
    data_mem[quanta_start_addr] = temp_payload;
  endfunction : backdoor_memory_write

  /*
    Function: backdoor_memory_read
    Back door read data from memory
  */
  function bit[C_AXI_WDATA_WIDTH-1:0] backdoor_memory_read(input xil_axi_ulong addr );
    bit[C_AXI_WDATA_WIDTH-1:0]    read_payload;
    bit[C_AXI_WDATA_WIDTH-1:0]    tmp_beat;
    xil_axi_ulong                 quanta_start_addr;
    xil_axi_uint                  addr_offset;

    if(addr > ( (1 << C_AXI_ADDR_WIDTH)-1) ) begin
      `xil_warning(this.get_name(),$sformatf("Addr(0x%0x) is out of range(0x%0x). Address will be truncated.",addr,( (1 << C_AXI_ADDR_WIDTH)-1)))
      addr &= ( (1 << C_AXI_ADDR_WIDTH) - 1);
    end
    quanta_start_addr = addr >> $clog2(C_AXI_WDATA_WIDTH/8);
    addr_offset = addr & ((1 << ($clog2(C_AXI_WDATA_WIDTH/8)))-1);
    if(!data_mem.exists(quanta_start_addr)) begin
      `ifndef XIL_DO_NOT_USE_ADV_RANDOMIZATION
        BACKDOOR_RANDOMIZE_FAIL: assert(std::randomize(tmp_beat));
      `else
        for (xil_axi_uint i = 0; i < (C_AXI_WDATA_WIDTH/32); i++) begin
          tmp_beat = tmp_beat << 32;
          tmp_beat[31:0] = $urandom();
        end
      `endif
      case(this.get_memory_fill_policy())
        XIL_AXI_MEMORY_FILL_FIXED:  data_mem[quanta_start_addr] = this.get_default_memory_value();
        XIL_AXI_MEMORY_FILL_RANDOM: data_mem[quanta_start_addr] = tmp_beat;
        default: `xil_fatal(this.get_name(), "Unsupported Default memory fill type.")
      endcase
    end
    read_payload = data_mem[quanta_start_addr];
    return(read_payload);
  endfunction : backdoor_memory_read

  // write data, user information etc to read channel
  /*
   Function:  fill_rd_reactive
   Fill in read channel from memory model
  */
  function axi_transaction fill_rd_reactive(input axi_transaction t);
    xil_axi_ulong         addr;
    axi_transaction       convert_tran;
    xil_axi_uint          burst_offset;
    xil_axi_data_beat     data;

    ///////////////////////////////////////////////////////////////////////////
    //Start off with an INCR/FIXED
    if (t.get_burst() == XIL_AXI_BURST_TYPE_WRAP) begin
      convert_tran = t.convert_wrap_to_incr();
      addr = convert_tran.get_addr();
    end else begin
      addr  = t.get_addr();
      convert_tran = t;
    end
    ///////////////////////////////////////////////////////////////////////////
    //Read the memory
    for(int beat_cnt = 0; beat_cnt <= convert_tran.get_len(); beat_cnt++) begin
      burst_offset = convert_tran.get_burst_byte_offset(beat_cnt);
      data = this.backdoor_memory_read(addr) >> (burst_offset * 8);
      convert_tran.set_data_beat(beat_cnt, data, this.get_inter_beat_gap());
      convert_tran.set_ruser(beat_cnt, 'h0);
      if (t.get_burst() != XIL_AXI_BURST_TYPE_FIXED ) begin
        addr += 1 << t.get_size();
      end
    end
    ///////////////////////////////////////////////////////////////////////////
    //When WRAP store back the transaction.
    if (t.get_burst() == XIL_AXI_BURST_TYPE_WRAP) begin
      t = convert_tran.convert_incr_to_wrap(t.get_addr() & (t.get_num_bytes_in_transaction() - 1));
    end
    return(t);
  endfunction : fill_rd_reactive


  ///////////////////////////////////////////////////////////////////////////
  //fill reactive response for write transaction
  /*
   Function:  fill_wr_reactive
   Fill in write response channel 
  */
  function void fill_wr_reactive(inout axi_transaction t);
    t.set_response_delay(this.get_bresp_delay());
    t.set_buser('h0);
    t.set_bresp(XIL_AXI_RESP_OKAY);
  endfunction : fill_wr_reactive

  ///////////////////////////////////////////////////////////////////////////
  //write transaction data to memory
  /*
   Function: write_transaction_to_memory
   Write transaction to memory
  */
  function void write_transaction_to_memory(input axi_transaction t);
    xil_axi_ulong         addr;
    axi_transaction       convert_tran;
    xil_axi_uint          burst_offset;
    xil_axi_data_beat     data;
    xil_axi_strb_beat     strb;

    if (t.get_burst() == XIL_AXI_BURST_TYPE_WRAP) begin
      convert_tran = t.convert_wrap_to_incr();
      addr = convert_tran.get_addr();
    end else begin
      convert_tran = t;
      addr  = t.get_addr();
    end

    addr &= ~((1 << t.get_size()) - 1);

    for(int beat_cnt = 0; beat_cnt <= convert_tran.get_len(); beat_cnt++) begin
      burst_offset = convert_tran.get_burst_byte_offset(beat_cnt);
      data = convert_tran.get_data_beat(beat_cnt) << (burst_offset * 8);
      strb = convert_tran.get_strb_beat(beat_cnt) << burst_offset;
      this.backdoor_memory_write(addr, data, strb);
      if(t.get_burst() != XIL_AXI_BURST_TYPE_FIXED ) begin
        addr += 1 << t.get_size();
      end
    end
  endfunction : write_transaction_to_memory
endclass : xil_axi_slv_mem_model

/*
  Class: axi_slv_agent
  AXI Slave Agent.
*/
class axi_slv_agent `AXI_PARAM_DECL extends xil_agent;

  protected xil_axi_uint              rd_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint              wr_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint              transaction_depth_checks_enabled = 1;

  ///////////////////////////////////////////////////////////////////////////
  // Monitor
  axi_monitor         `AXI_PARAM_ORDER monitor;

  ///////////////////////////////////////////////////////////////////////////
  // write driver
  axi_slv_wr_driver    `AXI_PARAM_ORDER wr_driver;

  ///////////////////////////////////////////////////////////////////////////
  // read driver
  axi_slv_rd_driver    `AXI_PARAM_ORDER rd_driver;

  ///////////////////////////////////////////////////////////////////////////
  // Proxy
  axi_vif_mem_proxy `AXI_PARAM_ORDER vif_proxy;

  /*
    Function: new
    Constructor to create an AXI Slave Agent.
  */
  function new (string name = "unnamed_axi_slv_agent", virtual interface axi_vip_v1_0_1_if `AXI_PARAM_ORDER vif);
    super.new(name);
    this.monitor = new($sformatf("%s_monitor",name));
    this.wr_driver = new($sformatf("%s_wr_driver",name));
    this.rd_driver = new($sformatf("%s_rd_driver",name));
    this.vif_proxy = new($sformatf("%s_vif",name));
    this.vif_proxy.assign_vi(vif);
    this.set_vif(this.vif_proxy);
  endfunction : new

  /*
    Function: set_verbosity
    Sets the verbosity of the Agent and all sub classes.
  */
  virtual function void set_verbosity(xil_verbosity updated);
    if(updated >= XIL_AXI_VERBOSITY_FULL && this.TAG== "xil_object")
      `xil_warning(this.get_tag(), "Debug information for slave agent is printed out, but set_agent_tag is not set,for easily debug, please set it up")
    this.verbosity = updated;
    this.monitor.set_verbosity(this.get_verbosity());
    this.wr_driver.set_verbosity(this.get_verbosity());
    this.rd_driver.set_verbosity(this.get_verbosity());
    this.vif_proxy.set_verbosity(this.get_verbosity());
  endfunction : set_verbosity

  /*
    Function: set_agent_tag
    Sets the tag of the Agent and all sub classes.
  */
  virtual function void set_agent_tag(string updated);
    this.TAG = updated;
    this.monitor.set_tag($sformatf("%s_monitor", this.get_tag()));
    this.wr_driver.set_tag($sformatf("%s_wr_driver", this.get_tag()));
    this.rd_driver.set_tag($sformatf("%s_rd_driver", this.get_tag()));
    this.vif_proxy.set_tag($sformatf("%s_vif", this.get_tag()));
  endfunction : set_agent_tag

  /*
    Function: set_vif
    Sets the Agent's virtual interface. This is the interface that will be monitored and/or driven.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    if(vif.m_vif.intf_is_master ==1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign Master top to slave agent"))
    end else begin
      vif.m_vif.set_intf_slave();
      `xil_info(this.get_tag(),$sformatf("Set VIF in Slave VIP "), XIL_AXI_VERBOSITY_NONE)
      this.wr_driver.set_vif(vif);
      `xil_info(this.get_tag(),$sformatf("Assigning VIF to Slave VIP Write Driver"), XIL_AXI_VERBOSITY_NONE)
      this.rd_driver.set_vif(vif);
      `xil_info(this.get_tag(),$sformatf("Assigning VIF to Slave VIP Read Driver"), XIL_AXI_VERBOSITY_NONE)
      this.monitor.set_vif(vif);
      `xil_info(this.get_tag(),$sformatf("Assigning VIF to Slave VIP Monitor"), XIL_AXI_VERBOSITY_NONE)
    end
  endfunction : set_vif

  /*
    Function: set_wr_transaction_depth
    Sets the number of WRITE transactions that the Agent will have in flight at one time.
  */
  function void set_wr_transaction_depth(input xil_axi_uint update);
    if (update == 0) begin
      `xil_warning(this.get_tag(), "Setting the WRITE transaction Depth to 0. No transactions will be issued")
    end

    this.wr_transaction_depth = update;
    `xil_info(this.get_tag(),$sformatf("Setting WR Driver WR Transaction Depth to %d", this.get_wr_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.wr_driver.set_transaction_depth(this.get_wr_transaction_depth());
    `xil_info(this.get_tag(),$sformatf("Setting Monitor WR Transaction Depth to %d", this.get_wr_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.monitor.set_wr_transaction_depth(this.get_wr_transaction_depth());
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Agent will have in flight at one time.
  */
  function xil_axi_uint get_wr_transaction_depth();
    return(this.wr_transaction_depth);
  endfunction

  /*
    Function: set_rd_transaction_depth
    Sets the number of READ transactions that the Agent will have in flight at one time.
  */
  function void set_rd_transaction_depth(input xil_axi_uint update);
    this.rd_transaction_depth = update;
    if (update == 0) begin
      `xil_warning(this.get_tag(), "Setting the READ transaction Depth to 0. No transactions will be issued")
    end
    `xil_info(this.get_tag(),$sformatf("Setting RD Driver RD Transaction Depth to %d", this.get_rd_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.rd_driver.set_transaction_depth(this.get_rd_transaction_depth());
    `xil_info(this.get_tag(),$sformatf("Setting Monitor RD Transaction Depth to %d", this.get_rd_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.monitor.set_rd_transaction_depth(this.get_rd_transaction_depth());
  endfunction

  /*
    Function: get_rd_transaction_depth
    Returns the maximum number of READ transactions that the Agent will have in flight at one time.
  */
  function xil_axi_uint get_rd_transaction_depth();
    return(this.rd_transaction_depth);
  endfunction

  /*
    Function: enable_transaction_depth_checks
    Turn on current agent's transaction depth check and its monitor's enable_transaction_depth_checks
  */
  function void enable_transaction_depth_checks();
    this.transaction_depth_checks_enabled = 1;
    this.monitor.enable_transaction_depth_checks();
  endfunction

  /*
    Function: disable_transaction_depth_checks
    Turn off current agent's transaction depth check and its monitor's enable_transaction_depth_checks
  */
  function void disable_transaction_depth_checks();
    this.transaction_depth_checks_enabled = 0;
    this.monitor.enable_transaction_depth_checks();
  endfunction

  /*
    Function: start_monitor
    Enables the monitor in this agent to start collecting data.
  */
  virtual task start_monitor();
    fork
      this.monitor.run_phase();
    join_none
  endtask : start_monitor

  /*
    Function: start_slave
    Enables the READ and WRITE drivers in this agent to start collecting data.
    The drivers will only issue transactions when the send functions are called.
  */
  virtual task start_slave();
    fork
      this.start_monitor();
      this.wr_driver.run_phase();
      this.rd_driver.run_phase();
    join_none
    fork
      this.wr_driver.wait_enabled();
      this.rd_driver.wait_enabled();
    join
    if(vif_proxy.m_vif.intf_is_slave !=1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign non-slave VIF to slave agent"))
    end
  endtask : start_slave

  /*
    Function: stop_slave
    Disables the READ and WRITE drivers of the slave. Once disabled, no further action will occur by the drivers.
  */
  virtual task stop_slave();
    this.wr_driver.stop_phase();
    this.rd_driver.stop_phase();
  endtask  : stop_slave

  /*
    Function: stop_monitor
    Disables the monitor in this agent from start collecting data. . Once disabled, no further action will occur by the monitor.
  */
  virtual task stop_monitor();
    this.monitor.stop_phase();
  endtask : stop_monitor

  /*
   Function: set_nobackpressure_readies
   Convenience function to set the ARREADY/WREADY/AWREADY of the slave to not apply any backpressure to the simulation.
  */
  virtual task set_nobackpressure_readies();
    axi_ready_gen arready;
    axi_ready_gen awready;
    axi_ready_gen wready;
    arready = new("nobackpressure_arready");
    wready = new("nobackpressure_wready");
    awready = new("nobackpressure_awready");

    arready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    arready.set_low_time_range(0,0);
    arready.set_high_time_range(100,100);
    this.rd_driver.set_arready_gen(arready);

    wready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    wready.set_low_time_range(0,0);
    wready.set_high_time_range(100,100);
    this.wr_driver.set_wready_gen(wready);

    awready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    awready.set_low_time_range(0,0);
    awready.set_high_time_range(100,100);
    this.wr_driver.set_awready_gen(awready);
  endtask : set_nobackpressure_readies

endclass : axi_slv_agent
/*
  Class: axi_slv_mem_agent
  AXI Slave Agent with Memory
*/

class axi_slv_mem_agent`AXI_PARAM_DECL  extends axi_slv_agent`AXI_PARAM_ORDER;

  xil_axi_slv_mem_model  `AXI_PARAM_ORDER  mem_model;

  //Constructor to create an AXI Slave Agent with memory model
  /*
    Function: new
    Constructor to create an AXI Slave Agent with memory model
  */
  function new(string name="unnamed_axi_slv_mem_agent", virtual interface axi_vip_v1_0_1_if `AXI_PARAM_ORDER vif);
    super.new(name,vif);
    this.mem_model = new($sformatf("%s_mem_model",name));
  endfunction :new

  /*
    Function: set_agent_tag
    Sets the tag of the Agent and all sub classes.
  */
  virtual function void set_agent_tag(string updated);
    super.set_agent_tag(updated);
  endfunction : set_agent_tag

  protected virtual task put_rd_response();
    axi_transaction       rd_reactive;
    axi_transaction       rd_send;
    forever begin
      this.rd_driver.get_rd_reactive(rd_reactive);
      rd_send = this.mem_model.fill_rd_reactive(rd_reactive);
      this.rd_driver.send(rd_send);
    end
  endtask: put_rd_response

  protected virtual task put_wr_response();
    axi_transaction       wr_reactive;
    forever begin
      this.wr_driver.get_wr_reactive(wr_reactive);
      this.mem_model.write_transaction_to_memory(wr_reactive);
      this.mem_model.fill_wr_reactive(wr_reactive);
      this.wr_driver.send(wr_reactive);
    end
  endtask: put_wr_response

  /*
    Function: start_slave
    Enables the READ and WRITE drivers in this agent to start collecting data.
    The drivers will only issue transactions when the send functions are called.
  */
  virtual task start_slave();
    super.start_slave();
    fork
      this.put_wr_response();
      this.put_rd_response();
    join_none
    fork
      this.wr_driver.wait_enabled();
      this.rd_driver.wait_enabled();
    join
    if(vif_proxy.m_vif.intf_is_slave !=1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign non-slave VIF to slave mem agent"))
    end
  endtask : start_slave

endclass : axi_slv_mem_agent

/*
  Class: axi_passthrough_agent
  AXI Passthrough Agent.
*/
class axi_passthrough_agent `AXI_PARAM_DECL extends xil_agent;

  protected xil_axi_uint              rd_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint              wr_transaction_depth = XIL_AXI_DEFAULT_TRANSACTION_DEPTH;
  protected xil_axi_uint              transaction_depth_checks_enabled = 1;

  ///////////////////////////////////////////////////////////////////////////
  // Monitor
  axi_monitor         `AXI_PARAM_ORDER monitor;

  ///////////////////////////////////////////////////////////////////////////
  // slave write driver
  axi_slv_wr_driver    `AXI_PARAM_ORDER slv_wr_driver;

  ///////////////////////////////////////////////////////////////////////////
  // slave read driver
  axi_slv_rd_driver    `AXI_PARAM_ORDER slv_rd_driver;

  ///////////////////////////////////////////////////////////////////////////
  // master write driver
  axi_mst_wr_driver    `AXI_PARAM_ORDER mst_wr_driver;

  ///////////////////////////////////////////////////////////////////////////
  // master read driver
  axi_mst_rd_driver    `AXI_PARAM_ORDER mst_rd_driver;

  ///////////////////////////////////////////////////////////////////////////
  // Proxy
  axi_vif_mem_proxy `AXI_PARAM_ORDER vif_proxy;

  /*
    Function: new
    Constructor to create an AXI Passthrough Agent.
  */
  function new (string name = "unnamed_axi_passthrough_agent", virtual interface axi_vip_v1_0_1_if `AXI_PARAM_ORDER vif);
    super.new(name);
    this.monitor = new($sformatf("%s_monitor",name));
    this.mst_wr_driver = new($sformatf("%s_mst_wr_driver",name));
    this.mst_rd_driver = new($sformatf("%s_mst_rd_driver",name));
    this.slv_wr_driver = new($sformatf("%s_slv_wr_driver",name));
    this.slv_rd_driver = new($sformatf("%s_slv_rd_driver",name));
    this.vif_proxy = new($sformatf("%s_vif",name));
    this.vif_proxy.assign_vi(vif);
    this.set_vif(this.vif_proxy);
  endfunction : new

  /*
    Function: set_verbosity
    Sets the verbosity of the Agent and all sub classes.
  */
  virtual function void set_verbosity(xil_verbosity updated);
    if(updated >= XIL_AXI_VERBOSITY_FULL && this.TAG== "xil_object")
      `xil_warning(this.get_tag(), "Debug information for passthrough agent is printed out, but set_agent_tag is not set,for easily debug, please set it up")
    this.verbosity = updated;
    this.monitor.set_verbosity(this.get_verbosity());
    this.mst_wr_driver.set_verbosity(this.get_verbosity());
    this.mst_rd_driver.set_verbosity(this.get_verbosity());
    this.slv_wr_driver.set_verbosity(this.get_verbosity());
    this.slv_rd_driver.set_verbosity(this.get_verbosity());
    this.vif_proxy.set_verbosity(this.get_verbosity());
  endfunction : set_verbosity

  /*
    Function: set_agent_tag
    Sets the tag of the Agent and all sub classes.
  */
  virtual function void set_agent_tag(string updated);
    this.TAG = updated;
    this.monitor.set_tag($sformatf("%s_monitor", this.get_tag()));
    this.mst_wr_driver.set_tag($sformatf("%s_mst_wr_driver", this.get_tag()));
    this.mst_rd_driver.set_tag($sformatf("%s_mst_rd_driver", this.get_tag()));
    this.slv_wr_driver.set_tag($sformatf("%s_slv_wr_driver", this.get_tag()));
    this.slv_rd_driver.set_tag($sformatf("%s_slv_rd_driver", this.get_tag()));
    this.vif_proxy.set_tag($sformatf("%s_vif", this.get_tag()));
  endfunction : set_agent_tag

  /*
    Function: set_vif
    Sets the Agent's virtual interface. This is the interface that will be monitored and/or driven.
  */
  function void set_vif(axi_vif_mem_proxy `AXI_PARAM_ORDER vif);
    `xil_info(this.get_tag(),$sformatf("Set VIF in Passthrough mode"), XIL_AXI_VERBOSITY_NONE)
    this.mst_wr_driver.set_vif(vif);
    `xil_info(this.get_tag(),$sformatf("Assigning VIF to Passthrough VIP Master write Driver"), XIL_AXI_VERBOSITY_NONE)
    this.mst_rd_driver.set_vif(vif);
    `xil_info(this.get_tag(),$sformatf("Assigning VIF to Passthroug VIP Master Read Driver"), XIL_AXI_VERBOSITY_NONE)
    this.slv_wr_driver.set_vif(vif);
    `xil_info(this.get_tag(),$sformatf("Assigning VIF to Passthrough VIP Slave Write Driver"), XIL_AXI_VERBOSITY_NONE)
    this.slv_rd_driver.set_vif(vif);
    `xil_info(this.get_tag(),$sformatf("Assigning VIF to Passthrough VIP Slave Read Driver"), XIL_AXI_VERBOSITY_NONE)
    this.monitor.set_vif(vif);
    `xil_info(this.get_tag(),$sformatf("Assigning VIF to Passthough VIP Monitor"), XIL_AXI_VERBOSITY_NONE)
  endfunction : set_vif

  /*
    Function: set_wr_transaction_depth
    Sets the number of WRITE transactions that the Agent will have in flight at one time.
  */
  function void set_wr_transaction_depth(input xil_axi_uint update);
    if (update == 0) begin
      `xil_warning(this.get_tag(), "Setting the WRITE transaction Depth to 0. No transactions will be issued")
    end
    this.wr_transaction_depth = update;
    `xil_info(this.get_tag(),$sformatf("Setting WR Driver WR Transaction Depth to %d", this.get_wr_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.mst_wr_driver.set_transaction_depth(this.get_wr_transaction_depth());
    this.slv_wr_driver.set_transaction_depth(this.get_wr_transaction_depth());
    `xil_info(this.get_tag(),$sformatf("Setting Monitor WR Transaction Depth to %d", this.get_wr_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.monitor.set_wr_transaction_depth(this.get_wr_transaction_depth());
  endfunction

  /*
    Function: get_wr_transaction_depth
    Returns the maximum number of WRITE transactions that the Agent will have in flight at one time.
  */
  function xil_axi_uint get_wr_transaction_depth();
    return(this.wr_transaction_depth);
  endfunction

  /*
    Function: set_rd_transaction_depth
    Sets the number of READ transactions that the Agent will have in flight at one time.
  */
  function void set_rd_transaction_depth(input xil_axi_uint update);
    this.rd_transaction_depth = update;
    if (update == 0) begin
      `xil_warning(this.get_tag(), "Setting the READ transaction Depth to 0. No transactions will be issued")
    end
    `xil_info(this.get_tag(),$sformatf("Setting RD Driver RD Transaction Depth to %d", this.get_rd_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.mst_rd_driver.set_transaction_depth(this.get_rd_transaction_depth());
    this.slv_rd_driver.set_transaction_depth(this.get_rd_transaction_depth());
    `xil_info(this.get_tag(),$sformatf("Setting Monitor RD Transaction Depth to %d", this.get_rd_transaction_depth()), XIL_AXI_VERBOSITY_NONE)
    this.monitor.set_rd_transaction_depth(this.get_rd_transaction_depth());
  endfunction

  /*
    Function: get_rd_transaction_depth
    Returns the maximum number of READ transactions that the Agent will have in flight at one time.
  */
  function xil_axi_uint get_rd_transaction_depth();
    return(this.rd_transaction_depth);
  endfunction

  /*
    Function: enable_transaction_depth_checks
    Turn on current agent's transaction depth check and its monitor's enable_transaction_depth_checks
  */
  function void enable_transaction_depth_checks();
    this.transaction_depth_checks_enabled = 1;
    this.monitor.enable_transaction_depth_checks();
  endfunction

  /*
    Function: disable_transaction_depth_checks
    Turn off current agent's transaction depth check and its monitor's enable_transaction_depth_checks
  */
  function void disable_transaction_depth_checks();
    this.transaction_depth_checks_enabled = 0;
    this.monitor.enable_transaction_depth_checks();
  endfunction

  /*
    Function: start_monitor
    Enables the monitor in this agent to start collecting data.
  */
  virtual task start_monitor();
    fork
      this.monitor.run_phase();
    join_none
  endtask : start_monitor

  /*
    Function: start_master
    Enables the READ and WRITE drivers in this agent to start collecting data.
    The drivers will only issue transactions when the send functions are called.
  */
  virtual task start_master();
    fork
      this.start_monitor();
      this.mst_wr_driver.run_phase();
      this.mst_rd_driver.run_phase();
    join_none
    fork
      this.mst_wr_driver.wait_enabled();
      this.mst_rd_driver.wait_enabled();
    join
    if(vif_proxy.m_vif.intf_is_master !=1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign non-master VIF to passthrough agent in runtime master mode"))
    end 
  endtask : start_master

  /*
    Function: start_slave
    Enables the READ and WRITE drivers in this agent to start collecting data.
    The drivers will only issue transactions when the send functions are called.
  */
  virtual task start_slave();
    fork
      this.start_monitor();
      this.slv_wr_driver.run_phase();
      this.slv_rd_driver.run_phase();
    join_none
    fork
      this.slv_wr_driver.wait_enabled();
      this.slv_rd_driver.wait_enabled();
    join
    if(vif_proxy.m_vif.intf_is_slave !=1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign non-slave VIF to passthrough agent in runtime slave mode"))
    end 
  endtask : start_slave

  /*
    Function: stop_master
    Disables the READ and WRITE drivers of the master. Once disabled, no further action will occur by the drivers.
  */
  virtual task stop_master();
    this.mst_wr_driver.stop_phase();
    this.mst_rd_driver.stop_phase();
  endtask  : stop_master

  /*
    Function: halt_master
    Allows for all inflight transactions to complete and no new transaction will be serviced. All other transactions
    will halt.
  */
  virtual task halt_master();
    fork
      this.mst_wr_driver.halt_phase();
      this.mst_rd_driver.halt_phase();
    join
  endtask : halt_master

  /*
    Function: resume_master
    Resumes processing of the pending transactions.
  */
  virtual task resume_master();
    this.mst_wr_driver.resume_phase();
    this.mst_rd_driver.resume_phase();
  endtask : resume_master

  /*
    Function: stop_slave
    Disables the READ and WRITE drivers of the slave. Once disabled, no further action will occur by the drivers.
  */
  virtual task stop_slave();
    this.slv_wr_driver.stop_phase();
    this.slv_rd_driver.stop_phase();
  endtask  : stop_slave

  /*
    Function: stop_monitor
    Disables the monitor in this agent from start collecting data. . Once disabled, no further action will occur by the monitor.
  */
  virtual task stop_monitor();
    this.monitor.stop_phase();
  endtask : stop_monitor

  /*
   Function: set_nobackpressure_readies
   Convenience function to set the RREADY/BREADY of the master and ARREADY/WREADY/AWREADY of the slave to not apply any backpressure to the simulation.
  */
  virtual task set_nobackpressure_readies();
    axi_ready_gen rready;
    axi_ready_gen bready;
    axi_ready_gen arready;
    axi_ready_gen awready;
    axi_ready_gen wready;
    arready = new("nobackpressure_arready");
    wready = new("nobackpressure_wready");
    awready = new("nobackpressure_awready");
    rready = new("nobackpressure_rready");
    bready = new("nobackpressure_bready");

    arready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    arready.set_low_time_range(0,0);
    arready.set_high_time_range(100,100);
    this.slv_rd_driver.set_arready_gen(arready);

    wready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    wready.set_low_time_range(0,0);
    wready.set_high_time_range(100,100);
    this.slv_wr_driver.set_wready_gen(wready);

    awready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    awready.set_low_time_range(0,0);
    awready.set_high_time_range(100,100);
    this.slv_wr_driver.set_awready_gen(awready);

    rready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    rready.set_low_time_range(0,0);
    rready.set_high_time_range(100,100);
    this.mst_rd_driver.set_rready_gen(rready);

    bready.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    bready.set_low_time_range(0,0);
    bready.set_high_time_range(100,100);
    this.mst_wr_driver.set_bready_gen(bready);
  endtask : set_nobackpressure_readies

  /*
   Function: wait_mst_drivers_idle
   This blocking function will not return until all the downstream transactions have completed.
  */
  task wait_mst_drivers_idle();
    fork
      this.mst_wr_driver.wait_driver_idle();
      this.mst_rd_driver.wait_driver_idle();
    join
  endtask : wait_mst_drivers_idle

endclass : axi_passthrough_agent

/*
  Class: axi_passthrough_agent
  AXI Passthrough Agent with memory model.
*/
class axi_passthrough_mem_agent`AXI_PARAM_DECL  extends axi_passthrough_agent`AXI_PARAM_ORDER;

  xil_axi_slv_mem_model  `AXI_PARAM_ORDER  mem_model;

  //Constructor to create an AXI passthrough Agent with memory model

  /*
    Function: new
    Constructor to create an AXI Passsthrough Agent with memory model
  */
  function new(string name="unnamed_axi_passthrough_mem_agent", virtual interface axi_vip_v1_0_1_if `AXI_PARAM_ORDER vif);
    super.new(name,vif);
    this.mem_model = new($sformatf("%s_mem_model",name));
  endfunction :new

    /*
    Function: set_agent_tag
    Sets the tag of the Agent and all sub classes.
  */
  virtual function void set_agent_tag(string updated);
    super.set_agent_tag(updated);
  endfunction : set_agent_tag

  protected virtual task put_rd_response();
    axi_transaction       rd_reactive;
    axi_transaction       rd_send;
    forever begin
      this.slv_rd_driver.get_rd_reactive(rd_reactive);
      rd_send = this.mem_model.fill_rd_reactive(rd_reactive);
      this.slv_rd_driver.send(rd_send);
    end
  endtask: put_rd_response

  protected virtual task put_wr_response();
    axi_transaction       wr_reactive;
    forever begin
      this.slv_wr_driver.get_wr_reactive(wr_reactive);
      this.mem_model.write_transaction_to_memory(wr_reactive);
      this.mem_model.fill_wr_reactive(wr_reactive);
      this.slv_wr_driver.send(wr_reactive);
    end
  endtask: put_wr_response

 /*
    Function: start_slave
    Enables the READ and WRITE drivers in this agent to start collecting data.
    The drivers will only issue transactions when the send functions are called.
  */
  virtual task start_slave();
    super.start_slave();
    fork
      this.put_wr_response();
      this.put_rd_response();
    join_none
    fork
      this.slv_wr_driver.wait_enabled();
      this.slv_rd_driver.wait_enabled();
    join
    if(vif_proxy.m_vif.intf_is_slave !=1) begin
      `xil_fatal(this.get_tag(),$sformatf("Attempting to assign non-slave VIF to passthrough agent in runtime slave mem mode"))
    end 
  endtask : start_slave


endclass : axi_passthrough_mem_agent

endpackage : axi_vip_v1_0_1_pkg

`undef AXI_PARAM_DECL
`undef AXI_PARAM_ORDER
`endif


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
`ifndef _axi_vip_v1_0_1_IF_SV_
`define _axi_vip_v1_0_1_IF_SV_
`timescale 1ps/1ps
import axi_vip_v1_0_1_pkg::*;
`include "axi_vip_v1_0_1_axi4pc.sv"

interface axi_vip_v1_0_1_if #(
  int C_AXI_PROTOCOL              = 0, 
      C_AXI_ADDR_WIDTH            = 32, 
      C_AXI_WDATA_WIDTH           = 32, 
      C_AXI_RDATA_WIDTH           = 32, 
      C_AXI_WID_WIDTH             = 0,
      C_AXI_RID_WIDTH             = 0, 
      C_AXI_AWUSER_WIDTH          = 0, 
      C_AXI_WUSER_WIDTH           = 0, 
      C_AXI_BUSER_WIDTH           = 0, 
      C_AXI_ARUSER_WIDTH          = 0, 
      C_AXI_RUSER_WIDTH           = 0,
      C_AXI_SUPPORTS_NARROW       = 1,
      C_AXI_HAS_BURST             = 1,
      C_AXI_HAS_LOCK              = 1,
      C_AXI_HAS_CACHE             = 1,
      C_AXI_HAS_REGION            = 1,
      C_AXI_HAS_PROT              = 1,
      C_AXI_HAS_QOS               = 1,
      C_AXI_HAS_WSTRB             = 1,
      C_AXI_HAS_BRESP             = 1,
      C_AXI_HAS_RRESP             = 1,
      C_AXI_HAS_ARESETN           = 1
  ) 
  (input bit ACLK, ACLKEN, ARESET_N);
  parameter time C_HOLD_TIME        = 1ps;
  parameter integer C_MAXRBURSTS    = 64;
  parameter integer C_MAXWBURSTS    = 64;
  parameter integer C_MAXWAITS      = 64;
  parameter integer C_MAXSTALLWAITS = 1024;

  // write address channel
  wire  [(C_AXI_ADDR_WIDTH-1):0]                                          AWADDR;
  wire  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  AWID;
  wire  [7:0]                                                             AWLEN;
  wire  [2:0]                                                             AWSIZE;
  wire  [1:0]                                                             AWBURST;
  wire  [1:0]                                                             AWLOCK;
  wire  [3:0]                                                             AWCACHE;
  wire  [2:0]                                                             AWPROT;
  wire                                                                    AWVALID;
  wire                                                                    AWREADY;
  wire  [3:0]                                                             AWREGION;
  wire  [3:0]                                                             AWQOS;
  wire  [((C_AXI_AWUSER_WIDTH == 0) ? 0 : C_AXI_AWUSER_WIDTH -1):0]       AWUSER;

  // write data channel
  wire  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  WID;
  wire                                                                    WLAST;
  wire  [(C_AXI_WDATA_WIDTH-1):0]                                         WDATA;
  wire  [(C_AXI_WDATA_WIDTH/8 ==0 ? 0: C_AXI_WDATA_WIDTH/8)-1:0]          WSTRB;
  wire                                                                    WVALID;
  wire                                                                    WREADY;
  wire  [((C_AXI_WUSER_WIDTH == 0) ? 0 : C_AXI_WUSER_WIDTH -1):0]         WUSER;

  // write response channel
  wire  [1:0]                                                             BRESP;
  wire  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  BID;
  wire                                                                    BVALID;
  wire                                                                    BREADY;
  wire  [((C_AXI_BUSER_WIDTH == 0) ? 0 : C_AXI_BUSER_WIDTH -1):0]         BUSER;

  // read address channel
  wire  [(C_AXI_ADDR_WIDTH-1):0]                                          ARADDR;
  wire  [((C_AXI_RID_WIDTH==0) ? 1:C_AXI_RID_WIDTH)-1:0]                  ARID;
  wire  [7:0]                                                             ARLEN;
  wire  [2:0]                                                             ARSIZE;
  wire  [1:0]                                                             ARBURST;
  wire  [1:0]                                                             ARLOCK;
  wire  [3:0]                                                             ARCACHE;
  wire  [2:0]                                                             ARPROT;
  wire                                                                    ARVALID;
  wire                                                                    ARREADY;
  wire  [3:0]                                                             ARREGION;
  wire  [3:0]                                                             ARQOS;
  wire  [((C_AXI_ARUSER_WIDTH == 0) ? 0 : C_AXI_ARUSER_WIDTH -1):0]       ARUSER;

  // read data  channel
  wire  [((C_AXI_RID_WIDTH==0) ? 1:C_AXI_RID_WIDTH)-1:0]                  RID;
  wire                                                                    RLAST;
  wire  [(C_AXI_RDATA_WIDTH-1):0]                                         RDATA;
  wire  [1:0]                                                             RRESP;
  wire                                                                    RVALID;
  wire                                                                    RREADY;
  wire  [((C_AXI_RUSER_WIDTH == 0) ? 0 : C_AXI_RUSER_WIDTH -1):0]         RUSER;

  integer unsigned  awcmd_id = 0;
  integer unsigned  arcmd_id = 0;
  integer unsigned  rcmd_id = 0;
  integer unsigned  wcmd_id = 0;
  integer unsigned  bcmd_id = 0;
  logic intf_is_master = 0;
  logic intf_is_slave  = 0;

  logic supports_write = 1;
  logic supports_read = 1;
  logic xilinx_slave_ready_check_enable = 1;

  /*
  * Function: set_supports_write
  * Sets supports_write to be 1
  */
  function void set_supports_write();
    supports_write = 1;
  endfunction

  /*
  * Function: clr_supports_write
  * Sets supports_write to be 0
  */
  function void clr_supports_write();
    supports_write = 0;
  endfunction

  /*
  * Function: set_supports_read
  * Sets supports_read to be 1
  */
  function void set_supports_read();
    supports_read = 1;
  endfunction

  /*
  * Function: clr_supports_read
  * Sets supports_read to be 0
  */
  function void clr_supports_read();
    supports_read = 0;
  endfunction

  /*
  *  Function: set_xilinx_slave_ready_check
 *   Sets xilinx_slave_ready_check_enable to be 1
  */
  function void set_xilinx_slave_ready_check();
    xilinx_slave_ready_check_enable = 1;
  endfunction

  /*
   * Function: clr_xilinx_slave_ready_check
   * Sets xilinx_slave_ready_check_enable to be 0
  */
  function void clr_xilinx_slave_ready_check();
    xilinx_slave_ready_check_enable = 0;
  endfunction

  // write address channel
  logic  [(C_AXI_ADDR_WIDTH-1):0]                                          awaddr;
  logic  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  awid;
  logic  [7:0]                                                             awlen;
  logic  [2:0]                                                             awsize;
  logic  [1:0]                                                             awburst;
  logic  [1:0]                                                             awlock;
  logic  [3:0]                                                             awcache;
  logic  [2:0]                                                             awprot;
  logic                                                                    awvalid = 1'b0;
  logic                                                                    awready = 1'b0;
  logic  [3:0]                                                             awregion;
  logic  [3:0]                                                             awqos;
  logic  [((C_AXI_AWUSER_WIDTH == 0) ? 0 : C_AXI_AWUSER_WIDTH -1):0]       awuser;

  // write data channel
  logic  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  wid;
  logic                                                                    wlast;
  logic  [(C_AXI_WDATA_WIDTH-1):0]                                         wdata;
  logic  [(C_AXI_WDATA_WIDTH/8)-1:0]                                       wstrb;
  logic                                                                    wvalid = 1'b0;
  logic                                                                    wready = 1'b0;
  logic  [((C_AXI_WUSER_WIDTH == 0) ? 0 : C_AXI_WUSER_WIDTH -1):0]         wuser;

  // write response channel
  logic  [1:0]                                                             bresp;
  logic  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  bid;
  logic                                                                    bvalid = 1'b0;
  logic                                                                    bready = 1'b0;
  logic  [((C_AXI_BUSER_WIDTH == 0) ? 0 : C_AXI_BUSER_WIDTH -1):0]         buser;

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // read address channel
  logic  [(C_AXI_ADDR_WIDTH-1):0]                                          araddr;
  logic  [((C_AXI_RID_WIDTH==0) ? 1:C_AXI_RID_WIDTH)-1:0]                  arid;
  logic  [7:0]                                                             arlen;
  logic  [2:0]                                                             arsize;
  logic  [1:0]                                                             arburst;
  logic  [1:0]                                                             arlock;
  logic  [3:0]                                                             arcache;
  logic  [2:0]                                                             arprot;
  logic                                                                    arvalid = 1'b0;
  logic                                                                    arready = 1'b0;
  logic  [3:0]                                                             arregion;
  logic  [3:0]                                                             arqos;
  logic  [((C_AXI_ARUSER_WIDTH == 0) ? 0 : C_AXI_ARUSER_WIDTH -1):0]       aruser;

  // read data  channel
  logic  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  rid;
  logic                                                                    rlast;
  logic  [(C_AXI_RDATA_WIDTH-1):0]                                         rdata;
  logic  [1:0]                                                             rresp;
  logic                                                                    rvalid = 1'b0;
  logic                                                                    rready = 1'b0;
  logic  [((C_AXI_RUSER_WIDTH == 0) ? 0 : C_AXI_RUSER_WIDTH -1):0]         ruser;

  /*
  *  Function: set_intf_slave
  *  Sets interface to slave mode
  */
  function void set_intf_slave();
    intf_is_master = 0;
    intf_is_slave = 1;
  endfunction : set_intf_slave

  /*
  *  Function: set_intf_master
  *  Sets interface to master mode
  */
  function void set_intf_master();
    intf_is_master = 1;
    intf_is_slave = 0;
  endfunction : set_intf_master

  /*
  *  Function: set_intf_monitor
  *  Sets interface to monitor mode
  */
  function void set_intf_monitor();
    intf_is_master = 0;
    intf_is_slave = 0;
  endfunction : set_intf_monitor

  assign AWADDR   = intf_is_master ? awaddr   : 'z;
  assign AWID     =  ((C_AXI_PROTOCOL == 2) || (C_AXI_WID_WIDTH == 0)) ? 1'b0 : intf_is_master ? awid     : 'z;
  assign AWLEN    = intf_is_master ? awlen    : 'z;
  assign AWSIZE   = intf_is_master ? awsize   : 'z;
  assign AWBURST  = intf_is_master ? awburst  : 'z;
  assign AWLOCK   = intf_is_master ? awlock   : 'z;
  assign AWCACHE  = intf_is_master ? awcache  : 'z;
  assign AWPROT   = intf_is_master ? awprot   : 'z;
  assign AWVALID  = intf_is_master ? awvalid  : 'z;
  assign AWREADY  = intf_is_slave  ? awready  : 'z;
  assign AWREGION = intf_is_master ? awregion : 'z;
  assign AWQOS    = intf_is_master ? awqos    : 'z;
  assign AWUSER   = (C_AXI_AWUSER_WIDTH == 0) ? 1'b0 : intf_is_master ? awuser   : 'z;
  assign WID      =  ((C_AXI_PROTOCOL == 2) || (C_AXI_WID_WIDTH == 0)) ? 1'b0 : intf_is_master ? wid      : 'z;
  assign WLAST    = intf_is_master ? wlast    : 'z;
  assign WDATA    = intf_is_master ? wdata    : 'z;
  assign WSTRB    = intf_is_master ? wstrb    : 'z;
  assign WVALID   = intf_is_master ? wvalid   : 'z;
  assign WREADY   = intf_is_slave  ? wready   : 'z;
  assign WUSER    = (C_AXI_WUSER_WIDTH == 0) ? 1'b0 :intf_is_master ? wuser   : 'z;
  assign BRESP    = intf_is_slave  ? bresp    : 'z;
  assign BID      = ((C_AXI_PROTOCOL == 2) || (C_AXI_WID_WIDTH == 0)) ? 1'b0 : intf_is_slave  ? bid      : 'z;
  assign BVALID   = intf_is_slave  ? bvalid   : 'z;
  assign BREADY   = intf_is_master ? bready   : 'z;
  assign BUSER    = (C_AXI_BUSER_WIDTH == 0)  ? 1'b0 : intf_is_slave  ? buser   : 'z;
  assign ARADDR   = intf_is_master ? araddr   : 'z;
  assign ARID     = ((C_AXI_PROTOCOL == 2) || (C_AXI_RID_WIDTH == 0)) ? 1'b0 : intf_is_master ? arid     : 'z;
  assign ARLEN    = intf_is_master ? arlen    : 'z;
  assign ARSIZE   = intf_is_master ? arsize   : 'z;
  assign ARBURST  = intf_is_master ? arburst  : 'z;
  assign ARLOCK   = intf_is_master ? arlock   : 'z;
  assign ARCACHE  = intf_is_master ? arcache  : 'z;
  assign ARPROT   = intf_is_master ? arprot   : 'z;
  assign ARVALID  = intf_is_master ? arvalid  : 'z;
  assign ARREADY  = intf_is_slave  ? arready  : 'z;
  assign ARREGION = intf_is_master ? arregion : 'z;
  assign ARQOS    = intf_is_master ? arqos    : 'z;
  assign ARUSER   = (C_AXI_ARUSER_WIDTH == 0) ? 1'b0 : intf_is_master ? aruser   : 'z;
  assign RID      = ((C_AXI_PROTOCOL == 2) || (C_AXI_RID_WIDTH == 0)) ? 1'b0 : intf_is_slave  ? rid      : 'z;
  assign RLAST    = intf_is_slave  ? rlast    : 'z;
  assign RDATA    = intf_is_slave  ? rdata    : 'z;
  assign RRESP    = intf_is_slave  ? rresp    : 'z;
  assign RVALID   = intf_is_slave  ? rvalid   : 'z;
  assign RREADY   = intf_is_master ? rready   : 'z;
  assign RUSER    = (C_AXI_RUSER_WIDTH == 0) ? 1'b0 :intf_is_slave  ? ruser   : 'z;

  wire   awready_internal = (supports_write == 0) ? 1'b0 : AWREADY;
  wire   arready_internal = (supports_read == 0)  ? 1'b0 : ARREADY;
  wire   wready_internal  = (supports_write == 0) ? 1'b0 : WREADY;
  wire   rready_internal  = (supports_read == 0)  ? 1'b0 : RREADY;
  wire   bready_internal  = (supports_write == 0) ? 1'b0 : BREADY;
  wire   awvalid_internal = (supports_write == 0) ? 1'b0 : AWVALID;
  wire   arvalid_internal = (supports_read == 0)  ? 1'b0 : ARVALID;
  wire   wvalid_internal  = (supports_write == 0) ? 1'b0 : WVALID;
  wire   rvalid_internal  = (supports_read == 0)  ? 1'b0 : RVALID;
  wire   bvalid_internal  = (supports_write == 0) ? 1'b0 : BVALID;

  wire  [((C_AXI_RID_WIDTH==0) ? 1:C_AXI_RID_WIDTH)-1:0]      arid_internal;
  wire  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]      wid_internal;
  wire  [((C_AXI_RID_WIDTH==0) ? 1:C_AXI_RID_WIDTH)-1:0]      rid_internal;
  wire  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]      awid_internal;
  wire  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]      bid_internal;

  assign arid_internal  = (C_AXI_RID_WIDTH==0) ? 1'b0 : ARID;
  assign wid_internal   = (C_AXI_WID_WIDTH==0) ? 1'b0 : WID;
  assign rid_internal   = (C_AXI_RID_WIDTH==0) ? 1'b0 : RID;
  assign awid_internal  = (C_AXI_WID_WIDTH==0) ? 1'b0 : AWID;
  assign bid_internal   = (C_AXI_WID_WIDTH==0) ? 1'b0 : BID;

  localparam  LP_ADDR_WIDTH = (C_AXI_ADDR_WIDTH > 12) ? C_AXI_ADDR_WIDTH : 13;
  wire [LP_ADDR_WIDTH-1:0] scaled_awaddr = {LP_ADDR_WIDTH{1'b0}} | AWADDR[C_AXI_ADDR_WIDTH-1:0];
  wire [LP_ADDR_WIDTH-1:0] scaled_araddr = {LP_ADDR_WIDTH{1'b0}} | ARADDR[C_AXI_ADDR_WIDTH-1:0];
  wire aclk_internal = (ACLKEN == 1'b0) ? 1'b0 : ACLK;

  wire        wlast_internal  = (C_AXI_PROTOCOL == 2) ? 1'b1 : WLAST;
  wire        rlast_internal  = (C_AXI_PROTOCOL == 2) ? 1'b1 : RLAST;

  wire [7:0]  awlen_internal  = (C_AXI_PROTOCOL == 0) ? AWLEN :
                                (C_AXI_PROTOCOL == 1) ? {4'h0,AWLEN[3:0]} :
                                8'h00;
  wire [7:0]  arlen_internal  = (C_AXI_PROTOCOL == 0) ? ARLEN :
                                (C_AXI_PROTOCOL == 1) ? {4'h0,ARLEN[3:0]} :
                                8'h00;
  wire [3:0]  arregion_internal = (C_AXI_PROTOCOL == 0) ? ARREGION :
                                  (C_AXI_PROTOCOL == 1) ? 4'h0 :
                                  4'h0;
  wire [3:0]  awregion_internal = (C_AXI_PROTOCOL == 0) ? AWREGION :
                                  (C_AXI_PROTOCOL == 1) ? 4'h0 :
                                  4'h0;
  wire [3:0]  arqos_internal =  (C_AXI_PROTOCOL == 0) ? ARQOS :
                                (C_AXI_PROTOCOL == 1) ? 4'h0 :
                                4'h0;
  wire [3:0]  awqos_internal =  (C_AXI_PROTOCOL == 0) ? AWQOS :
                                (C_AXI_PROTOCOL == 1) ? 4'h0 :
                                4'h0;
  wire [1:0]  awlock_internal = (C_AXI_PROTOCOL == 0) ? {1'b0,AWLOCK[0]} :
                                (C_AXI_PROTOCOL == 1) ? AWLOCK :
                                2'h0;
  wire [1:0]  arlock_internal = (C_AXI_PROTOCOL == 0) ? {1'b0,ARLOCK[0]} :
                                (C_AXI_PROTOCOL == 1) ? ARLOCK :
                                2'h0;
  wire [1:0]  awburst_internal =  (C_AXI_PROTOCOL == 0) ? AWBURST :
                                  (C_AXI_PROTOCOL == 1) ? AWBURST :
                                  2'h0;
  wire [1:0]  arburst_internal =  (C_AXI_PROTOCOL == 0) ? ARBURST :
                                  (C_AXI_PROTOCOL == 1) ? ARBURST :
                                  2'h0;
  wire [3:0]  awcache_internal =  (C_AXI_PROTOCOL == 0) ? AWCACHE :
                                  (C_AXI_PROTOCOL == 1) ? AWCACHE :
                                  4'h0;
  wire [3:0]  arcache_internal =  (C_AXI_PROTOCOL == 0) ? ARCACHE :
                                  (C_AXI_PROTOCOL == 1) ? ARCACHE :
                                  4'h0;
  wire [2:0]  awsize_internal = (C_AXI_PROTOCOL == 0) ? AWSIZE :
                                (C_AXI_PROTOCOL == 1) ? AWSIZE :
                                (C_AXI_WDATA_WIDTH == 32 ? 3'b010 : 3'b011);
  wire [2:0]  arsize_internal = (C_AXI_PROTOCOL == 0) ? ARSIZE :
                                (C_AXI_PROTOCOL == 1) ? ARSIZE :
                                (C_AXI_RDATA_WIDTH == 32 ? 3'b010 : 3'b011);

`ifndef XILINX_SIMULATOR
  axi_vip_v1_0_1_axi4pc #(
    .PROTOCOL         (C_AXI_PROTOCOL),
    .WADDR_WIDTH      (LP_ADDR_WIDTH), 
    .RADDR_WIDTH      (LP_ADDR_WIDTH),
    .RDATA_WIDTH      (C_AXI_RDATA_WIDTH),
    .WDATA_WIDTH      (C_AXI_WDATA_WIDTH),
    .RID_WIDTH        (C_AXI_WID_WIDTH),
    .WID_WIDTH        (C_AXI_RID_WIDTH),
    .AWUSER_WIDTH     (C_AXI_AWUSER_WIDTH ),
    .WUSER_WIDTH      (C_AXI_WUSER_WIDTH  ),
    .BUSER_WIDTH      (C_AXI_BUSER_WIDTH  ),
    .ARUSER_WIDTH     (C_AXI_ARUSER_WIDTH ),
    .RUSER_WIDTH      (C_AXI_RUSER_WIDTH  ),
    .MAXRBURSTS       ( C_MAXRBURSTS ),
    .MAXWBURSTS       ( C_MAXWBURSTS ),
    .MAXWAITS         ( C_MAXWAITS ),
    .MAXSTALLWAITS    ( C_MAXSTALLWAITS ),
    .RecommendOn      ( 1  ),
    .RecMaxWaitOn     ( 0  ),
    .HAS_ARESETN      ( C_AXI_HAS_ARESETN)
  ) PC (
    .ACLK               (ACLK), 
    .ACLKEN             (ACLKEN),
    .ARESETn            (ARESET_N),
    .AWADDR             (scaled_awaddr),
    .AWID               (awid_internal   ),
    .AWLEN              (awlen_internal  ),
    .AWSIZE             (awsize_internal ),
    .AWBURST            (awburst_internal),
    .AWLOCK             (awlock_internal[0]),
    .AWCACHE            (awcache_internal),
    .AWPROT             (AWPROT ),
    .AWVALID            (awvalid_internal),
    .AWREADY            (awready_internal),
    .AWREGION           (awregion_internal),
    .AWQOS              (awqos_internal),
    .AWUSER             (AWUSER ),

    .WLAST              (wlast_internal ),
    .WDATA              (WDATA ),
    .WSTRB              (WSTRB ),
    .WVALID             (wvalid_internal),
    .WREADY             (wready_internal),
    .WUSER              (WUSER ),

    .BRESP              (BRESP ),
    .BID                (bid_internal   ),
    .BVALID             (bvalid_internal),
    .BREADY             (bready_internal),
    .BUSER              (BUSER ),

    .ARADDR             (scaled_araddr ),
    .ARID               (arid_internal   ),
    .ARLEN              (arlen_internal  ),
    .ARSIZE             (arsize_internal ),
    .ARBURST            (arburst_internal),
    .ARLOCK             (arlock_internal[0]),
    .ARCACHE            (arcache_internal),
    .ARPROT             (ARPROT ),
    .ARVALID            (arvalid_internal),
    .ARREADY            (arready_internal),
    .ARREGION           (arregion_internal),
    .ARQOS              (arqos_internal),
    .ARUSER             (ARUSER ),

    .RID                (rid_internal   ),
    .RLAST              (rlast_internal ),
    .RDATA              (RDATA ),
    .RRESP              (RRESP ),
    .RVALID             (rvalid_internal),
    .RREADY             (rready_internal),
    .RUSER              (RUSER ),
    
    .CACTIVE            ( 1'b1 ),
    .CSYSREQ            ( 1'b1 ),
    .CSYSACK            ( 1'b1 )
  ); 
`endif    
    
`ifdef XILINX_SIMULATOR
  logic                                                                    ACLKEN_O=0;
  logic                                                                    ARESET_N_O=0;
  logic  [(C_AXI_ADDR_WIDTH-1):0]                                          AWADDR_O;
  logic  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  AWID_O;
  logic  [7:0]                                                             AWLEN_O;
  logic  [2:0]                                                             AWSIZE_O;
  logic  [1:0]                                                             AWBURST_O;
  logic  [1:0]                                                             AWLOCK_O;
  logic  [3:0]                                                             AWCACHE_O;
  logic  [2:0]                                                             AWPROT_O;
  logic                                                                    AWVALID_O;
  logic                                                                    AWREADY_O;
  logic  [3:0]                                                             AWREGION_O;
  logic  [3:0]                                                             AWQOS_O;
  logic  [((C_AXI_AWUSER_WIDTH == 0) ? 0 : C_AXI_AWUSER_WIDTH -1):0]       AWUSER_O;

  // write data channel
  logic  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  WID_O;
  logic                                                                    WLAST_O;
  logic  [(C_AXI_WDATA_WIDTH-1):0]                                         WDATA_O;
  logic  [(C_AXI_WDATA_WIDTH/8 ==0 ? 0: C_AXI_WDATA_WIDTH/8)-1:0]          WSTRB_O;
  logic                                                                    WVALID_O;
  logic                                                                    WREADY_O;
  logic  [((C_AXI_WUSER_WIDTH == 0) ? 0 : C_AXI_WUSER_WIDTH -1):0]         WUSER_O;

  // write response channel
  logic  [1:0]                                                             BRESP_O;
  logic  [((C_AXI_WID_WIDTH==0) ? 1:C_AXI_WID_WIDTH)-1:0]                  BID_O;
  logic                                                                    BVALID_O;
  logic                                                                    BREADY_O;
  logic  [((C_AXI_BUSER_WIDTH == 0) ? 0 : C_AXI_BUSER_WIDTH -1):0]         BUSER_O;

  // read address channel
  logic  [(C_AXI_ADDR_WIDTH-1):0]                                          ARADDR_O;
  logic  [((C_AXI_RID_WIDTH==0) ? 1:C_AXI_RID_WIDTH)-1:0]                  ARID_O;
  logic  [7:0]                                                             ARLEN_O;
  logic  [2:0]                                                             ARSIZE_O;
  logic  [1:0]                                                             ARBURST_O;
  logic  [1:0]                                                             ARLOCK_O;
  logic  [3:0]                                                             ARCACHE_O;
  logic  [2:0]                                                             ARPROT_O;
  logic                                                                    ARVALID_O;
  logic                                                                    ARREADY_O;
  logic  [3:0]                                                             ARREGION_O;
  logic  [3:0]                                                             ARQOS_O;
  logic  [((C_AXI_ARUSER_WIDTH == 0) ? 0 : C_AXI_ARUSER_WIDTH -1):0]       ARUSER_O;

  // read data  channel
  logic  [((C_AXI_RID_WIDTH==0) ? 1:C_AXI_RID_WIDTH)-1:0]                  RID_O;
  logic                                                                    RLAST_O;
  logic  [(C_AXI_RDATA_WIDTH-1):0]                                         RDATA_O;
  logic  [1:0]                                                             RRESP_O;
  logic                                                                    RVALID_O;
  logic                                                                    RREADY_O;
  logic  [((C_AXI_RUSER_WIDTH == 0) ? 0 : C_AXI_RUSER_WIDTH -1):0]         RUSER_O;

  always @(posedge ACLK) begin
    ARESET_N_O  <= #1 ARESET_N;
    ACLKEN_O   <= #1 ACLKEN;
    AWADDR_O   <= #1 AWADDR;
    AWID_O     <= #1 AWID ;
    AWLEN_O    <= #1 AWLEN ;
    AWSIZE_O   <= #1 AWSIZE ;
    AWBURST_O  <= #1 AWBURST;
    AWLOCK_O   <= #1 AWLOCK;
    AWCACHE_O  <= #1 AWCACHE;
    AWPROT_O   <= #1 AWPROT;
    AWVALID_O  <= #1 AWVALID;
    AWREADY_O  <= #1 AWREADY;
    AWREGION_O <= #1 AWREGION;
    AWQOS_O    <= #1 AWQOS ;
    AWUSER_O  <= #1 AWUSER;

  // write data channel
    WID_O      <= #1 WID;
    WLAST_O    <= #1 WLAST;
    WDATA_O    <= #1 WDATA;
    WSTRB_O    <= #1 WSTRB;
    WVALID_O   <= #1 WVALID;
    WREADY_O   <= #1 WREADY;
    WUSER_O    <= #1 WUSER;

  // write response channel
    BRESP_O    <= #1 BRESP;
    BID_O      <= #1 BID;
    BVALID_O   <= #1 BVALID;
    BREADY_O   <= #1 BREADY;
    BUSER_O    <= #1 BUSER;

  // read address channel
    ARADDR_O   <= #1 ARADDR ;
    ARID_O     <= #1 ARID;
    ARLEN_O    <= #1 ARLEN;
    ARSIZE_O   <= #1 ARSIZE;
    ARBURST_O  <= #1 ARBURST ;
    ARLOCK_O   <= #1 ARLOCK;
    ARCACHE_O  <= #1 ARCACHE;
    ARPROT_O   <= #1 ARPROT;
    ARVALID_O  <= #1 ARVALID;
    ARREADY_O  <= #1 ARREADY;
    ARREGION_O <= #1 ARREGION ;
    ARQOS_O    <= #1 ARQOS;
    ARUSER_O   <= #1 ARUSER;

  // read data  channel
    RID_O     <= #1 RID ;
    RLAST_O   <= #1 RLAST ;
    RDATA_O   <= #1 RDATA ;
    RRESP_O   <= #1 RRESP ;
    RVALID_O  <= #1 RVALID;
    RREADY_O  <= #1 RREADY;
    RUSER_O   <= #1 RUSER;

  end

  integer     bbeat   [int unsigned];
  integer     awbeat  [int unsigned];
  integer     rbeat   [int unsigned];
  integer     arbeat  [int unsigned];
  integer     wbeat = 0;

  always @(posedge ACLK) begin
    if (ARESET_N_O == 0) begin
      bbeat.delete();
      awbeat.delete();
      wbeat = 0;
      awcmd_id = 0;
      wcmd_id = 0;
      bcmd_id = 0;
      rbeat.delete();
      arbeat.delete();
      arcmd_id = 0;
      rcmd_id = 0;
    end else if (ACLKEN_O == 1) begin
      if (AWVALID && AWREADY) begin
        awcmd_id++;
        if (!awbeat.exists(awid_internal)) begin
          awbeat[awid_internal] = 0;
        end
        awbeat[awid_internal]++;
      end
      if (BVALID && BREADY) begin
        bcmd_id++;
        if (!bbeat.exists(bid_internal)) begin
          bbeat[bid_internal] = 0;
        end
        bbeat[bid_internal]++;
      end
      if (WVALID && WREADY) begin
        if ((C_AXI_PROTOCOL == 2) || (WLAST)) begin
          wcmd_id++;
          wbeat = 0;
        end else begin
          wbeat++;
        end
      end
      if (ARVALID && ARREADY) begin
        arcmd_id++;
        if (!arbeat.exists(arid_internal)) begin
          arbeat[arid_internal] = 0;
        end
        arbeat[arid_internal]++;
      end
      if (RVALID && RREADY) begin
        if ((C_AXI_PROTOCOL == 2) || (RLAST)) begin
          rcmd_id++;
          rbeat[rid_internal] = 0;
        end else begin
          if (!rbeat.exists(rid_internal)) begin
            rbeat[rid_internal] = 0;
          end
          rbeat[rid_internal]++;
        end
      end
    end
  end

  `else
  default clocking cb @(posedge aclk_internal);
    default input #1step output #C_HOLD_TIME;
    input   ARESET_N;
    input   ACLKEN;
    inout   AWADDR;
    inout   AWID;
    inout   AWLEN;
    inout   AWSIZE;
    inout   AWBURST;
    inout   AWLOCK;
    inout   AWCACHE;
    inout   AWPROT;
    inout   AWVALID;
    inout   AWREADY;
    inout   AWREGION;
    inout   AWQOS;
    inout   AWUSER;
    inout   WID;
    inout   WLAST;
    inout   WDATA;
    inout   WSTRB;
    inout   WVALID;
    inout   WREADY;
    inout   WUSER;
    inout   BRESP;
    inout   BID;
    inout   BVALID;
    inout   BREADY;
    inout   BUSER;
    inout   ARADDR;
    inout   ARID;
    inout   ARLEN;
    inout   ARSIZE;
    inout   ARBURST;
    inout   ARLOCK;
    inout   ARCACHE;
    inout   ARPROT;
    inout   ARVALID;
    inout   ARREADY;
    inout   ARREGION;
    inout   ARQOS;
    inout   ARUSER;
    inout   RID;
    inout   RLAST;
    inout   RDATA;
    inout   RRESP;
    inout   RVALID;
    inout   RREADY;
    inout   RUSER;
    inout   arid_internal;
    inout   wid_internal ;
    inout   rid_internal ;
    inout   awid_internal;
    inout   bid_internal ;
  endclocking : cb

  integer     bbeat   [int unsigned];
  integer     awbeat  [int unsigned];
  integer     rbeat   [int unsigned];
  integer     arbeat  [int unsigned];
  integer     wbeat = 0;

  always @(cb) begin
    if (cb.ARESET_N == 0) begin
      bbeat.delete();
      awbeat.delete();
      wbeat = 0;
      awcmd_id = 0;
      wcmd_id = 0;
      bcmd_id = 0;
      rbeat.delete();
      arbeat.delete();
      arcmd_id = 0;
      rcmd_id = 0;
    end else if (cb.ACLKEN == 1) begin
      if (cb.AWVALID && cb.AWREADY) begin
        awcmd_id++;
        if (!awbeat.exists(cb.awid_internal)) begin
          awbeat[cb.awid_internal] = 0;
        end
        awbeat[cb.awid_internal]++;
      end
      if (cb.BVALID && cb.BREADY) begin
        bcmd_id++;
        if (!bbeat.exists(cb.bid_internal)) begin
          bbeat[cb.bid_internal] = 0;
        end
        bbeat[cb.bid_internal]++;
      end
      if (cb.WVALID && cb.WREADY) begin
        if ((C_AXI_PROTOCOL == 2) || (cb.WLAST)) begin
          wcmd_id++;
          wbeat = 0;
        end else begin
          wbeat++;
        end
      end
      if (cb.ARVALID && cb.ARREADY) begin
        arcmd_id++;
        if (!arbeat.exists(cb.arid_internal)) begin
          arbeat[cb.arid_internal] = 0;
        end
        arbeat[cb.arid_internal]++;
      end
      if (cb.RVALID && cb.RREADY) begin
        if ((C_AXI_PROTOCOL == 2) || (cb.RLAST)) begin
          rcmd_id++;
          rbeat[cb.rid_internal] = 0;
        end else begin
          if (!rbeat.exists(cb.rid_internal)) begin
            rbeat[cb.rid_internal] = 0;
          end
          rbeat[cb.rid_internal]++;
        end
      end
    end
  end

  `endif

  function automatic xil_axi_uint xil_clog2(input xil_axi_uint value);
    if (value !== 0) begin
      value = value - 1;
      for (xil_clog2 = 0; value > 0; xil_clog2 = xil_clog2 + 1) begin
        value = value >> 1;
      end
    end else begin
      xil_clog2 = 0;
    end
  endfunction // xil_clog2


  `ifndef XILINX_SIMULATOR
  // INDEX:        - XILINX_AXI4_ERRM_AWREADY_RESET
  // =====
  property XILINX_AXI4_ERRM_AWREADY_RESET;
    @(posedge ACLK)
      !(ARESET_N) & !($isunknown(ARESET_N)) & (xilinx_slave_ready_check_enable == 1) & (supports_write == 1)
      ##1   ARESET_N |-> !AWREADY;
  endproperty
  xilinx_axi4_errm_awready_reset: assert property (XILINX_AXI4_ERRM_AWREADY_RESET) else
   $error("XILINX_AXI4_ERRM_AWREADY_RESET. AWREADY must be low for the first clock edge that ARESETn goes high. Xilinx Design Guidlines");

  // INDEX:        - XILINX_AXI4_ERRM_ARREADY_RESET
  // =====
  property XILINX_AXI4_ERRM_ARREADY_RESET;
    @(posedge ACLK)
      !(ARESET_N) & !($isunknown(ARESET_N)) & (xilinx_slave_ready_check_enable == 1) & (supports_read == 1)
      ##1   ARESET_N |-> !ARREADY;
  endproperty
  xilinx_axi4_errm_arready_reset: assert property (XILINX_AXI4_ERRM_ARREADY_RESET) else
   $error("XILINX_AXI4_ERRM_ARREADY_RESET. ARREADY must be low for the first clock edge that ARESETn goes high. Xilinx Design Guidlines");

  // INDEX:        - XILINX_AXI4_ERRM_WREADY_RESET
  // =====
  property XILINX_AXI4_ERRM_WREADY_RESET;
    @(posedge ACLK)
      !(ARESET_N) & !($isunknown(ARESET_N)) & (xilinx_slave_ready_check_enable == 1) & (supports_write == 1)
      ##1   ARESET_N |-> !WREADY;
  endproperty
  xilinx_axi4_errm_wready_reset: assert property (XILINX_AXI4_ERRM_WREADY_RESET) else
   $error("XILINX_AXI4_ERRM_WREADY_RESET. WREADY must be low for the first clock edge that ARESETn goes high. Xilinx Design Guidlines");

  // INDEX:        - XILINX_AXI4_ERRM_WREADY_MAX_RESET
  // =====
  property   XILINX_AXI4_ERRM_WREADY_MAX_RESET;
    @(posedge ACLK) disable iff (ACLKEN == 0)
      !(ARESET_N) & !($isunknown(ARESET_N)) & (xilinx_slave_ready_check_enable == 1) & (supports_write == 1)
      |-> ##[1:8] (!WREADY); 
  endproperty
  xilinx_axi4_errm_wready_max_reset: assert property (XILINX_AXI4_ERRM_WREADY_MAX_RESET) else
   $error("XILINX_AXI4_ERRM_WREADY_MAX_RESET. WREADY must go low after 8 cycles following the first clock edge that ARESETn goes low. Xilinx Design Guidlines");

  // INDEX:        - XILINX_AXI4_ERRM_ARREADY_MAX_RESET
  // =====
  property   XILINX_AXI4_ERRM_ARREADY_MAX_RESET;
    @(posedge ACLK) disable iff (ACLKEN == 0)
      !(ARESET_N) & !($isunknown(ARESET_N)) & (xilinx_slave_ready_check_enable == 1) & (supports_read == 1)
      |-> ##[1:8] (!ARREADY); 
  endproperty
  xilinx_axi4_errm_arready_max_reset: assert property (XILINX_AXI4_ERRM_ARREADY_MAX_RESET) else
   $error("XILINX_AXI4_ERRM_ARREADY_MAX_RESET. ARREADY must go low after 8 cycles following the first clock edge that ARESETn goes low. Xilinx Design Guidlines");

  // INDEX:        - XILINX_AXI4_ERRM_AWREADY_MAX_RESET
  // =====
  property   XILINX_AXI4_ERRM_AWREADY_MAX_RESET;
    @(posedge ACLK) disable iff (ACLKEN == 0)
      !(ARESET_N) & !($isunknown(ARESET_N)) & (xilinx_slave_ready_check_enable == 1) & (supports_write == 1)
      |-> ##[1:8] (!AWREADY); 
  endproperty
  xilinx_axi4_errm_awready_max_reset: assert property (XILINX_AXI4_ERRM_AWREADY_MAX_RESET) else
   $error("XILINX_AXI4_ERRM_AWREADY_MAX_RESET. AWREADY must go low after 8 cycles following the first clock edge that ARESETn goes low. Xilinx Design Guidlines");
`endif

endinterface : axi_vip_v1_0_1_if

`endif


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
//
// AXI VIP wrapper
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axi_vip
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_vip_v1_0_1_top #
  (
   parameter C_AXI_PROTOCOL                      = 0,
   parameter C_AXI_INTERFACE_MODE                = 1,  //master, slave and bypass
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_WDATA_WIDTH           = 32,
   parameter integer C_AXI_RDATA_WIDTH           = 32,
   parameter integer C_AXI_WID_WIDTH             = 0,
   parameter integer C_AXI_RID_WIDTH             = 0,
   parameter integer C_AXI_AWUSER_WIDTH          = 0,
   parameter integer C_AXI_ARUSER_WIDTH          = 0,
   parameter integer C_AXI_WUSER_WIDTH           = 0,
   parameter integer C_AXI_RUSER_WIDTH           = 0,
   parameter integer C_AXI_BUSER_WIDTH           = 0,
   parameter integer C_AXI_SUPPORTS_NARROW       = 1,
   parameter integer C_AXI_HAS_BURST             = 1,
   parameter integer C_AXI_HAS_LOCK              = 1,
   parameter integer C_AXI_HAS_CACHE             = 1,
   parameter integer C_AXI_HAS_REGION            = 1,
   parameter integer C_AXI_HAS_PROT              = 1,
   parameter integer C_AXI_HAS_QOS               = 1,
   parameter integer C_AXI_HAS_WSTRB             = 1,
   parameter integer C_AXI_HAS_BRESP             = 1,
   parameter integer C_AXI_HAS_RRESP             = 1,
   parameter integer C_AXI_HAS_ARESETN           = 1
   )
  (
   //NOTE:  C_AXI_INTERFACE_MODE =0 means MASTER MODE, 1 means PASS-THROUGH MODE and 2 means SLAVE MODE
   //Please refer xgui tcl and coreinfo.yml
   
   // System Signals
   input wire aclk,
   input wire aclken,
   input wire aresetn,

   // Slave Interface Write Address Ports
   input  wire [C_AXI_WID_WIDTH==0?0:C_AXI_WID_WIDTH-1:0]          s_axi_awid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]                              s_axi_awaddr,
   input  wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]               s_axi_awlen,
   input  wire [3-1:0]                                             s_axi_awsize,
   input  wire [2-1:0]                                             s_axi_awburst,
   input  wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]               s_axi_awlock,
   input  wire [4-1:0]                                             s_axi_awcache,
   input  wire [3-1:0]                                             s_axi_awprot,
   input  wire [4-1:0]                                             s_axi_awregion,
   input  wire [4-1:0]                                             s_axi_awqos,
   input  wire [C_AXI_AWUSER_WIDTH==0?0:C_AXI_AWUSER_WIDTH-1:0]    s_axi_awuser,
   input  wire                                                     s_axi_awvalid,
   output wire                                                     s_axi_awready,

   // Slave Interface Write Data Ports
   input  wire [C_AXI_WID_WIDTH==0?0:C_AXI_WID_WIDTH-1:0]          s_axi_wid,
   input  wire [C_AXI_WDATA_WIDTH-1:0]                             s_axi_wdata,
   input  wire [C_AXI_WDATA_WIDTH/8==0 ?0:C_AXI_WDATA_WIDTH/8-1:0] s_axi_wstrb,
   input  wire                                                     s_axi_wlast,
   input  wire [C_AXI_WUSER_WIDTH==0?0:C_AXI_WUSER_WIDTH-1:0]      s_axi_wuser,
   input  wire                                                     s_axi_wvalid,
   output wire                                                     s_axi_wready,

   // Slave Interface Write Response Ports
   output wire [C_AXI_WID_WIDTH==0?0:C_AXI_WID_WIDTH-1:0]          s_axi_bid,
   output wire [2-1:0]                                             s_axi_bresp,
   output wire [C_AXI_BUSER_WIDTH==0?0:C_AXI_BUSER_WIDTH-1:0]      s_axi_buser,
   output wire                                                     s_axi_bvalid,
   input  wire                                                     s_axi_bready,

   // Slave Interface Read Address Ports
   input  wire [C_AXI_RID_WIDTH==0?0:C_AXI_RID_WIDTH-1:0]          s_axi_arid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]                              s_axi_araddr,
   input  wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]               s_axi_arlen,
   input  wire [3-1:0]                                             s_axi_arsize,
   input  wire [2-1:0]                                             s_axi_arburst,
   input  wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]               s_axi_arlock,
   input  wire [4-1:0]                                             s_axi_arcache,
   input  wire [3-1:0]                                             s_axi_arprot,
   input  wire [4-1:0]                                             s_axi_arregion,
   input  wire [4-1:0]                                             s_axi_arqos,
   input  wire [C_AXI_ARUSER_WIDTH==0?0:C_AXI_ARUSER_WIDTH-1:0]    s_axi_aruser,
   input  wire                                                     s_axi_arvalid,
   output wire                                                     s_axi_arready,

   // Slave Interface Read Data Ports
   output wire [C_AXI_RID_WIDTH==0?0:C_AXI_RID_WIDTH-1:0]          s_axi_rid,
   output wire [C_AXI_RDATA_WIDTH-1:0]                             s_axi_rdata,
   output wire [2-1:0]                                             s_axi_rresp,
   output wire                                                     s_axi_rlast,
   output wire [C_AXI_RUSER_WIDTH==0?0:C_AXI_RUSER_WIDTH-1:0]      s_axi_ruser,
   output wire                                                     s_axi_rvalid,
   input  wire                                                     s_axi_rready,
   
   // Master Interface Write Address Port
   output wire [C_AXI_WID_WIDTH==0?0:C_AXI_WID_WIDTH-1:0]          m_axi_awid,
   output wire [C_AXI_ADDR_WIDTH-1:0]                              m_axi_awaddr,
   output wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]               m_axi_awlen,
   output wire [3-1:0]                                             m_axi_awsize,
   output wire [2-1:0]                                             m_axi_awburst,
   output wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]               m_axi_awlock,
   output wire [4-1:0]                                             m_axi_awcache,
   output wire [3-1:0]                                             m_axi_awprot,
   output wire [4-1:0]                                             m_axi_awregion,
   output wire [4-1:0]                                             m_axi_awqos,
   output wire [C_AXI_AWUSER_WIDTH==0?0:C_AXI_AWUSER_WIDTH-1:0]    m_axi_awuser,
   output wire                                                     m_axi_awvalid,
   input  wire                                                     m_axi_awready,
   
   // Master Interface Write Data Ports
   output wire [C_AXI_WID_WIDTH==0?0:C_AXI_WID_WIDTH-1:0]          m_axi_wid,
   output wire [C_AXI_WDATA_WIDTH-1:0]                             m_axi_wdata,
   output wire [C_AXI_WDATA_WIDTH/8 ==0?0:C_AXI_WDATA_WIDTH/8-1:0] m_axi_wstrb,
   output wire                                                     m_axi_wlast,
   output wire [C_AXI_WUSER_WIDTH==0?0:C_AXI_WUSER_WIDTH-1:0]      m_axi_wuser,
   output wire                                                     m_axi_wvalid,
   input  wire                                                     m_axi_wready,
   
   // Master Interface Write Response Ports
   input  wire [C_AXI_WID_WIDTH==0?0:C_AXI_WID_WIDTH-1:0]          m_axi_bid,
   input  wire [2-1:0]                                             m_axi_bresp,
   input  wire [C_AXI_BUSER_WIDTH==0?0:C_AXI_BUSER_WIDTH-1:0]      m_axi_buser,
   input  wire                                                     m_axi_bvalid,
   output wire                                                     m_axi_bready,
   
   // Master Interface Read Address Port
   output wire [C_AXI_RID_WIDTH==0?0:C_AXI_RID_WIDTH-1:0]          m_axi_arid,
   output wire [ C_AXI_ADDR_WIDTH-1:0]                             m_axi_araddr,
   output wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]               m_axi_arlen,
   output wire [3-1:0]                                             m_axi_arsize,
   output wire [2-1:0]                                             m_axi_arburst,
   output wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]               m_axi_arlock,
   output wire [4-1:0]                                             m_axi_arcache,
   output wire [3-1:0]                                             m_axi_arprot,
   output wire [4-1:0]                                             m_axi_arregion,
   output wire [4-1:0]                                             m_axi_arqos,
   output wire [C_AXI_ARUSER_WIDTH==0?0:C_AXI_ARUSER_WIDTH-1:0]    m_axi_aruser,
   output wire                                                     m_axi_arvalid,
   input  wire                                                     m_axi_arready,
   
   // Master Interface Read Data Ports
   input  wire [C_AXI_RID_WIDTH==0?0:C_AXI_RID_WIDTH-1:0]          m_axi_rid,
   input  wire [C_AXI_RDATA_WIDTH-1:0]                             m_axi_rdata,
   input  wire [2-1:0]                                             m_axi_rresp,
   input  wire                                                     m_axi_rlast,
   input  wire [C_AXI_RUSER_WIDTH==0?0:C_AXI_RUSER_WIDTH-1:0]      m_axi_ruser,
   input  wire                                                     m_axi_rvalid,
   output wire                                                     m_axi_rready
  );
   
  /**********************************************************************************************
  * NOTE:  
  *   C_AXI_INTERFACE_MODE =0 -- MASTER MODE, 
  *   C_AXI_INTERFACE_MODE =1 -- PASS-THROUGH MODE 
  *   C_AXI_INTERFACE_MODE =2 -- SLAVE MODE
  *   Please refer xgui tcl and coreinfo.yml
  *   User can change PASS_THROUGH VIP to run time master mode or run time slave mode during 
  *   the simulation 
  *********************************************************************************************/

  /**********************************************************************************************
  * Master_mode means that either the dut is statically being configured to be in master mode
  * or it statically being configured to be pass-through mode and switched to be in master mode
  * in run time. 
   
  * Slave mode means that either the dut is statically being configured to be in slave mode
  * or it statically being configured to be pass-through mode and switched to be in slave mode
  * in run time. 

   * Pass-through mode means that either the dut is statically being configured to be in
   * pass-through mode or it statically being configured to be pass-through mode and switched
   * to be in master/slave mode and then switch back to be in pass-through mode in run time
  *********************************************************************************************/

  logic runtime_master =0;
  logic runtime_slave =0;

  wire run_slave_mode;
  wire run_master_mode;
  wire run_passth_mode;
  wire compile_master_mode;
  wire compile_slave_mode;
  wire master_mode;
  wire slave_mode;

  assign run_master_mode = (C_AXI_INTERFACE_MODE ==1 && runtime_master ==1 &&runtime_slave ==0);
  assign run_slave_mode = C_AXI_INTERFACE_MODE ==1 && runtime_slave ==1 && runtime_master ==0;
  assign run_passth_mode = (runtime_slave ==0 && runtime_master ==0);

  assign compile_master_mode = (C_AXI_INTERFACE_MODE ==0 || C_AXI_INTERFACE_MODE ==1 )&& run_passth_mode ;   
  assign compile_slave_mode  = (C_AXI_INTERFACE_MODE ==2 || C_AXI_INTERFACE_MODE ==1) && run_passth_mode ;

  assign master_mode = compile_master_mode || run_master_mode; 
  assign slave_mode = compile_slave_mode || run_slave_mode;

  // Slave Interface Write Address Ports Internal
  assign IF.AWID        = slave_mode? s_axi_awid : {C_AXI_WID_WIDTH==0?1:C_AXI_WID_WIDTH{1'bz}};
  assign IF.AWADDR      = slave_mode? s_axi_awaddr : {C_AXI_ADDR_WIDTH{1'bz}};
  assign IF.AWLEN       = slave_mode? s_axi_awlen : {((C_AXI_PROTOCOL == 1) ? 4 : 8){1'bz}};
  assign IF.AWSIZE      = slave_mode? s_axi_awsize : {3{1'bz}};
  assign IF.AWBURST     = slave_mode? s_axi_awburst : {2{1'bz}};
  assign IF.AWLOCK      = slave_mode? s_axi_awlock : {((C_AXI_PROTOCOL == 1) ? 2 : 1){1'bz}};
  assign IF.AWCACHE     = slave_mode? s_axi_awcache : {4{1'bz}};
  assign IF.AWPROT      = slave_mode? s_axi_awprot : {3{1'bz}};
  assign IF.AWREGION    = slave_mode? s_axi_awregion : {4{1'bz}};
  assign IF.AWQOS       = slave_mode? s_axi_awqos : {4{1'bz}};
  assign IF.AWUSER      = slave_mode? s_axi_awuser : {C_AXI_AWUSER_WIDTH==0?1:C_AXI_AWUSER_WIDTH{1'bz}};
  assign IF.AWVALID     = slave_mode? s_axi_awvalid : {1'bz};
  assign s_axi_awready  = slave_mode? IF.AWREADY : {1'b0};

  // Slave Interface Write Data Ports  
  assign IF.WID         = slave_mode? s_axi_wid : {C_AXI_WID_WIDTH==0?1:C_AXI_WID_WIDTH{1'bz}};
  assign IF.WDATA       = slave_mode? s_axi_wdata : {C_AXI_WDATA_WIDTH{1'bz}};
  assign IF.WSTRB       = slave_mode? s_axi_wstrb : {(C_AXI_WDATA_WIDTH/8){1'bz}};
  assign IF.WLAST       = slave_mode? s_axi_wlast: {1'bz};
  assign IF.WUSER       = slave_mode? s_axi_wuser : {C_AXI_WUSER_WIDTH==0?1:C_AXI_WUSER_WIDTH{1'bz}};
  assign IF.WVALID      = slave_mode? s_axi_wvalid : {1'bz}; 
  assign s_axi_wready   = slave_mode? IF.WREADY : {1'b0};

  // Slave Interface Write Response Ports
  assign s_axi_bid      = slave_mode? IF.BID : {C_AXI_WID_WIDTH==0?1:C_AXI_WID_WIDTH{1'b0}};
  assign s_axi_bresp    = slave_mode? IF.BRESP : {2{1'b0}};
  assign s_axi_buser    = slave_mode? IF.BUSER : {C_AXI_BUSER_WIDTH==0?1:C_AXI_BUSER_WIDTH{1'b0}};
  assign s_axi_bvalid   = slave_mode? IF.BVALID : {1{1'b0}};
  assign IF.BREADY      = slave_mode? s_axi_bready :{1{1'bz}};

  // Slave Interface Read Address Ports 
  assign IF.ARID        = slave_mode? s_axi_arid :{C_AXI_RID_WIDTH==0?1:C_AXI_RID_WIDTH{1'bz}};
  assign IF.ARADDR      = slave_mode? s_axi_araddr : {C_AXI_ADDR_WIDTH{1'bz}} ;
  assign IF.ARLEN       = slave_mode? s_axi_arlen: {((C_AXI_PROTOCOL == 1) ? 4 : 8){1'bz}};
  assign IF.ARSIZE      = slave_mode? s_axi_arsize : {3{1'bz}};
  assign IF.ARBURST     = slave_mode? s_axi_arburst : {2{1'bz}};
  assign IF.ARLOCK      = slave_mode? s_axi_arlock : {((C_AXI_PROTOCOL == 1) ? 2 : 1){1'bz}};
  assign IF.ARCACHE     = slave_mode? s_axi_arcache : {4{1'bz}};
  assign IF.ARPROT      = slave_mode? s_axi_arprot : {3{1'bz}};
  assign IF.ARREGION    = slave_mode? s_axi_arregion :{4{1'bz}} ;
  assign IF.ARQOS       = slave_mode? s_axi_arqos : {4{1'bz}};
  assign IF.ARUSER      = slave_mode? s_axi_aruser :{C_AXI_ARUSER_WIDTH==0?1:C_AXI_ARUSER_WIDTH{1'bz}};
  assign IF.ARVALID     = slave_mode? s_axi_arvalid : {1'bz};
  assign s_axi_arready  = slave_mode? IF.ARREADY : {1'b0};

  //Slave Interface Read Data Ports 
  assign s_axi_rid      = slave_mode?  IF.RID: {C_AXI_RID_WIDTH==0?1:C_AXI_RID_WIDTH{1'b0}};
  assign s_axi_rdata    = slave_mode? IF.RDATA : {C_AXI_RDATA_WIDTH{1'b0}};
  assign s_axi_rresp    = slave_mode? IF.RRESP : {2{1'b0}};
  assign s_axi_rlast    = slave_mode? IF.RLAST : {{1'b0}};
  assign s_axi_ruser    = slave_mode? IF.RUSER : {C_AXI_RUSER_WIDTH==0?1:C_AXI_RUSER_WIDTH{1'b0}};
  assign s_axi_rvalid   = slave_mode? IF.RVALID : {{1'b0}};
  assign IF.RREADY      = slave_mode? s_axi_rready:{{1'bz}};

  // Master Interface Write Address Port 
  assign m_axi_awid     = master_mode? IF.AWID : {C_AXI_WID_WIDTH==0?1:C_AXI_WID_WIDTH{1'b0}};
  assign m_axi_awaddr   = master_mode? IF.AWADDR : {C_AXI_ADDR_WIDTH{1'b0}};
  assign m_axi_awlen    = master_mode? IF.AWLEN : {((C_AXI_PROTOCOL == 1) ? 4 : 8){1'b0}};
  assign m_axi_awsize   = master_mode? IF.AWSIZE : {3{1'b0}};
  assign m_axi_awburst  = master_mode? IF.AWBURST : {2{1'b0}};
  assign m_axi_awlock   = master_mode? IF.AWLOCK : {((C_AXI_PROTOCOL == 1) ? 2 : 1){1'b0}};
  assign m_axi_awcache  = master_mode? IF.AWCACHE : {4{1'b0}};
  assign m_axi_awprot   = master_mode? IF.AWPROT : {3{1'b0}};
  assign m_axi_awregion = master_mode? IF.AWREGION : {4{1'b0}};
  assign m_axi_awqos    = master_mode? IF.AWQOS : {4{1'b0}};
  assign m_axi_awuser   = master_mode? IF.AWUSER : {C_AXI_AWUSER_WIDTH==0?1:C_AXI_AWUSER_WIDTH{1'b0}};
  assign m_axi_awvalid  = master_mode? IF.AWVALID :{1'b0};
  assign IF.AWREADY     = master_mode? m_axi_awready :{1'bz};

  // Master Interface Write Data Ports Internal
  assign m_axi_wid      = master_mode? IF.WID : {C_AXI_WID_WIDTH==0?1:C_AXI_WID_WIDTH{1'b0}};
  assign m_axi_wdata    = master_mode? IF.WDATA : {C_AXI_WDATA_WIDTH{1'b0}};
  assign m_axi_wstrb    = master_mode? IF.WSTRB : {(C_AXI_WDATA_WIDTH/8){1'b0}};
  assign m_axi_wlast    = master_mode? IF.WLAST : {1'b0};
  assign m_axi_wuser    = master_mode? IF.WUSER : {C_AXI_WUSER_WIDTH==0?1:C_AXI_WUSER_WIDTH{1'b0}};
  assign m_axi_wvalid   = master_mode? IF.WVALID : {1'b0};
  assign IF.WREADY      = master_mode? m_axi_wready : {1'bz};

  // Master Interface Write Response Ports Internal
  assign IF.BID        = master_mode? m_axi_bid : {C_AXI_WID_WIDTH==0?1:C_AXI_WID_WIDTH{1'bz}};
  assign IF.BRESP      = master_mode? m_axi_bresp : {2{1'bz}};
  assign IF.BUSER      = master_mode? m_axi_buser : {C_AXI_BUSER_WIDTH==0?1:C_AXI_BUSER_WIDTH{1'bz}};
  assign IF.BVALID     = master_mode? m_axi_bvalid : 1'bz;
  assign m_axi_bready  = master_mode? IF.BREADY : 1'b0;

  // Master Interface Read Address Port Internal
  assign m_axi_arid     = master_mode? IF.ARID : {C_AXI_RID_WIDTH==0?1:C_AXI_RID_WIDTH{1'b0}};
  assign m_axi_araddr   = master_mode? IF.ARADDR : {C_AXI_ADDR_WIDTH{1'b0}};
  assign m_axi_arlen    = master_mode? IF.ARLEN : {((C_AXI_PROTOCOL == 1) ? 4 : 8){1'b0}};
  assign m_axi_arsize   = master_mode? IF.ARSIZE : {3{1'b0}};
  assign m_axi_arburst  = master_mode? IF.ARBURST : {2{1'b0}};
  assign m_axi_arlock   = master_mode? IF.ARLOCK : {((C_AXI_PROTOCOL == 1) ? 2 : 1){1'b0}};
  assign m_axi_arcache  = master_mode?IF.ARCACHE : {4{1'b0}};
  assign m_axi_arprot   = master_mode? IF.ARPROT : {3{1'b0}};
  assign m_axi_arregion = master_mode? IF.ARREGION : {4{1'b0}};
  assign m_axi_arqos    = master_mode? IF.ARQOS : {4{1'b0}};
  assign m_axi_aruser   = master_mode? IF.ARUSER : {C_AXI_ARUSER_WIDTH==0?1:C_AXI_ARUSER_WIDTH{1'b0}};
  assign m_axi_arvalid  = master_mode? IF.ARVALID :{1'b0};
  assign IF.ARREADY     = master_mode? m_axi_arready : {1{1'bz}};

  // Master Interface Read Data Ports Internal
  assign IF.RID        = master_mode? m_axi_rid : {C_AXI_RID_WIDTH==0?1:C_AXI_RID_WIDTH{1'bz}};
  assign IF.RDATA      = master_mode? m_axi_rdata : {C_AXI_RDATA_WIDTH{1'bz}};
  assign IF.RRESP      = master_mode? m_axi_rresp : {2{1'bz}};
  assign IF.RLAST      = master_mode? m_axi_rlast : {1{1'bz}};
  assign IF.RUSER      = master_mode? m_axi_ruser : {C_AXI_RUSER_WIDTH==0?1:C_AXI_RUSER_WIDTH{1'bz}};
  assign IF.RVALID     = master_mode? m_axi_rvalid : {1{1'bz}};
  assign m_axi_rready  = master_mode? IF.RREADY : {1{1'b0}};

  axi_vip_v1_0_1_if #(
    .C_AXI_PROTOCOL(C_AXI_PROTOCOL),
    .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH ),
    .C_AXI_WDATA_WIDTH(C_AXI_WDATA_WIDTH ),
    .C_AXI_RDATA_WIDTH(C_AXI_RDATA_WIDTH ),
    .C_AXI_WID_WIDTH(C_AXI_WID_WIDTH ),
    .C_AXI_RID_WIDTH(C_AXI_RID_WIDTH ), 
    .C_AXI_AWUSER_WIDTH(C_AXI_AWUSER_WIDTH ), 
    .C_AXI_WUSER_WIDTH(C_AXI_WUSER_WIDTH ),
    .C_AXI_BUSER_WIDTH(C_AXI_BUSER_WIDTH ),
    .C_AXI_ARUSER_WIDTH(C_AXI_ARUSER_WIDTH ),
    .C_AXI_RUSER_WIDTH(C_AXI_RUSER_WIDTH ),
    .C_AXI_SUPPORTS_NARROW(C_AXI_SUPPORTS_NARROW),
    .C_AXI_HAS_BURST(C_AXI_HAS_BURST),
    .C_AXI_HAS_LOCK(C_AXI_HAS_LOCK),
    .C_AXI_HAS_CACHE(C_AXI_HAS_CACHE),
    .C_AXI_HAS_REGION(C_AXI_HAS_REGION),
    .C_AXI_HAS_PROT(C_AXI_HAS_PROT),
    .C_AXI_HAS_QOS(C_AXI_HAS_QOS),
    .C_AXI_HAS_WSTRB(C_AXI_HAS_WSTRB),
    .C_AXI_HAS_BRESP(C_AXI_HAS_BRESP),
    .C_AXI_HAS_RRESP(C_AXI_HAS_RRESP),
    .C_AXI_HAS_ARESETN(C_AXI_HAS_ARESETN)
  ) IF (
    .ACLK(aclk),
    .ARESET_N(aresetn),
    .ACLKEN(aclken)
  );  

`ifdef XILINX_SIMULATOR 
  generate 
    if(C_AXI_WID_WIDTH <16) begin
      axi_protocol_checker_v1_1_13_top #(
            .C_AXI_PROTOCOL(C_AXI_PROTOCOL), 
            .C_AXI_ID_WIDTH(C_AXI_WID_WIDTH ==0 ? 1: C_AXI_WID_WIDTH  ) ,
            .C_AXI_DATA_WIDTH(C_AXI_WDATA_WIDTH) ,
            .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH) ,
            .C_AXI_AWUSER_WIDTH(C_AXI_AWUSER_WIDTH ==0 ? 1: C_AXI_AWUSER_WIDTH ) ,
            .C_AXI_WUSER_WIDTH(C_AXI_WUSER_WIDTH ==0 ?1 : C_AXI_WUSER_WIDTH ) ,
            .C_AXI_BUSER_WIDTH(C_AXI_BUSER_WIDTH ==0 ? 1: C_AXI_BUSER_WIDTH) ,
            .C_AXI_ARUSER_WIDTH(C_AXI_ARUSER_WIDTH ==0 ? 1: C_AXI_ARUSER_WIDTH) ,
            .C_AXI_RUSER_WIDTH(C_AXI_RUSER_WIDTH ==0 ? 1:C_AXI_RUSER_WIDTH )  ,
            .C_PC_MAXRBURSTS            ( 64),
            .C_PC_MAXWBURSTS            ( 64),
            .C_PC_EXMON_WIDTH           ( 0),
            .C_PC_AW_MAXWAITS               ( 0),
            .C_PC_AR_MAXWAITS               ( 0),
            .C_PC_W_MAXWAITS                ( 0),
            .C_PC_R_MAXWAITS                ( 0),
            .C_PC_B_MAXWAITS                ( 0),
            .C_PC_MESSAGE_LEVEL             ( 2),
            .C_PC_SUPPORTS_NARROW_BURST     ( 1),
            .C_PC_MAX_BURST_LENGTH          ( 256),
            .C_PC_HAS_SYSTEM_RESET          ( 0),
            .C_PC_STATUS_WIDTH              ( 97)
      ) PC (
            .pc_status(),
            .pc_asserted(), 
            .system_resetn(aresetn),
        //AXI CLK
            .aclk(aclk),
        //AXI Reset
            .aresetn(aresetn),
        //AXI Write Address
            .pc_axi_awid(IF.awid_internal),
            .pc_axi_awaddr(IF.AWADDR),
            .pc_axi_awlen(IF.awlen_internal[(C_AXI_PROTOCOL ==1 ?3: 7):0]),
            .pc_axi_awsize(IF.awsize_internal),
            .pc_axi_awburst(IF.awburst_internal),
            .pc_axi_awlock(IF.awlock_internal[(C_AXI_PROTOCOL ==1 ?1: 0):0]  ),
            .pc_axi_awcache(IF.awcache_internal),
            .pc_axi_awprot(IF.AWPROT),
            .pc_axi_awqos(IF.awqos_internal),
            .pc_axi_awregion(IF.awregion_internal),
            .pc_axi_awuser(IF.AWUSER),
            .pc_axi_awvalid(IF.awvalid_internal),
            .pc_axi_awready(IF.awready_internal),
        //AXI Write Data
            .pc_axi_wid(IF.wid_internal),
            .pc_axi_wlast(IF.wlast_internal),
            .pc_axi_wdata(IF.WDATA),
            .pc_axi_wstrb(IF.WSTRB),
            .pc_axi_wuser(IF.WUSER),
            .pc_axi_wvalid(IF.wvalid_internal),
            .pc_axi_wready(IF.wready_internal),
        //AXI Write Response
            .pc_axi_bid(IF.bid_internal),
            .pc_axi_bresp(IF.BRESP),
            .pc_axi_buser(IF.BUSER),
            .pc_axi_bvalid(IF.bvalid_internal),
            .pc_axi_bready(IF.bready_internal),
        //AXI Read Address
            .pc_axi_arid(IF.arid_internal),
            .pc_axi_araddr(IF.ARADDR),
            .pc_axi_arlen(IF.arlen_internal[(C_AXI_PROTOCOL ==1 ?3: 7):0]  ),
            .pc_axi_arsize(IF.arsize_internal),
            .pc_axi_arburst(IF.arburst_internal),
            .pc_axi_arlock(IF.arlock_internal[(C_AXI_PROTOCOL ==1 ?1: 0):0] ),
            .pc_axi_arcache(IF.arcache_internal),
            .pc_axi_arprot(IF.ARPROT),
            .pc_axi_arqos(IF.arqos_internal),
            .pc_axi_arregion(IF.arregion_internal),
            .pc_axi_aruser(IF.ARUSER ),
            .pc_axi_arvalid(IF.arvalid_internal),
            .pc_axi_arready(IF.arready_internal),
        //AXI Read Data
           .pc_axi_rid(IF.rid_internal),
           .pc_axi_rlast(IF.rlast_internal),
           .pc_axi_rdata(IF.RDATA),
           .pc_axi_rresp (IF.RRESP ),
           .pc_axi_ruser(IF.RUSER ),
           .pc_axi_rvalid(IF.rvalid_internal),
           .pc_axi_rready(IF.rready_internal)
      );
    end  
  endgenerate
`endif
  //synthesis translate_off
  initial begin
    `ifdef XILINX_SIMULATOR 
      if(C_AXI_WID_WIDTH >=16) begin
       $display("INFO: ID width is %0d bigger than 16, AXI protocol Checker will not be instantiated in this case ",C_AXI_WID_WIDTH);
      end
    `endif
    $display("XilinxAXIVIP: Found at Path: %m");
  end

  //set IF mode to be in the correct mode according to C_AXI_INTERFACE_MODE,Default is monitor mode  
  generate
    initial begin
      if(C_AXI_INTERFACE_MODE ==0) begin
        IF.set_intf_master;
      end else if(C_AXI_INTERFACE_MODE ==2) begin
        IF.set_intf_slave;
      end else if(C_AXI_INTERFACE_MODE ==1) begin
        $display("This AXI VIP is in passthrough mode");
      end else begin
        $fatal(0,"This AXI VIP's mode is out of range");
      end
    end  
  endgenerate

  /*
   Function: set_passthrough_mode
   Sets AXI VIP passthrough into run time passthrough mode
  */
  function void set_passthrough_mode();
    if (C_AXI_INTERFACE_MODE == 1) begin
      runtime_master = 0;
      runtime_slave = 0;
      IF.set_intf_monitor();
    end else begin
      $fatal(0,"XilinxAXIVIP: VIP was not initially configured as Pass-through. Cannot change mode.");
    end
  endfunction: set_passthrough_mode

  /*
   Function: set_master_mode
   Sets AXI VIP passthrough into run time master mode
  */
  function void set_master_mode();
    if (C_AXI_INTERFACE_MODE == 1) begin
      runtime_master = 1;
      runtime_slave = 0;
      IF.set_intf_master();
    end else begin
      $fatal(0,"XilinxAXIVIP: VIP was not initially configured as Pass-through. Cannot change mode.");
    end
  endfunction : set_master_mode

  /*
   Function: set_slave_mode
   Sets AXI VIP passthrough into run time slave mode
  */
  function void set_slave_mode();
    if (C_AXI_INTERFACE_MODE == 1) begin
      runtime_master = 0;
      runtime_slave = 1;
      IF.set_intf_slave();
    end else begin
      $fatal(0,"XilinxAXIVIP: VIP was not initially configured as Pass-through. Cannot change mode.");
    end
  endfunction : set_slave_mode

  /*
  Function: set_xilinx_slave_ready_check
  Sets xilinx_slave_ready_check_enable of IF to be 1
  */
  function void set_xilinx_slave_ready_check();
    IF.xilinx_slave_ready_check_enable = 1;
  endfunction

  /*
   Function: clr_xilinx_slave_ready_check
   Sets xilinx_slave_ready_check_enable of IF to be 0
  */
  function void clr_xilinx_slave_ready_check();
    IF.xilinx_slave_ready_check_enable = 0;
  endfunction

 `ifndef XILINX_SIMULATOR
  /*
   Function: set_max_aw_wait_cycles (not available in VIVADO Simulator)
   Sets max_aw_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_aw_wait_cycles(input integer unsigned new_num);
    IF.PC.max_aw_wait_cycles = new_num;
  endfunction : set_max_aw_wait_cycles

  /*
   Function: set_max_ar_wait_cycles (not available in VIVADO Simulator)
   Sets max_ar_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_ar_wait_cycles(input integer unsigned new_num);
    IF.PC.max_ar_wait_cycles = new_num;
  endfunction : set_max_ar_wait_cycles

  /*
   Function: set_max_r_wait_cycles (not available in VIVADO Simulator)
   Sets max_r_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_r_wait_cycles(input integer unsigned new_num);
    IF.PC.max_r_wait_cycles = new_num;
  endfunction : set_max_r_wait_cycles

  /*
   Function: set_max_b_wait_cycles (not available in VIVADO Simulator)
   Sets max_b_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_b_wait_cycles(input integer unsigned new_num);
    IF.PC.max_b_wait_cycles = new_num;
  endfunction : set_max_b_wait_cycles

  /*
   Function: set_max_w_wait_cycles (not available in VIVADO Simulator)
   Sets max_w_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_w_wait_cycles(input integer unsigned new_num);
    IF.PC.max_w_wait_cycles = new_num;
  endfunction : set_max_w_wait_cycles

  /*
   Function: set_max_wlast_wait_cycles (not available in VIVADO Simulator)
   Sets max_wlast_to_awvalid_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_wlast_wait_cycles(input integer unsigned new_num);
    IF.PC.max_wlast_to_awvalid_wait_cycles = new_num;
  endfunction : set_max_wlast_wait_cycles

  /*
   Function: set_max_rtransfer_wait_cycles (not available in VIVADO Simulator)
   Sets max_rtransfer_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_rtransfers_wait_cycles(input integer unsigned new_num);
    IF.PC.max_rtransfers_wait_cycles = new_num;
  endfunction : set_max_rtransfers_wait_cycles

  /*
   Function: set_max_wtransfer_wait_cycles (not available in VIVADO Simulator)
   Sets max_wtransfer_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_wtransfers_wait_cycles(input integer unsigned new_num);
    IF.PC.max_wtransfers_wait_cycles = new_num;
  endfunction : set_max_wtransfers_wait_cycles

  /*
   Function: set_max_wlcmd_wait_cycles (not available in VIVADO Simulator)
   Sets max_wlcmd_wait_cycles of PC(ARM Protocol Checker) 
  */
  function void set_max_wlcmd_wait_cycles(input integer unsigned new_num);
    IF.PC.max_wlcmd_wait_cycles = new_num;
  endfunction : set_max_wlcmd_wait_cycles

  /*
   Function: get_max_aw_wait_cycles (not available in VIVADO Simulator)
   Returns max_aw_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_aw_wait_cycles();
    return(IF.PC.max_aw_wait_cycles);
  endfunction : get_max_aw_wait_cycles

  /*
   Function: get_max_ar_wait_cycles (not available in VIVADO Simulator)
   Returns max_ar_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_ar_wait_cycles();
    return(IF.PC.max_ar_wait_cycles);
  endfunction : get_max_ar_wait_cycles

  /*
   Function: get_max_r_wait_cycles (not available in VIVADO Simulator)
   Returns max_r_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_r_wait_cycles();
    return(IF.PC.max_r_wait_cycles);
  endfunction : get_max_r_wait_cycles

  /*
   Function: get_max_b_wait_cycles (not available in VIVADO Simulator)
   Returns max_b_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_b_wait_cycles();
    return(IF.PC.max_b_wait_cycles);
  endfunction : get_max_b_wait_cycles

  /*
   Function: get_max_w_wait_cycles (not available in VIVADO Simulator)
   Returns max_w_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_w_wait_cycles();
    return(IF.PC.max_w_wait_cycles);
  endfunction :get_max_w_wait_cycles

  /*
   Function: get_max_wlast_wait_cycles (not available in VIVADO Simulator)
   Returns max_wlast_to_awvalid_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_wlast_wait_cycles();
    return(IF.PC.max_wlast_to_awvalid_wait_cycles);
  endfunction :get_max_wlast_wait_cycles

  /*
   Function: get_max_rtransfer_wait_cycles (not available in VIVADO Simulator)
   Returns max_rtransfer_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_rtransfers_wait_cycles();
    return(IF.PC.max_rtransfers_wait_cycles);
  endfunction :get_max_rtransfers_wait_cycles

  /*
   Function: get_max_wtransfer_wait_cycles (not available in VIVADO Simulator)
   Returns max_wtransfer_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_wtransfers_wait_cycles();
    return(IF.PC.max_wtransfers_wait_cycles);
  endfunction :get_max_wtransfers_wait_cycles

  /*
   Function: get_max_wlcmd_wait_cycles (not available in VIVADO Simulator)
   Returns max_wlcmd_wait_cycles of PC(ARM Protocol Checker) 
  */
  function integer unsigned get_max_wlcmd_wait_cycles();
    return(IF.PC.max_wlcmd_wait_cycles);
  endfunction :get_max_wlcmd_wait_cycles

  /*
   Function:  set_fatal_to_warnings (not available in VIVADO Simulator)
   Sets fatal_to_warnings of PC(ARM Protocol Checker) to be 1
  */
  function void set_fatal_to_warnings();
    IF.PC.fatal_to_warnings = 1;
  endfunction : set_fatal_to_warnings

  /*
   Function:   clr_fatal_to_warnings (not available in VIVADO Simulator)
   Sets fatal_to_warnings of PC(ARM Protocol Checker) to be 0
  */
  function void clr_fatal_to_warnings();
    IF.PC.fatal_to_warnings = 0;
  endfunction : clr_fatal_to_warnings
`endif
  //synthesis translate_on

endmodule // axi_vip_v1_0_1_top


