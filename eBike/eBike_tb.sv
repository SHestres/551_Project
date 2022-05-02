module eBike_tb();
 
  // include or import tasks?

  localparam FAST_SIM = 1;		// accelerate simulation by default

  ///////////////////////////
  // Stimulus of type reg //
  /////////////////////////
  reg clk,RST_n;
  reg [11:0] BATT;				// analog values
  reg [11:0] BRAKE,TORQUE;		// analog values
  reg tgglMd;					// push button for assist mode
  reg [15:0] YAW_RT;			// models angular rate of incline (+ => uphill)


  //////////////////////////////////////////////////
  // Declare any internal signal to interconnect //
  ////////////////////////////////////////////////
  wire A2D_SS_n,A2D_MOSI,A2D_SCLK,A2D_MISO;
  wire highGrn,lowGrn,highYlw,lowYlw,highBlu,lowBlu;
  wire hallGrn,hallBlu,hallYlw;
  wire inertSS_n,inertSCLK,inertMISO,inertMOSI,inertINT;
  logic cadence;
  wire [1:0] LED;			// hook to setting from PB_intf
  
  wire signed [11:0] coilGY,coilYB,coilBG;
  logic [11:0] curr;		// comes from hub_wheel_model
  wire [11:0] BATT_TX, TORQUE_TX, CURR_TX;
  logic vld_TX;
  
  //////////////////////////////////////////////////
  // Instantiate model of analog input circuitry //
  ////////////////////////////////////////////////
  AnalogModel iANLG(.clk(clk),.rst_n(RST_n),.SS_n(A2D_SS_n),.SCLK(A2D_SCLK),
                    .MISO(A2D_MISO),.MOSI(A2D_MOSI),.BATT(BATT),
		    .CURR(curr),.BRAKE(BRAKE),.TORQUE(TORQUE));

  ////////////////////////////////////////////////////////////////
  // Instantiate model inertial sensor used to measure incline //
  //////////////////////////////////////////////////////////////
  eBikePhysics iPHYS(.clk(clk),.RST_n(RST_n),.SS_n(inertSS_n),.SCLK(inertSCLK),
	             .MISO(inertMISO),.MOSI(inertMOSI),.INT(inertINT),
		     .yaw_rt(YAW_RT),.highGrn(highGrn),.lowGrn(lowGrn),
		     .highYlw(highYlw),.lowYlw(lowYlw),.highBlu(highBlu),
		     .lowBlu(lowBlu),.hallGrn(hallGrn),.hallYlw(hallYlw),
		     .hallBlu(hallBlu),.avg_curr(curr));

  //////////////////////
  // Instantiate DUT //
  ////////////////////
  eBike #(FAST_SIM) iDUT(.clk(clk),.RST_n(RST_n),.A2D_SS_n(A2D_SS_n),.A2D_MOSI(A2D_MOSI),
                         .A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),.hallGrn(hallGrn),
			 .hallYlw(hallYlw),.hallBlu(hallBlu),.highGrn(highGrn),
			 .lowGrn(lowGrn),.highYlw(highYlw),.lowYlw(lowYlw),
			 .highBlu(highBlu),.lowBlu(lowBlu),.inertSS_n(inertSS_n),
			 .inertSCLK(inertSCLK),.inertMOSI(inertMOSI),
			 .inertMISO(inertMISO),.inertINT(inertINT),
			 .cadence(cadence),.tgglMd(tgglMd),.TX(TX_RX),
			 .LED(LED));
			 
			 
  ////////////////////////////////////////////////////////////
  // Instantiate UART_rcv or some other telemetry monitor? //
  //////////////////////////////////////////////////////////
	


  localparam test_duration = 50000;
  int cadence_period = 50000;

  //TODO: Add UART checks
  //TODO: tgglMD checks
  //TODO: torque checks
  //TODO: brake checks
  //TODO: batt checks
  //TODO: YAW_RT checks
  initial begin
    clk = 0;
	RST_n = 0;
	cadence = 0;
	tgglMd = 1'b0;
	YAW_RT = 16'h0000;
	TORQUE = 12'h0F0;
	BRAKE = 12'h000;
	BATT = 12'hFFF;
	
	@(posedge clk);
	@(negedge clk);
	RST_n = 1; 
	repeat(5)@(posedge clk)
	
	//Test reset conditions
	
	//Test PB_intf -------------do via task?
	if (iDUT.scale !== 3'b101) begin
		$display("scale should be 101 upon reset");
		$stop;
	end
	 
	@(posedge clk)
	tgglMd = 1'b1;
	repeat(10)@(posedge clk)
	tgglMd = 1'b0;
	
	if (iDUT.scale !== 3'b111) begin
		$display("scale should be 111 now");
		$stop;
	end
	
	@(posedge clk)
	tgglMd = 1'b1;
	repeat(10)@(posedge clk)
	tgglMd = 1'b0;
	
	if (iDUT.scale !== 3'b000) begin
		$display("scale should be 000 now");
		$stop;
	end
	
	@(posedge clk)
	tgglMd = 1'b1;
	repeat(10)@(posedge clk)
	tgglMd = 1'b0;
	
	if (iDUT.scale !== 3'b011) begin
		$display("scale should be 011 now");
		$stop;
	end
	
	@(posedge clk)
	tgglMd = 1'b1;
	repeat(10)@(posedge clk)
	tgglMd = 1'b0;
	
	if (iDUT.scale !== 3'b101) begin
		$display("scale should be 101 now");
		$stop;
	end
	
	repeat(test_duration) @(posedge clk);
	
	//Tests with different cadences
	cadence_period = 100000;
	repeat(test_duration) @(posedge clk);
	
	cadence_period = 150000;
	repeat(test_duration) @(posedge clk);

	cadence_period = 100000;
	
	//Tests with different inclines
	YAW_RT = 16'h1000;
	repeat(test_duration) @(posedge clk);
	
	YAW_RT = 16'h2000;
	repeat(test_duration) @(posedge clk);
	  
	YAW_RT = 16'h9000;
	repeat(test_duration) @(posedge clk);
	
	YAW_RT = 16'h0000;
	repeat(test_duration) @(posedge clk);
	
	//Tests with different torques
	TORQUE = 12'hF00;
	repeat(test_duration) @(posedge clk);
	
	TORQUE = 12'hFFF;
	repeat(test_duration) @(posedge clk);
	
	TORQUE = 12'h000;
	repeat(test_duration) @(posedge clk);
	
	
	//TODO

	$stop;
	
  end
  
  ///////////////////
  // Generate clk //
  /////////////////
  always
    #10 clk <= ~clk;

  ///////////////////////////////////////////
  // Block for cadence signal generation? //
  /////////////////////////////////////////
  always 
  	#cadence_period cadence <= ~cadence;

endmodule
