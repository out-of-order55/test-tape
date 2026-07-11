#!/usr/bin/env bash

set -e

# this should be run from chipyard repo top
RDIR=$(git rev-parse --show-toplevel)

(
    pushd $RDIR/soc-generator/generator/constellation
    if [ -d espresso ]
    then
	git submodule deinit -f espresso
    fi
    popd
)
(
    pushd $RDIR/dependencies/tools/cde
    git config --local status.showUntrackedFiles no
    popd
)
(
    if [ -d $RDIR/soc-generator/generator/cva6/src/main/resources/cva6/vsrc ]
    then
        pushd $RDIR/soc-generator/generator/cva6/src/main/resources/cva6/vsrc
        if [ -d cva6 ]
        then
	    git submodule deinit -f cva6
        fi
        popd
    fi
)
