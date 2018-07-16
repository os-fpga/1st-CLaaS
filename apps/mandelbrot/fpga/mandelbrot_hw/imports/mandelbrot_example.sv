// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
module mandelbrot_example #(
  parameter integer C_M00_AXI_NUM_THREADS = 1  ,
  parameter integer C_M00_AXI_ID_WIDTH    = 1  ,
  parameter integer C_M00_AXI_ADDR_WIDTH  = 64 ,
  parameter integer C_M00_AXI_DATA_WIDTH  = 512
)
(
  // System Signals
  input  wire                              ap_clk         ,
  input  wire                              ap_rst_n       ,
  input  wire                              ap_clk_2       ,
  input  wire                              ap_rst_n_2     ,
  // AXI4 master interface m00_axi
  output wire                              m00_axi_awvalid,
  input  wire                              m00_axi_awready,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]   m00_axi_awaddr ,
  output wire [C_M00_AXI_ID_WIDTH-1:0]     m00_axi_awid   ,
  output wire [8-1:0]                      m00_axi_awlen  ,
  output wire [3-1:0]                      m00_axi_awsize ,
  output wire                              m00_axi_wvalid ,
  input  wire                              m00_axi_wready ,
  output wire [C_M00_AXI_DATA_WIDTH-1:0]   m00_axi_wdata  ,
  output wire [C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb  ,
  output wire                              m00_axi_wlast  ,
  input  wire                              m00_axi_bvalid ,
  output wire                              m00_axi_bready ,
  input  wire [C_M00_AXI_ID_WIDTH-1:0]     m00_axi_bid    ,
  output wire                              m00_axi_arvalid,
  input  wire                              m00_axi_arready,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]   m00_axi_araddr ,
  output wire [C_M00_AXI_ID_WIDTH-1:0]     m00_axi_arid   ,
  output wire [8-1:0]                      m00_axi_arlen  ,
  output wire [3-1:0]                      m00_axi_arsize ,
  input  wire                              m00_axi_rvalid ,
  output wire                              m00_axi_rready ,
  input  wire [C_M00_AXI_DATA_WIDTH-1:0]   m00_axi_rdata  ,
  input  wire                              m00_axi_rlast  ,
  input  wire [C_M00_AXI_ID_WIDTH-1:0]     m00_axi_rid    ,
  // SDx Control Signals
  input  wire                              ap_start       ,
  output wire                              ap_idle        ,
  output wire                              ap_done        ,
  input  wire [32-1:0]                     ctrl_length    ,
  input  wire [64-1:0]                     a              
);


timeunit 1ps;
timeprecision 1ps;

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
// Large enough for interesting traffic.
localparam integer  LP_WORD_BYTES      = 4;
localparam integer  LP_NUMBER_OF_WORDS = 4096;
localparam integer  LP_LENGTH_IN_BYTES = LP_WORD_BYTES*LP_NUMBER_OF_WORDS;
localparam integer  LP_NUM_EXAMPLES    = 1;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
logic                                areset                         = 1'b0;
logic                                kernel_rst                     = 1'b0;
logic                                ap_start_r                     = 1'b0;
logic                                ap_idle_r                      = 1'b0;
logic                                ap_start_pulse                ;
logic [LP_NUM_EXAMPLES-1:0]          ap_done_i                     ;
logic [LP_NUM_EXAMPLES-1:0]          ap_done_r                      = {LP_NUM_EXAMPLES{1'b0}};
logic [32-1:0]                       m00_axi_length_int             = (LP_LENGTH_IN_BYTES%(C_M00_AXI_DATA_WIDTH/8)) == 0 ? (LP_LENGTH_IN_BYTES/(C_M00_AXI_DATA_WIDTH/8)) : (LP_LENGTH_IN_BYTES/(C_M00_AXI_DATA_WIDTH/8)) + 1;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
end

// create pulse when ap_start transitions to 1
always @(posedge ap_clk) begin
  begin
    ap_start_r <= ap_start;
  end
end

assign ap_start_pulse = ap_start & ~ap_start_r;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
always @(posedge ap_clk) begin
  if (areset) begin
    ap_idle_r <= 1'b1;
  end
  else begin
    ap_idle_r <= ap_done ? 1'b1 :
      ap_start_pulse ? 1'b0 : ap_idle;
  end
end

assign ap_idle = ap_idle_r;

// Done logic
always @(posedge ap_clk) begin
  if (areset) begin
    ap_done_r <= '0;
  end
  else begin
    ap_done_r <= (ap_start_pulse | ap_done) ? '0 : ap_done_r | ap_done_i;
  end
end

assign ap_done = &ap_done_r;


// Register and invert kernel reset signal.
always @(posedge ap_clk_2) begin
  kernel_rst <= ~ap_rst_n_2;
end


// Vadd example
mandelbrot_example_vadd #(
  .C_M_AXI_NUM_THREADS ( C_M00_AXI_NUM_THREADS ),
  .C_M_AXI_ID_WIDTH    ( C_M00_AXI_ID_WIDTH    ),
  .C_M_AXI_ADDR_WIDTH  ( C_M00_AXI_ADDR_WIDTH  ),
  .C_M_AXI_DATA_WIDTH  ( C_M00_AXI_DATA_WIDTH  ),
  .C_ADDER_BIT_WIDTH   ( 32                    ),
  .C_NUM_CLOCKS        ( 2                     )
)
inst_example_vadd_m00_axi (
  .aclk             ( ap_clk             ),
  .areset           ( areset             ),
  .kernel_clk       ( ap_clk_2           ),
  .kernel_rst       ( kernel_rst         ),
  .ctrl_addr_offset ( a                  ),
  .ctrl_length      ( ctrl_length        ),
  .ctrl_constant    ( 32'b1              ),
  .ap_start         ( ap_start_pulse     ),
  .ap_done          ( ap_done_i[0]       ),
  .m_axi_awvalid    ( m00_axi_awvalid    ),
  .m_axi_awready    ( m00_axi_awready    ),
  .m_axi_awaddr     ( m00_axi_awaddr     ),
  .m_axi_awid       ( m00_axi_awid       ),
  .m_axi_awlen      ( m00_axi_awlen      ),
  .m_axi_awsize     ( m00_axi_awsize     ),
  .m_axi_wvalid     ( m00_axi_wvalid     ),
  .m_axi_wready     ( m00_axi_wready     ),
  .m_axi_wdata      ( m00_axi_wdata      ),
  .m_axi_wstrb      ( m00_axi_wstrb      ),
  .m_axi_wlast      ( m00_axi_wlast      ),
  .m_axi_bvalid     ( m00_axi_bvalid     ),
  .m_axi_bready     ( m00_axi_bready     ),
  .m_axi_bid        ( m00_axi_bid        ),
  .m_axi_arvalid    ( m00_axi_arvalid    ),
  .m_axi_arready    ( m00_axi_arready    ),
  .m_axi_araddr     ( m00_axi_araddr     ),
  .m_axi_arid       ( m00_axi_arid       ),
  .m_axi_arlen      ( m00_axi_arlen      ),
  .m_axi_arsize     ( m00_axi_arsize     ),
  .m_axi_rvalid     ( m00_axi_rvalid     ),
  .m_axi_rready     ( m00_axi_rready     ),
  .m_axi_rdata      ( m00_axi_rdata      ),
  .m_axi_rlast      ( m00_axi_rlast      ),
  .m_axi_rid        ( m00_axi_rid        )
);


endmodule : mandelbrot_example
`default_nettype wire
