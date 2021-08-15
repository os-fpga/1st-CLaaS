//\m4_TLV_version 1d --fmtFlatSignals --debugSigs --bestsv --noline: tl-x.org
\m4_TLV_version 1d --noline --debugSigs: tl-x.org
\SV
// -----------------------------------------------------------------------------
// Copyright (c) 2019, Steven F. Hoover
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
//     * Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * The name Steven F. Hoover
//       may not be used to endorse or promote products derived from this software
//       without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

// For Xilinx: \m4_TLV_version 1d --fmtFlatSignals --bestsv --noline: tl-x.org

// Overview:
// ========
//
// This kernel, in it's current form, instantiates a single WARP-V RISC-V CPU. It accepts input traffic
// (via 1st CLaaS WebSocket) to:
//   o load instruction memory (IMem)
//   o reset the CPU (but not the data memory (DMem)) and run the program, which must produce a result value via CSR write
//
// API:
//
// The following chunks are supported:
//   o IMEM_WRITE: {..., data, addr, type} =>    // addr is instruction-granular
//                 {..., data, addr, type}
//        Write a single IMem instruction word.
//   o IMEM_READ:  {...,       addr, type} =>
//                 {..., data, addr, type}
//        Read a single IMem instruction word.
//   o RUN:        {...,            type} =>
//                 {..., CSR_value, type}
//        Reset the CPU and execute the program from PC=0 until the CLAASRSP CSR is written,
//        returning the value written to the CSR in a single chunk.
//
// Microarchitecture:
// =================
//
// This kernel utilizes the tlv_flow_lib to create a short back-pressured pipeline from kernel input to
// kernel output. IMEM_READ/WRITE transactions traverse this as follows.
// Stages:
//   |kernel_in0@1: kernel input and transit
//   |kernel_in1@1 / |kernel1@1 (same unless RUN): mux PC and kernel input addr, and rd/wr addr decode
//   |kernel2@1: array data out and transit
//   |kernel3@1: transit and encode kernel output data
// RUN transactions run the program as an m4+wait_for in |kernel1@1.
// and the CSR write injects into the kernel output.
// Kernel interaction with IMem is a backpressured pipeline.
/* verilator lint_off UNOPTFLAT */
m4+definitions(['
// --------------------------------------------------------------------
//
// A library file for developing FPGA kernels for use with 1st CLaaS
// (https://github.com/stevehoover/1st-CLaaS)
//
// --------------------------------------------------------------------
// Macros used by WARP-V
   m4_def(ISA, RISCV)
   m4_def(EXT_E, 0)
   m4_def(EXT_M, 0)
   m4_def(EXT_F, 0)
   m4_def(EXT_B, 0)
   m4_def(NUM_CORES, 5)
   m4_def(NUM_VCS, 2)
   m4_def(NUM_PRIOS, 2)
   m4_def(MAX_PACKET_SIZE, 8)
   m4_def(soft_reset, 1'b1)
   m4_def(cpu_blocked, 1'b0)
   m4_def(BRANCH_PRED, two_bit)
   m4_def(EXTRA_REPLAY_BUBBLE, 0)
   m4_def(EXTRA_PRED_TAKEN_BUBBLE, 0)
   m4_def(EXTRA_JUMP_BUBBLE, 0)
   m4_def(EXTRA_BRANCH_BUBBLE, 0)
   m4_def(EXTRA_INDIRECT_JUMP_BUBBLE, 0)
   m4_def(EXTRA_NON_PIPELINED_BUBBLE, 1)
   m4_def(EXTRA_TRAP_BUBBLE, 1)
   m4_def(NEXT_PC_STAGE, 0)
   m4_def(FETCH_STAGE, 0)
   m4_def(DECODE_STAGE, 1)
   m4_def(BRANCH_PRED_STAGE, 1)
   m4_def(REG_RD_STAGE, 1)
   m4_def(EXECUTE_STAGE, 2)
   m4_def(RESULT_STAGE, 2)
   m4_def(REG_WR_STAGE, 3)
   m4_def(MEM_WR_STAGE, 3)
   m4_def(LD_RETURN_ALIGN, 4)

   m4_define(['M4_XILINX'], 0)

   m4_include_url(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/7a2b37cc0ccd06bc66984c37e17ceb970fd6f339/pipeflow_lib.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/5a8c0387be80b2deccfcd1506299b36049e0663e/arrays.tlv'])
   m4_ifelse(M4_XILINX, 0,,['
     m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/5a8c0387be80b2deccfcd1506299b36049e0663e/xilinx_macros.tlv'])
   '])
   m4_include_lib(['https://raw.githubusercontent.com/vineetjain07/warp-v/multicore/warp-v.tlv'])

   m4_define_csr(['claasrsp'], 12'hC00, ['32, VAL, 0'], ['32'b0'], ['{32{1'b1}}'], 0)

   m4_define(['M4_IMEM_MACRO_NAME'], ['imem'])


   // =========
   // Constants
   // =========

   m4_define(['M4_IMEM_WRITE_TYPE'], 4'h1)
   m4_define(['M4_IMEM_READ_TYPE'],  4'h2)
   m4_define(['M4_RUN_TYPE'],        4'h4)

   m4_define(M4_IMEM_FETCH_ALIGN, m4_eval(M4_FETCH_STAGE - 1))

   m4_define_hier(M4_IMEM_ENTRY, 1024)

   m4_define_hier(['M4_IMEM'], 1024)
// 1st CLaaS imported from https://github.com/stevehoover/makerchip_examples/blob/master/1st-claas_template_with_macros.tlv

// The 1st CLaaS kernel module definition.
// This must be defined prior to any \TLV region, so \TLV macro syntax cannot be used - just raw m4.
// $1: kernel name

m4_define(['m4_kernel_module_def'], ['
   module $1['']_kernel #(
       parameter integer C_DATA_WIDTH = 512 // Data width of both input and output data
   )
   (
       input wire                       clk,
       input wire                       reset,

       output wire                      in_ready,
       input wire                       in_avail,
       input wire  [C_DATA_WIDTH-1:0]   in_data,
       
       input wire                       out_ready,
       output wire                      out_avail,
       output wire [C_DATA_WIDTH-1:0]   out_data
   );
'])

// Makerchip module definition containing a testbench and instantiation of the custom kernel.
// This must be defined prior to any \TLV region, so \TLV macro syntax cannot be used - just raw m4.
// $1: kernel name
// $2: (opt) passed statement
// $3: (opt) failed statement

m4_define(['m4_makerchip_module_with_random_kernel_tb'], [' m4_ifelse_block(M4_MAKERCHIP, 1, ['
   // Makerchip interfaces with this module, coded in SV.
   m4_makerchip_module
      // Instantiate a 1st CLaaS kernel with random inputs.
      logic [511:0] in_data = {2{RW_rand_vect[255:0]}};
      logic in_avail = ^ RW_rand_vect[7:0];
      logic out_ready = ^ RW_rand_vect[15:8];

      $1['']_kernel kernel (
            .*,  // clk, reset, and signals above
            .in_ready(),  // Ignore blocking (inputs are random anyway).
            .out_avail(),  // Outputs dangle.
            .out_data()    //  "
         );
      $2
      $3
   endmodule
m4_kernel_module_def($1)
'], ['
m4_kernel_module_def($1)
'])
'])

'])

// (Finally, now in TLV-land)

// The hookup of kernel module SV interface signals to TLV signals following flow library conventions.
\TLV tlv_wrapper(|_in, @_in, |_out, @_out, /_trans)
   m4_pushdef(['m4_trans_ind'], m4_ifelse(/_trans, [''], [''], ['   ']))
   // The input interface hookup.
   |_in
      @_in
         $reset = *reset;
         `BOGUS_USE($reset)
         $avail = *in_avail;
         *in_ready = ! $blocked;
         /trans
      m4_trans_ind   $data[C_DATA_WIDTH-1:0] = *in_data;
   // The output interface hookup.
   |_out
      @_out
         $blocked = ! *out_ready;
         *out_avail = $avail;
         /trans
      m4_trans_ind   *out_data = $data;
      
\TLV array2r2w(/_top, /_entries, /_wr_scope, |_wr, @_wr, $_wr, $_wr_addr, $_wr_data, /_read_scope, |_rd, @_rd, $_rd, $_rd_addr, $_rd_data, /_trans)
   m4_define(['m4_rd_data_sig'], m4_ifelse($_rd_data, , $_rw_data, $_rd_data))
   // Write Pipeline
   // The array entries hierarchy (needs a definition to define range, and currently, /_trans declaration required before reference).
   /m4_echo(M4_['']m4_to_upper(m4_strip_prefix(/_entries))_HIER)
      /_trans
         
   // Write transaction to cache
   // (TLV assignment syntax prohibits assignment outside of it's own scope, but \SV_plus does not.)
   /m4_echo(M4_['']m4_to_upper(m4_strip_prefix(/_wr_scope))_HIER)
      \SV_plus
         always_comb
            if (/top/_wr_scope|_wr/_trans>>m4_stage_eval(@_wr - 0)$_wr && /top/_wr_scope|_wr>>m4_stage_eval(@_wr - 0)$accepted)
               /top/_entries[/top/_wr_scope|_wr/_trans>>m4_stage_eval(@_wr - 0)$_wr_addr]/_trans$['']$_wr_data = /top/_wr_scope|_wr/_trans>>m4_stage_eval(@_wr - 0)$_wr_data;
   
   // Read Pipeline
   /m4_echo(M4_['']m4_to_upper(m4_strip_prefix(/_read_scope))_HIER)
      |_rd
         @_rd
            // Read transaction from cache.
            $m4_strip_prefix(/_entries)_rd_en = /_trans$_rd && $accepted;
            ?$m4_strip_prefix(/_entries)_rd_en
               /_trans
               m4_ifelse(/_trans, [''], [''], ['   '])['']m4_rd_data_sig = /_top/_entries[$_rd_addr]/_trans>>m4_stage_eval(1 - @_rd)$_wr_data;
            
            
\TLV imem()
   // WARP-V configured to use this for IMem, though
   // IMem and read defined elsewhere. This just hooks up $raw.
   |fetch
      /instr
         @m4_eval(M4_FETCH_STAGE + 1)
            ?$fetch
               $raw[M4_INSTR_RANGE] = /top/core|imem>>m4_align(2, M4_FETCH_STAGE + 1)$rd_instr;
      
      
\SV
m4_makerchip_module_with_random_kernel_tb(manycore, ['assign passed = cyc_cnt > 20;']) // Provide the name the top module for 1st CLaaS in $3 param
m4+definitions([''])  // A hack to reset line alignment to address the fact that the above macro is multi-line. 
\TLV
   
   m4+tlv_wrapper(|kernel_in0, @1, |kernel3, @1, /trans)
   
   m4+bp_pipeline(/top, |kernel_in, 0, 1, /trans)
   m4+stall_flow(/top, |kernel_in1, @1, |kernel1, @1, /trans)
   m4+bp_pipeline(/top, |kernel, 1, 3, /trans)
   
   m4_define(['M4_KERNEL_PC_ALIGN'], m4_align(3, M4_NEXT_PC_STAGE - 1))  // |kernel_in1@1 trigger CPU.
   m4_define(['M4_EXE_KERNEL_ALIGN'], m4_align(M4_EXECUTE_STAGE + 1, 1))     // |kernel_in1@1 stop stalling.
   m4_define(['m4_soft_reset'], ['/top|kernel_in1>>M4_KERNEL_PC_ALIGN$ResetPc'])
   // Block CPU execution if kernel pipeline is blocked.
   m4_define(['m4_cpu_blocked'], m4_dquote(m4_cpu_blocked)[' || /top|kernel1>>m4_align(M4_REG_RD_STAGE, 1)$blocked'])
   
   /M4_CORE_HIER
      // TODO: Find a better place for this:
      // Block CPU |fetch pipeline if blocked.
      m4_define(['m4_cpu_blocked'], m4_cpu_blocked || /core|egress_in/instr<<M4_EXECUTE_STAGE$pkt_wr_blocked || /core|ingress_out<<M4_EXECUTE_STAGE$pktrd_blocked)
      m4+cpu(/core)
      m4+noc_cpu_buffers(/core, m4_eval(M4_MAX_PACKET_SIZE + 1))
      m4+noc_insertion_ring(/core, m4_eval(M4_MAX_PACKET_SIZE + 1))


   // ---------------------
   // Stall the BP Pipeline
   
   |kernel_in1
      @1
         // On M4_RUN_TYPE we:
         //   o begin stalling the back-pressured pipeline
         //   o releases CPU reset, starting the CPU from PC==0
         // We run until CSR CLAASRSP is written, then:
         //   o capture CSR CLAASRSP
         //   o begin resetting the CPU
         // Once the EXE stage is again reset, we release the stall.
         
         // One cycle pulse on start.
         $start = $avail && ! $Held && /trans$chunk_type == M4_RUN_TYPE;
         // Stop pulse when CSR is written while running.
         $stop = ! $ResetPc && ! $reset_exe &&
                 /top/core[0]|fetch/instr>>M4_EXE_KERNEL_ALIGN$commit &&
                 /top/core[0]|fetch/instr>>M4_EXE_KERNEL_ALIGN$is_csr_claasrsp;
         // 1'b0 for M4_RUN_TYPE after $start through $stop.
         $ResetPc <= $reset ? 1'b1 :
                     $start ? 1'b0 :
                     $stop  ? 1'b1 :
                              $RETAIN;
         // 1'b1 for an M4_RUN_TYPE after $start through $accepted.
         $Held <= $reset ? 1'b0 :
                  ($Held || $start) ? ! $accepted :
                           $RETAIN;
         $reset_exe = /top/core[0]|fetch/instr>>M4_EXE_KERNEL_ALIGN$reset;
         $stalled = $start || ! $ResetPc || ! $reset_exe;
         /trans
            // Grab CLAASRSP CSR when written (cycle after write) and hold.
            $rsp_value[31:0] =
                 |kernel_in1$reset           ? 32'b0 :
                 |kernel_in1$stop ? /top/core[0]|fetch/instr>>m4_eval(M4_EXE_KERNEL_ALIGN - 1)$csr_claasrsp :
                                    $RETAIN;

   |kernel_in0
      @1
         /trans
            $in_data[C_DATA_WIDTH-1:0] = $data[C_DATA_WIDTH-1:0];
   |kernel3
      @1
         /trans
            $data[511:0] =  /top|kernel2/trans<>0$out_data;
            `BOGUS_USE($dummy)

   // =================
   // BP_Pipeline Logic
   // =================
   
   // Decode $in_data.
   /* verilator lint_off SELRANGE */
   |kernel_in0
      @1
         // Minimal decode logic.
         ?$accepted
            /trans
               $chunk_type[3:0] = $in_data[3:0];
               $addr[M4_IMEM_INDEX_RANGE] = $in_data[(1 * M4_INSTR_CNT) + M4_IMEM_INDEX_MAX:(1 * M4_INSTR_CNT)];
               $instr[M4_INSTR_RANGE] = $in_data[(3 * M4_INSTR_CNT) - 1: 2 * M4_INSTR_CNT];
   
   /M4_CORE_HIER
      // Mux from |kernel_in1@1 and |fetch@M4_FETCH_STAGE. TODO: No exclusivity check.
      |imem
         @1
            $accepted = /top|kernel_in1<>0$accepted || /top/core|fetch/instr>>M4_IMEM_FETCH_ALIGN$fetch;
            ?$accepted
               $addr[M4_IMEM_INDEX_RANGE] = /top|kernel_in1<>0$accepted ? /top|kernel_in1/trans<>0$addr :
                                                                       /top/core|fetch/instr>>M4_IMEM_FETCH_ALIGN$Pc[M4_IMEM_INDEX_MAX + M4_PC_MIN:M4_PC_MIN];
               $instr[M4_INSTR_RANGE] = /top|kernel_in1/trans<>0$instr;  // (no write for CPU pipeline, so $instr is DONT_CARE)
            $wr_en =  (/top|kernel_in1/trans<>0$chunk_type == M4_IMEM_WRITE_TYPE) && /top|kernel_in1<>0$accepted;
            $rd_en = ((/top|kernel_in1/trans<>0$chunk_type == M4_IMEM_READ_TYPE ) && /top|kernel_in1<>0$accepted) ||
                     /top/core|fetch/instr>>M4_IMEM_FETCH_ALIGN$fetch;
         
   m4_ifelse_block(M4_XILINX, 0, ['
   m4+array2r2w(/top, /imem_entry, /core, |imem, @1, $wr_en, $addr, $instr[M4_INSTR_RANGE], /core, |imem, @1, $rd_en, $addr, $rd_instr[M4_INSTR_RANGE])
   '])
   // Recirculate rd_data (as the bp_pipeline would naturally have done the cycle before).
   |kernel2
      @1
         // Recirculate rd_data (as the bp_pipeline would naturally have done the cycle before).
         $rd_instr_held[M4_INSTR_RANGE] = /top/core[0]|imem>>1$rd_en ? /top/core[0]|imem>>1$rd_instr : $RETAIN;
         ?$accepted
            /trans
               $rd_instr[M4_INSTR_RANGE] = |kernel2$rd_instr_held;
               $dummy = 0;
   
   // Encode $out_data.
   |kernel2
      @1
         ?$accepted
            /trans
               $out_data[511:0] =
                    ($chunk_type == M4_IMEM_WRITE_TYPE) ? {m4_eval(32 * (16 - 3))'b0, $instr,    m4_eval(32 - M4_IMEM_INDEX_CNT)'b0, $addr, 28'b0, $chunk_type} :
                    ($chunk_type == M4_IMEM_READ_TYPE)  ? {m4_eval(32 * (16 - 3))'b0, $rd_instr, m4_eval(32 - M4_IMEM_INDEX_CNT)'b0, $addr, 28'b0, $chunk_type} :
                    ($chunk_type == M4_RUN_TYPE)?         {m4_eval(512-32-32)'b0, $rsp_value, 28'b0, $chunk_type} :
                                                             512'b0;
   /* verilator lint_on SELRANGE */
   /* verilator lint_on UNOPTFLAT */
   
\SV
   endmodule

