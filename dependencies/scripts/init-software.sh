#!/usr/bin/env bash

# exit script if any command fails
set -e
set -o pipefail

# Enable submodule update for software submodules
git config --unset submodule.app/nvdla-workload.update || :
git config --unset submodule.app/coremark.update || :
git config --unset submodule.app/spec2017.update || :

# Initialize local software submodules
git submodule update --init --recursive applications/nvdla-workload
git submodule update --init --recursive applications/coremark
git submodule update --init --recursive applications/spec2017
