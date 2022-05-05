module telemetry(clk, rst_n, batt_v, avg_curr, avg_torque, TX);
input clk, rst_n;
input [11:0] batt_v, avg_curr, avg_torque;
output logic TX;

typedef enum logic [3:0] {START, FIRST_TRMT, FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH, SEVENTH, EIGHTH, HOLD} state_t;


logic [7:0] tx_data;
logic trmt, tx_done;

logic [20:0] cntr;
logic cnt_done, trmt_set;
state_t state, next_state;

UART_tx uart(.clk(clk), .rst_n(rst_n), .tx_data(tx_data), .trmt(trmt), .tx_done(tx_done), .TX(TX));

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		cntr <= 0;
	else if (cnt_done)
		cntr <= 0;
             else	
		cntr <= cntr + 1;
end
assign cnt_done = cntr[20];

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		 state <= START;
	else 
	         state <= next_state;	
end

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		 trmt <= 0;
	else if (trmt_set) 
	          trmt  <= 1;	
	     else
		  trmt <= 0;
end


always_comb begin
	case (state)
		START: begin
			if (rst_n)
				next_state = FIRST_TRMT;
			else
				next_state = next_state;
		       end

		FIRST_TRMT: begin
			next_state = FIRST;
			trmt_set = 1;
			tx_data = 8'hAA;
		end

		FIRST: begin
			if (tx_done) begin
				next_state = SECOND;
				trmt_set = 1;
		        end
			else  begin
				next_state = next_state;
			        trmt_set = 0;
			end
		       tx_data = 8'hAA;
	       end


		SECOND: begin
			if (tx_done) begin
				next_state = THIRD;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = 8'h55; 
		       end

		THIRD: begin
			if (tx_done) begin
				next_state = FOURTH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = {4'h0, batt_v[11:8]};
		       end

		FOURTH: begin
			if (tx_done) begin
				next_state = FIFTH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = batt_v[7:0];
		       end
		FIFTH: begin
			if (tx_done) begin
				next_state = SIXTH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = {4'h0, avg_curr[11:8]};
		       end
		SIXTH: begin
			if (tx_done) begin
				next_state = SEVENTH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = avg_curr[7:0];
		       end
		SEVENTH: begin
			if (tx_done) begin
				next_state = EIGHTH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = {4'h0, avg_torque[11:8]};
		       end
		EIGHTH: begin
			trmt_set = 0;
			if (tx_done)
				next_state = HOLD;
			else
				next_state = next_state;
			tx_data = avg_torque[7:0];
		       end
		HOLD: begin
			trmt_set = 0;
			if (cnt_done)
				next_state = FIRST;
			else
				next_state = next_state;
		       end

             endcase
     end
endmodule
