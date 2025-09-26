import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


# Instructions organized in 16 bytes blocks
addlw = [132, 25, 136, 30, 64, 0, 0, 127] # Program ends
sublw = [132, 33, 140, 3, 64, 0, 0, 127] # Program ends
mullw = [132, 120, 145, 220, 7, 64, 128, 7, 65, 0, 127] # Program ends
andlw = [132, 248, 148, 8, 64, 0, 0, 127] # Program ends
orlw = [132, 170, 152, 85, 64, 0, 0, 127] # Program ends
xorlw = [132, 136, 156, 8, 64, 0, 0, 127] # Program ends
addmw = [132, 8, 130, 5, 132, 8, 138, 5, 64, 0, 0, 127] # Program ends
submw = [132, 8, 130, 12, 132, 28, 142, 12, 64, 0, 0, 127] # Program ends
mulmw = [132, 27, 130, 200, 132, 52, 147, 200, 5, 64, 128, 5, 65, 0, 0, 127] # Program ends
xchwm = [135, 15, 55, 132, 66, 160, 15, 64, 128, 15, 65, 0, 0, 127] # Program ends

# Operations with literals
@cocotb.test()
async def add_literal_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = addlw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (addlw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = addlw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 55, f"Unexpected P0: desired 55, got {dut.p0_tb.value}";

@cocotb.test()
async def sub_literal_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = sublw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (sublw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = sublw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 30, f"Unexpected P0: desired 30, got {dut.p0_tb.value}";

@cocotb.test()
async def mul_literal_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = mullw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (mullw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = mullw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 32, f"Unexpected P0: desired 32, got {dut.p0_tb.value}";
    assert dut.p1_tb.value == 103, f"Unexpected P1: desired 103, got {dut.p1_tb.value}";

@cocotb.test()
async def and_literal_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = andlw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (andlw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = andlw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 8, f"Unexpected P0: desired 8, got {dut.p0_tb.value}";

@cocotb.test()
async def or_literal_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = orlw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (orlw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = orlw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 255, f"Unexpected P0: desired 255, got {dut.p0_tb.value}";

@cocotb.test()
async def xor_literal_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = xorlw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (xorlw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = xorlw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 128, f"Unexpected P0: desired 128, got {dut.p0_tb.value}";

# Operations with memory
@cocotb.test()
async def add_memory_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = addmw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (addmw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = addmw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 16, f"Unexpected P0: desired 16, got {dut.p0_tb.value}";

@cocotb.test()
async def sub_memory_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = submw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (submw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = submw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 20, f"Unexpected P0: desired 20, got {dut.p0_tb.value}";

@cocotb.test()
async def mul_memory_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = mulmw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (mulmw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = mulmw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 124, f"Unexpected P0: desired 124, got {dut.p0_tb.value}";
    assert dut.p1_tb.value == 5, f"Unexpected P1: desired 5, got {dut.p1_tb.value}";

@cocotb.test()
async def exchange_work_memory(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = xchwm[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (xchwm[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = xchwm[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 55, f"Unexpected P0: desired 55, got {dut.p0_tb.value}";
    assert dut.p1_tb.value == 66, f"Unexpected P1: desired 66, got {dut.p1_tb.value}";
