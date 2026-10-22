import pytest

from models.golden.rv32i import RegisterFile, alu, s32, u32


def test_register_file_starts_zero_and_x0_is_immutable():
    registers = RegisterFile()

    assert [registers.read(index) for index in range(32)] == [0] * 32
    registers.write(0, 0xDEADBEEF)
    registers.write(5, -1)

    assert registers.read(0) == 0
    assert registers.read(5) == 0xFFFFFFFF


def test_register_file_rejects_invalid_indices():
    registers = RegisterFile()

    with pytest.raises(ValueError):
        registers.read(32)
    with pytest.raises(ValueError):
        registers.write(-1, 1)


@pytest.mark.parametrize(
    ("operation", "left", "right", "expected"),
    [
        ("ADD", 0xFFFFFFFF, 1, 0),
        ("SUB", 0, 1, 0xFFFFFFFF),
        ("AND", 0xF0, 0x0F, 0),
        ("OR", 0xF0, 0x0F, 0xFF),
        ("XOR", 0xFF, 0x0F, 0xF0),
        ("SLL", 1, 5, 0x20),
        ("SRL", 0x80000000, 4, 0x08000000),
        ("SRA", 0x80000000, 4, 0xF8000000),
        ("SLT", 0xFFFFFFFF, 1, 1),
        ("SLT", 1, 0xFFFFFFFF, 0),
        ("SLTU", 0xFFFFFFFF, 1, 0),
        ("SLTU", 1, 0xFFFFFFFF, 1),
    ],
)
def test_alu_operations(operation, left, right, expected):
    assert alu(operation, left, right) == expected


def test_shift_amount_uses_only_five_bits():
    assert alu("SLL", 1, 0x21) == 2


def test_word_conversion_helpers():
    assert u32(-1) == 0xFFFFFFFF
    assert s32(0xFFFFFFFF) == -1
    assert s32(0x7FFFFFFF) == 0x7FFFFFFF
