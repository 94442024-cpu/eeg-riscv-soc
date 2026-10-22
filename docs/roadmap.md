# Project Roadmap

This roadmap is deliberately incremental. Each phase must have passing tests and documented interfaces before the next phase begins.

## Phase 0 - Foundation

- Repository structure and contribution conventions
- Python model and cocotb test infrastructure
- Toolchain documentation
- Initial architecture and verification plans

## Phase 1 - RV32I Host Core

- Instruction decoder and immediate generator
- Register file with hardwired `x0`
- ALU
- Single-cycle control and PC update logic
- Local instruction and data memories for simulation
- Directed and randomized instruction tests
- Relevant `rv32ui` compliance tests

## Phase 2 - SoC Interconnect

- Select Wishbone or AXI-Lite interface
- Address decoder and response behavior
- Unified system memory map
- Connect the host core to memory-mapped peripherals

## Phase 3 - EEG Convolution Accelerator

- Define register and streaming interfaces
- Python/NumPy reference model
- Fixed-point arithmetic specification
- MAC datapath and control logic
- Single-channel filtering first, then multi-channel support

## Phase 4 - DMA Controller

- Memory-to-accelerator transfers
- Accelerator-to-memory transfers
- Control/status registers
- Directed and randomized transfer tests

## Phase 5 - Interrupts and Firmware

- Interrupt controller
- RISC-V trap/CSR support required by the chosen software model
- C driver and example firmware
- End-to-end command and completion flow

## Phase 6 - Full Integration

- Integrate CPU, memory, bus, accelerator, DMA, and interrupts
- Re-run module and system regressions
- Validate against representative EEG data

## Phase 7 - Benchmarking

- Latency, throughput, area, and energy measurements
- Compare against the STM32H743 software implementation
- Document accuracy and fixed-point effects

## Phase 8 - FPGA Validation

- FPGA top-level and constraints
- Hardware-in-the-loop tests
- Measure real timing and resource usage

## Phase 9 - ASIC and Optional Tiny Tapeout

- Select a process and shuttle target
- Synthesis, timing, power, and area reports
- DFT, clock/reset, pad-ring, and signoff requirements
- Tiny Tapeout submission only after the target-specific checklist is complete
