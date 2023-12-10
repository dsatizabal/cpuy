`default_nettype none

module alu (
    input wire enable,
    input wire [7:0] operation,
    input wire [7:0] op1,
    input wire [7:0] op2,
	input wire cpu_carry,
    output wire [7:0] result_l,
    output wire [7:0] result_h,
    output wire carry,
    output wire zero,
    output wire sign
);
	reg [7:0] res_h;
	reg [7:0] res_l;
	reg ca;
	reg ze;
	reg si;

	assign carry = ca;
	assign zero = ze;
	assign sign = si;

	assign result_l = res_l;
	assign result_h = res_h;

	always @(*) begin
		if (enable) begin
			res_l = 8'h00; // default value
			res_h = 8'h00; // default value
			ca = 0;
			ze = 0;
			si = 0;

			case (operation[7])
				1'b1: begin // Operations with 2 operands
					case (operation[6:1])
						6'b00_0100: begin // Add L2W
							if ((op1 + op2 + { 7'b0000000, cpu_carry }) > 255) ca = 1;
							res_l = (op1 + op2 + { 7'b0000000, cpu_carry });
						end
						6'b00_0101: begin // Add M2W
							if ((op1 + op2 + { 7'b0000000, cpu_carry }) > 255) ca = 1;
							res_l = (op1 + op2 + { 7'b0000000, cpu_carry });
						end
						6'b00_0110: begin // Sub L2W
							if ((op1 - op2) == 0) ze = 1;
							if (op1 < op2) begin
								si = 1;
								res_l = (op2 - op1);
							end else begin
								res_l = (op1 - op2);
							end
						end
						6'b00_0111: begin // Sub M2W
							if ((op1 - op2) == 0) ze = 1;
							if (op1 < op2) begin
								si = 1;
								res_l = (op2 - op1);
							end else begin
								res_l = (op1 - op2);
							end
						end
						6'b00_1000: begin // Mul LW
							if ((op1 == 0) | (op2 == 0)) ze = 1;
							{ res_h, res_l } = (op1 * op2);
						end
						6'b00_1001: begin // Mul M2W
							if ((op1 == 0) | (op2 == 0)) ze = 1;
							{ res_h, res_l } = (op1 * op2);
						end
						6'b00_1010: begin // And L2W
							if ((op1 & op2) == 0) ze = 1;
							res_l = (op1 & op2);
						end
						6'b00_1011: begin // And M2W
							if ((op1 & op2) == 0) ze = 1;
							res_l = (op1 & op2);
						end
						6'b00_1100: begin // Or L2W
							if ((op1 | op2) == 0) ze = 1;
							res_l = (op1 | op2);
						end
						6'b00_1101: begin // Or M2W
							if ((op1 | op2) == 0) ze = 1;
							res_l = (op1 | op2);
						end
						6'b00_1110: begin // Xor L2W
							if ((op1 ^ op2) == 0) ze = 1;
							res_l = (op1 ^ op2);
						end
						6'b00_1111: begin // Xor M2W
							if ((op1 ^ op2) == 0) ze = 1;
							res_l = (op1 ^ op2);
						end
						default: begin
							res_l = 8'h00; // default value
							res_h = 8'h00; // default value
							ca = 0;
							ze = 0;
							si = 0;
						end
					endcase
				end

				1'b0: begin // Single operand operations
					if (operation[6:3] == 4'b1100) begin // SetbW N
						res_l = op1 | (8'b00000001 << operation[2:0]);
					end else if (operation[6:3] == 4'b1101) begin  // ClrbW N
						if ((op1 & ~(8'b00000001 << operation[2:0])) == 8'b0000_0000) ze = 1;
						res_l = op1 & ~(8'b00000001 << operation[2:0]);
					end else begin
						case (operation)
							8'b0000_0001: begin // DEC
								if (op1 == 8'h01) ze = 1;
								if (op1 < 8'h01) begin
									si = 1;
									res_l = 8'h01;
								end else begin
									res_l = (op1 - 1'b1);
								end
							end
							8'b0000_0010: begin // INC
								if (op1 == 8'hFF) begin
									ca = 1;
									ze = 1;
								end
								res_l = (op1 + 1'b1);
							end
							8'b0000_0011: begin // Not
								if ((~op1) == 8'h00) ze = 1;
								res_l = ~op1;
							end
							8'b0000_0100: begin // SetC
								ca = 1;
								res_l = op1;
							end
							8'b0000_0101: begin // ClrC
								ca = 0;
								res_l = op1;
							end
							8'b0000_0110: begin // RL in loop
								if (op1 == 0) ze = 1;
								res_l = { op1[6:0], op1[7] };
							end
							8'b0000_0111: begin // RR
								if (op1 == 0) ze = 1;
								res_l = { op1[0], op1[7:1] };
							end
							8'b0000_1000: begin // RLC
								if ({ op1[6:0], cpu_carry } == 0) ze = 1;
								res_l = { op1[6:0], cpu_carry };
								ca = op1[7];
							end
							8'b0000_1001: begin // RRC
								if ({ cpu_carry, op1[7:1] } == 0) ze = 1;
								res_l = { cpu_carry, op1[7:1] };
								ca = op1[0];
							end
							8'b0000_1010: begin // Swap
								if (op1 == 0) ze = 1;
								res_l = { op1[3:0], op1[7:4] };
							end
							default: begin
								res_l = 8'h00; // default value
								res_h = 8'h00; // default value
								ca = 0;
								ze = 0;
								si = 0;
							end
						endcase
					end
				end
				default: begin
					res_l = 8'h00; // default value
					res_h = 8'h00; // default value
					ca = 0;
					ze = 0;
					si = 0;
				end
			endcase
		end else begin
			res_l = 8'h00; // default value
			res_h = 8'h00; // default value
			ca = 0;
			ze = 0;
			si = 0;
		end
	end

endmodule
