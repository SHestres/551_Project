module cadence_filt(clk, rst_n, cadence, cadence_filt, cadence_rise);

input logic clk, rst_n, cadence;
output logic cadence_filt, cadence_rise;

parameter FAST_SIM;

logic q1, q2, q3; //Metastability flop outputs and delay input flop
logic chngd_n;
logic [15:0] count; //Internal signal to count stability
logic [15:0] stbl_cnt;

generate
always @(posedge(clk), negedge(rst_n)) begin : flops
if(!rst_n) begin
q1 <= 1'b0;
q2 <= 1'b0;
cadence_filt <= 01'b0;
end
else begin
	q1 <= cadence;
	q2 <= q1;
	q3 <= q2;
	
	stbl_cnt <= count;
	if(!FAST_SIM) begin
		if(&stbl_cnt)
			cadence_filt <= q3;
	end
	else begin
		if(&stbl_cnt[8:0])
			cadence_filt <= q3;
	end
end
end : flops
endgenerate

always_comb begin
cadence_rise = q2 & !q3;
chngd_n = !(q2^q3);

count = {16{chngd_n}} & (stbl_cnt + 1);
end



endmodule