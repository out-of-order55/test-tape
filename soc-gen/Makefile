#########################################################################################
# soc-gen top-level entrypoint
#########################################################################################

SIM ?= verilator

ifeq ($(SIM),verilator)
sim_make_dir := $(CURDIR)/sim/verilator
else ifeq ($(SIM),vcs)
sim_make_dir := $(CURDIR)/sim/vcs
else
$(error Unsupported SIM='$(SIM)'. Use SIM=verilator or SIM=vcs)
endif

.DEFAULT_GOAL := help

.PHONY: verilog firrtl emu emu-debug run run-fast run-debug clean clean-sim clean-sim-debug \
	launch-sbt find-configs find-config-fragments run-firtool run-uniquify help

verilog firrtl clean clean-sim clean-sim-debug launch-sbt find-configs find-config-fragments run-firtool run-uniquify help:
	$(MAKE) -C $(sim_make_dir) $@

emu:
	$(MAKE) -C $(sim_make_dir) default

emu-debug:
	$(MAKE) -C $(sim_make_dir) debug

run:
	$(MAKE) -C $(sim_make_dir) run-binary

run-fast:
	$(MAKE) -C $(sim_make_dir) run-binary-fast

run-debug:
	$(MAKE) -C $(sim_make_dir) run-binary-debug

print-%:
	$(MAKE) -C $(sim_make_dir) $@
