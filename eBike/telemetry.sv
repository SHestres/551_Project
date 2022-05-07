module telemetry (
	input clk, rst_n,
	input [11:0] batt_v, avg_curr, avg_torque,
	output logic TX
);

typedef enum logic [3:0] {NADA, TX_START, DELIM_1, DELIM_2, BATT_HIGH, BATT_LOW, CURR_HIGH, CURR_LOW, TRQ_HIGH, TRQ_LOW, HOLD_HIGH} state_t;

// Decare transmission state logics
logic [7:0] tx_data;
logic trmt, tx_done;

logic [20:0] cntr;
logic cnt_done, trmt_set;
state_t state, next_state;

// instantiate the UART module
UART_tx uart(.clk(clk), .rst_n(rst_n), .tx_data(tx_data), .trmt(trmt), .tx_done(tx_done), .TX(TX));

// Declare the FSM
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		state <= NADA;
	else 
		state <= next_state;	
end

always_comb begin
	case (state)
	// Kickoff the transmission
		NADA: begin
			if (rst_n)
				next_state = TX_START;
			else
				next_state = next_state;
			end
		TX_START: begin
			next_state = DELIM_1;
			trmt_set = 1;
			tx_data = 8'hAA;
		end
	// Send DELIMITER
		DELIM_1: begin
			if (tx_done) begin
				next_state = DELIM_2;
				trmt_set = 1;
			end
			else  begin
				next_state = next_state;
				trmt_set = 0;
			end
		       	tx_data = 8'hAA;
	       	end


		DELIM_2: begin
			if (tx_done) begin
				next_state = BATT_HIGH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = 8'h55; 
			end
	// SEND BATT
		BATT_HIGH: begin
			if (tx_done) begin
				next_state = BATT_LOW;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = {4'h0, batt_v[11:8]};
			end

		BATT_LOW: begin
			if (tx_done) begin
				next_state = CURR_HIGH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = batt_v[7:0];
			end
	// SEND AVG CURR
		CURR_HIGH: begin
			if (tx_done) begin
				next_state = CURR_LOW;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = {4'h0, avg_curr[11:8]};
			end
		CURR_LOW: begin
			if (tx_done) begin
				next_state = TRQ_HIGH;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = avg_curr[7:0];
			end
	// SEND AVG TRQ
		TRQ_HIGH: begin
			if (tx_done) begin
				next_state = TRQ_LOW;
				trmt_set = 1;
			end
			else begin
				next_state = next_state;
				trmt_set = 0;
			end
			tx_data = {4'h0, avg_torque[11:8]};
			end
		TRQ_LOW: begin
			trmt_set = 0;
			if (tx_done)
				next_state = HOLD_HIGH;
			else
				next_state = next_state;
				tx_data = avg_torque[7:0];
			end
		// FINISH TRANSMISSION
		HOLD_HIGH: begin
			trmt_set = 0;
			if (cnt_done)
				next_state = DELIM_1;
			else
				next_state = next_state;
			end

			endcase
     end

// Declare the transmission states
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		trmt <= 0;
	else if (trmt_set) 
		trmt  <= 1;	
	else
		trmt <= 0;
end

// Declare a counter register
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		cntr <= 0;
	else if (cnt_done)
		cntr <= 0;
	else	
		cntr <= cntr + 1;
end
assign cnt_done = cntr[20];

endmodule