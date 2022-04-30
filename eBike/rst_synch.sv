module rst_synch(
  input clk, RST_n,
  output reg rst_n
);

  reg intr;

  always_ff @(negedge clk, negedge RST_n) begin
    if (!RST_n) begin
	  intr <= 1'b0;
	  rst_n <= 1'b0;
	end
	else begin
	  intr <= 1'b1;
	  rst_n <= intr;
	end
  end

endmodule