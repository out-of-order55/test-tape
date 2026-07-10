#!/bin/bash

# turn echo on and error on earliest command
set -ex

# get shared variables
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
source $SCRIPT_DIR/defaults.sh

# install Zephyr dependencies
git submodule update --init $LOCAL_CHIPYARD_DIR/app/zephyrproject/zephyr
cd $LOCAL_CHIPYARD_DIR/app/zephyrproject/zephyr/
west init -l .
west config manifest.file west-riscv.yml
west update

# set environment variables for Zephyr
export ZEPHYR_BASE=$LOCAL_CHIPYARD_DIR/app/zephyrproject/zephyr
export ZEPHYR_TOOLCHAIN_VARIANT=cross-compile
export CROSS_COMPILE=$RISCV/bin/riscv64-unknown-elf-


# Build hello world
west build -p -b chipyard_riscv64 samples/chipyard/hello_world/