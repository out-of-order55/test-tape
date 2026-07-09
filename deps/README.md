# deps transition area

`soc-gen` treats this directory as the home for non-SoC-generator dependencies.

During the first migration phase these entries are symlinks back to the existing
top-level Chipyard directories. This keeps submodule paths stable while the new
`soc-gen` top-level Make/SBT workflow is validated.

Current compatibility links:

- `tools -> ../tools`
- `fpga -> ../fpga`
- `scripts -> ../scripts`
- `sims -> ../sims`
- `software -> ../software`
- `toolchains -> ../toolchains`

The next migration phase can replace these links with real directories and then
update `.gitmodules` paths.

`soc-gen` also exposes selected compatibility links (`tools/`, `fpga/`,
`sims/`, and `scripts/`) inside its own tree so SBT sees every subproject under
the `soc-gen` build root.
