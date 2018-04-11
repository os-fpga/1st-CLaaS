vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/xil_common_vip_v1_0_0
vlib activehdl/smartconnect_v1_0
vlib activehdl/axi_protocol_checker_v1_1_13
vlib activehdl/axi_vip_v1_0_1

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap xil_common_vip_v1_0_0 activehdl/xil_common_vip_v1_0_0
vmap smartconnect_v1_0 activehdl/smartconnect_v1_0
vmap axi_protocol_checker_v1_1_13 activehdl/axi_protocol_checker_v1_1_13
vmap axi_vip_v1_0_1 activehdl/axi_vip_v1_0_1

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
"/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"/xilinx/software/SDx/2017.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"../../../ipstatic/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_common_vip_v1_0_0  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"../../../ipstatic/hdl/xil_common_vip_v1_0_vl_rfs.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"../../../ipstatic/hdl/sc_util_v1_0_vl_rfs.sv" \

vlog -work axi_protocol_checker_v1_1_13  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"../../../ipstatic/hdl/axi_protocol_checker_v1_1_vl_rfs.sv" \

vlog -work axi_vip_v1_0_1  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"../../../ipstatic/hdl/axi_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"../../../../mandelbrot_ex.srcs/sources_1/ip/control_mandelbrot_vip/sim/control_mandelbrot_vip_pkg.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" "+incdir+../../../ipstatic/hdl" "+incdir+../../../ipstatic/hdl/verilog" \
"../../../../mandelbrot_ex.srcs/sources_1/ip/control_mandelbrot_vip/sim/control_mandelbrot_vip.v" \

vlog -work xil_defaultlib \
"glbl.v"

