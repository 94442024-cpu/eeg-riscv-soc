IVERILOG ?= iverilog
VVP ?= vvp
PYTEST ?= pytest
BUILD_DIR := sim/build
CORE_RTL := rtl/core/alu.v rtl/core/regfile.v rtl/core/imm_gen.v rtl/core/control.v rtl/core/instr_mem.v rtl/core/data_mem.v rtl/core/riscv_core.v

.PHONY: test test-python test-rtl test-cocotb clean

test: test-python test-rtl

test-cocotb:
	python tb/cocotb/run.py

test-python:
	$(PYTEST) models/golden/test_rv32i.py -q

test-rtl: $(BUILD_DIR)/test_rv32i_blocks.vvp $(BUILD_DIR)/test_decode_imm.vvp $(BUILD_DIR)/test_memory.vvp $(BUILD_DIR)/test_riscv_core.vvp $(BUILD_DIR)/test_riscv_core_regression.vvp $(BUILD_DIR)/test_control_flow.vvp $(BUILD_DIR)/test_rv32i_widths_and_alu.vvp
	$(VVP) $(BUILD_DIR)/test_rv32i_blocks.vvp
	$(VVP) $(BUILD_DIR)/test_decode_imm.vvp
	$(VVP) $(BUILD_DIR)/test_memory.vvp
	$(VVP) $(BUILD_DIR)/test_riscv_core.vvp
	$(VVP) $(BUILD_DIR)/test_riscv_core_regression.vvp
	$(VVP) $(BUILD_DIR)/test_control_flow.vvp
	$(VVP) $(BUILD_DIR)/test_rv32i_widths_and_alu.vvp

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(BUILD_DIR)/test_rv32i_blocks.vvp: $(BUILD_DIR) rtl/core/alu.v rtl/core/regfile.v tb/core/test_rv32i_blocks.v
	$(IVERILOG) -g2012 -o $@ rtl/core/alu.v rtl/core/regfile.v tb/core/test_rv32i_blocks.v

$(BUILD_DIR)/test_decode_imm.vvp: $(BUILD_DIR) rtl/core/imm_gen.v rtl/core/control.v tb/core/test_decode_imm.v
	$(IVERILOG) -g2012 -o $@ rtl/core/imm_gen.v rtl/core/control.v tb/core/test_decode_imm.v

$(BUILD_DIR)/test_memory.vvp: $(BUILD_DIR) rtl/core/instr_mem.v rtl/core/data_mem.v tb/core/test_memory.v
	$(IVERILOG) -g2012 -o $@ rtl/core/instr_mem.v rtl/core/data_mem.v tb/core/test_memory.v

$(BUILD_DIR)/test_riscv_core.vvp: $(BUILD_DIR) $(CORE_RTL) tb/core/test_riscv_core.v
	$(IVERILOG) -g2012 -o $@ $(CORE_RTL) tb/core/test_riscv_core.v

$(BUILD_DIR)/test_riscv_core_regression.vvp: $(BUILD_DIR) $(CORE_RTL) tb/core/test_riscv_core_regression.v
	$(IVERILOG) -g2012 -o $@ $(CORE_RTL) tb/core/test_riscv_core_regression.v

$(BUILD_DIR)/test_control_flow.vvp: $(BUILD_DIR) $(CORE_RTL) tb/core/test_control_flow.v
	$(IVERILOG) -g2012 -o $@ $(CORE_RTL) tb/core/test_control_flow.v

$(BUILD_DIR)/test_rv32i_widths_and_alu.vvp: $(BUILD_DIR) $(CORE_RTL) tb/core/test_rv32i_widths_and_alu.v
	$(IVERILOG) -g2012 -o $@ $(CORE_RTL) tb/core/test_rv32i_widths_and_alu.v

clean:
	Remove-Item -Recurse -Force $(BUILD_DIR)
