module sensorCondition(clk, rst_n, torque, cadence_raw, curr, incline, scale, batt, error, not_pedaling, TX);

input clk, rst_n, cadence_raw;
input[11:0] torque, curr, batt;
input[12:0] incline;
input[2:0] scale;
output[12:0] error;
output not_pedaling, TX;

localparam LOW_BATT_THRES = 12'hA98;


logic cadence_rise, cadence_filt;
logic not_pedaling;
logic[7:0] cadence_per;
logic[5:0] cadence;

cadence_filt iCadFilt(.clk(clk), .rst_n(rst_n), .cadence(cadence_raw), .cadence_filt(cadence_filt), .cadence_rise(cadence_rise));
cadence_meas iCadMeas(.clk(clk), .rst_n(rst_n), .cadence_filt(cadence_filt), .cadence_per(cadence_per), .not_pedaling(not_pedaling));
cadence_LU iCadLU(.cadence_per(cadence_per), .cadence(cadence));

endmodule
