# dep

`soc-gen` treats this directory as the home for non-SoC-generator dependencies.

During the first migration phase these entries are symlinks back to the existing
top-level Chipyard directories. This keeps submodule paths stable while the new
`soc-gen` top-level Make/SBT workflow is validated.

Current compatibility links:

- `tools -> ../tools`
- `fpga -> ../fpga`
- `scripts -> ../scripts`
- `toolchains -> ../toolchains`

Application and software trees are exposed through the sibling `app/` entry.
Simulation trees belong to `soc-gen/sims`; FireSim is exposed there through
`soc-gen/sims/firesim`.

The next migration phase can replace these links with real directories and then
update `.gitmodules` paths.
