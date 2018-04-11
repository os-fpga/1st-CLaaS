// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none

module mandelbrot_example_pipeline #(
  parameter integer C_DWIDTH = 1,          // Range: 1+
  parameter integer C_DEPTH = 1,           // Range: 0+
  parameter         C_SHREG_EXTRACT = "no" // Range: "no" or "yes" allowed
) (
  input  wire                      aclk,
  input  wire                      aclken,
  input  wire                      areset,
  input  wire [C_DWIDTH-1:0]       din,
  output wire [C_DWIDTH-1:0]       dout
);

  timeunit 1ps;
  timeprecision 1ps;
  (* shreg_extract = C_SHREG_EXTRACT *) reg [C_DWIDTH-1:0]  pipe [C_DEPTH:0] = '{default: '0};

  always @(*) begin
    pipe[0] = din;
  end

  generate
    genvar gendepth;
    for (gendepth=1; gendepth<=C_DEPTH; gendepth=gendepth+1) begin : gen_pipe
      always @(posedge aclk) begin
        if (areset) begin
          pipe[gendepth] <= '0;
        end
        else if (aclken) begin
          pipe[gendepth] <= pipe[gendepth-1];
        end
      end
    end
  endgenerate

  assign dout = pipe[C_DEPTH];

endmodule : mandelbrot_example_pipeline

`default_nettype wire

