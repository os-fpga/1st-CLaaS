# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info, with the following additions:

include ../../../framework/build/Makefile

# ---- Local overrides for Mandelbrot (appends after the framework include) ----

# Where the framework puts build outputs
OUT := $(abspath ../out/$(TARGET)/$(AWS_PLATFORM))

# Deterministic UNIX socket path the host & webserver will share
SOCK ?= /tmp/mandelbrot_$(shell id -u).sock

# Host + xclbin produced by 'make build'
HOST_BIN := $(OUT)/host
XCLBIN   := $(OUT)/mandelbrot.xclbin

PORT ?= 8888

.PHONY: launch
launch: build
	@echo "Launching with:"
	@echo "  OUT   = $(OUT)"
	@echo "  SOCK  = $(SOCK)"
	@test -x "$(HOST_BIN)" || (echo "ERROR: Missing host: $(HOST_BIN). Run 'make build'." && exit 1)
	@test -r "$(XCLBIN)"   || (echo "ERROR: Missing xclbin: $(XCLBIN). Run 'make build'." && exit 1)
	# Hand the socket and xclbin to the patched launch script.
	# (The script also generates emconfig.json into $(OUT) and exports EMCONFIG_PATH/XRT_INI_PATH.)
	AWS_PLATFORM=$(AWS_PLATFORM) ../../../framework/build/launch -s "$(SOCK)" $(TARGET) "$(HOST_BIN) -s $(SOCK) $(XCLBIN)"

# Handy target to run the host alone (no webserver) for debugging
.PHONY: host-only
host-only: build
	@mkdir -p "$(OUT)"
	@printf "[Debug]\nverbosity=4\ntimeline_trace=true\n" > "$(OUT)/xrt.ini"
	cd "$(OUT)" && \
	  emconfigutil --nd 1 --platform "$(AWS_PLATFORM)" && \
	  XCL_EMULATION_MODE=hw_emu \
	  EMCONFIG_PATH="$(OUT)" \
	  XRT_INI_PATH="$(OUT)/xrt.ini" \
	  "$(HOST_BIN)" -s "$(SOCK)" "$(XCLBIN)"

.PHONY: show-sock
show-sock:
	@echo $(SOCK)
	
