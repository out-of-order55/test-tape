#!/usr/bin/env bash

CY_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
export CY_DIR

if ! command -v nix >/dev/null 2>&1; then
    echo "ERROR: Nix is required. Install Nix with flakes enabled before sourcing env.sh." >&2
    return 1 2>/dev/null || exit 1
fi

# Read the Nix shell environment through Bash so this file is also sourceable from zsh.
NIX_ENV=$(cd "$CY_DIR" && nix develop --no-write-lock-file --command bash -c \
    'printf "%s\n%s\n%s" "$PATH" "$JAVA_HOME" "$RISCV"')
NIX_PATH=${NIX_ENV%%$'\n'*}
NIX_ENV_REST=${NIX_ENV#*$'\n'}
NIX_JAVA_HOME=${NIX_ENV_REST%%$'\n'*}
NIX_RISCV=${NIX_ENV_REST#*$'\n'}
export PATH="$NIX_PATH"
export JAVA_HOME="$NIX_JAVA_HOME"
NIX_FIRTOOL=$(command -v firtool)

export RISCV="$CY_DIR/.nix-riscv"
mkdir -p "$RISCV"
for directory in bin include lib riscv64-unknown-elf; do
    if [ ! -e "$RISCV/$directory" ]; then
        cp -a "$NIX_RISCV/$directory" "$RISCV/$directory"
    fi
done

# Keep the local toolchain prefix writable for the extra tools built by build-setup.sh.
find -P "$RISCV" -type d -exec chmod u+rwx {} +
while IFS= read -r -d '' link; do
    target=$(readlink -f "$link" 2>/dev/null || true)
    case "$target" in
            /nix/store/*)
            temporary_dir=$(mktemp -d "${TMPDIR:-/tmp}/chipyard-nix-link.XXXXXX")
            cp -aL "$link" "$temporary_dir/value"
            chmod -R u+rwX "$temporary_dir/value"
            rm "$link"
            mv "$temporary_dir/value" "$link"
            rmdir "$temporary_dir"
            ;;
    esac
done < <(find "$RISCV" -type l -print0)

# The local toolchain prefix persists across shell invocations. Refresh its
# firtool link whenever the flake changes so it cannot mask the Nix version.
ln -sfn "$NIX_FIRTOOL" "$RISCV/bin/firtool"

export PATH="$RISCV/bin:$PATH"

export FIRTOOL_BIN="$NIX_FIRTOOL"
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
