// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps
// Top level of the kernel. Do not modify module name, parameters or ports.
module mandelbrot #(
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12 ,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32 ,
  parameter integer C_M00_AXI_NUM_THREADS      = 1  ,
  parameter integer C_M00_AXI_ID_WIDTH         = 1  ,
  parameter integer C_M00_AXI_ADDR_WIDTH       = 64 ,
  parameter integer C_M00_AXI_DATA_WIDTH       = 512
)
(
  // System Signals
  input  wire                                    ap_clk               ,
  input  wire                                    ap_rst_n             ,
  input  wire                                    ap_clk_2             ,
  input  wire                                    ap_rst_n_2           ,
  // AXI4 master interface m00_axi
  output wire                                    m00_axi_awvalid      ,
  input  wire                                    m00_axi_awready      ,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]         m00_axi_awaddr       ,
  output wire [C_M00_AXI_ID_WIDTH-1:0]           m00_axi_awid         ,
  output wire [8-1:0]                            m00_axi_awlen        ,
  output wire [3-1:0]                            m00_axi_awsize       ,
  output wire [2-1:0]                            m00_axi_awburst      ,
  output wire [4-1:0]                            m00_axi_awcache      ,
  output wire                                    m00_axi_wvalid       ,
  input  wire                                    m00_axi_wready       ,
  output wire [C_M00_AXI_DATA_WIDTH-1:0]         m00_axi_wdata        ,
  output wire [C_M00_AXI_DATA_WIDTH/8-1:0]       m00_axi_wstrb        ,
  output wire                                    m00_axi_wlast        ,
  input  wire                                    m00_axi_bvalid       ,
  output wire                                    m00_axi_bready       ,
  input  wire [C_M00_AXI_ID_WIDTH-1:0]           m00_axi_bid          ,
  output wire                                    m00_axi_arvalid      ,
  input  wire                                    m00_axi_arready      ,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]         m00_axi_araddr       ,
  output wire [C_M00_AXI_ID_WIDTH-1:0]           m00_axi_arid         ,
  output wire [8-1:0]                            m00_axi_arlen        ,
  output wire [3-1:0]                            m00_axi_arsize       ,
  output wire [2-1:0]                            m00_axi_arburst      ,
  output wire [4-1:0]                            m00_axi_arcache      ,
  input  wire                                    m00_axi_rvalid       ,
  output wire                                    m00_axi_rready       ,
  input  wire [C_M00_AXI_DATA_WIDTH-1:0]         m00_axi_rdata        ,
  input  wire                                    m00_axi_rlast        ,
  input  wire [C_M00_AXI_ID_WIDTH-1:0]           m00_axi_rid          ,
  // AXI4-Lite slave interface
  input  wire                                    s_axi_control_awvalid,
  output wire                                    s_axi_control_awready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr ,
  input  wire                                    s_axi_control_wvalid ,
  output wire                                    s_axi_control_wready ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata  ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb  ,
  input  wire                                    s_axi_control_arvalid,
  output wire                                    s_axi_control_arready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr ,
  output wire                                    s_axi_control_rvalid ,
  input  wire                                    s_axi_control_rready ,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata  ,
  output wire [2-1:0]                            s_axi_control_rresp  ,
  output wire                                    s_axi_control_bvalid ,
  input  wire                                    s_axi_control_bready ,
  output wire [2-1:0]                            s_axi_control_bresp  
);

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
reg                                 areset                         = 1'b0;
wire                                ap_start                      ;
wire                                ap_idle                       ;
wire                                ap_done                       ;
wire [32-1:0]                       ctrl_length                   ;
wire [64-1:0]                       a                             ;
// Note: AxBURST and AxCACHE signals are tied off to non-zero values for optimal interconnect connections.
// If these signals are used or are not tied off to these values, then the bd.tcl should be modified to 
// enable the signals by changing the HAS_BURST and HAS_CACHE properties to 1.
assign m00_axi_awburst = 2'b01; // Always use incr burst.
assign m00_axi_awcache = 4'b0011; // Allows cache and width conversion (if necessary.)
assign m00_axi_arburst = 2'b01; // Always use incr burst.
assign m00_axi_arcache = 4'b0011; // Allows cache and width conversion (if necessary.)

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
end

///////////////////////////////////////////////////////////////////////////////
// Begin control interface RTL.  Modifying not recommended.
///////////////////////////////////////////////////////////////////////////////


