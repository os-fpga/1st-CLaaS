VIVADO := $(XILINX_VIVADO)/bin/vivado
$(TEMP_DIR)/vadd.xo: scripts/package_kernel.tcl scripts/gen_xo.tcl ../fpga/*.sv ../fpga/*.v ../fpga/tlv/*.tlv
	sandpiper-saas -i ../fpga/tlv/sw.tlv --outdir ../fpga/ -o krnl_vadd_rtl_adder.sv --fmtFlatSignals --bestsv --noline
	mkdir -p $(TEMP_DIR)
	$(VIVADO) -mode batch -source scripts/gen_xo.tcl -tclargs $(TEMP_DIR)/vadd.xo vadd $(TARGET) $(DEVICE) $(XSA)
