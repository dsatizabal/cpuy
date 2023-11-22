import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

instructions = [132, 1, 136, 2, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

@cocotb.test()
async def test_fetcher(dut):
    clock = Clock(dut.clk_tb, 10, "us")
    cocotb.fork(clock.start())

    dut.ext_int_tb.value = 0

    dut.rst_tb.value = 1
    await ClockCycles(dut.clk_tb, 2)
    await Timer(10, units="ns");
    dut.rst_tb.value = 0

    await ClockCycles(dut.clk_tb, 2)
    await Timer(10, units="ns");
    
    for i in range(10):
        print(i)
        dut.data_bus_tb.value = instructions[i]
        await ClockCycles(dut.clk_tb, 1)
        await Timer(10, units="ns");
    
    assert dut.p0_tb.value == 3, f"Unexpected result:  desired 3, got {dut.p0_tb.value}";