// AXI4-Lite slave interface
mandelbrot_control_s_axi #(
  .C_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH )
)
inst_control_s_axi (
  .aclk        ( ap_clk                ),
  .areset      ( areset                ),
  .aclk_en     ( 1'b1                  ),
  .awvalid     ( s_axi_control_awvalid ),
  .awready     ( s_axi_control_awready ),
  .awaddr      ( s_axi_control_awaddr  ),
  .wvalid      ( s_axi_control_wvalid  ),
  .wready      ( s_axi_control_wready  ),
  .wdata       ( s_axi_control_wdata   ),
  .wstrb       ( s_axi_control_wstrb   ),
  .arvalid     ( s_axi_control_arvalid ),
  .arready     ( s_axi_control_arready ),
  .araddr      ( s_axi_control_araddr  ),
  .rvalid      ( s_axi_control_rvalid  ),
  .rready      ( s_axi_control_rready  ),
  .rdata       ( s_axi_control_rdata   ),
  .rresp       ( s_axi_control_rresp   ),
  .bvalid      ( s_axi_control_bvalid  ),
  .bready      ( s_axi_control_bready  ),
  .bresp       ( s_axi_control_bresp   ),
  .ap_start    ( ap_start              ),
  .ap_done     ( ap_done               ),
  .ap_idle     ( ap_idle               ),
  .ctrl_length ( ctrl_length           ),
  .a           ( a                     )
);

///////////////////////////////////////////////////////////////////////////////
// Add kernel logic here.  Modify/remove example code as necessary.
///////////////////////////////////////////////////////////////////////////////

// Example RTL block.  Remove to insert custom logic.
mandelbrot_example #(
  .C_M00_AXI_NUM_THREADS ( C_M00_AXI_NUM_THREADS ),
  .C_M00_AXI_ID_WIDTH    ( C_M00_AXI_ID_WIDTH    ),
  .C_M00_AXI_ADDR_WIDTH  ( C_M00_AXI_ADDR_WIDTH  ),
  .C_M00_AXI_DATA_WIDTH  ( C_M00_AXI_DATA_WIDTH  )
)
inst_example (
  .ap_clk          ( ap_clk          ),
  .ap_rst_n        ( ap_rst_n        ),
  .ap_clk_2        ( ap_clk_2        ),
  .ap_rst_n_2      ( ap_rst_n_2      ),
  .m00_axi_awvalid ( m00_axi_awvalid ),
  .m00_axi_awready ( m00_axi_awready ),
  .m00_axi_awaddr  ( m00_axi_awaddr  ),
  .m00_axi_awid    ( m00_axi_awid    ),
  .m00_axi_awlen   ( m00_axi_awlen   ),
  .m00_axi_awsize  ( m00_axi_awsize  ),
  .m00_axi_wvalid  ( m00_axi_wvalid  ),
  .m00_axi_wready  ( m00_axi_wready  ),
  .m00_axi_wdata   ( m00_axi_wdata   ),
  .m00_axi_wstrb   ( m00_axi_wstrb   ),
  .m00_axi_wlast   ( m00_axi_wlast   ),
  .m00_axi_bvalid  ( m00_axi_bvalid  ),
  .m00_axi_bready  ( m00_axi_bready  ),
  .m00_axi_bid     ( m00_axi_bid     ),
  .m00_axi_arvalid ( m00_axi_arvalid ),
  .m00_axi_arready ( m00_axi_arready ),
  .m00_axi_araddr  ( m00_axi_araddr  ),
  .m00_axi_arid    ( m00_axi_arid    ),
  .m00_axi_arlen   ( m00_axi_arlen   ),
  .m00_axi_arsize  ( m00_axi_arsize  ),
  .m00_axi_rvalid  ( m00_axi_rvalid  ),
  .m00_axi_rready  ( m00_axi_rready  ),
  .m00_axi_rdata   ( m00_axi_rdata   ),
  .m00_axi_rlast   ( m00_axi_rlast   ),
  .m00_axi_rid     ( m00_axi_rid     ),
  .ap_start        ( ap_start        ),
  .ap_done         ( ap_done         ),
  .ap_idle         ( ap_idle         ),
  .ctrl_length     ( ctrl_length     ),
  .a               ( a               )
);

endmodule
`default_nettype wire
