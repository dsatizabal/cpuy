`default_nettype none
`timescale 1ns/1ns
`define Proteus

// A simple 8-bits CPU with timer and interrupt support using external ROM and RAM
module cpuy(
	input wire clk,
	input wire rst,
	input wire ext_int,
	input wire [7:0] data_bus,
	output reg [11:0] addr_bus,
	output reg [7:0] p0,
	output reg [7:0] p1
);
	assign addr_bus = pc;
	assign p0 = ports[0];
	assign p1 = ports[1];

	// Some internal parameters definitions
	localparam 		RAM_SIZE = 256;
	localparam 		RESET_VECTOR = 12'h000;
	localparam 		EI_INTERRUPTION_VECTOR = 12'h010; // External Interruption
	localparam 		T0_INTERRUPTION_VECTOR = 12'h020; // Timer 0
	localparam 		T1_INTERRUPTION_VECTOR = 12'h030; // Timer 1

	// Interruption sources
	localparam		NO_INTERRUPTION = 0; // None
	localparam		EI_INTERRUPTION = 1; // External Interruption
	localparam 		T0_INTERRUPTION = 2; // Timer 0
	localparam 		T1_INTERRUPTION = 3; // Timer 1

	reg	[11:0]		pc; // program counter
	reg				cpu_state; // Current status of CPU state machine
	reg 			interrupt_source;
	reg 			interrupt_sources_inhibit;

	// CPU State machine statuses
	localparam 		FETCHING_OPCODE = 0;
	localparam 		FETCHING_OPERANDS = 1;
	localparam 		EXECUTING = 2;
	localparam 		INTERRUPT_REDIRECTION = 3;

	// Flags register
	// X X X X - X S Z C
	reg		[7:0]   flags;

	// CPU Control
	// [GIE] [ExtIE] [T0IE] [T1IE] _ [X] [X] [X] [X]
	reg		[7:0]   cpu_cfg;

	// IO Ports
	reg		[7:0] 	ports 	[1:0];

	// Work register
	reg		[7:0]   w;
	reg		[7:0]   w_swap; // For internal use only

	// 8 General purpose internal registers
	reg		[7:0] 	registers	[7:0];

	// 256 bytes memory bank
	reg 	[0:7] 	ram[RAM_SIZE - 1:0];

	reg		[7:0]   op_code;
	reg		[1:0]   operands_count;
	reg		[1:0]   current_operand;
	reg		[7:0] 	operands	[1:0];
	reg		[7:0] 	operands_cpy	[1:0]; // For internal use only

	// Timer control
	// [x] [T1AR] [T1DIR] [T1E] _ [x] [T0AR] [T0DIR] [T0E]
	reg		[7:0]   tmr_cfg;

    // Peripherals instantiation
	// ALU control signals
	reg rst_alu;
	reg enable_alu;
	reg result_h_alu;
	reg result_l_alu;
	reg carry_out_alu;
	reg zero_out_alu;
	reg sign_out_alu;

    alu alu(
        .clk (clk),
        .rst (rst_alu),
        .enable (enable_alu),
        .operation (op_code),
        .op1 (operands[0]),
        .op2 (operands[1]),
        .cpu_carry (flags[0]),
        .result_l (result_l_alu),
        .result_h (result_h_alu),
        .carry (carry_out_alu),
        .zero (zero_out_alu),
        .sign (sign_out_alu)
    );

	// T0 control signals
	reg set_t0;
	reg done_ack_t0;
	reg done_ack_t0;
	reg done_t0;

    timer tmr0 (
        .clk (clk),
        .enable (tmr_cfg[0]),
        .set (set_t0),
        .direction (tmr_cfg[1]),
        .auto_reload (tmr_cfg[2]),
        .done_ack (done_ack_t0),
        .count ({ registers[1], registers[0] }),
        .done (done_t0)
    );

	// T1 control signals
	reg set_t1;
	reg done_ack_t1;
	reg done_ack_t1;
	reg done_t1;

    timer tmr1 (
        .clk (clk),
        .enable (tmr_cfg[4]),
        .set (set_t1),
        .direction (tmr_cfg[5]),
        .auto_reload (tmr_cfg[6]),
        .done_ack (done_ack_t1),
        .count ({ registers[3], registers[2] }),
        .done (done_t1)
    );

	// Stack control signals
	reg rst_stack;
	reg enable_stack;
	reg rst_stack;
	reg operation_stack;
	reg [15:0] data_out_stack;
	reg full_stack;
	reg empty_stack;

    stack stack (
        .clk (clk),
        .rst (rst_stack),
        .enable (enable_stack),
        .operation (operation_stack),
        .data_in (pc),
        .data_out (data_out_stack),
        .full (full_stack),
        .empty (empty_stack)
    );

	// uCode control signals
	reg alu_operation_ucode;
	reg alu_multibyte_result_ucode;
	reg jump_operation_ucode;
	reg jump_condition_ucode;
	reg mov_operation_ucode;
	reg destination_w_ucode;
	reg destination_flags_ucode;
	reg destination_memory_ucode;
	reg destination_registers_ucode;
	reg destination_ports_ucode;
	reg destination_index_ucode;
	reg [2:0] ram_operand_ucode;
	reg duplicate_w_ucode;
	reg source_ports_ucode;
	reg source_registers_ucode;

	reg stack_operation_ucode;
	reg stack_direction_ucode;
	reg destination_cpu_config_ucode;
	reg destination_timers_config_ucode;

	ucode ucode (
		.clk (clk),
		.opcode (op_code),
		.w (w),
		.carry (flags[0]),
		.zero (flags[1]),
		.alu_operation (alu_operation_ucode),
		.alu_multibyte_result (alu_multibyte_result_ucode),
		.jump_operation (jump_operation_ucode),
		.jump_condition (jump_condition_ucode),
		.mov_operation (mov_operation_ucode),
		.destination_w (destination_w_ucode),
		.destination_flags (destination_flags_ucode),
		.destination_memory (destination_memory_ucode),
		.destination_registers (destination_registers_ucode),
		.destination_ports (destination_ports_ucode),
		.destination_index (destination_index_ucode),
		.ram_operand (ram_operand_ucode),
		.duplicate_w (duplicate_w_ucode),
		.source_ports (source_ports_ucode),
		.source_registers (source_registers_ucode),
		.stack_operation (stack_operation_ucode),
		.stack_direction (stack_direction_ucode),
		.destination_cpu_config (destination_cpu_config_ucode),
		.destination_timers_config (destination_timers_config_ucode)
	);

	always @(posedge clk) begin
		if (rst) begin
			pc <= RESET_VECTOR;
			cpu_state <= FETCHING_OPCODE;

			flags <= 8'b0000_0000;
			w <= 0;

			op_code <= 8'h00;
			operands_count <= 2'b00;
			current_operand <= 2'b00;

			cpu_cfg <= 8'b0000_0000;
			tmr_cfg <= 8'b0000_0000;

			interrupt_source <= 0;
			interrupt_sources_inhibit <= 0;
		end else begin
			// Timer and interrupt control
			if (cpu_cfg[7] & interrupt_source == 0) begin // Global Interruption enable, cannot trigger interrupt if other is in course
				if (cpu_cfg[6]) begin // External interruption enable
					if (ext_int) begin
						interrupt_source <= EI_INTERRUPTION;
						interrupt_sources_inhibit <= 1;
					end if
				end
				if (cpu_cfg[5] & !interrupt_sources_inhibit) begin // Timer 0 interruption enable
					if (done_t0) begin
						interrupt_source <= T0_INTERRUPTION;
						interrupt_sources_inhibit <= 1;
					end if
				end
				if (cpu_cfg[4] & !interrupt_sources_inhibit) begin // Timer 1 interruption enable
					if (done_t1) begin
						interrupt_source <= T1_INTERRUPTION;
					end if
				end

				if (interrupt_source > 0) begin
					// TODO: validate that stack isn't full and properly handle exception
					enable_stack <= 1;
					operation_stack <= 1; // Push for interruption redirection
					cpu_state <= INTERRUPT_REDIRECTION;
				end
			end

			case (cpu_state)
				INTERRUPT_REDIRECTION: begin
					enable_stack <= 0;
					interrupt_sources_inhibit <= 1;
					if (interrupt_source == EI_INTERRUPTION) begin
						pc <= EI_INTERRUPTION_VECTOR;
					end
					if (interrupt_source == T0_INTERRUPTION) begin
						pc <= T0_INTERRUPTION_VECTOR;
					end
					if (interrupt_source == T1_INTERRUPTION) begin
						pc <= T1_INTERRUPTION_VECTOR;
					end

					cpu_state <= FETCHING_OPCODE;
				end
				FETCHING_OPCODE: begin
					op_code <= data_bus;

					if (op_code[7]) begin // Instructions with operands
						cpu_state <= FETCHING_OPERANDS;
						operands_count <= op_code[7] + 1'b1;
						current_operand <= 0;
					end else begin // Instructions without operands
						cpu_state <= EXECUTING;
					end

					// Ret instruction
					if (stack_operation_ucode & !stack_direction_ucode) begin
						// TODO: validate that stack isn't empty and properly handle exception
						enable_stack <= 1;
						operation_stack <= 0; // Pop for Ret from call
					end

					pc <= pc + 1;
				end

				FETCHING_OPERANDS: begin // Fetch operands indicated in the opcode
					if (current_operand < operands_count) begin
						operands[current_operand] <= data_bus;
						operands_cpy[current_operand] <= data_bus;

						current_operand <= current_operand + 1'b1;

						if (current_operand >= operands_count) begin
							if (ram_operand_ucode) begin
								operands[0] <= ram[operands_cpy[0]];
							end

							// Call instruction
							if (stack_operation_ucode & stack_direction_ucode) begin
								// TODO: validate that stack isn't full and properly handle exception
								enable_stack <= 1;
								operation_stack <= 1; // Push for call
							end

							cpu_state <= EXECUTING;
						end
					end else begin
						cpu_state <= EXECUTING; // Never should happen
					end

					if (duplicate_w_ucode) begin
						w_swap <= w;
					end

					pc <= pc + 1;
				end

				EXECUTING: begin
					// alu_operation, mov_operation and jump_operation are mutually exclusive
					if (alu_operation_ucode) begin
						w <= result_l_alu;
						flags[0] <= carry_out_alu;
						flags[1] <= zero_out_alu;
						flags[2] <= sign_out_alu;

						if (alu_multibyte_result_ucode) begin
							ram[operands[2]] <= result_h_alu;
						end
					end

					if (mov_operation_ucode) begin
						if (destination_flags_ucode) begin
							flags[0] <= carry_out_alu;
						end

						if (destination_registers_ucode) begin
							registers[destination_index_ucode] <= w;
						end

						if (destination_ports_ucode) begin
							ports[destination_index_ucode] <= w;
						end						

						if (destination_w_ucode & destination_memory_ucode) begin
							w <= ram[operands[0]];
							ram[operands[0]] <= w_swap;
						end

						if (destination_cpu_config_ucode) begin
							cpu_cfg <= w;
						end

						if (destination_timers_config_ucode) begin
							tmr_cfg <= w; // TODO set corresponding timer for at least a clk cycle
						end

						if (destination_w_ucode) begin
							if (source_ports_ucode) begin
								w <= ports[destination_index_ucode];
							end else if (source_registers_ucode) begin
								w <= registers[destination_index_ucode];
							end else if (destination_memory_ucode) begin
								w <= ram[operands[0]];
								ram[operands[0]] <= w_swap;
							end else begin
								w <= operands[0];
							end
						end
					end

					if (jump_operation_ucode & jump_condition_ucode) begin
						pc <= { operands[1], operands[0] };
					end

					if (stack_operation_ucode) begin
						enable_stack <= 0;

						if (stack_direction_ucode) begin // Push for call
							pc <= { operands[1], operands[0] };
						end else begin // Pop for Ret
							pc <= data_out_stack;
							interrupt_source <= NO_INTERRUPTION; // TODO: Maybe a Reti instruction is in order, this limits interruption handle to no calls
						end
					end

					cpu_state <= FETCHING_OPERANDS;
				end

			endcase
		end
	end
endmodule
