module incline_sat(incline, incline_sat);

input logic signed [12:0] incline;
output logic signed [9:0] incline_sat;




	assign incline_sat = 	!incline[12] && (|incline[12:9]) ? {1'b0, {9{1'b1}}} : 
				incline[12] && !(&incline[12:9]) ? {1'b1, {9{1'b0}}} :
				incline[9:0];


endmodule;
