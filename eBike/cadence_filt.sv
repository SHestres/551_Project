module cadence_filt#(parameter FAST_SIM = 1)(clk, rst_n, cadence, cadence_filt, cadence_rise);
input clk, rst_n, cadence;
output cadence_filt, cadence_rise;

// cadence_filt outputs cadence cadence is held stable for 1 ms.
// cadence_rise detects whether the cadence has a rising edge.
logic cadence_ff1, cadence_ff2, cadence_ff3;
logic cadence_rise, cadence_filt;
logic stable;
logic [15:0] stbl_cnt;

always_ff @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		cadence_ff1 <= 0;
		cadence_ff2 <= 0;
		cadence_ff3 <= 0;
	end
	else begin
		cadence_ff1 <= cadence;
		cadence_ff2 <= cadence_ff1;
		cadence_ff3 <= cadence_ff2;
	end
end

// Separate the ff because they're different functions
// This ff tells when the candence stabilizes
generate
always_ff @(posedge clk, negedge rst_n) begin
	if ((cadence_ff2 != cadence_ff3) || (~rst_n))
		stbl_cnt <= 0;
	else
		stbl_cnt <= stbl_cnt + 1;

	if(!FAST_SIM) begin
		if (stable) 
			cadence_filt <= cadence_ff3;
	end
	else begin
		if(&stbl_cnt[8:0])
			cadence_filt <= cadence_ff3;
	end
end
endgenerate


always_comb begin
	stable = &stbl_cnt;
	cadence_rise = cadence_ff2 & ~cadence_ff3;
end

endmodule