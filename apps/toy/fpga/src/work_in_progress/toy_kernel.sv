
/* verilator lint_off WIDTH */
module toy_kernel #(
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

logic [7:0] debug_sigs;

// The low byte specifies how many chunks to generate from the input, where each chunk is decremented from the last.
logic [C_DATA_WIDTH-1:0] data, good_in_data, prev_out_data;
logic [15:0] data_cnt;

assign good_in_data = (in_ready && in_avail) ? in_data : {4{8'h01}};
assign in_ready = out_ready && (prev_out_data[7:0] == 8'h00);
assign out_avail = data[7:0] != 8'h00;

logic mismatch, sticky_mismatch;
assign mismatch = good_in_data != {good_in_data[511:8], 8'h01};
always_ff @(posedge clk) begin
    if (reset) sticky_mismatch <= 0;
    else if (mismatch) sticky_mismatch <= 1;
end
always_ff @(posedge clk) begin
    if (reset) data_cnt <= '0;
    else if (in_ready && in_avail) data_cnt <= data_cnt + 1;
end


assign data = (in_ready && in_avail) ? good_in_data : prev_out_data;
//assign data = (in_ready && in_avail) ? {good_in_data[511:8], 8'h01} : prev_out_data;

genvar i;
generate
 for (i = 0; i < C_DATA_WIDTH / 32; i++) begin
   assign out_data[i*32 +: 32] =
       !(out_ready && out_avail) ? {4{8'h0F}} :  // Dont-care output - use a specific recognizable pattern.
       (i == 2)                  ? {mismatch || sticky_mismatch, data_cnt[14:0], {2{debug_sigs}}} :   // Info for debug.
       //(i == 3)                  ? ctrl_xfer_size_in_bytes :
       //(i == 4)                  ? resp_xfer_size_in_bytes :
                                   data[i*32 +: 32] - 1;  // Valid output.
 end
endgenerate


always_ff @(posedge clk) begin
    if (reset) begin
        prev_out_data <= '0;
    end else if (out_ready && out_avail) begin
        // out_data accepted at output.
        prev_out_data <= out_data;
    end
end



// 2nd copy of logic.


// The low byte specifies how many chunks to generate from the input, where each chunk is decremented from the last.
logic [C_DATA_WIDTH-1:0] data2, prev_out_data2, out_data2;

assign data2 = (in_ready && in_avail) ? good_in_data : prev_out_data2;

generate
 for (i = 0; i < C_DATA_WIDTH / 32; i++) begin
   assign out_data2[i*32 +: 32] = data2[i*32 +: 32] - 1;
 end
endgenerate


always_ff @(posedge clk) begin
    if (reset) begin
        prev_out_data2 <= '0;
    end else if (out_ready && out_avail) begin
        // out_data accepted at output.
        prev_out_data2 <= out_data2;
    end
end


// Capture signals for debug.
always_ff @(posedge clk) begin
    if (reset) begin
       debug_sigs[3:0] <= {in_ready, in_avail, out_ready, out_avail};
    end
    debug_sigs[7:4] <= {in_ready, in_avail, out_ready, out_avail};
end

endmodule
