module sensorCondition#(parameter FAST_SIM = 1)(clk, rst_n, torque, cadence_raw, curr, incline, scale, batt, error, not_pedaling, TX);

input clk, rst_n, cadence_raw;
input[11:0] torque, curr, batt;
input[12:0] incline;
input[2:0] scale;
output logic[12:0] error;
output not_pedaling, TX;

localparam LOW_BATT_THRES = 12'hA98;

logic cadence_rise, cadence_filt;
logic not_pedaling;
logic[7:0] cadence_per;
logic[4:0] cadence;
logic pedaling_resumes;

logic [11:0] avg_curr;
logic [13:0] accum_curr;
logic [11:0] avg_torque;
logic [16:0] accum_torque;

logic [21:0] count;
logic include_smpl;

generate
	if(!FAST_SIM)
		assign include_smpl = &count;
	else
		assign include_smpl = &count[15:0];
endgenerate

cadence_filt #(.FAST_SIM(FAST_SIM)) iCadFilt(.clk(clk), .rst_n(rst_n), .cadence(cadence_raw), .cadence_filt(cadence_filt), .cadence_rise(cadence_rise));
cadence_meas #(.FAST_SIM(FAST_SIM)) iCadMeas(.clk(clk), .rst_n(rst_n), .cadence_filt(cadence_filt), .cadence_per(cadence_per), .not_pedaling(not_pedaling));
cadence_LU iCadLU(.cadence_per(cadence_per), .cadence(cadence));

//Pedaling Resumes
logic prev;
always_ff @(posedge clk) begin: not_ped_fall_detect
	prev <= not_pedaling;
	pedaling_resumes <= (!not_pedaling) & prev;
end: not_ped_fall_detect

//Include Sample Timer
always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n)
	count <= 0;
else if(include_smpl)
	count <= 0;
else
	count <= count + 1;
end

//Exponential Accum Curr
logic [14:0] prod_curr;
assign avg_curr = accum_curr[13:2];
assign prod_curr = accum_curr * 3;

always @(posedge clk, negedge rst_n) begin
if(!rst_n)
	accum_curr <= 0;
else if(include_smpl)
	accum_curr <= curr + prod_curr[14:2];
end


//Exponential Accum Torque
logic [21:0] prod_torque;
assign avg_torque = accum_torque[16:5];
assign prod_torque = (accum_torque << 5) - accum_torque;  // * 31

always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n)
	accum_torque <= 0;
else if(pedaling_resumes)
	accum_torque <= {1'b0, torque, 4'h0};
else if(cadence_rise)
	accum_torque <= torque + prod_torque[21:5];
end


//Error
logic[11:0] target_curr;
desiredDrive iDesDrive(.clk(clk), .avg_torque(avg_torque), .cadence(cadence), .incline(incline), .scale(scale), .not_pedaling(not_pedaling), .target_curr(target_curr));

always_comb begin
if(not_pedaling) 
	error = 0;
else if(batt < LOW_BATT_THRES)
	error = 0;
else
	error = target_curr - avg_curr;
end

//Telemetry
telemetry iTele(.clk(clk), .rst_n(rst_n), .batt_v(batt), .avg_curr(avg_curr), .avg_torque(avg_torque), .TX(TX));

endmodule