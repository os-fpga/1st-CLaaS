\m4_TLV_version 1d --fmtFlatSignals --bestsv --noline: tl-x.org
\SV

// TODO: Structure this for Makerchip editing, (like Mandelbrot).

module warpv_kernel #(
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
   // Combinational only. Connect output backpressure directly to inputs.
   *in_ready = *out_ready;
   *out_avail = *in_avail;
   
   /value[C_DATA_WIDTH/32-1:0]
      *out_data[value * 32 +: 32] = *in_data[value * 32 +: 32];

\SV
endmodule