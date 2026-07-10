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

For this migration phase, `generator/` contains symlinks to the existing
top-level generator directories and non-generator dependencies are referenced
through `../dep`.

FireSim is exposed through `sims/firesim`, currently as a symlink to the
existing top-level FireSim checkout. Application/software trees are exposed at
the repository top level through `../app`.
