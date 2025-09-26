module dump();
	initial begin
		$dumpfile ("cpuy.vcd");
		$dumpvars (0, tb);
		#1;
	end
endmodule
