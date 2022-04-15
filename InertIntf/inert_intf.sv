module inert_intf(
  input clk, rst_n, MISO, INT,
  output logic SS_n, SCLK, MOSI, vld, LED,
  output logic [12:0] incline
);
  
  logic C_R_H, C_R_L, C_Y_H, C_Y_L, C_AY_H, C_AY_L, C_AZ_H, C_AZ_L, snd, done, INT_ff1, INT_ff2;
  logic [7:0] roll_rt_H, roll_rt_L, yaw_rt_H, yaw_rt_L, AY_H, AY_L, AZ_H, AZ_L;
  logic [15:0] cnt_16, resp, cmd;
  
  SPI_mnrch SPI(.clk(clk), .rst_n(rst_n), .snd(snd), .MISO(MISO), .cmd(cmd), .done(done), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .resp(resp));
  inertial_integrator INRTL(.clk(clk), .rst_n(rst_n), .vld(vld), .roll_rt({roll_rt_H,roll_rt_L}), .yaw_rt({yaw_rt_H,yaw_rt_L}), .AY({AY_H,AY_L}), .AZ({AZ_H,AZ_L}), .incline(incline), .LED(LED));
  
  typedef enum logic [3:0] {INIT1, INIT2, INIT3, INIT4, WAIT, rollL, rollH, yawL, yawH, AYL, AYH, AZL, AZH, DONE} state_t;
  state_t state, nxt_state;
  
  // double flop INT for metastability
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
	  INT_ff1 <= 1'b0;
	  INT_ff2 <= 1'b0;
	end
	else begin
	  INT_ff1 <= INT;
	  INT_ff2 <= INT_ff1;
	end
  end
  
  // 16 bit counter, wait for inerial sensor chip to be ready
  always_ff @(posedge clk, negedge rst_n) begin				
    if (!rst_n)
	  cnt_16 <= 16'h0000;
	else
	  cnt_16 <= cnt_16 + 1'b1;
  end 
  
  // flop for each of the holding regs
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
	  roll_rt_H <= 1'b0;
	  roll_rt_L <= 1'b0;
	  yaw_rt_H <= 1'b0;
	  yaw_rt_L <= 1'b0;
	  AY_H <= 1'b0;
	  AY_L <= 1'b0;
	  AZ_H <= 1'b0;
	  AZ_L <= 1'b0;
	end
	else if (C_R_H)
	  roll_rt_H <= resp[7:0];
	else if (C_R_L)
	  roll_rt_L <= resp[7:0];
	else if (C_Y_H)
	  yaw_rt_H <= resp[7:0];
	else if (C_Y_L)
	  yaw_rt_L <= resp[7:0];
	else if (C_AY_H)
	  AY_H <= resp[7:0];
	else if (C_AY_L)
	  AY_L <= resp[7:0];
	else if (C_AZ_H)
	  AZ_H <= resp[7:0];
	else if (C_AZ_L)
	  AZ_L <= resp[7:0];
  end
  
  // state flop
  always @(posedge clk, negedge rst_n) begin										
    if (!rst_n)
	  state <= INIT1;
	else 
	  state <= nxt_state;
  end
  
  // next state and output logic 
  always_comb begin																	
    nxt_state = state;
	snd = 1'b0;
	vld = 1'b0;
	C_R_L = 1'b0;
	C_R_H = 1'b0;
	C_Y_L = 1'b0;
	C_Y_H = 1'b0;
	C_AY_L = 1'b0;
	C_AY_H = 1'b0;
	C_AZ_L = 1'b0;
	C_AZ_H = 1'b0;
	cmd = 16'h0000;
	case (state) 
	  INIT2			  	: begin
						    cmd = 16'h1053;
						    if (done) begin
							  snd = 1'b1;
						      nxt_state = INIT3;
						    end
						  end
	  INIT3            	: begin
						    cmd = 16'h1150;
						    if (done) begin
							  snd = 1'b1;
						      nxt_state = INIT4;
						    end
						  end
	  INIT4			  	: begin
						    cmd = 16'h1460;
						    if (done) begin
							  snd = 1'b1;
						      nxt_state = INIT4;
						    end
						  end
	  WAIT				: begin
						      if (INT_ff2)
						      nxt_state = rollL;
						  end
	  rollL            : begin
						    cmd = 16'hA4xx;
						    snd = 1'b1;
						    nxt_state = rollH;
						  end
	  rollH				: begin
						    cmd = 16'hA5xx;
						    if (done) begin
						      C_R_L = 1'b1;
						      snd = 1'b1;
						      nxt_state = yawL;
						    end
						  end
	  yawL            	: begin
						    cmd = 16'hA6xx;
						    if (done) begin
						      C_R_H = 1'b1;
						      snd = 1'b1;
						      nxt_state = yawH;
						    end
						  end
	  yawH			  	: begin
						    cmd = 16'hA7xx;
						    if (done) begin
						      C_Y_L = 1'b1;
						      snd = 1'b1;
						      nxt_state = AYL;
						    end
						  end
	  AYL            	: begin
						    cmd = 16'hAAxx;
						    if (done) begin
						      C_Y_H = 1'b1;
						      snd = 1'b1;
						      nxt_state = AYH;
						    end
						  end
	  AYH			  	: begin
						    cmd = 16'hABxx;
						    if (done) begin
						      C_AY_L = 1'b1;
						      snd = 1'b1;
						      nxt_state = AZL;
						    end
						  end
	  AZL            	: begin
						    cmd = 16'hACxx;
						    if (done) begin
						      C_AY_H = 1'b1;
						      snd = 1'b1;
						      nxt_state = AZH;
						    end
						  end
	  AZH			  	: begin
						    cmd = 16'hADxx;
						    if (done) begin
						      C_AZ_L = 1'b1;
						      snd = 1'b1;
						      nxt_state = DONE;
						    end
						  end
	  DONE				: begin
						    if (done) begin
						      C_AZ_H = 1'b1;
						      vld = 1'b1;
							  nxt_state = WAIT;
						      end
						  end
	  default           : begin
						    cmd = 16'h0D02;
						    if (&cnt_16) begin
						      snd = 1'b1;
						      nxt_state = INIT2;
						    end
						  end
	endcase
  end   
endmodule
  