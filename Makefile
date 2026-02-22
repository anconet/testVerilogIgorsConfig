# Gather all SystemVerilog files
SRCS := $(wildcard *.sv)

# Detect all testbenches
TBS := $(filter %_tb.sv,$(SRCS))

# Strip .sv extension
TB_NAMES := $(basename $(TBS))

# Outputs
SIMS := $(TB_NAMES:%=%.out)
VCDS := $(TB_NAMES:%=%.vcd)

.PHONY: all run waveform clean help watch

# Display help information
help:
	@echo "Available targets:"
	@echo "  all      - Compile all testbenches (default)"
	@echo "  run      - Run all simulations and generate VCD files"
	@echo "  waveform - Open GTKWave for the first testbench"
	@echo "  wave-<TB_NAME> - Open GTKWave for a specific testbench (e.g., make wave-counter_tb)"
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

clean:
	rm -f $(SIMS) $(VCDS)