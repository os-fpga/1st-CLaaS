# WARP-V manycore Example

The kernel in this example contains the manycore version of WARP-V, a TL-Verilog RISC-V CPU.

The web front-end accepts a simple form of assembly code. It sends the assembled binary data to the kernel to load in instruction memory. A reset command (TODO: not implemented) will start execution and receive data from the CPU.

# Implementation

refer to WARP-V example.

  - At present, core-0 is attached with the I/O of stream interface, and all cores access instructions though Global Imem.

# Notes
  - The manycore_kernal.tlv file in fpga/src can also be used in Makerchip for development after removing `--compiler verilator` flag`. Although the stimulus provided is random but can be changed as per ones need.
  - The number of cores can manually be changed by modifing `NUM_CORES`.


# TODO:
  - Port these feature to be complied as their 1st-ClaaS version from warp-v configurator.
  - Change m4_include pointer after PR.
  - add VIZ
