\m4_TLV_version 1d --fmtFlatSignals --bestsv --noline: tl-x.org

\SV
   m4_include_lib(['./matrix_mult_makerchip.tlvlib'])
   `define NUM_SIZE 3
   `define NUM_BUFFERS 2
   `define REG_FILE_SIZE 16
   `define REG_WIDTH 32
   `define NUM_ROWS 3
   `define NUM_COLS 3

module matrix_mult_kernel #(
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


\TLV
   |mult
      @0
         // Input connections
         $in_avail = *in_avail; 
         $in_data[511:0] = *in_data; 
         // UNUSED $out_ready = *out_ready;


   // Matrix mult definition in matrix_mult_makerchip.tlv
   m4+matrix_mult();
   
   |mult
      @3
         // Output connections
         *in_ready = $in_ready;
         *out_avail = $out_avail;
         *out_data = $out_data;

\SV
endmodule
