module nonoverlap(
  input  logic clk, rst_n, highIn, lowIn, 
  output logic highOut, lowOut
);

  logic highIn_1, lowIn_1, high_chg, low_chg;
  logic [4:0] cnt = 5'b00000;

  always_ff @(posedge clk)										// flop to test for change
    highIn_1 <= highIn;
	
  always_ff @(posedge clk)										// flop to test for change
    lowIn_1 <= lowIn;
	
  assign high_chg = (highIn ^ highIn_1);						// test for change
  assign low_chg = (lowIn ^ lowIn_1);							// test for change
  
  always @(posedge clk, negedge rst_n) begin					// counts how long inputs haven't changed
	if (!rst_n)
	  cnt <= 5'b00000;
	else if (low_chg | high_chg)
	  cnt <= 5'b00000;
	else 
	  cnt <= cnt + 1'b1;
  end
  
  always_ff @(posedge clk, negedge rst_n) begin					// if no rst_n asserted or input change output driven with input
    if (!rst_n)
	  highOut <= 1'b0;
	else if (high_chg)
	  highOut <= 1'b0;
	else if (&cnt)
	  highOut <= highIn;
  end
  
  always_ff @(posedge clk, negedge rst_n) begin					// f no rst_n asserted or input change output driven with input
    if (!rst_n)
	  lowOut <= 1'b0;
	else if (low_chg)
	  lowOut <= 1'b0;
	else if (&cnt)
	  lowOut <= lowIn;
  end

endmodule