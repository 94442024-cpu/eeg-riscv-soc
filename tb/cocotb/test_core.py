import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def executes_program_and_writes_memory(dut):
    dut.reset.value = 1
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())

    program = [
        0x00500093,  # addi x1, x0, 5
        0x00700113,  # addi x2, x0, 7
        0x002081B3,  # add x3, x1, x2
        0x04302023,  # sw x3, 64(x0)
        0x04002203,  # lw x4, 64(x0)
    ]
    for _ in range(2):
        await RisingEdge(dut.clock)
    dut.reset.value = 0

    for _ in range(len(program) + 2):
        await RisingEdge(dut.clock)
    await Timer(1, units="ns")

    assert dut.register_file.registers[1].value.integer == 5
    assert dut.register_file.registers[2].value.integer == 7
    assert dut.register_file.registers[3].value.integer == 12
    assert dut.register_file.registers[4].value.integer == 12
