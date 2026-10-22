"""Small executable reference models for the RV32I core."""

MASK32 = 0xFFFFFFFF


def u32(value: int) -> int:
    """Return value represented as an unsigned 32-bit word."""
    return value & MASK32


def s32(value: int) -> int:
    """Interpret value as a signed 32-bit two's-complement integer."""
    value = u32(value)
    return value if value < 0x80000000 else value - 0x100000000


class RegisterFile:
    """RV32I integer register file with a hardwired-zero x0."""

    def __init__(self) -> None:
        self._registers = [0] * 32

    def read(self, index: int) -> int:
        self._check_index(index)
        return 0 if index == 0 else self._registers[index]

    def write(self, index: int, value: int) -> None:
        self._check_index(index)
        if index != 0:
            self._registers[index] = u32(value)

    @staticmethod
    def _check_index(index: int) -> None:
        if not isinstance(index, int) or not 0 <= index < 32:
            raise ValueError(f"register index must be an integer from 0 to 31: {index!r}")


def alu(operation: str, left: int, right: int) -> int:
    """Evaluate one RV32I ALU operation and return an unsigned 32-bit word."""
    left = u32(left)
    right = u32(right)
    shift = right & 0x1F

    if operation == "ADD":
        result = left + right
    elif operation == "SUB":
        result = left - right
    elif operation == "AND":
        result = left & right
    elif operation == "OR":
        result = left | right
    elif operation == "XOR":
        result = left ^ right
    elif operation == "SLL":
        result = left << shift
    elif operation == "SRL":
        result = left >> shift
    elif operation == "SRA":
        result = s32(left) >> shift
    elif operation == "SLT":
        result = int(s32(left) < s32(right))
    elif operation == "SLTU":
        result = int(left < right)
    else:
        raise ValueError(f"unsupported ALU operation: {operation}")

    return u32(result)
