import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


movlw = [132, 25, 64, 0, 0, 127] # Program ends
movlm_mw = [135, 5, 23, 128, 5, 64, 0, 0, 127] # Program ends
movwm_mw = [132, 180, 130, 16, 132, 0, 128, 16, 64, 0, 0, 127] # Program ends

@cocotb.test()
async def mov_literal_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = movlw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (movlw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = movlw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 25, f"Unexpected P0: desired 25, got {dut.p0_tb.value}";

@cocotb.test()
async def mov_work_to_mem_and_mem_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = movwm_mw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (movwm_mw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = movwm_mw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 180, f"Unexpected P0: desired 180, got {dut.p0_tb.value}";

@cocotb.test()
async def mov_literal_to_mem_and_mem_to_work(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 1)
    dut.data_bus_tb.value = movlm_mw[0]
    await ClockCycles(dut.clk_tb, 1)

    while True:
        if (movlm_mw[dut.addr_bus_tb.value] == 127):
            break

        dut.data_bus_tb.value = movlm_mw[dut.addr_bus_tb.value]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(1, units="ns");
    
    assert dut.p0_tb.value == 23, f"Unexpected P0: desired 23, got {dut.p0_tb.value}";
