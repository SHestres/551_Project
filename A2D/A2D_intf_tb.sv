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
	#1000000;
	@(negedge clk);
	rst_n = 0;
	A2D_data = 15'h0001;
	@(negedge clk);
	rst_n = 1;
	#1000000;
	$stop;
  end
  
  always 
    #5 clk <= ~clk;

endmodule