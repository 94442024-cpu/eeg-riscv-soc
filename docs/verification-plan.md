# Verification Plan

## Principle

Every hardware block gets a behavioral reference model before or alongside RTL implementation. The reference model is the source used by self-checking scoreboards; it is not a replacement for RTL simulation or synthesis checks.

## Test Progression

1. Directed tests for known instruction and interface cases.
2. Randomized tests with reproducible seeds.
3. Differential tests against the Python model.
4. Integration tests across bus and peripheral boundaries.
5. Representative EEG workloads after numerical behavior is fixed.

## Phase 1 Core Checks

- Register reads and writes
- Register `x0` always reads as zero
- ALU operations and signed/unsigned comparisons
- All six immediate formats
- Branch taken and not taken behavior
- `JAL` and `JALR` link addresses
- Load/store byte, halfword, and word behavior
- Sign extension and zero extension
- Natural alignment assumptions
- PC reset and sequential progression
- Hand-written mixed instruction program
- Relevant RV32I compliance tests

## Reproducibility

Tests should report the simulator, tool versions, test name, and random seed. Generated waveforms and simulator build products belong under `sim/` and should not be committed by default.
