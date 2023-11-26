import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


calli = [135, 100, 44, 171, 32, 0, 132, 45, 65, 0, 0, 127, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         128, 100, 64, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 127] # Program ends

jmp = [132, 90, 64, 163, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       132, 100, 65, 0, 0, 0, 0, 0, 0, 127, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 127] # Program ends

jmpc = [132, 75, 64, 4, 165, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       132, 80, 65, 0, 0, 0, 0, 0, 127, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 127] # Program ends


@cocotb.test()
async def call_ret(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = calli[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (calli[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = calli[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 44, f"Unexpected P0: desired 44, got {dut.p0_tb.value}";
    assert dut.p1_tb.value == 45, f"Unexpected P1: desired 45, got {dut.p0_tb.value}";

@cocotb.test()
async def unconditional_jump(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = jmp[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (jmp[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = jmp[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 90, f"Unexpected P0: desired 90, got {dut.p0_tb.value}";
    assert dut.p1_tb.value == 100, f"Unexpected P1: desired 100, got {dut.p0_tb.value}";

@cocotb.test()
async def jump_if_carry(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = jmpc[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (jmpc[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = jmpc[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 75, f"Unexpected P0: desired 75, got {dut.p0_tb.value}";
    assert dut.p1_tb.value == 80, f"Unexpected P1: desired 80, got {dut.p0_tb.value}";
