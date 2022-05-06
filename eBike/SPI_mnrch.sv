module SPI_mnrch(
  input clk, rst_n, snd, MISO,
  input [15:0] cmd,
  output logic done, SS_n, SCLK, MOSI,
  output logic [15:0] resp
);

  typedef enum logic [1:0] {IDLE, SHIFT, DONE} state_t;
  state_t state, nxt_state;
  
  logic [4:0] SCLK_div, SCLK_div_d, bit_cntr, bit_cntr_d1, bit_cntr_d2;
  logic ld_SCLK,  full, shft, done16, init, set_done;
  logic [15:0] shft_reg;
  
  // Creates SCLK at 1/16 of clk
  always @(posedge clk) begin	
	if (ld_SCLK)
	  SCLK_div <= 5'b10111;
	else
	  SCLK_div <= SCLK_div + 1'b1;
  end	
  assign SCLK = SCLK_div[4];	
  assign full = (&SCLK_div) ? 1'b1 : 1'b0;	
  assign shft = (SCLK_div == 5'b10001) ? 1'b1 : 1'b0;
  
  // Counter to know when shifting is done
  always @(posedge clk) begin 
	if (init) 
	  bit_cntr <=  5'b00000;
	else if (shft)
	  bit_cntr <= bit_cntr + 1'b1;
  end
  assign done16 = (bit_cntr == 5'b10000) ? 1'b1 : 1'b0;
  //assign bit_cntr_d1 = (shft == 1'b1) ? bit_cntr + 1 : bit_cntr; 
  //assign bit_cntr_d2 = (init == 1'b1) ? 5'b00000 : bit_cntr_d1;	  
  
  //always @(posedge clk) begin
  //  if (shft | init)
  //    bit_cntr <= bit_cntr_d2; 
  //end
  
  
  // Shift Register
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
	  shft_reg <= 0;	
	else if (init)
	  shft_reg <= cmd;
	else if (shft)
	  shft_reg <= {shft_reg[14:0], MISO};
  end
  assign MOSI = shft_reg [15];
  
  // state flop
  always @(posedge clk, negedge rst_n) begin										
    if (!rst_n)
	  state <= IDLE;
	else 
	  state <= nxt_state;
  end
  
  // next state and output logic
  always_comb begin																	
    nxt_state = state;
	init = 1'b0;
	set_done = 1'b0;
	ld_SCLK = 1'b0;
	case (state) 
	  DONE            	: if (full) begin
						    set_done = 1'b1;
						    nxt_state = IDLE;
						  end
	  SHIFT			  	: if (done16) begin
						    nxt_state = DONE;
						  end
						  else if (snd)
						    init = 1'b1;
	  default		    : begin
						    ld_SCLK = 1'b1;
						    if (snd) begin
							  init = 1'b1;
							  nxt_state = SHIFT;
						    end
						  end
	endcase
  end
  
  assign resp = shft_reg;
  
  // SS_n flop
  always_ff @(posedge clk, negedge rst_n) begin								
    if (!rst_n) 
	  SS_n <= 1'b1;
	else if (init)
	  SS_n <= 1'b0;
	else if (set_done)
	  SS_n <= 1'b1;
  end
 
  // done flop
  always_ff @(posedge clk, negedge rst_n) begin								
    if (!rst_n)
	  done <= 1'b0;
	else if (init)
	  done <= 1'b0;
	else if (set_done)
	  done <= 1'b1;
  end


endmodule