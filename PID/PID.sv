module PID(
    input clk, rst_n, not_pedaling,
    input [12:0] error,
    output [11:0] drv_mag
);

parameter FAST_SIM = 0;

logic [13:0] I_term, P_term;
logic [19:0] decimator;
logic decimator_full;

generate if (FAST_SIM) begin
            assign decimator_full = &decimator[14:0];
        end else begin
            assign decimator_full = &decimator;
        end
endgenerate

//Clock detecting each 48th of a second, assuming 50MHz clk
always_ff @(posedge clk, negedge rst_n) begin 
    if(!rst_n)
        decimator <= 0;
    else
        decimator <= decimator + 1;
end

// /////////////////////////////
// // Calculate the P-Term /////
// /////////////////////////////
assign P_term = {error[12], error};

// /////////////////////////////
// // Calculate the I-Term /////
// /////////////////////////////
logic [17:0] integrator;
logic [17:0] added;

assign added = integrator + {{5{error[12]}}, error};
assign pos_ov = added[17] && (!added[16]);

always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n) 
	integrator <= 0;
else if(not_pedaling)
	integrator <= 18'h00000;
else if(!decimator_full)
	integrator <= integrator;
else if(pos_ov)
	integrator <= 18'h1FFFF;
else if(added[17])
	integrator <= 18'h00000;
else
	integrator <= added;
end

assign I_term = {{2{integrator[16]}}, integrator[16:5]};

// /////////////////////////////
// // Calculate the D-Term /////
// /////////////////////////////
// Signals every 1/48 second
logic [12:0] first_synch_val, second_synch_val, prev_err;
// Input signals for the flops
logic [12:0] first_synch_val_inp, second_synch_val_inp, prev_err_inp;

assign first_synch_val_inp = decimator_full ? error : first_synch_val;
assign second_synch_val_inp = decimator_full ? first_synch_val : second_synch_val;
assign prev_err_inp = decimator_full ? second_synch_val : prev_err;

always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        first_synch_val <= 0;
        second_synch_val <= 0;
        prev_err <= 0;
    end
    else begin
        first_synch_val <= first_synch_val_inp;
        second_synch_val <= second_synch_val_inp;
        prev_err <= prev_err_inp;
    end
end

logic signed [12:0] D_diff;
logic signed [8:0] D_diff_sat;

assign D_diff = error - prev_err;
assign D_diff_sat = (D_diff > 9'h0FF) ? 9'h0FF :
                    (D_diff < 9'h100) ? 9'h100 : D_diff;

logic signed [9:0] D_term;
assign D_term = D_diff << 2;

///////////////////////////////////////////////////////////
///// Sum over the PID term and determine the drv_mag /////
///////////////////////////////////////////////////////////
logic [13:0] PID, I_ext, D_ext;
logic [11:0] drv_mag_tmp;
assign I_ext = {1'b0, I_term};
assign D_ext = {{4{D_term[9]}}, D_term};
assign PID = P_term + I_term + D_term;

assign drv_mag_tmp = PID[12] ? 12'hFFF : PID[11:0];
assign drv_mag = PID[13] ? 12'h000 : drv_mag_tmp;

endmodule
