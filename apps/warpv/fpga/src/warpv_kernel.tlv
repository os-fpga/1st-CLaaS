\m4_TLV_version 1d --fmtFlatSignals --bestsv --noline: tl-x.org
\SV

// Config:
m4_define(['M4_XILINX'], 0)

// Libraries
m4_include_lib(['./kernel_module.tlvlib'])
m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/fundamentals_lib.tlv'])
m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/pipeflow_lib.tlv'])
m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/arrays.tlv'])
m4_ifelse(M4_XILINX, 0,,
  ['m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/xilinx_macros.tlv'])']
)

// TODO: Structure this for Makerchip editing, (like Mandelbrot).



// Chunk types:
m4_define(['M4_IMEM_WRITE_TYPE'], 4'h1)  // {..., data, addr(instr-granular), type}
m4_define(['M4_IMEM_READ_TYPE'],  4'h2)  // {..., addr, type}
m4_define(['M4_HALT_TYPE'],       4'h3)  // {..., type}
m4_define(['M4_RUN_TYPE'],        4'h4)  // {..., type}

m4_define_hier(['M4_INSTR'], 32)  // TODO: Will be defined by WARP-V.

\SV
   m4_kernel_module(warpv_kernel)
\TLV
   // Instantiate TLV kernel shell.
   m4+flow_shell(|kernel0, @1, |kernel2, @1, /trans)
   
   // Kernel is a 2-stage backpressured pipeline.
   m4+bp_pipeline(/top, |kernel, 0, 2, /trans)
   
   m4_define_hier(['M4_IMEM'], 1024)
   
   // Decode $in_data.
   |kernel0
      @1
         // Minimal decode logic.
         ?$accepted
            /trans
               $chunk_type[3:0] = $in_data[3:0];
               $addr[M4_IMEM_INDEX_RANGE] = $in_data[(1 * M4_INSTR_CNT) + M4_IMEM_INDEX_MAX:(1 * M4_INSTR_CNT)];
               $instr[M4_INSTR_RANGE] = $in_data[(3 * M4_INSTR_CNT) - 1: 2 * M4_INSTR_CNT];
               $wr = $chunk_type == M4_IMEM_WRITE_TYPE;
               $rd = $chunk_type == M4_IMEM_READ_TYPE;
   
   // Instruction memory.
   m4_ifelse_block(M4_XILINX, 0, ['
   m4+array1r1w(/top, /imem, |kernel1, @1, $wr, $addr, $instr[M4_INSTR_RANGE], |kernel1, @1, $rd, $addr, $rd_instr[M4_INSTR_RANGE], /trans)
   '], ['
   // TODO: I'm not sure about the timing. I'm assuming inputs are a cycle before outputs.
   $imem_wr_en                     = |kernel0>>1$accepted &&
                                     |kernel0/trans>>1$wr;
   $imem_wr_data[M4_INSTR_RANGE]   = |kernel0/trans>>1$instr;
   $imem_addr[M4_IMEM_INDEX_RANGE] = |kernel0/trans>>1$addr;
   $imem_rd_en                     = |kernel0>>1$accepted &&
                                     |kernel0/trans>>1$rd;
   m4+bram_sdp(M4_INSTR_CNT, $imem_wr_data, $imem_addr, $imem_wr_en, $imem_rd_data[M4_INSTR_RANGE], $imem_rd_en, $imem_addr)
   // Recirculate rd_data (as the bp_pipeline would naturally have done the cycle before).
   $imem_rd_data_held[M4_INSTR_RANGE] = >>1$imem_rd_en ? $imem_rd_data : >>1$imem_rd_data_held;
   |kernel1
      @1
         ?$accepted
            /trans
               $rd_instr[M4_INSTR_RANGE] = /top<<1$imem_rd_data_held;
   '])
   
   // Encode $out_data.
   |kernel2
      @1
         ?$accepted
            /trans
               $out_data[511:0] = 
                    ($chunk_type == M4_IMEM_WRITE_TYPE) ? {m4_eval(32 * (16 - 3))'b0, $instr,    m4_eval(32 - M4_IMEM_INDEX_CNT)'b0, $addr, 28'b0, $chunk_type} :
                    ($chunk_type == M4_IMEM_READ_TYPE)  ? {m4_eval(32 * (16 - 3))'b0, $rd_instr, m4_eval(32 - M4_IMEM_INDEX_CNT)'b0, $addr, 28'b0, $chunk_type} :
                    ($chunk_type == M4_HALT_TYPE)       ? {m4_eval(32 * (16 - 1))'b0, 28'b0, $chunk_type} :
                    ($chunk_type == M4_RUN_TYPE)        ? {m4_eval(32 * (16 - 1))'b0, 28'b0, $chunk_type} :
                                                          512'b0;
\SV
   endmodule
