module cadence_filt(
  input clk,
  input rst_n,
  input cadence,
  output reg cadence_filt,
  output cadence_rise
);

  logic cad1, cad2, cad3, not_cad3, chngd_n, cadence_filt_d;
  logic [15:0] stbl_cnt_q, stbl_cnt_d;
  
  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
	  cad1 <= 1'b0;
	else
	  cad1 <= cadence;
  end
  
   always @(posedge clk, negedge rst_n) begin				// 2nd ff for stability
    if (!rst_n)
	  cad2 <= 1'b0;
	else
	  cad2 <= cad1;
  end
  
   always @(posedge clk, negedge rst_n) begin    			// 3rd ff to use to check for change in cadence
    if (!rst_n)
	  cad3 <= 1'b0;
	else
	  cad3 <= cad2;
  end
  
  assign chngd_n = (cad2 ~^ cad3);															// checks if cadence changed
  assign not_cad3 = ~cad3;
  assign cadence_rise = (cad2 & not_cad3);													// checks for rising edge of cadence

  assign stbl_cnt_d[15:0] = (chngd_n == 0) ? 16'h0000 : (stbl_cnt_q[15:0] + 1'b1);
  
  always @(posedge clk) begin
    if (!rst_n)
	  stbl_cnt_q[15:0] <= 16'h0000;
	else
	  stbl_cnt_q[15:0] <= stbl_cnt_d;
  end
  
  assign cadence_filt_d = (&stbl_cnt_q[15:0]) ? cad3 : cadence_filt;						//is counter full?
  
  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
	  cadence_filt <= 1'b0;
	else
	  cadence_filt <= cadence_filt_d;
  end

endmodule