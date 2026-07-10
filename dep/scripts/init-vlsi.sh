#!/usr/bin/env bash

# exit script if any command fails
set -e
set -o pipefail

# exit script if the Chipyard Nix environment is not active
if [[ -z "${RISCV:-}" ]]; then
    echo 'ERROR: Chipyard Nix environment not active. Please source env.sh and run this script again.'
    exit 1
fi

# Explicitly install mentor plugins for Calibre if you have access
if [[ $1 == "calibre" ]]; then
    git clone git@github.com:ucb-bar/hammer-mentor-plugins.git vlsi/hammer-mentor-plugins
    pip install -e vlsi/hammer-mentor-plugins
fi

# Initialize HAMMER tech plugin
# Install the selected technology plugin into the active Python environment.
if [[ $1 != *asap7* ]] && [[ $1 != *sky130* ]]; then
    git submodule update --init --recursive vlsi/hammer-$1-plugin
    pip install -e vlsi/hammer-$1-plugin
fi
