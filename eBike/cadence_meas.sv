module cadence_meas#(parameter FAST_SIM = 1)(clk, rst_n, cadence_filt, cadence_per, not_pedaling);

input cadence_filt, clk, rst_n;
output logic [7:0] cadence_per;
output not_pedaling;

localparam THIRD_SEC_REAL = 24'hE4E1C0;
localparam THIRD_SEC_FAST = 24'h007271;
localparam THIRD_SEC_UPPER = 8'hE4;

//parameter FAST_SIM;

logic [23:0]THIRD_SEC;
logic cadence_rise, capture_per;
logic [23:0]count;
logic countEqThird;

generate if(FAST_SIM)
	assign THIRD_SEC = THIRD_SEC_FAST;
else
	assign THIRD_SEC = THIRD_SEC_REAL;
endgenerate


logic prev;
always_ff @(posedge clk, negedge rst_n) begin: riseDetect
if(!rst_n) begin
	cadence_rise <= 0;
	prev <= 0;
	end
else begin
	prev <= cadence_filt;	
	cadence_rise <= cadence_filt & !prev;
	end
end: riseDetect


assign countEqThird = (count == THIRD_SEC);

always_ff@(posedge clk, negedge rst_n) begin
if(!rst_n)
	count <= 24'h000000;
else if(cadence_rise)
	count <= 24'h000000;
else if (countEqThird)
	count <= count;
else 
	count <= count + 1;
end

always_ff @(posedge clk) begin
if(!rst_n) cadence_per <= THIRD_SEC_UPPER;
else if(!capture_per) cadence_per <= cadence_per;
else if(FAST_SIM) cadence_per <= count[14:7];
else cadence_per <= count[23:16];
end


assign capture_per = cadence_rise | countEqThird;

assign not_pedaling = (THIRD_SEC_UPPER == cadence_per);

endmodule