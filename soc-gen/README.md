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

By default these commands use `sim/verilator`. Set `SIM=vcs` to use the VCS
entry point:

```sh
make SIM=vcs CONFIG=RocketConfig verilog
```

For this migration phase, `generators/` contains symlinks to the existing
top-level generator directories and non-generator dependencies are referenced
through `../deps`.

SBT project bases must remain under the build root, so `tools/`, `fpga/`,
`sims/`, and `scripts/` are also exposed inside `soc-gen/` as compatibility
symlinks to `../deps/...`.
