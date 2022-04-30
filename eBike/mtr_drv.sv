module mtr_drv(
  input [10:0] duty,
  input [1:0] selGrn, selYlw, selBlu,
  input clk, rst_n,
  output PWM_synch, highGrn, lowGrn, highYlw, lowYlw, highBlu, lowBlu
);

  logic PWM_sig, highInGrn, lowInGrn, highInYlw, lowInYlw, highInBlu, lowInBlu;

  PWM PWM1(.clk(clk), .rst_n(rst_n), .duty(duty), .PWM_synch(PWM_synch), .PWM_sig(PWM_sig));
  nonoverlap nonoverlap1(.clk(clk), .rst_n(rst_n), .highIn(highInGrn), .lowIn(lowInGrn), .highOut(highGrn), .lowOut(lowGrn));
  nonoverlap nonoverlap2(.clk(clk), .rst_n(rst_n), .highIn(highInYlw), .lowIn(lowInYlw), .highOut(highYlw), .lowOut(lowYlw));
  nonoverlap nonoverlap3(.clk(clk), .rst_n(rst_n), .highIn(highInBlu), .lowIn(lowInBlu), .highOut(highBlu), .lowOut(lowBlu));
  
  assign highInGrn = (selGrn == 2'b00) ? 1'b0 :
					(selGrn == 2'b01) ? ~PWM_sig :
					(selGrn == 2'b10) ? PWM_sig :
					1'b0;

  assign highInYlw = (selYlw == 2'b00) ? 1'b0 :
					(selYlw == 2'b01) ? ~PWM_sig :
					(selYlw == 2'b10) ? PWM_sig :
					1'b0;
					
  assign highInBlu = (selBlu == 2'b00) ? 1'b0 :
					(selBlu == 2'b01) ? ~PWM_sig :
					(selBlu == 2'b10) ? PWM_sig :
					1'b0;
					
  assign lowInGrn = (selGrn == 2'b00) ? 1'b0 :
					(selGrn == 2'b01) ? PWM_sig :
					(selGrn == 2'b10) ? ~PWM_sig :
					PWM_sig;

  assign lowInYlw = (selYlw == 2'b00) ? 1'b0 :
					(selYlw == 2'b01) ? PWM_sig :
					(selYlw == 2'b10) ? ~PWM_sig :
					PWM_sig;
					
  assign lowInBlu = (selBlu == 2'b00) ? 1'b0 :
					(selBlu == 2'b01) ? PWM_sig :
					(selBlu == 2'b10) ? ~PWM_sig :
					PWM_sig;
					
endmodule