from pathlib import Path

from cocotb.runner import get_runner


ROOT = Path(__file__).resolve().parents[2]
BUILD_DIR = ROOT / "sim" / "cocotb"
PROGRAM_FILE = BUILD_DIR / "program.hex"
PROGRAM = [
    0x00500093,
    0x00700113,
    0x002081B3,
    0x04302023,
    0x04002203,
]
SOURCES = [
    ROOT / "rtl" / "core" / "alu.v",
    ROOT / "rtl" / "core" / "regfile.v",
    ROOT / "rtl" / "core" / "imm_gen.v",
    ROOT / "rtl" / "core" / "control.v",
    ROOT / "rtl" / "core" / "instr_mem.v",
    ROOT / "rtl" / "core" / "data_mem.v",
    ROOT / "rtl" / "core" / "riscv_core.v",
]


runner = get_runner("icarus")
BUILD_DIR.mkdir(parents=True, exist_ok=True)
PROGRAM_FILE.write_text(
    "\n".join(f"{word:08x}" for word in PROGRAM + [0x00000013] * (1024 - len(PROGRAM)))
    + "\n",
    encoding="ascii",
)
runner.build(
    sources=[str(source) for source in SOURCES],
    hdl_toplevel="riscv_core",
    build_dir=str(BUILD_DIR),
    build_args=["-g2012"],
    always=True,
)
runner.test(
    hdl_toplevel="riscv_core",
    test_module="test_core",
    test_dir=str(Path(__file__).parent),
    plusargs=[f"+PROGRAM={PROGRAM_FILE}"],
)
