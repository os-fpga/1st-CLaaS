# 1st CLaaS WARP-V Planning

## Many-Core

### Virtex  UltraScale+ vu9p Resources

Ultra RAMs:  960 (288 Kb ea. 2rw; e.g. 8k x 36b)
Block RAMs: 2060 (2rw 1k x 36b or 1r1w 512 x 72b)
DSP Slices: 6840 (27x18 add/mul)
LUTs: 1182k

### Targets

These are limit calculations for what can fit on f1.2xlarge instance w/ 1 FPGA. We will not reach these. These do not account for shell logic.

#### WARP-V RISC-V

```
1920 cores, so per core:
Ultra RAMs: 0.5 (+0%) [18KB DMem 1rw]
Block RAMs: 1 (+7%) [1k instr IMem (share and grow)]
DSP Slices: 3 (+18%) [2 for EXE, 1 for branch target?, 0 for address calc?]
LUTs:       378 (at 60% util. of 630)
```

DSPs:

#### WARP-V DSP CPU

```
6840 cores, so per core:
Ultra RAMs: 0.125 (12%) [36KB shared IMem]
Block RAMs: 0.25 (20%) [1KB / core, 2rw / 4 cores]
DSP Slices: 1 (.0)
LUTs:       106 (at 60% util. of 177)  <= experiment w/ feasibility (include interconnect)
```

18-bit instr, 16b data (DSPs are 18b, but distributed RAM for RF is 16b).
IStream is in UltraRAM, shared by 8 cores. 4 cores share 1 port. Each reads blocks of 4 instrs every 4 cycles. ICache can be an enhancement.
Block RAM 2 ports shared by 4 cores, with each port shared by 2 cores.
