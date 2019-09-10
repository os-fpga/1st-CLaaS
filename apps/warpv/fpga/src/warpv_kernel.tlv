\m4_TLV_version 1d --fmtFlatSignals --bestsv --noline: tl-x.org
\SV
   m4_include_lib(['./kernel_module.tlvlib'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/fundamentals_lib.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/pipeflow_lib.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/arrays.tlv'])

// TODO: Structure this for Makerchip editing, (like Mandelbrot).


// Chunk types:
m4_define(['M4_IMEM_WRITE_TYPE'], 4'h1)  // {..., data, addr(instr-granular), type}
m4_define(['M4_IMEM_READ_TYPE'],  4'h2)  // {..., addr, type}
m4_define(['M4_HALT_TYPE'],       4'h3)  // {..., type}
m4_define(['M4_RUN_TYPE'],        4'h4)  // {..., type}

\SV
   m4_kernel_module(warpv_kernel)
\TLV
   // Instantiate TLV kernel shell.
   m4+flow_shell(|kernel0, @1, |kernel2, @1, /trans)
   
   // Kernel is a 2-stage backpressured pipeline.
   m4+bp_pipeline(/top, |kernel, 0, 2, /trans)
   
   m4_define_hier(['M4_INSTR'], 16)
   
   // Decode $in_data.
   |kernel0
      @1
         // Minimal decode logic.
         ?$accepted
            /trans
               $chunk_type[3:0] = $in_data[3:0];
               $addr[M4_INSTR_INDEX_MAX:0] = $in_data[(1 * 32) + M4_INSTR_INDEX_MAX:(1 * 32)];
               $instr[31:0] = $in_data[(2 * 32) + 31: 2 * 32];
               $wr = $chunk_type == M4_IMEM_WRITE_TYPE;
               $rd = $chunk_type == M4_IMEM_READ_TYPE;
   
   // Instruction memory.
   m4+array1r1w(/top, /instr, |kernel1, @1, $wr, $addr, $instr[31:0], |kernel1, @1, $rd, $addr, $rd_instr[31:0], /trans)
   
   // Encode $out_data.
   |kernel2
      @1
         ?$accepted
            /trans
               $out_data[511:0] = 
                    ($chunk_type == M4_IMEM_WRITE_TYPE) ? {m4_eval(32 * (16 - 3))'b0, $instr, 28'b0, $addr, 28'b0, $chunk_type} :
                    ($chunk_type == M4_IMEM_READ_TYPE)  ? {m4_eval(32 * (16 - 3))'b0, $rd_instr, 28'b0, $addr, 28'b0, $chunk_type} :
                    ($chunk_type == M4_HALT_TYPE)       ? {m4_eval(32 * (16 - 1))'b0, 28'b0, $chunk_type} :
                    ($chunk_type == M4_RUN_TYPE)        ? {m4_eval(32 * (16 - 1))'b0, 28'b0, $chunk_type} :
                                                          512'b0;
\SV
   endmodule
