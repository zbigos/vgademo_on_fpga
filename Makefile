SEED = 1

# COCOTB variables
export COCOTB_REDUCED_LOG_FMT=1
export PYTHONPATH := test:$(PYTHONPATH)
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)


NAME = vga_demo
PROJECT = fpga/$(NAME)
SOURCES= src/top.v src/sphere.v src/vga_core.v src/vga_pll.v src/top_fpga.v
ICEBREAKER_DEVICE = hx8k
ICEBREAKER_PIN_DEF = fpga/icoboard.pcf
ICEBREAKER_PACKAGE = ct256
VSIM_ARGS=-t 1ps
SEED = 1
BOARD_ADDR = 192.168.88.250
BOARD_FPREF = /mnt/ramdisc

# COCOTB variables
export COCOTB_REDUCED_LOG_FMT=1

all : test_vga_core

test_toplevel:
	echo "don't run this, it takes a while"
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s vga_demo -g2012 src/top.v src/sphere.v src/vga_core.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_toplevel vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml
	
show_%: %.vcd %.gtkw
	gtkwave $^

# FPGA recipes

show_synth_%: src/%.v
	yosys -p "read_verilog $<; proc; opt; show -stretch -prefix count -colors 2 -width -signed"

%.json: $(SOURCES)
	yosys  -l fpga/yosys.log -p 'synth_ice40 -top top -json $(PROJECT).json' $(SOURCES)

%.asc: %.json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 -l fpga/nextpnr.log --seed $(SEED) --freq 30 --package $(ICEBREAKER_PACKAGE) --$(ICEBREAKER_DEVICE) --asc $@ --pcf $(ICEBREAKER_PIN_DEF) --json $<

%.asc2: %.json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 -l fpga/nextpnr.log --seed $(SEED) --freq 30 --package $(ICEBREAKER_PACKAGE) --$(ICEBREAKER_DEVICE) --asc $@ --pcf $(ICEBREAKER_PIN_DEF) --json fpga/vga_demo.json --routed-svg routed.svg


%.bin: %.asc
	icepack $< $@

prog: $(PROJECT).bin
	@echo "moving" $(PROJECT).bin to $(BOARD_ADDR):$(BOARD_FPREF)/$(NAME).bin
	scp $(PROJECT).bin zbyszek@$(BOARD_ADDR):$(BOARD_FPREF)/$(NAME).bin
	@echo "programming... zbyszek@"$(BOARD_ADDR) "icoprog -p <"$(BOARD_FPREF)/$(NAME).bin
	ssh zbyszek@$(BOARD_ADDR) chmod 766 $(BOARD_FPREF)/$(NAME).bin
	ssh zbyszek@$(BOARD_ADDR) ./flashit.sh


killpi: $(PROJECT).bin
	ssh zbyszek@$(BOARD_ADDR) sudo shutdown -t now
# icoprog $<

# general recipes

lint:
	verible-verilog-lint src/*v --rules_config verible.rules

clean:
	rm -rf *vcd sim_build fpga/*log fpga/*bin test/__pycache__

.PHONY: clean

