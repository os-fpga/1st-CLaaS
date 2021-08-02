# WARP-V Example

The kernel in this example contains a WARP-V TL-Verilog RISC-V CPU (TODO: not yet and eventually many-core).

The web front-end accepts a simple form of assembly code. It sends the assembled binary data to the kernel to load in instruction memory. A reset command (TODO: not implemented) will start execution and receive data from the CPU.

# Implementation

WARP-V uses M4 macro pre-processing to define the instruction set. This definition is used to generate CPU decode logic and also to provide a simple assembler, so the assembler remains in sync w/ the hardware from a single definition of the instruction set. This simplifies the job of customizing the ISA (though, admittedly, the M4 code is rather ugly).

We wish to preserve this single-source property in our example, so, we must use the same WARP-V code base that provides the kernel to assemble the instructions. This WARP-V TLV file must be accessible via a URL, and there is a slight burden on the user currently to use the same WARP-V for kernel build and assembly.

The assembly code is processed as follows:

  - Lines in the source code starting with a parenthetical list of args are interpreted as instructions.
  - Each parenthetical expression is extracted as arguments for a TL-Verilog `m4_asm` macro instantiation.
  - A TL-Verilog file (well, string) is formed containing the `m4_asm`s. This TL-Verilog "file" includes the given WARP-V source code URL (via `m4_include_lib`). This WARP-V code presumably defines the `m4_asm` macro.
  - The TL-Verilog "file" is sent to SandPiper SaaS Edition to evaluate the `m4_asm` statements into Verilog constant expressions for the instructions' binary values.
  - The Verilog constant expressions from the resulting Verilog file are parsed into integer values.
  - These integer values are bundled into chunks and sent to the kernel to program the WARP-V in the kernel.

# TODO:

  - Keep WARP-V version in sync between assembly and kernel. Either
    - Use NPM to install WARP-V and serve WARP-V TLV. JS will provide this file to SandPiper SaaS, and kernel compile will use it as a local include.
    - Create a file containing the WARP-V TLV URL. Serve this file for JS to use and use M4 to access this file for URL inclusion.
  - Instructions are assumed to be 32 bits, so this is not currently customizable.
  