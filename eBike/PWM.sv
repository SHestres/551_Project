module PWM(
  input clk,
  input rst_n,
  input [10:0] duty,
  output reg PWM_sig,
  output PWM_synch
);

  logic [10:0] cnt = 11'h000;
  logic PWM_sig_d;
  
  assign PWM_sig_d = (cnt <= duty) ? 1'b1 : 1'b0;				// PWM is on if cnt is less than or equal to duty 
  
  assign PWM_synch = (cnt == 11'h001) ? 1'b1 : 1'b0;
  
  always @(posedge clk, negedge rst_n) begin					
    if (!rst_n)
	  PWM_sig <= 1'b0;
	else
	  PWM_sig <= PWM_sig_d;
  end

  always @(posedge clk, negedge rst_n) begin					// cnt + 1 each clk cycle
	if (!rst_n)
	  cnt <= 11'h000;
	else
	  cnt <= cnt + 1'b1;
  end
  
  
endmodule