module sensorCondition_tb();

logic clk, rst_n, cadence_raw, not_pedaling, TX;
logic[11:0] torque, curr, batt;
logic[12:0] incline;
logic[2:0] scale;
logic[12:0] error;

sensorCondition #(.FAST_SIM(1)) iDUT(.clk(clk), .rst_n(rst_n), .torque(torque), .cadence_raw(cadence_raw), 
			.curr(curr), .scale(scale), .incline(incline), .batt(batt), .error(error), 
			.not_pedaling(not_pedaling), .TX(TX));


initial begin
clk = 0;
rst_n = 0;
cadence_raw = 0;
curr = 12'h3ff;
torque = 12'h2ff;

@(posedge clk);
@(negedge clk) rst_n = 1;

repeat(500000) @(posedge clk);

$stop();
end

always
#5 clk = ~clk;

always begin
repeat(4096) @(posedge clk);
cadence_raw = ~cadence_raw;
end


always @(posedge iDUT.cadence_filt) begin
iDUT.cadence_rise = 1;
@(posedge clk) #1 iDUT.cadence_rise = 0;
end

endmodule
