# Architecture Notes

## Initial Boundary

Phase 1 is a simulation-oriented RV32I single-cycle core. It uses separate local instruction and data memories so that core behavior can be verified before the system bus exists.

The Phase 1 memories are not the final SoC memory map. The final map will be defined when the interconnect and accelerator registers are designed.

## Future System Boundary

The RISC-V host will access memory and peripherals through a shared interconnect. The convolution accelerator should be treated as a memory-mapped hardware peripheral with a documented register interface and, later, a data path suitable for DMA.

## Fabrication Readiness

Fabrication is a later target, not an assumption of the first RTL milestone. Process choice, clocking, reset strategy, IO, SRAM/macros, power intent, verification signoff, and physical-design constraints must be recorded before a tapeout target is selected.
