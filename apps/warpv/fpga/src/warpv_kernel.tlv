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

m4+definitions(['

   // =========
   // Libraries
   // =========
   
   // Config (affecting library includes):
   m4_define(['M4_XILINX'], 0)
   
   m4_include_lib(['./kernel_module.tlvlib'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/fundamentals_lib.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/pipeflow_lib.tlv'])
   //m4_include_lib(['./pipeflow.tlvlib'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/arrays.tlv'])
   m4_ifelse(M4_XILINX, 0,,['
     m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/xilinx_macros.tlv'])
   '])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v/master/warp-v.tlv'])
   //m4_include_lib(['./warp-v.tlvlib'])
   
   
   // TODO: Structure this for Makerchip editing, (like Mandelbrot).
   
   
   // ================
   // Customize WARP-V
   // ================
   
   // CSRs for 1st CLaaS.
   // A quick-n-dirty mechanism for WARP-V to return a single value to client. Every program must return exactly one value, or
   // application will hang.
   // (Longer-term, connect web client as an end-point on the NoC.)
   // TODO: Consult RISC-V spec to allocate CSR address space.
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
   
   
   // ===========
   // IMem Hookup
   // ===========
'])
\TLV imem()
   // WARP-V configured to use this for IMem, though
   // IMem and read defined elsewhere. This just hooks up $raw.
   |fetch
      /instr
         @m4_eval(M4_FETCH_STAGE + 1)
            ?$fetch
               // IMem
               $raw[M4_INSTR_RANGE] = /top|imem>>m4_align(2, M4_FETCH_STAGE + 1)$rd_instr;

\SV
   // =============
   // Kernel Module
   // =============
   
   m4_kernel_module(warpv_kernel)
   
\TLV

   // ========
   // The Flow
   // ========
   
   // Instantiate TLV kernel shell.
   m4+flow_shell(|kernel_in0, @1, |kernel3, @1, /trans)
   
   m4+bp_pipeline(/top, |kernel_in, 0, 1, /trans)
   m4+stall_flow(/top, |kernel_in1, @1, |kernel1, @1, /trans)
   m4+bp_pipeline(/top, |kernel, 1, 3, /trans)


   // ===========
   // WARP-V Core
   // ===========
   
   // Reset CPU except when the kernel pipeline is stalled by M4_RUN_TYPE (with a little delay). CPU will be allowed to
   // run for a few cycles after the CSR write.
   m4_define(['M4_KERNEL_PC_ALIGN'], m4_align(3, M4_NEXT_PC_STAGE - 1))  // |kernel_in1@1 trigger CPU.
   m4_define(['M4_EXE_KERNEL_ALIGN'], m4_align(M4_EXECUTE_STAGE + 1, 1))     // |kernel_in1@1 stop stalling.
   m4_define(['m4_soft_reset'], ['/top|kernel_in1>>M4_KERNEL_PC_ALIGN$ResetPc'])
   // Block CPU execution if kernel pipeline is blocked.
   m4_define(['m4_cpu_blocked'], m4_dquote(m4_cpu_blocked)[' || /top|kernel1>>m4_align(M4_REG_RD_STAGE, 1)$blocked'])
   
   // WARP-V Core
   m4+warpv()

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
                 /top|fetch/instr>>M4_EXE_KERNEL_ALIGN$commit &&
                 /top|fetch/instr>>M4_EXE_KERNEL_ALIGN$is_csr_write &&
                 /top|fetch/instr>>M4_EXE_KERNEL_ALIGN$is_csr_claasrsp;
         // 1'b0 for M4_RUN_TYPE after $start through $stop.
         $ResetPc <= $reset ? 1'b1 :
                     $start ? 1'b0 :
                     $stop  ? 1'b1 :
                              $RETAIN;
         // 1'b1 for an M4_RUN_TYPE after $start through $accepted.
         $Held <= $reset ? 1'b0 :
                  ($Held || $start) ? ! $accepted :
                           $RETAIN;
         $reset_exe = /top|fetch/instr>>M4_EXE_KERNEL_ALIGN$reset;
         $stalled = $start || ! $ResetPc || ! $reset_exe;
         /trans
            // Grab CLAASRSP CSR when written (cycle after write) and hold.
            $rsp_value[31:0] =
                 |kernel_in1$reset           ? 32'b0 :
                 |kernel_in1$stop ? /top|fetch/instr>>m4_eval(M4_EXE_KERNEL_ALIGN - 1)$csr_claasrsp :
                                    $RETAIN;


   // =================
   // BP_Pipeline Logic
   // =================
   
   // Decode $in_data.
   |kernel_in0
      @1
         // Minimal decode logic.
         ?$accepted
            /trans
               $chunk_type[3:0] = $in_data[3:0];
               $addr[M4_IMEM_INDEX_RANGE] = $in_data[(1 * M4_INSTR_CNT) + M4_IMEM_INDEX_MAX:(1 * M4_INSTR_CNT)];
               $instr[M4_INSTR_RANGE] = $in_data[(3 * M4_INSTR_CNT) - 1: 2 * M4_INSTR_CNT];
   
   |imem
      // Mux from |kernel_in1@1 and |fetch@M4_FETCH_STAGE. TODO: No exclusivity check.
      @1
         $accepted = /top|kernel_in1<>0$accepted || /top|fetch/instr>>M4_IMEM_FETCH_ALIGN$fetch;
         ?$accepted
            $addr[M4_IMEM_INDEX_RANGE] = /top|kernel_in1<>0$accepted ? /top|kernel_in1/trans<>0$addr :
                                                                    /top|fetch/instr>>M4_IMEM_FETCH_ALIGN$Pc[M4_IMEM_INDEX_MAX + M4_PC_MIN:M4_PC_MIN];
            $instr[M4_INSTR_RANGE] = /top|kernel_in1/trans<>0$instr;  // (no write for CPU pipeline, so $instr is DONT_CARE)
         $wr_en =  (/top|kernel_in1/trans<>0$chunk_type == M4_IMEM_WRITE_TYPE) && /top|kernel_in1<>0$accepted;
         $rd_en = ((/top|kernel_in1/trans<>0$chunk_type == M4_IMEM_READ_TYPE ) && /top|kernel_in1<>0$accepted) ||
                  /top|fetch/instr>>M4_IMEM_FETCH_ALIGN$fetch;
         
   m4_ifelse_block(M4_XILINX, 0, ['
   m4+array1r1w(/top, /imem_entry, |imem, @1, $wr_en, $addr, $instr[M4_INSTR_RANGE], |imem, @1, $rd_en, $addr, $rd_instr[M4_INSTR_RANGE])
   '], ['
   |imem
      @1
         // TODO: I'm not sure about the timing. I'm assuming inputs are a cycle before outputs.
         m4+bram_sdp(M4_INSTR_CNT, $instr, $addr, $wr_en, $rd_instr[M4_INSTR_RANGE], $accepted && $rd_en, $addr)
   '])
   // Recirculate rd_data (as the bp_pipeline would naturally have done the cycle before).
   |kernel2
      @1
         // Recirculate rd_data (as the bp_pipeline would naturally have done the cycle before).
         $rd_instr_held[M4_INSTR_RANGE] = /top|imem>>1$rd_en ? /top|imem>>1$rd_instr : $RETAIN;
         ?$accepted
            /trans
               //$rd_instr[M4_INSTR_RANGE] = /top<<1$imem_rd_data_held;
               $rd_instr[M4_INSTR_RANGE] = |kernel2$rd_instr_held;
   
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
   

\SV
   endmodule
