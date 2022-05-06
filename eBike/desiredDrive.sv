module desiredDrive(
    input [11:0] avg_torque,
    input [4:0] cadence,
    input not_pedaling,
    input signed [12:0] incline,
    input [2:0] scale,
    input clk,
    input rst_n,
    output [11:0] target_curr
);

localparam TORQUE_MIN = 12'h380;
localparam TOO_SMALL = 5'h05;

// Limit the incling sensor to its effective 10 bit range.
logic signed [9:0] incline_sat;
assign incline_sat = (incline[12] & ~&incline[11:9]) ? 10'h200 :
                    (~incline[12] & |incline[11:9]) ? 10'h1FF :
                    incline[9:0];

// Adjust the pedaling helping effort for steep hills
logic signed [10:0] incline_factor;
assign incline_factor = {incline_sat[9], incline_sat[9:0]} + 11'd256;

// Make the inc_factor fall in the range of 0-511 by limiting and clipping it
logic [8:0] incline_factor_limit;
assign incline_factor_limit = (incline_factor[10]) ? 9'h000 : 		// set value to 0 if less than 0
                            (incline_factor[9]) ? 9'd511 :		// saturate at 511 if larger than 511
                            incline_factor[8:0];

// Subtract the offset of the start of the motor
logic signed [12:0] torque_off;
logic [12:0] torque_pos;
assign torque_off = {1'b0, avg_torque} - {1'b0, TORQUE_MIN};

// Adjust the helping rate from motor and add that to the cadence
logic [5:0] cadence_factor, cad_plus_32, cad_old;
// ------------------Pipelining to meet timing and reduce area added by Synopsis---------------
always_ff @(posedge clk, negedge rst_n) begin: pipeline_flops
    if (~rst_n) begin
        cadence_factor <= 0;
        cad_plus_32 <= 0;
        cad_old <= 0;
    end
    else begin
        cad_old <= cadence;
        cad_plus_32 <= cadence + 32;
        cadence_factor <= (cad_old > 1) ? cad_plus_32 : 6'h00;
        // Limit the torque_off to zero when the subtraction gives a negative value; we don't want to interpret it as negative val.
        torque_pos <= torque_off[12] ? 12'h000 : torque_off[11:0];
    end
end: pipeline_flops

logic signed [30:0] torq_times_scale, inc_times_cad;
logic signed [30:0] assist_prod_check;
always_ff @(posedge clk, negedge rst_n) begin: second_pipeline
    if (~rst_n) begin
        torq_times_scale <= 0;
        inc_times_cad <= 0;
        assist_prod_check <= 0;
    end
    else begin
        torq_times_scale <= torque_pos * scale;
        inc_times_cad <= incline_factor_limit * cadence_factor;
        assist_prod_check <= torq_times_scale * inc_times_cad;
    end

end: second_pipeline
// ------------------Pipelining to meet timing and reduce area added by Synopsis---------------

// The assist level is the product of incline factor, rider's riding effort, and scale.
logic signed [30:0] assist_prod;
assign assist_prod = not_pedaling ? 30'h00000000 : assist_prod_check;

// If the assist level saturates to a 12-bit value we make the max assist.
assign target_curr = (|assist_prod[29:27]) ? 12'hFFF : assist_prod[26:15];

endmodule
