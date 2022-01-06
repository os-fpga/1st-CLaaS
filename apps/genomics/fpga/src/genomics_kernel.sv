
module genomics_kernel #(
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

// Combinational only. Connect output backpressure directly to inputs.
assign in_ready = out_ready;
assign out_avail = in_avail;

genvar i;
generate
 for (i = 0; i < C_DATA_WIDTH / 32; i++) begin
   assign out_data[i*32 +: 32] = in_data[i*32 +: 32] + 1;
 end
endgenerate

endmodule