# Gather all SystemVerilog files
SRCS := $(wildcard *.sv)

# Detect all testbenches
TBS := $(filter %_tb.sv,$(SRCS))

# Strip .sv extension
TB_NAMES := $(basename $(TBS))

# Outputs
SIMS := $(TB_NAMES:%=%.out)
VCDS := $(TB_NAMES:%=%.vcd)

.PHONY: all run waveform clean help watch install uninstall

# Display help information
help:
	@echo "Available targets:"
	@echo "  all      - Compile all testbenches (default)"
	@echo "  run      - Run all simulations and generate VCD files"
	@echo "  waveform - Open GTKWave for the first testbench"
	@echo "  wave-<TB_NAME> - Open GTKWave for a specific testbench (e.g., make wave-counter_tb)"
	@echo "  install  - Copy framework files into another project using rsync"
	@echo "             specify INSTALL_DIR=path (default ../)"
	@echo "  uninstall- Remove files previously installed by 'make install'"
	@echo "             (requires the .verilog_framework_installed record)"
	@echo "  clean    - Remove all compiled simulations and VCD files"
	@echo "  help     - Display this help message"

# Default: build all simulations
all: $(SIMS)

# Compile each testbench
%.out: %.sv $(SRCS)
	iverilog -g2012 -o $@ $^

# Run each simulation to produce VCD
%.vcd: %.out
	vvp $<

# Run all simulations
run: $(VCDS)

# Open GTKWave for the first testbench
waveform: $(VCDS)
	gtkwave $(firstword $(VCDS))

# Open GTKWave for a specific testbench
wave-%: %.vcd
	gtkwave $<

# Automatically re-run simulations when any .sv file changes
watch:
	@ls *.sv | entr -c make run

# Directory where the files will be installed. This is
# the root of the new project (typically the parent dir
# when this repo is added as a submodule).
INSTALL_DIR ?= ..

.PHONY: install uninstall

# Copy everything except VCS artifacts and git metadata
install:
	@if ! command -v rsync >/dev/null; then \
		echo "rsync is required for installation, please install it."; exit 1; \
	fi
	@echo "Installing framework files to $(INSTALL_DIR)"
	rsync -av --exclude='.git' \
		--exclude='*.out' --exclude='*.vcd' \
		--exclude='*.gtkw' --exclude='*.sav' \
		./ "$(INSTALL_DIR)"
	# record what was copied so uninstall can clean up
	@cd $(INSTALL_DIR) && \
		find . -maxdepth 1 ! -name . ! -name .git > .verilog_framework_installed || true

# Remove the files that were installed previously
uninstall:
	@echo "Uninstalling framework files from $(INSTALL_DIR)"
	@if [ ! -f "$(INSTALL_DIR)/.verilog_framework_installed" ]; then \
		echo "No install record found in $(INSTALL_DIR)"; exit 1; \
	fi
	@cd "$(INSTALL_DIR)" && \
		sed 's|^\./||' .verilog_framework_installed | \
		xargs -r rm -rf && \
		rm -f .verilog_framework_installed

clean:
	rm -f $(SIMS) $(VCDS)