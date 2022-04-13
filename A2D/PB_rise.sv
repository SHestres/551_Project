module PB_rise(
  input clk, rst_n, PB,
  output rise
);

  logic intr1, intr2, intr3, nintr3;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
	  intr1 <= 1'b1;
	  intr2 <= 1'b1;
	  intr3 <= 1'b1;
	end
	else begin
	  intr1 <= PB;
	  intr2 <= intr1;
	  intr3 <= intr2;
	end
  end
  
  not not0(nintr3, intr3);
  and and0(rise, nintr3, intr2);
  
endmodule