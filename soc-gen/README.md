# soc-gen

`soc-gen` is the SoC generation and simulation top-level.

Primary entry points:

- `make CONFIG=RocketConfig verilog`
- `make CONFIG=RocketConfig emu`
- `make CONFIG=RocketConfig emu-debug`
- `make CONFIG=RocketConfig run BINARY=/abs/path/test.elf`

When using the repository Nix environment, run them through `nix develop` from
the repository root:

```sh
nix develop --command bash -lc 'cd soc-gen && make CONFIG=RocketConfig verilog'
```

By default these commands use `sims/verilator`. Set `SIM=vcs` to use the VCS
entry point:

```sh
make SIM=vcs CONFIG=RocketConfig verilog
```

`generator/` contains the SoC generator sources and submodules. Non-generator
dependencies are stored in the sibling `../dep`. `soc-gen` intentionally does
not contain a `dep/` entry; the SBT build is loaded from the repository root so
`soc-gen/generator` and `dep` are both inside the build root.

The FireSim checkout lives at `sims/firesim`. Application and software trees
live at the repository top level under `../app`.
