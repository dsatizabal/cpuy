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
    input wire enable_tb,
    input wire [7:0] rom_data_in_tb,
    input wire [7:0] icp_value_tb,
    output reg [7:0] ecp_value_tb,
    output reg [7:0] data_out_0_tb,
    output reg [7:0] data_out_1_tb,
    output reg [7:0] data_out_2_tb,
    output wire inhibit_cpu_tb,
    output wire fetcher_inhibitted_tb
);

    // instantiate the DUT
    fetcher fetcher(
        .clk_tb (clk_tb),
        .rst (rst_tb),
        .enable (enable_tb),
        .rom_data_in_tb (rom_data_in_tb),
        .icp_value_tb (icp_value_tb),
        .ecp_value_tb (ecp_value_tb),
        .data_out_0_tb (data_out_0_tb),
        .data_out_1_tb (data_out_1_tb),
        .data_out_2_tb (data_out_2_tb),
        .inhibit_cpu_tb (inhibit_cpu_tb),
        .fetcher_inhibitted_tb (fetcher_inhibitted_tb)
    );

endmodule
