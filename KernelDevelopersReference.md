# Overview

This document describes development of custom FPGA RTL kernels using the provided Kernel API. Development that modifies the provided kernel interface is not covered here, nor elsewhere (other than in the commented code).



# Kernel Interface

A custom FPGA kernel named "foo" is provided as a System Verilog module with the following interface. Note that this is subject to change).

```
module foo_kernel #(
    parameter integer C_DATA_WIDTH = 512 // Data width of both input and output data
                                         // (This will be instantiated with its default value of 512.)
) (
    input wire                       clk,
    input wire                       reset,

    output wire                      in_ready,
    input wire                       in_avail,
    input wire  [C_DATA_WIDTH-1:0]   in_data,

    input wire                       out_ready,
    output wire                      out_avail,
    output wire [C_DATA_WIDTH-1:0]   out_data
);
```

This includes a streaming interface at the input and another at the output. Unless there are modifications to the intervening software layers, the data streaming into the kernel is the data sent from the Web Client application (or cloud application) communicating via the WebSocket, and the data sent from the kernel is received by the Web Client.

The streaming interface includes, `ready`, `avail`, and `data`. This is similar to a standard AXI streaming interface, generally referred to as a ready/valid protocol, though the naming is chosen to be consistent with TL-Verilog naming conventions.

In a given cycle, these signals relate to the same data transfer, where:

  - `ready`: The receiver is willing to accept the data.
  - `avail`: The transmitter has data to deliver.
  - `data`: The data.
  


# Development Using this Framework

Any means of delivering this kernel can be utilized, but we are partial to developing with TL-Verilog in  [Makerchip](https://makerchip.com/) IDE.


## Makerchip and TL-Verilog

You can copy `.tlv` code into Makerchip and copy back when finished. The Makefile will compile this into Verilog/SystemVerilog using
Redwood EDA's SandPiper(TM) SaaS edition running as a cloud service. (This link opens the
<a href="http://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Falessandrocomodi%2Ffpga-webserver%2Fmaster%2Fapps%2Fmandelbrot%2Ffpga%2Fsrc%2Fmandelbrot_kernel.tlv" target="_blank">latest Mandelbrot Kernel from GitHub in the Makerchip IDE</a>.

A WIP library of generic TL-Verilog components which mostly utilize the ready/avail interface protocol can be found <a href="https://github.com/stevehoover/tlv_flow_lib" target="_blank">here</a>.

