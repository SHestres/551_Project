module A2D_intf(
  input clk, rst_n,
  input [11:0] batt, curr, brake, torque,
  output logic SS_n, SCLK, MOSI,
  input MISO
);

  logic [1:0] cnt;
  logic [13:0] cnt_14;
  logic [15:0] cmd;
  logic en_ba, en_c, en_br, en_t, snd, done;
  logic [15:0] resp;
  typedef enum logic [1:0] {IDLE, FIRST, WAIT, SEC} state_t;
  state_t state, nxt_state;
  
  SPI_mnrch(.clk(clk), .rst_n(rst_n), .snd(snd), .MISO(MISO), .cmd(cmd),
			.done(done), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .resp(resp));
  
  always_ff @(posedge clk, negedge rst_n) begin			// 14 bit counter, when full start transfer
    if (!rst_n)
	  cnt_14 <= 14'h00000;
	else
	  cnt_14 <= cnt_14 + 1'b1;
  end  
  
  always_ff @(posedge clk, negedge rst_n) begin			// cycle through channel reads when previous read is done
    if (!rst_n)
	  cnt_2 <= 2'b00;
	else if (cnv_cmplt)
	  cnt_2 <= cnt_2 + 1'b1;
  end
  
  assign cmd = 	(cnt_2 == 2'b00) ? {2'b00, 3'b000, 11'h000} :					//  assign cmd based on cnt_2
				(cnt_2 == 2'b01) ? {2'b00, 3'b001, 11'h000} :		
				(cnt_2 == 2'b10) ? {2'b00, 3'b011, 11'h000} :
				{2'b00, 3'b100, 11'h000};
  
  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      state <= IDLE;
    else 
      state <= nxt_state;
  end
  
  always_comb begin
    nxt_state = state;
	snd = 1'b0;
	cnv_cmplt = 1'b0;
	case (state)
	  FIRST            	: if (done) begin
				    nxt_state = WAIT;
				  end
	  WAIT			: nxt_state = SEC;
	  
	  SEC		    	: if (done) begin
				    nxt_state = IDLE;
				    cnv_cmplt = 1'b1;
				  end
	  default		: if (&cnt_14) begin
				    snd = 1'b1;
				    nxt_state = FIRST;
				  end
	endcase
  end
  
  assign en_ba = (cnt_2 == 2'b00 & cnv_cmplt) ? 1'b1 : 1'b0;				//
  assign en_c = (cnt_2 == 2'b01 & cnv_cmplt) ? 1'b1 : 1'b0;				// enable when transaction is complete
  assign en_br = (cnt_2 == 2'b10 & cnv_cmplt) ? 1'b1 : 1'b0;				// and when cnt_2 is on there channel
  assign en_t = (cnt_2 == 2'b11 & cnv_cmplt) ? 1'b1 : 1'b0;				//
  
  always_ff@(posedge clk, negedge rst_n) begin
	if (!rst_n)
	  batt <= 12'h000;
	  curr <= 12'h000;
	  brake	<= 12'h000;
	  torque <= 12'h000;
	else if(en_ba)
	  batt <= resp[11:0];
	else if(en_c)
	  curr <= resp[11:0];
	else if(en_br)
	  brake <= resp[11:0];
	else if(en_t)
	  torque <= resp[11:0];
  end

endmodule
