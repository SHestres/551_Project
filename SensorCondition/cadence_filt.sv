module cadence_filt(clk, rst_n, cadence, cadence_filt, cadence_rise);

input logic clk, rst_n, cadence;
output logic cadence_filt, cadence_rise;

logic q1, q2, q3; //Metastability flop outputs and delay input flop
logic chngd_n;
logic [15:0] count, count_in; //Internal signals to count stability
logic [15:0] stbl_cnt;

parameter FAST_SIM;

generate
always @(posedge(clk), negedge(rst_n)) begin: flop

if(!rst_n) begin
q1 <= 1'b0;
q2 <= 1'b0;
cadence_filt <= 01'b0;
end
else begin: elseFunc
q1 <= cadence;
q2 <= q1;
q3 <= q2;

stbl_cnt <= count;


if(FAST_SIM)
	if(&(stbl_cnt[8:0]))
		cadence_filt <= q3;
	else
		cadence_filt <= cadence_filt;
else
	if(&stbl_cnt)
		cadence_filt <= q3;
	else
		cadence_filt <= cadence_filt;
end: elseFunc
end: flop
endgenerate

always @(posedge clk, negedge rst_n) begin


end

/*
logic prev;
always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n) begin 
prev <= 0;
cadence_rise <= 0;
end
else begin
prev <= cadence_filt;
cadence_rise <= cadence_filt & (cadence_filt ^ prev);
end
end
*/

endmodule;
