`default_nettype none

module stack (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire operation, // 1 = push, 0 = pop
    input wire [9:0] data_in,
    output reg [9:0] data_out,
    output wire full,
    output wire empty
);
	parameter DEPTH = 16;
	parameter ADDR_WIDTH = 4; // log2(DEPTH)

	// Stack memory and pointer
	reg [9:0] stack_mem [DEPTH - 1:0];
	reg [ADDR_WIDTH - 1:0] stack_ptr = 0;

	// Full and empty flag logic
	assign full = (stack_ptr == (DEPTH - 1));
	assign empty = (stack_ptr == 0);

	always @(posedge clk or posedge rst) begin
	    if (rst) begin
	        stack_ptr <= 0;
	        data_out <= 0;
	    end else begin
			if (enable) begin
				if (operation && !full) begin
					stack_mem[stack_ptr] <= data_in;
					stack_ptr <= stack_ptr + 1;
				end else if (!operation && !empty) begin
					stack_ptr <= stack_ptr - 1;
					data_out <= stack_mem[stack_ptr - 1];
				end
			end
	    end
	end

endmodule
