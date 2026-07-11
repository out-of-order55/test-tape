#!/usr/bin/env bash

# Sets up FireSim for use as a library within Chipyard

set -e
set -o pipefail

CYDIR=$(git rev-parse --show-toplevel)

cd "$CYDIR"

# Reenable the FireSim submodule
git config --unset submodule.soc-generator/sims/firesim.update || true
git submodule update --init --recursive soc-generator/sims/firesim
