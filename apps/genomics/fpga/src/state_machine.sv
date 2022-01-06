
module state_machine (clk, in, reset, out);
input   clk, in, reset;
output  [1:0]out;
reg     [1:0]out;
reg     [1:0]state;

parameter I = 0, S = 1, T = 2;

always @ (state) begin
    case (state)
        I:
        out = 2'b01;
        S:
        out = 2'b10;
        T:
        out = 2'b11;
        default:
        out = 2'b00;
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