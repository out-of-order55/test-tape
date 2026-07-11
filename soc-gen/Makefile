#########################################################################################
# soc-gen top-level entrypoint
#########################################################################################

SIM ?= verilator

ifeq ($(SIM),verilator)
sim_make_dir := $(CURDIR)/sims/verilator
else ifeq ($(SIM),vcs)
sim_make_dir := $(CURDIR)/sims/vcs
else
$(error Unsupported SIM='$(SIM)'. Use SIM=verilator or SIM=vcs)
endif

.DEFAULT_GOAL := help

APP_TESTS_DIR ?= $(CURDIR)/../app/tests
GEMMINI_TESTS_DIR ?= $(CURDIR)/generator/gemmini/software/gemmini-rocc-tests
GEMMINI_TEST ?= mvin_mvout

.PHONY: verilog firrtl emu emu-debug run run-fast run-debug clean clean-sim clean-sim-debug \
	rocket-hello boom-hello gemmini-test \
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

rocket-hello:
	cmake -S $(APP_TESTS_DIR) -B $(APP_TESTS_DIR)/build -D CMAKE_BUILD_TYPE=Debug
	cmake --build $(APP_TESTS_DIR)/build --target hello
	$(MAKE) CONFIG=RocketConfig run BINARY=$(APP_TESTS_DIR)/build/hello.riscv

boom-hello:
	cmake -S $(APP_TESTS_DIR) -B $(APP_TESTS_DIR)/build -D CMAKE_BUILD_TYPE=Debug
	cmake --build $(APP_TESTS_DIR)/build --target hello
	$(MAKE) CONFIG=SmallBoomV3Config run BINARY=$(APP_TESTS_DIR)/build/hello.riscv

gemmini-test:
	cd $(GEMMINI_TESTS_DIR) && ./build.sh
	$(MAKE) CONFIG=GemminiRocketConfig run BINARY=$(GEMMINI_TESTS_DIR)/build/bareMetalC/$(GEMMINI_TEST)-baremetal

print-%:
	$(MAKE) -C $(sim_make_dir) $@
