module incline_sat(
  input signed [12:0] incline,
  output signed [9:0] incline_sat
);

	logic signed [12:0] max = 13'b0000111111111;
	logic signed [12:0] min = 13'b1111000000000;
	logic signed [12:0] minmax;
	
	assign minmax = (incline[12] == 0) ? (incline - max) : (incline - min);
	
	assign incline_sat = (incline[12] == 0) ? ((minmax > 0) ? max[9:0] : {0, incline[8:0]}) 
											  : ((minmax < 0) ? min[9:0] : {1, incline[8:0]});

endmodule