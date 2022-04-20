module telemetry(clk, rst_n, batt_v, avg_curr, avg_torque, TX);

input clk, rst_n;
input[11:0] batt_v, avg_curr, avg_torque;
output TX;
logic [7:0] tx_data;
logic trmt, trmt_delay, tx_done;

UART_tx iTX(.clk(clk), .rst_n(rst_n), .TX(TX), .tx_data(tx_data), .trmt(trmt), .tx_done(tx_done));


typedef enum logic [2:0] {pl_1, pl_2, pl_3, pl_4, pl_5, pl_6, IDLE} state_t;
state_t state, nxt_state;

logic[19:0] period_cnt;

always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n) period_cnt <= 0;
else
period_cnt <= period_cnt + 1;
end


always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n) state <= IDLE;
else state <= nxt_state;
end


always_comb begin
nxt_state = state;
tx_data = 8'bx;

trmt = tx_done;
case (state)
	pl_1 : begin 
		tx_data = {4'b0, batt_v[11:8]}; 
		if(tx_done) begin
			nxt_state = pl_2;
			tx_data = {batt_v[7:0]};
			end
		end
	pl_2 : begin 
		tx_data = {batt_v[7:0]}; 
		if(tx_done) begin
			nxt_state = pl_3;
			tx_data = {4'b0, avg_curr[11:8]}; 
			end
		end
	pl_3 : begin 
		tx_data = {4'b0, avg_curr[11:8]}; 
		if(tx_done) begin
			nxt_state = pl_4;
			tx_data = {avg_curr[7:0]}; 
			end
		end
	pl_4 : begin 
		tx_data = {avg_curr[7:0]}; 
		if(tx_done) begin
			nxt_state = pl_5;
			tx_data = {4'b0, avg_torque[11:8]}; 
			end
		end
	pl_5 : begin 
		tx_data = {4'b0, avg_torque[11:8]}; 
		if(tx_done) begin
			nxt_state = pl_6;
			tx_data = {avg_torque[7:0]}; 
			end
		end
	pl_6 : begin 
		tx_data = {avg_torque[7:0]}; 
		if(tx_done) begin
			nxt_state = IDLE;
			trmt = 0;
			end
		end
	default : if(&period_cnt) begin 
		nxt_state = pl_1; 
		trmt = 1; 
		tx_data = {4'b0, batt_v[11:8]};
		end
endcase
end

endmodule
