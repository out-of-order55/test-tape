### This is a full chipyard setup

# BUILD BASE FOR CI

FROM ubuntu:20.04 as base
ARG CHIPYARD_HASH

MAINTAINER https://groups.google.com/forum/#!forum/chipyard

SHELL ["/bin/bash", "-c"]

# Install dependencies for ubuntu-req.sh
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    sudo \
    ca-certificates \
    keyboard-configuration \
    console-setup \
    bc \
    unzip

WORKDIR /root

# Install Chipyard
RUN git clone https://github.com/ucb-bar/chipyard.git && \
        cd chipyard && \
        git checkout $CHIPYARD_HASH

# Install Nix with flakes enabled.
RUN sh <(curl -L https://nixos.org/nix/install) --daemon

ENV PATH="/nix/var/nix/profiles/default/bin:/root/.nix-profile/bin:${PATH}"
ENV NIX_CONFIG="experimental-features = nix-command flakes"

# BUILD IMAGE WITH TOOLCHAINS

# Use above build as base
FROM base as base-with-tools

SHELL ["/bin/bash", "-cl"]

# Initialize the repository in the Nix development environment.
RUN cd chipyard && \
        export MAKEFLAGS=-"j $(nproc)" && \
        nix develop -c ./build-setup.sh --skip-firesim --skip-marshal --skip-precompile

# Set up FireMarshal. Building and cleaning br-base.json builds the underlying
# buildroot image (which takes a long time) but doesn't keep all the br-base
# stuff around (since that's faster to rebuild).
RUN cd chipyard && \
        source env.sh && \
        cd app/firemarshal && \
        ./init-submodules.sh && \
        ./marshal build br-base.json && \
        ./marshal clean br-base.json

# Run script to set environment variables on entry
ENTRYPOINT ["chipyard/dep/scripts/entrypoint.sh"]

# END IMAGE CUSTOMIZATIONS

CMD ["/bin/sh"]
