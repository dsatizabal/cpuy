`default_nettype none
`timescale 1ns/1ns
`define Proteus

// A simple 8-bits CPU with timer and interrupt support using external ROM and RAM
module cpuy(
	input wire clk,
	input wire rst,
	input wire ext_int,
	input reg [7:0] data_bus,
	output reg [11:0] addr_bus,
	output reg [7:0] p0,
	output reg [7:0] p1
);
	// Some internal parameters definitions
	localparam 		RAM_SIZE = 256;
	localparam 		RESET_VECTOR = 12'h000;
	localparam 		T0_INTERRUPTION_VECTOR = 12'h010; // Timer 0
	localparam 		T1_INTERRUPTION_VECTOR = 12'h020; // Timer 1
	localparam 		IE_INTERRUPTION_VECTOR = 12'h030; // External Interruption

	output	[11:0]	pc; // program counter
	reg				inhibit_pc;
	reg				cpu_state; // Current status of CPU state machine

	// CPU State machine statuses
	localparam 		FETCHING_OPCODE = 0;
	localparam 		FETCHING_OPERANDS = 1;
	localparam 		EXECUTING = 2;
	localparam 		FETCHING_RAM = 3;
	localparam 		MOVING_TO_RAM = 4;

	// Flags register
	// X X X X - X S Z C
	reg		[7:0]   flags;

	// CPU Control
	// [GIE] [ExtIE] [T1IE] [T0IE] _ [X] [ExtIF] [T1IF] [T0IF]
	reg		[7:0]   cpu_cfg;

	// IO Ports
	reg		[7:0] 	ports 	[1:0];

	// Work register
	reg		[7:0]   w;

	// 8 General purpose internal registers
	reg		[7:0] 	registers	[7:0];

	// 256 bytes memory bank
	reg 	[0:7] 	ram[RAM_SIZE - 1:0];

	reg		[7:0]   op_code;
	reg		[4:0]   sub_op_code_op;
	reg		[2:0]   sub_op_code_nop;
	reg		[2:0]   implicit_index;
	reg		[1:0]   operands_count;
	reg		[1:0]   current_operand;
	reg		[7:0] 	operands	[1:0];

	// Timer control
	// [x] [T1AR] [T1DIR] [T1E] _ [x] [T0AR] [T0DIR] [T0E]
	reg		[7:0]   tmr_cfg;

    // Peripherals instantiation
    alu alu(
        .clk (clk),
        .rst (),
        .enable (),
        .operation (),
        .op1 (),
        .op2 (),
        .cpu_carry (),
        .result_l (),
        .result_h (),
        .carry (),
        .zero (),
        .sign ()
    );

    timer tmr0 (
        .clk (clk),
        .enable (tmr_cfg[0]),
        .set (),
        .direction (tmr_cfg[1]),
        .auto_reload (tmr_cfg[2]),
        .done_ack (),
        .count (),
        .done ()
    );

    timer tmr1 (
        .clk (clk),
        .enable (tmr_cfg[4]),
        .set (),
        .direction (tmr_cfg[5]),
        .auto_reload (tmr_cfg[6]),
        .done_ack (),
        .count (),
        .done ()
    );

    stack stack (
        .clk (clk),
        .rst (),
        .enable (),
        .operation (),
        .data_in (),
        .data_out (),
        .full (),
        .empty ()
    );

	always @(posedge clk) begin
		if (rst) begin
			pc <= RESET_VECTOR;
			cpu_state <= FETCHING_OPCODE;
			inhibit_pc <= 0;

			flags <= 8'b0000_0000;
			w <= 0;

			op_code <= 8'h00;
			operands_count <= 2'b00;
			current_operand <= 2'b00;
			addr_set <= 1'b0;

			cpu_cfg <= 8'b0000_0000;
			tmr_cfg <= 8'b0000_0000;
		end else begin
			// Timer and interrupt control
            // TODO

			case (cpu_state)
				FETCHING_OPCODE begin
					op_code <= data_bus;

					if (op_code[7]) begin // Instructions with operands
						cpu_state <= FETCHING_OPERANDS;
						operands_count <= op_code[7] + 1'b1;
						current_operand <= 0;
					end else begin // Instructions without operands
						cpu_state <= EXECUTING;
					end
				end

				FETCHING_OPERANDS begin // Fetch operands indicated in the opcode
					if (current_operand < operands_count) begin
						operands[current_operand] <= data_bus;
						current_operand <= current_operand + 1'b1;

						if (current_operand >= operands_count) begin
							cpu_state <= EXECUTING;
						end
					end else begin
						cpu_state <= EXECUTING; // Never should happen
					end
				end

				EXECUTING begin

				end

				FETCHING_RAM begin

				end

				MOVING_TO_RAM begin

				end

			endcase

			if (!inhibit_pc) begin
				pc <= pc + 1;
			end
		end
	end
endmodule
