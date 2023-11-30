import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


# Instructions organized in 16 bytes blocks
incw = [132, 11, 1, 64, 0, 0, 127] # Program ends
decw = [132, 11, 2, 64, 0, 0, 127] # Program ends
notw = [132, 15, 3, 64, 0, 0, 127] # Program ends
rlw = [132, 1, 6, 64, 0, 0, 127] # Program ends
rrw = [132, 128, 7, 64, 0, 0, 127] # Program ends
rlc = [132, 1, 4, 8, 64, 0, 0, 127] # Program ends
rrc = [132, 2, 4, 9, 64, 0, 0, 127] # Program ends

@cocotb.test()
async def decrement_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = incw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (incw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = incw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 10, f"Unexpected P0: desired 10, got {dut.p0_tb.value}";

@cocotb.test()
async def increment_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = decw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (decw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = decw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 12, f"Unexpected P0: desired 12, got {dut.p0_tb.value}";

@cocotb.test()
async def not_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = notw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (notw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = notw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 240, f"Unexpected P0: desired 240, got {dut.p0_tb.value}";

@cocotb.test()
async def rotate_left_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = rlw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (rlw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = rlw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 2, f"Unexpected P0: desired 2, got {dut.p0_tb.value}";

@cocotb.test()
async def rotate_right_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = rrw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (rrw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = rrw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 64, f"Unexpected P0: desired 64, got {dut.p0_tb.value}";

@cocotb.test()
async def rotate_left_through_carry_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = rlc[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (rlc[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = rlc[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 3, f"Unexpected P0: desired 3, got {dut.p0_tb.value}";

# Operations with memory
@cocotb.test()
async def rotate_right_through_carry_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = rrc[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (rrc[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = rrc[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 129, f"Unexpected P0: desired 129, got {dut.p0_tb.value}";
