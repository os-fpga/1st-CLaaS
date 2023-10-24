\m4_TLV_version 1d --fmtFlatSignals --bestsv --noline: tl-x.org
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


m4+definitions(['
// --------------------------------------------------------------------
//
// A library file for developing FPGA kernels for use with 1st CLaaS
// (https://github.com/stevehoover/1st-CLaaS)
//
// --------------------------------------------------------------------

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
      

\SV
m4_makerchip_module_with_random_kernel_tb(calculator, ['assign passed = cyc_cnt > 20;']) // Provide the name the top module for 1st CLaaS in $3 param
m4+definitions([''])  // A hack to reset line alignment to address the fact that the above macro is multi-line. 
\TLV
   
   m4+tlv_wrapper(|in, @0, |out, @0, /trans)
   |in
      @0
         $data[31:0] = >>1$output;
      @1
         // Calculator logic
         
         
         // Extract input fields from input data
         $val1[31:0] = >>1$output;
         $val2[31:0] = /trans$data[31:0];
         $op[2:0] = /trans$data[34:32];

         //counter
         $counter = $reset?0:(>>1$counter+1);
         $valid = $reset || $counter;
         
      ?$valid
         @1
            $sum[31:0] = $val1[31:0] + $val2[31:0];
            $diff[31:0] = $val1[31:0] - $val2[31:0];
            $mult[31:0] = $val1[31:0] * $val2[31:0];
            $quot[31:0] = $val1[31:0] / $val2[31:0];
             //@2   
            $mem[31:0] = 
               $reset ? 0:
               ($op[2:0]==3'b101)
                  ? >>1$mem[31:0] : >>1$output;
            
            
            $output[31:0] = 
               $reset ? 0:
               ($op[2:0]==3'b000)
                  ? $sum[31:0] :
               ($op[2:0]==3'b001)
                  ? $diff[31:0] :
               ($op[2:0]==3'b010)
                  ? $mult[31:0] :
               ($op[2:0]==3'b011)
                  ? $quot[31:0] :
               ($op[2:0]==3'b100)
                  ? >>1$mem[31:0] : $val1[31:0];
            
            
   |out
      @0
         // Hook up inputs to outputs to implement a no-op kernel.
         // Delete this to add your kernel.
         $ANY = /top|in<>0$ANY;
         
         $ready = *out_ready;
         *out_avail = $avail;
         *out_data = $data;
         //`BOGUS_USE($op $rand $ready)
         `BOGUS_USE($ready)
         
         // Extract output data to the output field
         /trans@0$data = |in@1$output;
   
\SV
   endmodule


