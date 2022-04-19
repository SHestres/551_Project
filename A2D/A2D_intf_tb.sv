module A2D_intf_tb();

  logic clk, rst_n, SS_n, SCLK, MOSI, MISO, rdy;
  logic [15:0] A2D_data, cmd;
  logic [11:0] batt, curr, brake, torque;
  

  SPI_ADC128S SPI(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), 
  .MOSI(MOSI), .A2D_data(A2D_data), .MISO(MISO), .rdy(rdy), .cmd(cmd));
  
  A2D_intf A2D(.clk(clk), .rst_n(rst_n), .batt(batt), .curr(curr), 
  .brake(brake), .torque(torque), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));
  
  
  initial begin
    rst_n = 0;
	clk = 0;
	A2D_data = 15'h7FFF;
	@(negedge clk);
	rst_n = 1;
	repeat (100000) @(posedge clk);
	
	// all reg values should be updated with 12'hFFF
	if (batt !== 12'hFFF) begin
	  $display("Test 1: failed, batt did not match expected");
	  $stop;
	end 
	
	if (curr !== 12'hFFF) begin
	  $display("Test 2: failed, curr did not match expected");
	  $stop;
	end 
	
	if (brake !== 12'hFFF) begin
	  $display("Test 3: failed, brake did not match expected");
	  $stop;
	end 
	
	if (torque !== 12'hFFF) begin
	  $display("Test 4: failed, torque did not match expected");
	  $stop;
	end 
	
	@(negedge clk);
	rst_n = 0;
	A2D_data = 15'h0001;
	@(negedge clk);
	rst_n = 1;
	repeat (100000) @(posedge clk);
	
	// all reg values should be updated with 12'h001
	if (batt !== 12'h001) begin
	  $display("Test 5: failed, batt did not match expected");
	  $stop;
	end 
	
	if (curr !== 12'h001) begin
	  $display("Test 6: failed, curr did not match expected");
	  $stop;
	end 
	
	if (brake !== 12'h001) begin
	  $display("Test 7: failed, brake did not match expected");
	  $stop;
	end 
	
	if (torque !== 12'h001) begin
	  $display("Test 8: failed, torque did not match expected");
	  $stop;
	end 
	
	$display("All tests passed");
	$stop;
  end
  
  always 
    #5 clk <= ~clk;

endmodule