// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ps / 1 ps
import axi_vip_v1_0_1_pkg::*;
import slv_m00_axi_vip_pkg::*;
import control_mandelbrot_vip_pkg::*;

module mandelbrot_exdes_tb_basic ();
parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12;
parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32;
parameter integer C_M00_AXI_NUM_THREADS = 1;
parameter integer C_M00_AXI_ID_WIDTH = 1;
parameter integer C_M00_AXI_ADDR_WIDTH = 64;
parameter integer C_M00_AXI_DATA_WIDTH = 512;
parameter integer LP_CLK_PERIOD_PS = 4000; // 250 MHz
parameter integer LP_CLK2_PERIOD_PS = 5000; // 200 MHz
 
//System Signals
logic ap_clk = 0;
logic ap_rst_n = 0;

initial begin: AP_CLK
  forever begin
    ap_clk = #(LP_CLK_PERIOD_PS/2) ~ap_clk;
  end
end

initial begin: AP_RST
  repeat (25) @(posedge ap_clk);
  ap_rst_n = 1;
end

 logic ap_clk_2 = 0;
logic ap_rst_n_2 = 0;
initial begin: AP_CLK_2
  forever begin
    ap_clk_2 = #(LP_CLK2_PERIOD_PS/2) ~ap_clk_2;
  end
end
initial begin: AP_RST_2
  repeat (25) @(posedge ap_clk_2);
  ap_rst_n_2 = 1;
