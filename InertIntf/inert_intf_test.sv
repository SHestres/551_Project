module inert_intf_test(
  input RST_n, clk, MISO, INT,
  output logic SS_n, SCLK, MOSI,
  output logic [7:0] LED
);

  logic rst_n, vld;
  logic [12:0] incline;

  rst_synch RST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));
  
  inert_intf INRT(.clk(clk), .rst_n(rst_n), .MISO(MISO), .INT(INT), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .vld(vld), .incline(incline));
  
  always_ff @(posedge clk) begin
	if (vld) 
	  LED <= incline[8:1];
  end	  
endmodule
