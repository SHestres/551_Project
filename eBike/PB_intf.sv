module PB_intf(
  input tgglMd, clk, rst_n,
  output logic [2:0] scale,
  output logic [1:0] setting
);

  logic tgglMd_rise;

  PB_rise RSED(.clk(clk), .rst_n(rst_n), .PB(tgglMd), .rise(tgglMd_rise));
  
  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
	  setting <= 2'b10;
	else if(tgglMd_rise)
	  setting <= setting + 2'b01;
  end
  
  assign scale = (setting == 2'b00) ? 3'b000 :
				 (setting == 2'b01) ? 3'b011 :
				 (setting == 2'b10) ? 3'b101 :
									  3'b111;

endmodule  