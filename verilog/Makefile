# cocotb setup
# MODULE = test.test_cpuy
MODULE = test.test_cpuy, test.test_cpuy_alu_instructions_no_ops, test.test_cpuy_alu_instructions_ops, test.test_cpuy_mov_instructions, test.test_cpuy_branching_instructions
export MODULE
TOPLEVEL = tb
VERILOG_SOURCES = tb.v cpuy.v alu.v stack.v timer.v ucode.v

include $(shell cocotb-config --makefiles)/Makefile.sim

synth_cpuy:
	yosys -p "read_verilog cpuy.v; proc; opt; show -colors 2 -width -signed cpuy"

test_cpuy:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s tb -s dump -g2012 dump_cpuy.v cpuy.v alu.v stack.v timer.v ucode.v tb.v
	PYTHONOPTIMIZE=${NOASSERT} vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

gtkwave_cpuy:
	gtkwave cpuy.vcd cpuy.gtkw

formal_cpuy:
	sby -f cpuy.sby
