module desiredDrive(clk, avg_torque, cadence, not_pedaling, incline, scale, target_curr);

localparam TORQUE_MIN = 12'h380;

input clk;
input [11:0]avg_torque;
input [4:0]cadence;
input not_pedaling;
input [12:0]incline;
input[2:0]scale;
output [11:0]target_curr;

logic [9:0]inclineSat;
logic signed [10:0]incline_factor;
logic [8:0]incline_lim;
logic [12:0]torque_off;
logic [11:0]torque_pos;
logic [29:0]assist_prod, assist_prod_1;
logic [5:0]cadence_factor;

incline_sat iInSat(.incline(incline), .incline_sat(inclineSat));

assign incline_factor = {inclineSat[9], inclineSat} + 256;

/*
assign incline_lim = 	incline_factor[10] ? 0 :
			|incline_factor[10:9] ? 511 :
			incline_factor[8:0];
*/

//assign cadence_factor = |cadence[4:1] ? cadence + 32 : 0;

assign torque_off = {1'b0, avg_torque} - {1'b0, TORQUE_MIN};

//assign torque_pos = torque_off[12] ? 0 : torque_off[11:0];


always_ff @(posedge clk) begin: pipeline_flops
incline_lim <= incline_factor[10] ? 0 :
		|incline_factor[10:9] ? 511 :
		incline_factor[8:0];

cadence_factor <= |cadence[4:1] ? cadence + 32 : 0;

torque_pos <= torque_off[12] ? 0 : torque_off[11:0];

end: pipeline_flops


logic [14:0]mult1;
logic [14:0]mult2;
always_ff @(posedge clk) begin: second_pipeline
	mult1 <= torque_pos * scale;
	mult2 <= incline_lim * cadence_factor;
	assist_prod <= mult1 * mult2;
end: second_pipeline

//assign assist_prod = not_pedaling ? 0 : torque_pos * incline_lim * cadence_factor * scale;

assign assist_prod_1 = not_pedaling ? 0 : assist_prod;

assign target_curr = |assist_prod_1[29:27] ? 12'hFFF : assist_prod_1[26:15];

endmodule
