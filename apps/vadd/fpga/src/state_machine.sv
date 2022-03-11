`default_nettype none
`timescale 1 ns / 1 ps 
module state_machine (
input wire   clk, 
input wire in, 
input wire reset,
output wire [1:0] out
);

reg [1:0] out_reg;
reg     [1:0]state;

parameter I = 0, S = 1, T = 2;

assign out = out_reg;

always @ (state) begin
    case (state)
        I:
        out_reg <= 2'b01;
        S:
        out_reg <= 2'b10;
        T:
        out_reg <= 2'b11;
        default:
        out_reg <= 2'b00;
    endcase
end
always @ (posedge clk or posedge reset) begin
if (reset)
state <= I;
else
case (state)
   I:
      state <= S;
   S:
      if (in)
         state <= T;
      else
         state <= S;
   T:
      if (in)
         state <= S;
      else
         state <= T;
endcase
end
endmodule
