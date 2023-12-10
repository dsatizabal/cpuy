`default_nettype none

// A simple 8-bits CPU with timer and interrupt support using external ROM
module cpuy(
	input wire clk,
	input wire rst,
	input wire ext_int,
	input wire [7:0] data_bus,
	input wire [7:0] p0in,
	input wire [3:0] p1in,
	output wire [9:0] addr_bus,
	output wire [7:0] p0out,
	output wire [3:0] p1out,
	output wire [7:0] p0cfg,
	output wire [3:0] p1cfg
);
	assign addr_bus = pc;

	// TODO: Port cfg insntruction, and how to read from propper source according to por cfg
	assign p0out = ports[0];
	assign p1out = ports[1][3:0];

	assign p0cfg = ports_cfg[0];
	assign p1cfg = ports_cfg[1][3:0];

	// Some internal parameters definitions
	localparam 		RAM_SIZE = 256;
	localparam 		RESET_VECTOR = 10'b00_0000_0000;
	localparam 		EI_INTERRUPTION_VECTOR = 10'b00_0001_0000; // External Interruption 0x10
	localparam 		T0_INTERRUPTION_VECTOR = 10'b00_0010_0000; // Timer 0 0x20
	localparam 		T1_INTERRUPTION_VECTOR = 10'b00_0011_0000; // Timer 1 0x30
	// CPU State machine statuses
	localparam 		RESETTING = 0;
	localparam 		FETCHING_OPCODE = 1;
	localparam 		FETCHING_OPERANDS = 2;
	localparam 		POPPING_STACK = 3;
	localparam 		EXECUTING = 4;
	localparam 		INTERRUPT_REDIRECTION = 5;
	// Interruption sources
	localparam		NO_INTERRUPTION = 0; // None
	localparam		EI_INTERRUPTION = 1; // External Interruption
	localparam 		T0_INTERRUPTION = 2; // Timer 0
	localparam 		T1_INTERRUPTION = 3; // Timer 1

	reg	[9:0]		pc; // program counter
	reg	[2:0]		cpu_state; // Current state of CPU state machine
	reg	[1:0]		reset_counter;
	reg [2:0]		interrupt_source;
	reg 			interrupt_sources_inhibit;

	// Flags register
	// X X X X - X S Z C
	reg		[7:0]   flags;

	// CPU Control
	// [GIE] [ExtIE] [T0IE] [T1IE] _ [X] [X] [X] [X]
	reg		[7:0]   cpu_cfg;

	// IO Ports
	reg		[7:0] 	ports 		[1:0];
	reg		[7:0] 	ports_cfg 	[1:0];

	// Work register
	reg		[7:0]   w;
	reg		[7:0]   w_swap; // For internal use only

	// 8 General purpose internal registers
	reg		[7:0] 	registers	[7:0];

	// 256 bytes memory bank
	reg 	[7:0] 	ram[RAM_SIZE - 1:0];

	reg		[7:0]   op_code;
	reg		[1:0]   operands_count;
	reg		[1:0]   current_operand;
	reg		[7:0] 	operands	[1:0];

	// Timer control
	// [x] [T1AR] [T1DIR] [T1E] _ [x] [T0AR] [T0DIR] [T0E]
	reg		[7:0]   tmr_cfg;

    // Peripherals instantiation
	// ALU control signals
	reg enable_alu;
	reg [7:0] result_h_alu;
	reg [7:0] result_l_alu;
	reg carry_out_alu;
	reg zero_out_alu;
	reg sign_out_alu;

    alu alu(
        .enable (enable_alu),
        .operation (op_code),
        .op1 (w),
        .op2 (operands[0]),
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
	reg enable_stack;
	reg rst_stack;
	reg operation_stack;
	reg [9:0] data_out_stack;
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
	reg [2:0] destination_index_ucode;
	reg ram_operand_ucode;
	reg duplicate_w_ucode;
	reg source_ports_ucode;
	reg source_registers_ucode;
	reg stack_operation_ucode;
	reg stack_direction_ucode;
	reg destination_cpu_config_ucode;
	reg destination_timer_config_ucode;
	reg destination_ports_config_ucode;
	reg source_operands_ucode;

	ucode ucode (
		.opcode (op_code),
		.w (w),
		.carry (flags[0]),
		.zero (flags[1]),
		.sign(flags[2]),
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
		.destination_timer_config (destination_timer_config_ucode),
		.destination_ports_config (destination_ports_config_ucode),
		.source_operands(source_operands_ucode)
	);

	// DEBUG REGION
	/*
	integer i;
	initial begin
	for (i = 0; i < RAM_SIZE; i = i + 1)
		ram[i] = 0;
	end

	generate
	genvar o;
	for(o = 0; o < 2; o = o + 1) begin: operadns_dump
		wire [7:0] ops;
		assign ops = operands[o];
	end
	endgenerate

	generate
	genvar m;
	for(m = 0; m < 32; m = m + 1) begin: ram_dump
		wire [7:0] mems;
		assign mems = ram[m];
	end
	endgenerate

	generate
	genvar r;
	for(r = 0; r < 8; r = r + 1) begin: registers_dump
		wire [31:0] tmp;
		assign tmp = registers[r];
	end
	endgenerate
	*/
	// END DEBUG REGION

	always @(posedge clk) begin
		if (rst) begin
			reset_counter <= 1;
			cpu_state <= RESETTING;
		end else begin
			case (cpu_state)
				RESETTING: begin
					if (reset_counter == 0) begin
						cpu_state <= FETCHING_OPCODE;
						enable_alu <= 1'b1;
						rst_stack <= 0;
						done_ack_t0 <= 0;
						done_ack_t1 <= 0;
					end else begin
						pc <= RESET_VECTOR;

						interrupt_source <= NO_INTERRUPTION;
						interrupt_sources_inhibit <= 0;

						flags <= 8'b0000_0000;
						cpu_cfg <= 8'b0000_0000;

						ports[0] <= 0;
						ports[1] <= 0;
						ports_cfg[0] <= 0;
						ports_cfg[1] <= 0;

						w <= 0;
						w_swap <= 0;

						// TODO: Initialize registers

						op_code <= 8'h00;
						operands_count <= 2'b00;
						current_operand <= 2'b00;

						operands[0] <= 0;
						operands[1] <= 0;

						tmr_cfg <= 8'b0000_0000;

						// Resets peripherals
						rst_stack <= 1;
						done_ack_t0 <= 1;
						done_ack_t1 <= 1;
						set_t0 <= 0;
						set_t1 <= 0;

						reset_counter <= reset_counter - 1'b1;
					end
				end

				FETCHING_OPCODE: begin
					// Clears timer sets in case those had been set by a TmrCfg instruction
					set_t0 <= 0;
					set_t1 <= 0;

					op_code <= data_bus;
					pc <= pc + 1;

					if (data_bus[7]) begin // Instructions with operands
						cpu_state <= FETCHING_OPERANDS;
						operands_count <= data_bus[0] + 1'b1;
						current_operand <= 0;
					end else begin // Instructions without operands
						// Ret instruction: bad implementation :S
						if (data_bus == 8'b0011_1100) begin
							// TODO: validate that stack isn't empty and properly handle exception
							enable_stack <= 1;
							operation_stack <= 0; // Pop for Ret from call
							cpu_state <= POPPING_STACK;
						end else begin
							cpu_state <= EXECUTING;
						end
					end
				end

				FETCHING_OPERANDS: begin // Fetch operands indicated in the opcode
					operands[current_operand] <= data_bus;
					pc <= pc + 1;

					if (ram_operand_ucode && current_operand == 0) begin
						operands[0] <= ram[data_bus];
					end

					if (current_operand + 1'b1 >= operands_count) begin
						// Call instruction
						if (stack_operation_ucode & stack_direction_ucode) begin
							// TODO: validate that stack isn't full and properly handle exception
							enable_stack <= 1;
							operation_stack <= 1; // Push for call
						end

						if (duplicate_w_ucode) begin
							w_swap <= w;
						end

						operands_count <= 0;
						current_operand <= 0;

						cpu_state <= EXECUTING;
					end else begin
						current_operand <= current_operand + 1'b1;
					end
				end

				POPPING_STACK: begin
					enable_stack <= 0;
					operation_stack <= 0; // Pop for Ret from call
					cpu_state <= EXECUTING;
				end

				EXECUTING: begin
					// alu_operation, mov_operation and jump_operation are mutually exclusive
					if (alu_operation_ucode) begin
						w <= result_l_alu;
						flags[0] <= carry_out_alu;
						flags[1] <= zero_out_alu;
						flags[2] <= sign_out_alu;

						if (alu_multibyte_result_ucode) begin
							ram[operands[1]] <= result_h_alu;
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

						if (destination_memory_ucode & !destination_w_ucode) begin
							ram[operands[0]] <= source_operands_ucode ? operands[1] : w;
						end

						if (destination_cpu_config_ucode) begin
							cpu_cfg <= w;
						end

						if (destination_timer_config_ucode) begin
							tmr_cfg <= w;

							// Puts set pin of Timer module to high if corresponds to take the config values 
							set_t0 <= w[0];
							set_t1 <= w[4];
						end

						if (destination_ports_config_ucode) begin
							ports_cfg[0] <= registers[0];
							ports_cfg[1] <= registers[1][3:0];
						end

						if (destination_w_ucode) begin
							if (source_ports_ucode) begin
								if (destination_index_ucode == 3'b000) begin
									w <= ((p0in & ports_cfg[0]) | (ports[0] & ~ports_cfg[0]));
								end else begin
									w <= (( { 4'b0000, p1in } & ports_cfg[1]) | ( { 4'b0000, ports[1][3:0] } & ~ports_cfg[1]));
								end
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

					cpu_state <= FETCHING_OPCODE;

					// Timer and interrupt control: have to check higher priority interruptions on lower conditions to avoid triggering a double interrupt
					// can also reverse the order of checking conditions but unsure if that would work better
					if (cpu_cfg[7] & (interrupt_source == 0)) begin // Global Interruption enable, cannot trigger interrupt if other is in course
						if (cpu_cfg[6] & ext_int) begin // External interruption enable
							interrupt_source <= EI_INTERRUPTION;
							interrupt_sources_inhibit <= 1;
							enable_stack <= 1; // TODO: validate that stack isn't full and properly handle exception
							operation_stack <= 1; // Push for interruption redirection
							cpu_state <= INTERRUPT_REDIRECTION;
						end
						if (cpu_cfg[5] & done_t0 & !(cpu_cfg[6] & ext_int)) begin // Timer 0 interruption enable
							interrupt_source <= T0_INTERRUPTION;
							interrupt_sources_inhibit <= 1;
							done_ack_t0 <= 1;
							enable_stack <= 1; // TODO: validate that stack isn't full and properly handle exception
							operation_stack <= 1; // Push for interruption redirection
							cpu_state <= INTERRUPT_REDIRECTION;
						end
						if (cpu_cfg[4] & done_t1 & !(cpu_cfg[5] & done_t0) & !(cpu_cfg[6] & ext_int)) begin // Timer 1 interruption enable
							interrupt_source <= T1_INTERRUPTION;
							done_ack_t1 <= 1;
							enable_stack <= 1; // TODO: validate that stack isn't full and properly handle exception
							operation_stack <= 1; // Push for interruption redirection
							cpu_state <= INTERRUPT_REDIRECTION;
						end
					end
				end

				INTERRUPT_REDIRECTION: begin
					enable_stack <= 0;
					interrupt_sources_inhibit <= 1;
					if (interrupt_source == EI_INTERRUPTION) begin
						pc <= EI_INTERRUPTION_VECTOR;
					end
					if (interrupt_source == T0_INTERRUPTION) begin
						pc <= T0_INTERRUPTION_VECTOR;
						done_ack_t0 <= 0;
					end
					if (interrupt_source == T1_INTERRUPTION) begin
						pc <= T1_INTERRUPTION_VECTOR;
						done_ack_t1 <= 0;
					end

					cpu_state <= FETCHING_OPCODE;
				end
			endcase
		end
	end
endmodule
