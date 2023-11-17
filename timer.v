`default_nettype none
`timescale 1ns/1ns

module timer(
	input wire clk,
	input wire enable,
	input wire set,
	input wire direction,
	input wire auto_reload,
	input wire done_ack,
	input wire [15:0] count,
	output wire done
);
	reg [15:0] org_count;
	reg [15:0] counter;
	reg tmr_dir = 0;
	reg tmr_auto = 0;
	reg overflow = 0;
	reg run = 0;

	always @(posedge clk) begin
		if (done_ack) begin
			overflow <= 0;
		end

		if (enable) begin
			if (set) begin
				tmr_dir <= direction;
				tmr_auto <= auto_reload;
				counter <= count;
				org_count <= count;
				overflow <= 0;
				run <= 1;
			end else begin
				if (run) begin // Run goes to zero when overflow and no autoreload
					if (tmr_dir) begin // direction = 1 means count upwards
						counter <= counter + 1'b1;
					end else begin
						counter <= counter - 1'b1;
					end;

					if (counter == 16'h0000) begin
						overflow <= 1;

						if (tmr_auto) begin
							counter <= org_count;
						end else begin
							run <= 0;
						end;
					end;
				end;
			end;
		end; // Of general enable
	end;

	assign done = overflow == 1;

endmodule
