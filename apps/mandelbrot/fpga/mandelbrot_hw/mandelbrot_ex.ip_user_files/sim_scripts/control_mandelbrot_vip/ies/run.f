-makelib ies/xil_defaultlib -sv \
  "/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
  "/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies/xpm \
  "/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/axi_infrastructure_v1_1_0 \
  "../../../ipstatic/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib ies/xil_common_vip_v1_0_0 -sv \
  "../../../ipstatic/hdl/xil_common_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies/smartconnect_v1_0 -sv \
  "../../../ipstatic/hdl/sc_util_v1_0_vl_rfs.sv" \
-endlib
-makelib ies/axi_protocol_checker_v1_1_13 -sv \
  "../../../ipstatic/hdl/axi_protocol_checker_v1_1_vl_rfs.sv" \
-endlib
-makelib ies/axi_vip_v1_0_1 -sv \
  "../../../ipstatic/hdl/axi_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies/xil_defaultlib -sv \
  "../../../../mandelbrot_ex.srcs/sources_1/ip/control_mandelbrot_vip/sim/control_mandelbrot_vip_pkg.sv" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../mandelbrot_ex.srcs/sources_1/ip/control_mandelbrot_vip/sim/control_mandelbrot_vip.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

