# RTL Tests

Run the complete local regression from the repository root:

```powershell
make test
```

The Makefile uses Icarus Verilog for RTL tests and the project Python environment for the golden-model tests. Generated `.vvp` files are placed under `sim/build/` and ignored by Git.
