module cadence_filt(
    input clk, rst_n, cadence,
    output cadence_filt, cadence_rise
);

// Setup flops that detect the metastability
logic cd_flop1, cd_flop2, cd_flop3;
// Detect changes in the signal
logic chngd_n;
logic cd_fit_tmp, stbl_cnt_check, tmp, cdrise_tmp, cd_fit_tmp2;
logic [15:0] stbl_cnt, stb_cnt_p1, stbp1_and_stable;

parameter FAST_SIM = 1;

generate if (FAST_SIM) begin
            assign stbl_cnt_check = &stbl_cnt[8:0];
        end else begin
            assign stbl_cnt_check = &stbl_cnt;
        end
endgenerate

always_ff @(posedge clk) begin
    cd_flop1 <= cadence;
    cd_flop2 <= cd_flop1;
    cd_flop3 <= cd_flop2;
    cadence_filt <= cd_fit_tmp;
    stbl_cnt <= stbp1_and_stable;
end

always_ff @(posedge clk) begin
    // Counter that counts about 1ms
    stb_cnt_p1 = stbl_cnt + 1'b1;
end

// Kick off 1ms counting if stable signal detected
assign stbp1_and_stable = {16{chngd_n}} & stb_cnt_p1;

// Detects if it passes roughly 1ms and outputs cadence_filt
assign cd_fit_tmp = stbl_cnt_check ? cd_flop3 : cadence_filt;

// Detect if the signal changed
assign chngd_n = ~(cd_flop3 ^ cd_flop2);

// Detect change in signal and if it rises
assign cadence_rise = cd_flop2 & ~cd_flop3;

endmodule
