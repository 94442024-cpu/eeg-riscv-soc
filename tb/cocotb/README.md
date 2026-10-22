# Cocotb Test

From the repository root, run:

```powershell
python tb/cocotb/run.py
```

The test loads a short program into the simulation instruction memory and checks register and data-memory results through cocotb. The Python runner works in native Windows shells without requiring Unix shell utilities. CI should install `requirements-dev.txt` and provide Icarus Verilog before running this target.
