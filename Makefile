# cocotb setup
MODULE = test.test_fetcher
export MODULE
TOPLEVEL = tb
VERILOG_SOURCES = tb.v

include $(shell cocotb-config --makefiles)/Makefile.sim

synth_alu:
	yosys -p "read_verilog fetcher.v; proc; opt; show -colors 2 -width -signed fetcher"

test_alu:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s tb -s dump -g2012 dump_fetcher.v fetcher.v tb.v
	PYTHONOPTIMIZE=${NOASSERT} vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

gtkwave_alu:
	gtkwave fetcher.vcd fetcher.gtkw

formal_alu:
	sby -f fetcher.sby
