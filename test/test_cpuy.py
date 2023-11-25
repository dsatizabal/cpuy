import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

# Instructions organized in 16 bytes blocks
instructions = [132, 135, 136, 2, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, # Movlw 135, Addlw 2, MovwP0
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 127] # Program ends

instructions2 = [163, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, # Jmp 40h
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                132, 135, 136, 2, 64, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, # Movlw 135, Addlw 2, MovWp0, Ret
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                132, 20, 80, 132, 0, 81, 132, 0, 96, 63, 132, 0, 101, 103, 62, 0, # Movlw 20, MovwR0, Movlw 0, MovwR1, Movlw 0, Setb 0, TmrCfg, Movlw 0, Setb 5, Setb 7, CpuCfg
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                5, 132, 15, 136, 5, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, # ClrC, Movlw 15, Addlw 5, MovWP1
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 127] # Program ends

@cocotb.test()
async def simple_add(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = instructions[0]
    await ClockCycles(dut.clk_tb, 1)

    for i in range(1, 15):
        dut.data_bus_tb.value = instructions[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 137, f"Unexpected result:  desired 137, got {dut.p0_tb.value}";


@cocotb.test()
async def test_jump_timer_interruption(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = instructions2[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (instructions2[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = instructions2[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 137, f"Unexpected P0:  desired 137, got {dut.p0_tb.value}";
    assert dut.p1_tb.value == 20, f"Unexpected P1:  desired 20, got {dut.p1_tb.value}";
