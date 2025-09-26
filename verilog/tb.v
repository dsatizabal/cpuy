`default_nettype none
`timescale 1ns/1ns

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test/test_*.py files
	input wire clk_tb,
	input wire rst_tb,
	input wire ext_int_tb,
	input wire [7:0] data_bus_tb,
	output reg [11:0] addr_bus_tb,
	output reg [7:0] p0_tb,
	output reg [7:0] p1_tb
);

    // instantiate the DUT
    cpuy cpuy(
	    .clk (clk_tb),
	    .rst (rst_tb),
	    .ext_int (ext_int_tb),
	    .data_bus (data_bus_tb),
	    .addr_bus (addr_bus_tb),
	    .p0 (p0_tb),
	    .p1 (p1_tb)
    );

endmodule