end
//AXI4 master interface m00_axi
wire [1-1:0] m00_axi_awvalid;
wire [1-1:0] m00_axi_awready;
wire [C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr;
wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_awid;
wire [8-1:0] m00_axi_awlen;
wire [3-1:0] m00_axi_awsize;
wire [2-1:0] m00_axi_awburst;
wire [4-1:0] m00_axi_awcache;
wire [1-1:0] m00_axi_wvalid;
wire [1-1:0] m00_axi_wready;
wire [C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata;
wire [C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb;
wire [1-1:0] m00_axi_wlast;
wire [1-1:0] m00_axi_bvalid;
wire [1-1:0] m00_axi_bready;
wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_bid;
wire [1-1:0] m00_axi_arvalid;
wire [1-1:0] m00_axi_arready;
wire [C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr;
wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_arid;
wire [8-1:0] m00_axi_arlen;
wire [3-1:0] m00_axi_arsize;
wire [2-1:0] m00_axi_arburst;
wire [4-1:0] m00_axi_arcache;
wire [1-1:0] m00_axi_rvalid;
wire [1-1:0] m00_axi_rready;
wire [C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata;
wire [1-1:0] m00_axi_rlast;
wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_rid;
//AXI4LITE control signals
wire [1-1:0] s_axi_control_awvalid;
wire [1-1:0] s_axi_control_awready;
wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_awaddr;
wire [1-1:0] s_axi_control_wvalid;
wire [1-1:0] s_axi_control_wready;
wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_wdata;
wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb;
wire [1-1:0] s_axi_control_arvalid;
wire [1-1:0] s_axi_control_arready;
wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_araddr;
wire [1-1:0] s_axi_control_rvalid;
wire [1-1:0] s_axi_control_rready;
wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_rdata;
wire [2-1:0] s_axi_control_rresp;
wire [1-1:0] s_axi_control_bvalid;
wire [1-1:0] s_axi_control_bready;
wire [2-1:0] s_axi_control_bresp;

// DUT instantiation
mandelbrot #(
  .C_S_AXI_CONTROL_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_CONTROL_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH ),
  .C_M00_AXI_NUM_THREADS      ( C_M00_AXI_NUM_THREADS      ),
  .C_M00_AXI_ID_WIDTH         ( C_M00_AXI_ID_WIDTH         ),
  .C_M00_AXI_ADDR_WIDTH       ( C_M00_AXI_ADDR_WIDTH       ),
  .C_M00_AXI_DATA_WIDTH       ( C_M00_AXI_DATA_WIDTH       )
)
inst_dut (
  .ap_clk                ( ap_clk                ),
  .ap_rst_n              ( ap_rst_n              ),
  .ap_clk_2              ( ap_clk_2              ),
  .ap_rst_n_2            ( ap_rst_n_2            ),
  .m00_axi_awvalid       ( m00_axi_awvalid       ),
  .m00_axi_awready       ( m00_axi_awready       ),
  .m00_axi_awaddr        ( m00_axi_awaddr        ),
  .m00_axi_awid          ( m00_axi_awid          ),
  .m00_axi_awlen         ( m00_axi_awlen         ),
  .m00_axi_awsize        ( m00_axi_awsize        ),
  .m00_axi_awburst       ( m00_axi_awburst       ),
  .m00_axi_awcache       ( m00_axi_awcache       ),
  .m00_axi_wvalid        ( m00_axi_wvalid        ),
  .m00_axi_wready        ( m00_axi_wready        ),
  .m00_axi_wdata         ( m00_axi_wdata         ),
  .m00_axi_wstrb         ( m00_axi_wstrb         ),
  .m00_axi_wlast         ( m00_axi_wlast         ),
  .m00_axi_bvalid        ( m00_axi_bvalid        ),
  .m00_axi_bready        ( m00_axi_bready        ),
  .m00_axi_bid           ( m00_axi_bid           ),
  .m00_axi_arvalid       ( m00_axi_arvalid       ),
  .m00_axi_arready       ( m00_axi_arready       ),
  .m00_axi_araddr        ( m00_axi_araddr        ),
  .m00_axi_arid          ( m00_axi_arid          ),
  .m00_axi_arlen         ( m00_axi_arlen         ),
  .m00_axi_arsize        ( m00_axi_arsize        ),
  .m00_axi_arburst       ( m00_axi_arburst       ),
  .m00_axi_arcache       ( m00_axi_arcache       ),
  .m00_axi_rvalid        ( m00_axi_rvalid        ),
  .m00_axi_rready        ( m00_axi_rready        ),
  .m00_axi_rdata         ( m00_axi_rdata         ),
  .m00_axi_rlast         ( m00_axi_rlast         ),
  .m00_axi_rid           ( m00_axi_rid           ),
  .s_axi_control_awvalid ( s_axi_control_awvalid ),
  .s_axi_control_awready ( s_axi_control_awready ),
  .s_axi_control_awaddr  ( s_axi_control_awaddr  ),
  .s_axi_control_wvalid  ( s_axi_control_wvalid  ),
  .s_axi_control_wready  ( s_axi_control_wready  ),
  .s_axi_control_wdata   ( s_axi_control_wdata   ),
  .s_axi_control_wstrb   ( s_axi_control_wstrb   ),
  .s_axi_control_arvalid ( s_axi_control_arvalid ),
  .s_axi_control_arready ( s_axi_control_arready ),
  .s_axi_control_araddr  ( s_axi_control_araddr  ),
  .s_axi_control_rvalid  ( s_axi_control_rvalid  ),
  .s_axi_control_rready  ( s_axi_control_rready  ),
  .s_axi_control_rdata   ( s_axi_control_rdata   ),
  .s_axi_control_rresp   ( s_axi_control_rresp   ),
  .s_axi_control_bvalid  ( s_axi_control_bvalid  ),
  .s_axi_control_bready  ( s_axi_control_bready  ),
  .s_axi_control_bresp   ( s_axi_control_bresp   )
);

// Master Control instantiation
control_mandelbrot_vip inst_control_mandelbrot_vip (
  .aclk          ( ap_clk                ),
  .aresetn       ( ap_rst_n              ),
  .m_axi_awvalid ( s_axi_control_awvalid ),
  .m_axi_awready ( s_axi_control_awready ),
  .m_axi_awaddr  ( s_axi_control_awaddr  ),
  .m_axi_wvalid  ( s_axi_control_wvalid  ),
  .m_axi_wready  ( s_axi_control_wready  ),
  .m_axi_wdata   ( s_axi_control_wdata   ),
  .m_axi_wstrb   ( s_axi_control_wstrb   ),
  .m_axi_arvalid ( s_axi_control_arvalid ),
  .m_axi_arready ( s_axi_control_arready ),
  .m_axi_araddr  ( s_axi_control_araddr  ),
  .m_axi_rvalid  ( s_axi_control_rvalid  ),
  .m_axi_rready  ( s_axi_control_rready  ),
  .m_axi_rdata   ( s_axi_control_rdata   ),
  .m_axi_rresp   ( s_axi_control_rresp   ),
  .m_axi_bvalid  ( s_axi_control_bvalid  ),
  .m_axi_bready  ( s_axi_control_bready  ),
  .m_axi_bresp   ( s_axi_control_bresp   )
);

control_mandelbrot_vip_mst_t  ctrl;

// Slave MM VIP instantiation
slv_m00_axi_vip inst_slv_m00_axi_vip (
  .aclk          ( ap_clk          ),
  .aresetn       ( ap_rst_n        ),
  .s_axi_awvalid ( m00_axi_awvalid ),
  .s_axi_awready ( m00_axi_awready ),
  .s_axi_awaddr  ( m00_axi_awaddr  ),
  .s_axi_awid    ( m00_axi_awid    ),
  .s_axi_awlen   ( m00_axi_awlen   ),
  .s_axi_awsize  ( m00_axi_awsize  ),
  .s_axi_awburst ( m00_axi_awburst ),
  .s_axi_awcache ( m00_axi_awcache ),
  .s_axi_wvalid  ( m00_axi_wvalid  ),
  .s_axi_wready  ( m00_axi_wready  ),
  .s_axi_wdata   ( m00_axi_wdata   ),
  .s_axi_wstrb   ( m00_axi_wstrb   ),
  .s_axi_wlast   ( m00_axi_wlast   ),
  .s_axi_bvalid  ( m00_axi_bvalid  ),
  .s_axi_bready  ( m00_axi_bready  ),
  .s_axi_bid     ( m00_axi_bid     ),
  .s_axi_arvalid ( m00_axi_arvalid ),
  .s_axi_arready ( m00_axi_arready ),
  .s_axi_araddr  ( m00_axi_araddr  ),
  .s_axi_arid    ( m00_axi_arid    ),
  .s_axi_arlen   ( m00_axi_arlen   ),
  .s_axi_arsize  ( m00_axi_arsize  ),
  .s_axi_arburst ( m00_axi_arburst ),
  .s_axi_arcache ( m00_axi_arcache ),
  .s_axi_rvalid  ( m00_axi_rvalid  ),
  .s_axi_rready  ( m00_axi_rready  ),
  .s_axi_rdata   ( m00_axi_rdata   ),
  .s_axi_rlast   ( m00_axi_rlast   ),
  .s_axi_rid     ( m00_axi_rid     )
);


slv_m00_axi_vip_slv_mem_t   m00_axi;

initial begin : MEM_m00_axi
  m00_axi = new("m00_axi", mandelbrot_exdes_tb_basic.inst_slv_m00_axi_vip.inst.IF);
  m00_axi.start_slave();
end

axi_transaction   wr_xfer;
axi_transaction   rd_xfer;
axi_transaction   rd_rsp;
integer unsigned  rd_value;
//Instantiate AXI4 LITE VIP
initial begin : CTRL_TRAFFIC
  rd_value = 'h0;
  ctrl = new("ctrl", mandelbrot_exdes_tb_basic.inst_control_mandelbrot_vip.inst.IF);
  wr_xfer = ctrl.wr_driver.create_transaction("wr_xfer");
  rd_xfer = ctrl.rd_driver.create_transaction("rd_xfer");
  ctrl.start_master();

  ///////////////////////////////////////////////////////////////////////////
  //Write ID 0: ctrl_length (0x010) -> 32'hffffffff (scalar)
  assert(wr_xfer.randomize());
  wr_xfer.set_addr(32'h010);
  wr_xfer.set_data_beat(0, 32'hffffffff);
  ctrl.wr_driver.send(wr_xfer);

  ///////////////////////////////////////////////////////////////////////////
  //Write ID 1: a (0x018) -> Randomized 4k aligned address (Global memory, lower 32 bits)
  assert(wr_xfer.randomize());
  wr_xfer.set_addr(32'h018);
  wr_xfer.set_data_beat(0, (wr_xfer.get_data_beat(0) & ~(32'h00000fff)));
  ctrl.wr_driver.send(wr_xfer);

  ///////////////////////////////////////////////////////////////////////////
  //Write ID 1: a (0x01c) -> Randomized 4k aligned address (Global memory, upper 32 bits)
  assert(wr_xfer.randomize());
  wr_xfer.set_addr(32'h01c);
  wr_xfer.set_data_beat(0, (wr_xfer.get_data_beat(0)));
  ctrl.wr_driver.send(wr_xfer);

  ///////////////////////////////////////////////////////////////////////////
  //Start transfers
  wr_xfer.set_addr(32'h000);
  wr_xfer.set_data_beat(0, 32'h00000001);
  ctrl.wr_driver.send(wr_xfer);
  ctrl.wait_drivers_idle();
  ///////////////////////////////////////////////////////////////////////////
  //Start polling
  RDX: assert(rd_xfer.randomize());
  rd_xfer.set_addr(32'h00000000);
  rd_xfer.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);

  do begin
    ctrl.rd_driver.send(rd_xfer);
    ctrl.rd_driver.wait_rsp(rd_rsp);
    rd_value = rd_rsp.get_data_beat(0);
  end while ((rd_value & 32'h4) == 0);
  repeat (2) @(posedge ap_clk);
  $display( "Test completed successfully");
  $finish;
end

endmodule
`default_nettype wire
