module brushless(
  input clk, rst_n, hallGrn, hallYlw, hallBlu, brake_n, PWM_synch,
  input [11:0] drv_mag, 
  output logic [10:0] duty,
  output logic [1:0] selGrn, selYlw, selBlu
);

  logic hallGrn1, hallGrn2, synchGrn, hallYlw1, hallYlw2, synchYlw, hallBlu1, hallBlu2, synchBlu;
  logic [2:0] rotation_state;
  logic [10:0] drv_mag_1;
  
  always_ff @(posedge clk) begin
	hallGrn1 <= hallGrn;
	hallYlw1 <= hallYlw;
	hallBlu1 <= hallBlu;
	hallGrn2 <= hallGrn1;
	hallYlw2 <= hallYlw1;
	hallBlu2 <= hallBlu1;
  end
  
  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
	  synchGrn <= 0;
	  synchYlw <= 0;
	  synchBlu <= 0;
	end
	else if (PWM_synch) begin
	  synchGrn <= hallGrn2;
	  synchYlw <= hallYlw2;
	  synchBlu <= hallBlu2;
	end
  end
  
  assign rotation_state = {synchGrn,synchYlw,synchBlu};
  
  always_comb begin
    if (!brake_n) begin
      selGrn = 2'b11;
	  selYlw = 2'b11;
	  selBlu = 2'b11;
    end
    else begin
	case (rotation_state)
	  3'b101		: begin
						selGrn = 2'b10;
						selYlw = 2'b01;
						selBlu = 2'b00;
					  end
	  3'b100		: begin
						selGrn = 2'b10;
						selYlw = 2'b00;
						selBlu = 2'b01;
					  end
	  3'b110		: begin
						selGrn = 2'b00;
						selYlw = 2'b10;
						selBlu = 2'b01;
					  end
	  3'b010		: begin
						selGrn = 2'b01;
						selYlw = 2'b10;
						selBlu = 2'b00;
					  end
	  3'b011		: begin
						selGrn = 2'b01;
						selYlw = 2'b00;
						selBlu = 2'b10;
					  end
	  3'b001		: begin
						selGrn = 2'b00;
						selYlw = 2'b01;
						selBlu = 2'b10;
					  end
	  default		: begin
						selGrn = 2'b00;
						selYlw = 2'b00;
						selBlu = 2'b00;
					  end
	endcase
	end
  end
    
  assign drv_mag_1 = (drv_mag [11:2] + 11'h400);
  assign duty = (brake_n == 0) ? 11'h600 : drv_mag_1;


endmodule