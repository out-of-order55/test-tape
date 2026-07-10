#!/usr/bin/env bash

CY_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
export CY_DIR

if ! command -v nix >/dev/null 2>&1; then
    echo "ERROR: Nix is required. Install Nix with flakes enabled before sourcing env.sh." >&2
    return 1 2>/dev/null || exit 1
fi

# Read the Nix shell environment through Bash so this file is also sourceable from zsh.
NIX_PATH=$(cd "$CY_DIR" && nix develop --no-write-lock-file --command bash -c 'printf %s "$PATH"')
NIX_JAVA_HOME=$(cd "$CY_DIR" && nix develop --no-write-lock-file --command bash -c 'printf %s "$JAVA_HOME"')
NIX_FIRTOOL_BIN=$(cd "$CY_DIR" && nix develop --no-write-lock-file --command bash -c 'printf %s "$FIRTOOL_BIN"')
export PATH="$NIX_PATH"
export JAVA_HOME="$NIX_JAVA_HOME"
export FIRTOOL_BIN="$NIX_FIRTOOL_BIN"

NIX_RISCV=$(cd "$CY_DIR" && nix build .#chipyardRiscvTools --no-link --print-out-paths)
export RISCV="$CY_DIR/.nix-riscv"
mkdir -p "$RISCV"
for directory in bin include lib riscv64-unknown-elf; do
    if [ ! -e "$RISCV/$directory" ]; then
        cp -a "$NIX_RISCV/$directory" "$RISCV/$directory"
    fi
done
export PATH="$RISCV/bin:$PATH"

export FIRTOOL_BIN="$(command -v firtool)"
export COURSIER_CACHE="$CY_DIR/.coursier-cache"
export SBT_OPTS="-Dsbt.global.base=$CY_DIR/.sbt -Dsbt.boot.directory=$CY_DIR/.sbt/boot -Dsbt.ivy.home=$CY_DIR/.ivy2 ${SBT_OPTS:-}"
unset NIX_LDFLAGS
export EXTRA_SIM_CXXFLAGS="-O1 ${EXTRA_SIM_CXXFLAGS:-}"
export EXTRA_SIM_LDFLAGS="-no-pie ${EXTRA_SIM_LDFLAGS:-}"

source "$CY_DIR/dep/scripts/fix-open-files.sh"
export PATH="$CY_DIR/app/firemarshal:$PATH"

echo "Chipyard Nix environment"
echo "  RISCV=$RISCV"
echo "  firtool=$FIRTOOL_BIN"
echo "  verilator=$(command -v verilator)"
echo "  java=$JAVA_HOME"
