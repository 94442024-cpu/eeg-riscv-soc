TOPLEVEL_LANG := verilog
SIM := icarus
TOPLEVEL := riscv_core
MODULE := test_core
COMPILE_ARGS += -g2012

VERILOG_SOURCES := $(abspath ../../rtl/core/alu.v) \
                   $(abspath ../../rtl/core/regfile.v) \
                   $(abspath ../../rtl/core/imm_gen.v) \
                   $(abspath ../../rtl/core/control.v) \
                   $(abspath ../../rtl/core/instr_mem.v) \
                   $(abspath ../../rtl/core/data_mem.v) \
                   $(abspath ../../rtl/core/riscv_core.v)

include $(shell cocotb-config --makefiles)/Makefile.sim
