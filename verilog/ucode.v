`default_nettype none

module ucode (
    input wire [7:0] opcode,
    input wire [7:0] w,
    input wire carry,
    input wire zero,
    input wire sign,
    output wire alu_operation,
    output wire alu_multibyte_result,
    output wire jump_operation,
    output wire jump_condition,
    output wire mov_operation,
    output wire destination_w,
    output wire destination_flags, // TODO: remove this unrequired signal
    output wire destination_memory,
    output wire destination_registers,
    output wire destination_ports,
    output wire [2:0] destination_index,
    output wire ram_operand,
    output wire duplicate_w,
    output wire source_ports,
    output wire source_registers,
    output wire stack_operation,
    output wire stack_direction, // 0 Pop, 1 Push
	output wire destination_cpu_config,
	output wire destination_timer_config,
	output wire destination_ports_config,
	output wire source_operands
);
	reg alu_op;
    reg alu_mb;
    reg jmp_op;
    reg jmp_condition;
    reg mov_op;
    reg dst_w;
    reg dst_f;
    reg dst_memory;
    reg dst_reg;
    reg dst_por;
    reg [2:0] dst_index;
    reg ram_op;
    reg dup_w;
    reg src_port;
    reg src_reg;
    reg stack_op;
    reg stack_dir;
	reg dst_cpu_cfg;
	reg dst_tmr_cfg;
	reg dst_ports_cfg;
	reg src_op;

    assign alu_operation = alu_op;
    assign alu_multibyte_result = alu_mb;
    assign jump_operation = jmp_op;
    assign jump_condition = jmp_condition;
    assign mov_operation = mov_op;
    assign destination_w = dst_w;
    assign destination_flags = dst_f;
    assign destination_memory = dst_memory;
    assign destination_registers = dst_reg;
    assign destination_ports = dst_por;
	assign destination_index = dst_index;
	assign ram_operand = ram_op;
	assign duplicate_w = dup_w;
    assign source_ports = src_port;
    assign source_registers = src_reg;
    assign stack_operation = stack_op;
    assign stack_direction = stack_dir;
	assign destination_cpu_config = dst_cpu_cfg;
	assign destination_timer_config = dst_tmr_cfg;
	assign destination_ports_config = dst_ports_cfg;
	assign source_operands = src_op;

	always @(*) begin
		alu_op = 0;
		alu_mb = 0;
		jmp_op = 0;
		jmp_condition = 0;
		mov_op = 0;
		dst_w = 0;
		dst_f = 0;
		dst_memory = 0;
		dst_reg = 0;
		dst_por = 0;
		dst_index = 0;
		ram_op = 0;
    	dup_w = 0;
    	src_port = 0;
    	src_reg = 0;
		stack_op = 0;
		stack_dir = 0;
		dst_cpu_cfg = 0;
		dst_tmr_cfg = 0;
		dst_ports_cfg = 0;
		src_op = 0;

		case (opcode)
			// Instructions without operands
			8'b0000_0000: begin // NOP does nothing
				alu_op = 0;
				alu_mb = 0;
				jmp_op = 0;
				jmp_condition = 0;
				mov_op = 0;
				dst_w = 0;
				dst_f = 0;
				dst_memory = 0;
				dst_reg = 0;
				dst_por = 0;
				dst_index = 0;
				ram_op = 0;
				dup_w = 0;
				src_port = 0;
				src_reg = 0;
				stack_op = 0;
				stack_dir = 0;
				dst_cpu_cfg = 0;
				dst_tmr_cfg = 0;
				src_op = 0;
			end
			8'b0000_0001: begin // Dec
				alu_op = 1;
				dst_w = 1;
			end
			8'b0000_0010: begin // Inc
				alu_op = 1;
				dst_w = 1;
			end
			8'b0000_0011: begin // Not
				alu_op = 1;
				dst_w = 1;
			end
			8'b0000_0100: begin // SetC
				alu_op = 1;
				dst_f = 1;
			end
			8'b0000_0101: begin // ClrC
				alu_op = 1;
				dst_f = 1;
			end
			8'b0000_0110: begin // RL
				alu_op = 1;
				dst_w = 1;
			end
			8'b0000_0111: begin // RR
				alu_op = 1;
				dst_w = 1;
			end
			8'b0000_1000: begin // RLC
				alu_op = 1;
				dst_w = 1;
			end
			8'b0000_1001: begin // RRC
				alu_op = 1;
				dst_w = 1;
			end
			8'b0000_1010: begin // Swap
				alu_op = 1;
				dst_w = 1;
			end
			// 8'b0000_1011: begin
			// end
			// 8'b0000_1100: begin
			// end
			// 8'b0000_1101: begin
			// end
			// 8'b0000_1110: begin
			// end
			// 8'b0000_1111: begin
			// end
			// 8'b0001_0000: begin
			// end
			// 8'b0001_0001: begin
			// end
			// 8'b0001_0010: begin
			// end
			// 8'b0001_0011: begin
			// end
			// 8'b0001_0100: begin
			// end
			// 8'b0001_0101: begin
			// end
			// 8'b0001_0110: begin
			// end
			// 8'b0001_0111: begin
			// end
			// 8'b0001_1000: begin
			// end
			// 8'b0001_1001: begin
			// end
			// 8'b0001_1010: begin
			// end
			// 8'b0001_1011: begin
			// end
			// 8'b0001_1100: begin
			// end
			// 8'b0001_1101: begin
			// end
			// 8'b0001_1110: begin
			// end
			// 8'b0001_1111: begin
			// end
			// 8'b0010_0000: begin
			// end
			// 8'b0010_0001: begin
			// end
			// 8'b0010_0010: begin
			// end
			// 8'b0010_0011: begin
			// end
			// 8'b0010_0100: begin
			// end
			// 8'b0010_0101: begin
			// end
			// 8'b0010_0110: begin
			// end
			// 8'b0010_0111: begin
			// end
			// 8'b0010_1000: begin
			// end
			// 8'b0010_1001: begin
			// end
			// 8'b0010_1010: begin
			// end
			// 8'b0010_1011: begin
			// end
			// 8'b0010_1100: begin
			// end
			// 8'b0010_1101: begin
			// end
			// 8'b0010_1110: begin
			// end
			// 8'b0010_1111: begin
			// end
			// 8'b0011_0000: begin
			// end
			// 8'b0011_0001: begin
			// end
			// 8'b0011_0010: begin
			// end
			// 8'b0011_0011: begin
			// end
			// 8'b0011_0100: begin
			// end
			// 8'b0011_0101: begin
			// end
			// 8'b0011_0110: begin
			// end
			// 8'b0011_0111: begin
			// end
			// 8'b0011_1000: begin
			// end
			// 8'b0011_1001: begin
			// end
			// 8'b0011_1010: begin
			// end
			// 8'b0011_1011: begin
			// end

			8'b0011_1100: begin // Ret
				stack_op = 1;
				stack_dir = 0;
			end
			8'b0011_1101: begin // PortsCfg
				mov_op = 1;
				dst_ports_cfg = 1;
			end
			8'b0011_1110: begin // CpuCfg
				mov_op = 1;
				dst_cpu_cfg = 1;
			end
			8'b0011_1111: begin // TmrCfg
				mov_op = 1;
				dst_tmr_cfg = 1;
			end

			8'b0100_0000: begin // MovWP0
				mov_op = 1;
				dst_por = 1;
				dst_index = opcode[2:0];
			end
			8'b0100_0001: begin // MovWP1
				mov_op = 1;
				dst_por = 1;
				dst_index = opcode[2:0];
			end
			// 8'b0100_0010: begin
			// end
			// 8'b0100_0011: begin
			// end
			// 8'b0100_0100: begin
			// end
			// 8'b0100_0101: begin
			// end
			// 8'b0100_0110: begin
			// end
			// 8'b0100_0111: begin
			// end

			8'b0100_1000: begin // MovP0W
				mov_op = 1;
				dst_w = 1;
				src_port = 1;
				dst_index = opcode[2:0];
			end
			8'b0100_1001: begin // MovP1W
				mov_op = 1;
				dst_w = 1;
				src_port = 1;
				dst_index = opcode[2:0];
			end
			// 8'b0100_1010: begin
			// end
			// 8'b0100_1011: begin
			// end
			// 8'b0100_1100: begin
			// end
			// 8'b0100_1101: begin
			// end
			// 8'b0100_1110: begin
			// end
			// 8'b0100_1111: begin
			// end

			8'b0101_0000: begin // MovWR0
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_0001: begin // MovWR1
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_0010: begin // MovWR2
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_0011: begin // MovWR3
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_0100: begin // MovWR4
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_0101: begin // MovWR5
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_0110: begin // MovWR6
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_0111: begin // MovWR7
				mov_op = 1;
				dst_reg = 1;
				dst_index = opcode[2:0];
			end

			8'b0101_1000: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_1001: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_1010: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_1011: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_1100: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_1101: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_1110: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end
			8'b0101_1111: begin // MovR0W
				mov_op = 1;
				dst_w = 1;
				src_reg = 1;
				dst_index = opcode[2:0];
			end

			8'b0110_0000: begin // SetbW 0
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_0001: begin // SetbW 1
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_0010: begin // SetbW 2
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_0011: begin // SetbW 3
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_0100: begin // SetbW 4
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_0101: begin // SetbW 5
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_0110: begin // SetbW 6
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_0111: begin // SetbW 7
				alu_op = 1;
				dst_w = 1;
			end

			8'b0110_1000: begin // ClrbW 0
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_1001: begin // ClrbW 1
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_1010: begin // ClrbW 2
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_1011: begin // ClrbW 3
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_1100: begin // ClrbW 4
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_1101: begin // ClrbW 5
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_1110: begin // ClrbW 6
				alu_op = 1;
				dst_w = 1;
			end
			8'b0110_1111: begin // ClrbW 7
				alu_op = 1;
				dst_w = 1;
			end

			// 8'b0111_0000: begin
			// end
			// 8'b0111_0001: begin
			// end
			// 8'b0111_0010: begin
			// end
			// 8'b0111_0011: begin
			// end
			// 8'b0111_0100: begin
			// end
			// 8'b0111_0101: begin
			// end
			// 8'b0111_0110: begin
			// end
			// 8'b0111_0111: begin
			// end
			// 8'b0111_1000: begin
			// end
			// 8'b0111_1001: begin
			// end
			// 8'b0111_1010: begin
			// end
			// 8'b0111_1011: begin
			// end
			// 8'b0111_1100: begin
			// end
			// 8'b0111_1101: begin
			// end
			// 8'b0111_1110: begin
			// end
			// 8'b0111_1111: begin
			// end

			// Instructions with operands
			8'b1000_0000: begin // MovMW
				mov_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1000_0001: begin // MovMW
				mov_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1000_0010: begin // MovWM
				mov_op = 1;
				dst_memory = 1;
			end
			8'b1000_0011: begin // MovWM
				mov_op = 1;
				dst_memory = 1;
			end
			8'b1000_0100: begin // MovLW
				mov_op = 1;
				dst_w = 1;
			end
			8'b1000_0101: begin // MovLW
				mov_op = 1;
				dst_w = 1;
			end
			8'b1000_0110: begin // MovLM
				mov_op = 1;
				src_op = 1;
				dst_memory = 1;
			end
			8'b1000_0111: begin // MovLM
				mov_op = 1;
				src_op = 1;
				dst_memory = 1;
			end
			8'b1000_1000: begin // AddLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1000_1001: begin // AddLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1000_1010: begin // AddMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1000_1011: begin // AddMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1000_1100: begin // SubLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1000_1101: begin // SubLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1000_1110: begin // SubMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1000_1111: begin // SubMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1001_0000: begin // MulLW
				alu_op = 1;
				dst_w = 1;
				alu_mb = 1;
				dst_memory = 1;
			end
			8'b1001_0001: begin // MulLW
				alu_op = 1;
				dst_w = 1;
				alu_mb = 1;
				dst_memory = 1;
			end
			8'b1001_0010: begin // MulMW
				alu_op = 1;
				dst_w = 1;
				alu_mb = 1;
				dst_memory = 1;
				ram_op = 1;
			end
			8'b1001_0011: begin // MulMW
				alu_op = 1;
				dst_w = 1;
				alu_mb = 1;
				dst_memory = 1;
				ram_op = 1;
			end
			8'b1001_0100: begin // AndLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1001_0101: begin // AndLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1001_0110: begin // AndMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1001_0111: begin // AndMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1001_1000: begin // OrLW
				alu_op = 1;
				dst_w = 1;			
			end
			8'b1001_1001: begin // OrLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1001_1010: begin // OrMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1001_1011: begin // OrMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1001_1100: begin // XorLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1001_1101: begin // XorLW
				alu_op = 1;
				dst_w = 1;
			end
			8'b1001_1110: begin // XorMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1001_1111: begin // XorMW
				alu_op = 1;
				dst_w = 1;
				ram_op = 1;
			end
			8'b1010_0000: begin // XchWM
				mov_op = 1;
				dst_w = 1;
				dst_memory = 1;
				dup_w = 1;
			end
			8'b1010_0001: begin // XchWM
				mov_op = 1;
				dst_w = 1;
				dst_memory = 1;
				dup_w = 1;
			end
			8'b1010_0010: begin // Jmp
				jmp_op = 1;
				jmp_condition = 1;
			end
			8'b1010_0011: begin // Jmp
				jmp_op = 1;
				jmp_condition = 1;
			end
			8'b1010_0100: begin // JmpC
				jmp_op = 1;
				jmp_condition = carry;
			end
			8'b1010_0101: begin // JmpC
				jmp_op = 1;
				jmp_condition = carry;
			end
			8'b1010_0110: begin // JmpZ
				jmp_op = 1;
				jmp_condition = zero;
			end
			8'b1010_0111: begin // JmpZ
				jmp_op = 1;
				jmp_condition = zero;
			end
			8'b1010_1000: begin // JmpS
				jmp_op = 1;
				jmp_condition = sign;
			end
			8'b1010_1001: begin // JmpS
				jmp_op = 1;
				jmp_condition = sign;
			end
			8'b1010_1010: begin // Call
				stack_op = 1;
				stack_dir = 1;
			end
			8'b1010_1011: begin // Call
				stack_op = 1;
				stack_dir = 1;
			end

			// 8'b1010_1100: begin
			// end
			// 8'b1010_1101: begin
			// end
			// 8'b1010_1110: begin
			// end
			// 8'b1010_1111: begin
			// end
			// 8'b1011_0000: begin
			// end
			// 8'b1011_0001: begin
			// end
			// 8'b1011_0010: begin
			// end
			// 8'b1011_0011: begin
			// end
			// 8'b1011_0100: begin
			// end
			// 8'b1011_0101: begin
			// end
			// 8'b1011_0110: begin
			// end
			// 8'b1011_0111: begin
			// end
			// 8'b1011_1000: begin
			// end
			// 8'b1011_1001: begin
			// end
			// 8'b1011_1010: begin
			// end
			// 8'b1011_1011: begin
			// end
			// 8'b1011_1100: begin
			// end
			// 8'b1011_1101: begin
			// end
			// 8'b1011_1110: begin
			// end
			// 8'b1011_1111: begin
			// end
			// 8'b1100_0000: begin
			// end
			// 8'b1100_0001: begin
			// end
			// 8'b1100_0010: begin
			// end
			// 8'b1100_0011: begin
			// end
			// 8'b1100_0100: begin
			// end
			// 8'b1100_0101: begin
			// end
			// 8'b1100_0110: begin
			// end
			// 8'b1100_0111: begin
			// end
			// 8'b1100_1000: begin
			// end
			// 8'b1100_1001: begin
			// end
			// 8'b1100_1010: begin
			// end
			// 8'b1100_1011: begin
			// end
			// 8'b1100_1100: begin
			// end
			// 8'b1100_1101: begin
			// end
			// 8'b1100_1110: begin
			// end
			// 8'b1100_1111: begin
			// end
			// 8'b1101_0000: begin
			// end
			// 8'b1101_0001: begin
			// end
			// 8'b1101_0010: begin
			// end
			// 8'b1101_0011: begin
			// end
			// 8'b1101_0100: begin
			// end
			// 8'b1101_0101: begin
			// end
			// 8'b1101_0110: begin
			// end
			// 8'b1101_0111: begin
			// end
			// 8'b1101_1000: begin
			// end
			// 8'b1101_1001: begin
			// end
			// 8'b1101_1010: begin
			// end
			// 8'b1101_1011: begin
			// end
			// 8'b1101_1100: begin
			// end
			// 8'b1101_1101: begin
			// end
			// 8'b1101_1110: begin
			// end
			// 8'b1101_1111: begin
			// end

			8'b1110_0000: begin // Tbjc 0
			 	jmp_op = 1;
				jmp_condition = !w[0];
			end
			8'b1110_0001: begin // Tbjc 0
				jmp_op = 1;
				jmp_condition = !w[0];
			end
			8'b1110_0010: begin // Tbjc 1
				jmp_op = 1;
				jmp_condition = !w[1];
			end
			8'b1110_0011: begin // Tbjc 1
				jmp_op = 1;
				jmp_condition = !w[1];
			end
			8'b1110_0100: begin // Tbjc 2
				jmp_op = 1;
				jmp_condition = !w[2];
			end
			8'b1110_0101: begin // Tbjc 2
				jmp_op = 1;
				jmp_condition = !w[2];
			end
			8'b1110_0110: begin // Tbjc 3
				jmp_op = 1;
				jmp_condition = !w[3];
			end
			8'b1110_0111: begin // Tbjc 3
				jmp_op = 1;
				jmp_condition = !w[3];
			end
			8'b1110_1000: begin // Tbjc 4
				jmp_op = 1;
				jmp_condition = !w[4];
			end
			8'b1110_1001: begin // Tbjc 4
				jmp_op = 1;
				jmp_condition = !w[4];
			end
			8'b1110_1010: begin // Tbjc 5
				jmp_op = 1;
				jmp_condition = !w[5];
			end
			8'b1110_1011: begin // Tbjc 5
				jmp_op = 1;
				jmp_condition = !w[5];
			end
			8'b1110_1100: begin // Tbjc 6
				jmp_op = 1;
				jmp_condition = !w[6];
			end
			8'b1110_1101: begin // Tbjc 6
				jmp_op = 1;
				jmp_condition = !w[6];
			end
			8'b1110_1110: begin // Tbjc 7
				jmp_op = 1;
				jmp_condition = !w[7];
			end
			8'b1110_1111: begin // Tbjc 7
				jmp_op = 1;
				jmp_condition = !w[7];
			end
			
			8'b1111_0000: begin // Tbjs 0
				jmp_op = 1;
				jmp_condition = w[0];
			end
			8'b1111_0001: begin // Tbjs 0
				jmp_op = 1;
				jmp_condition = w[0];
			end
			8'b1111_0010: begin // Tbjs 1
				jmp_op = 1;
				jmp_condition = w[1];
			end
			8'b1111_0011: begin // Tbjs 1
				jmp_op = 1;
				jmp_condition = w[1];
			end
			8'b1111_0100: begin // Tbjs 2
				jmp_op = 1;
				jmp_condition = w[2];
			end
			8'b1111_0101: begin // Tbjs 2
				jmp_op = 1;
				jmp_condition = w[2];
			end
			8'b1111_0110: begin // Tbjs 3
				jmp_op = 1;
				jmp_condition = w[3];
			end
			8'b1111_0111: begin // Tbjs 3
				jmp_op = 1;
				jmp_condition = w[3];
			end
			8'b1111_1000: begin // Tbjs 4
				jmp_op = 1;
				jmp_condition = w[4];
			end
			8'b1111_1001: begin // Tbjs 4
				jmp_op = 1;
				jmp_condition = w[4];
			end
			8'b1111_1010: begin // Tbjs 5
				jmp_op = 1;
				jmp_condition = w[5];
			end
			8'b1111_1011: begin // Tbjs 5
				jmp_op = 1;
				jmp_condition = w[5];
			end
			8'b1111_1100: begin // Tbjs 6
				jmp_op = 1;
				jmp_condition = w[6];
			end
			8'b1111_1101: begin // Tbjs 6
				jmp_op = 1;
				jmp_condition = w[6];
			end
			8'b1111_1110: begin // Tbjs 7
				jmp_op = 1;
				jmp_condition = w[7];
			end
			8'b1111_1111: begin // Tbjs 7
				jmp_op = 1;
				jmp_condition = w[7];
			end
			default: begin
				alu_op = 0;
				alu_mb = 0;
				jmp_op = 0;
				jmp_condition = 0;
				mov_op = 0;
				dst_w = 0;
				dst_f = 0;
				dst_memory = 0;
				dst_reg = 0;
				dst_por = 0;
				dst_index = 0;
				ram_op = 0;
				dup_w = 0;
				src_port = 0;
				src_reg = 0;
				stack_op = 0;
				stack_dir = 0;
				dst_cpu_cfg = 0;
				dst_tmr_cfg = 0;
				src_op = 0;
			end
		endcase
	end

endmodule
