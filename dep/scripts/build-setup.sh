#!/usr/bin/env bash

set -euo pipefail

CYDIR=$(git rev-parse --show-toplevel)
source "$CYDIR/dep/scripts/utils.sh"
common_setup

usage() {
    echo "Usage: ${0} [OPTIONS] [riscv-tools]"
    echo ""
    echo "Helper script to initialize Chipyard using the Nix development environment."
    echo ""
    echo "Options"
    echo "  --help -h               : Display this message"
    echo "  --verbose -v            : Verbose printout"
    echo "  --build-circt           : Build CIRCT from source"
    echo "  --skip -s N             : Skip step N"
    echo "  --skip-nix              : Skip Nix environment initialization (step 1)"
    echo "  --skip-submodules       : Skip submodule initialization (step 2)"
    echo "  --skip-toolchain        : Skip toolchain collateral (step 3)"
    echo "  --skip-ctags            : Skip ctags (step 4)"
    echo "  --skip-precompile       : Skip precompiling sources (steps 5/7)"
    echo "  --skip-firesim          : Skip Firesim initialization (steps 6/7)"
    echo "  --skip-marshal          : Skip FireMarshal initialization (steps 8/9)"
    echo "  --skip-clean            : Skip repository cleanup (step 11)"
    exit "$1"
}

TOOLCHAIN_TYPE="riscv-tools"
VERBOSE_FLAG=""
SKIP_LIST=()
BUILD_CIRCT=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage 0 ;;
        riscv-tools)
            TOOLCHAIN_TYPE="$1" ;;
        --verbose|-v)
            VERBOSE_FLAG="$1"
            set -x ;;
        --build-circt)
            BUILD_CIRCT=true ;;
        --skip|-s)
            shift
            SKIP_LIST+=("$1") ;;
        --skip-nix)
            SKIP_LIST+=(1) ;;
        --skip-submodules)
            SKIP_LIST+=(2) ;;
        --skip-toolchain)
            SKIP_LIST+=(3) ;;
        --skip-ctags)
            SKIP_LIST+=(4) ;;
        --skip-precompile)
            SKIP_LIST+=(5 7) ;;
        --skip-firesim)
            SKIP_LIST+=(6 7) ;;
        --skip-marshal)
            SKIP_LIST+=(8 9) ;;
        --skip-clean)
            SKIP_LIST+=(11) ;;
        *)
            error "invalid option $1"
            usage 1 ;;
    esac
    shift
done

run_step() {
    [[ ! " ${SKIP_LIST[*]} " =~ " $1 " ]]
}

begin_step() {
    echo " ========== BEGINNING STEP $1: $2 =========="
}

{
    if run_step 1; then
        begin_step 1 "Nix environment setup"
        command -v nix >/dev/null 2>&1 || die "Nix is required. Install Nix with flakes enabled."
        source "$CYDIR/env.sh"
    fi

    if [ -z "${RISCV:-}" ]; then
        die "RISCV is not set. Source env.sh or omit --skip-nix."
    fi

    if run_step 2; then
        begin_step 2 "Initializing Chipyard submodules"
        "$CYDIR/dep/scripts/init-submodules-no-riscv-tools.sh" --full
    fi

    if run_step 3; then
        begin_step 3 "Building toolchain collateral"
        "$CYDIR/dep/scripts/build-toolchain-extra.sh" "$TOOLCHAIN_TYPE" -p "$RISCV"
    fi

    if run_step 4; then
        begin_step 4 "Running ctags for code navigation"
        "$CYDIR/dep/scripts/gen-tags.sh"
    fi

    if run_step 5; then
        begin_step 5 "Pre-compiling Chipyard Scala sources"
        pushd "$CYDIR/soc-gen/sims/verilator"
        make launch-sbt SBT_COMMAND=";project chipyard; compile"
        make launch-sbt SBT_COMMAND=";project tapeout; compile"
        popd
    fi

    if run_step 6; then
        begin_step 6 "Setting up FireSim"
        "$CYDIR/dep/scripts/firesim-setup.sh"
        "$CYDIR/soc-gen/sims/firesim/gen-tags.sh"

        if run_step 7; then
            begin_step 7 "Pre-compiling FireSim Scala sources"
            pushd "$CYDIR/soc-gen/sims/firesim"
            source sourceme-manager.sh --skip-ssh-setup
            pushd sim
            make sbt SBT_COMMAND="compile"
            popd
            popd
        fi
    fi

    if run_step 8; then
        begin_step 8 "Setting up FireMarshal"
        pushd "$CYDIR/app/firemarshal"
        ./init-submodules.sh

        if run_step 9; then
            begin_step 9 "Pre-compiling FireMarshal buildroot sources"
            source "$CYDIR/dep/scripts/fix-open-files.sh"
            ./marshal ${VERBOSE_FLAG:+$VERBOSE_FLAG} build br-base.json
            ./marshal ${VERBOSE_FLAG:+$VERBOSE_FLAG} build bare-base.json
        fi
        popd
    fi

    if run_step 10 && [ "$BUILD_CIRCT" = true ]; then
        begin_step 10 "Building CIRCT from source"
        "$CYDIR/dep/scripts/build-circt-from-source.sh" --prefix "$RISCV"
    fi

    if run_step 11; then
        begin_step 11 "Cleaning up repository"
        "$CYDIR/dep/scripts/repo-clean.sh"
    fi

    echo "Setup complete!"
} 2>&1 | tee build-setup.log
