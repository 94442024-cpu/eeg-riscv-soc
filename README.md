# EEG RISC-V SoC

A fabrication-oriented open-source SoC for EEG signal preprocessing.

The system will combine a small RV32I RISC-V host core with a memory-mapped convolution accelerator, DMA, interrupts, and verification infrastructure. The immediate milestone is a correct and self-checking RV32I single-cycle core.

## Current Status

Phase 1: RV32I single-cycle host core implemented and passing directed, integration, and cocotb smoke tests.

The remaining Phase 1 work is compliance-oriented coverage, linting, and a cleaner external memory interface before starting the Phase 2 interconnect.

## Planned System

```text
RISC-V host core <-> bus/interconnect <-> instruction/data memory
                                      <-> EEG convolution accelerator
                                      <-> DMA controller
                                      <-> interrupt controller
```

## Repository Layout

- `rtl/` - synthesizable Verilog/SystemVerilog hardware
- `tb/` - cocotb testbenches and simulation configuration
- `models/` - executable Python golden models
- `sw/` - firmware, startup code, and device headers
- `docs/` - architecture, memory map, decisions, and verification notes
- `fpga/` - FPGA-specific constraints and top-level integration
- `asic/` - synthesis, OpenROAD, and fabrication collateral
- `sim/` - generated simulation artifacts; waveform output is ignored

## Development Rules

1. Define or update the Python golden model before implementing new RTL behavior.
2. Use self-checking tests; waveforms are for debugging failures.
3. Test in this order: directed, randomized, then representative EEG data.
4. Keep interfaces and memory maps documented as they are created.
5. Run regression tests after integration changes.
6. Do not claim fabrication readiness until simulation, lint, synthesis, timing, and physical-design checks pass for a selected process and target.

## First Milestone

The first implementation milestone is the RV32I single-cycle core:

- arithmetic and logical instructions
- immediate instructions
- loads and stores with byte, halfword, and word access
- conditional branches
- `JAL` and `JALR`
- `LUI` and `AUIPC`
- hardwired-zero register `x0`
- self-checking compliance-oriented tests

See [`docs/roadmap.md`](docs/roadmap.md) and [`docs/verification-plan.md`](docs/verification-plan.md).
