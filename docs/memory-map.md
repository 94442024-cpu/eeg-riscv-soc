# Phase 1 Memory Map

Phase 1 uses separate simulation-local instruction and data memories. They are independent address spaces; this is not the final unified SoC map.

## Instruction Memory

- Module: `rtl/core/instr_mem.v`
- Size: 1024 words (4096 bytes)
- Address range: `0x00000000` - `0x00000FFC`
- Word-aligned fetches; the low two address bits select no byte
- Combinational read

## Data Memory

- Module: `rtl/core/data_mem.v`
- Size: 4096 bytes
- Address range: `0x00000000` - `0x00000FFF`
- Little-endian byte ordering
- Combinational reads and clocked writes
- Natural alignment is required for halfword and word accesses

| `funct3` | Access | Width | Load extension |
|---|---|---:|---|
| `000` | `LB` / `SB` | 8 bits | sign extension |
| `001` | `LH` / `SH` | 16 bits | sign extension |
| `010` | `LW` / `SW` | 32 bits | none |
| `100` | `LBU` | 8 bits | zero extension |
| `101` | `LHU` | 16 bits | zero extension |

The final SoC memory map will be defined when the shared interconnect and accelerator registers are implemented.
