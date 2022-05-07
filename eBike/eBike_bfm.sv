interface eBike_bfm;
    input clk;				// 50MHz clk
    input RST_n;				// active low RST_n from push button
    output A2D_SS_n;			// Slave select to A2D on DE0
    output A2D_SCLK;			// SPI clock to A2D on DE0
    output A2D_MOSI;			// serial output to A2D (what channel to read)
    input A2D_MISO;			// serial input from A2D
    input hallGrn;			// hall position input for "Green" phase
    input hallYlw;			// hall position input for "Yellow" phase
    input hallBlu;			// hall position input for "Blue" phase
    output highGrn;			// high side gate drive for "Green" phase
    output lowGrn;			// low side gate drive for "Green" phase
    output highYlw;			// high side gate drive for "Yellow" phase
    output lowYlw;			// low side gate drive for "Yellow" phas
    output highBlu;			// high side gate drive for "Blue" phase
    output lowBlu;			// low side gate drive for "Blue" phase
    output inertSS_n;			// Slave select to inertial (tilt) sensor
    output inertSCLK;			// SCLK signal to inertial (tilt) sensor
    output inertMOSI;			// Serial out to inertial (tilt) sensor  
    input inertMISO;			// Serial in from inertial (tilt) sensor
    input inertINT;			// Alerts when inertial sensor has new reading
    input cadence;			// pulse input from pedal cadence sensor
    input tgglMd;				// used to select setting[1:0] (from PB switch)
    output TX;				// serial output of measured batt,curr,torque
    output [1:0] LED;			// Lower 2-bits of LED (setting) 11 => easy, 10 => medium, 01 => hard, 00 => off

    task reset_eBike();
        rst_n = 1'b0;
        @(negedge clk);
        @(negedge clk);
        rst_n = 1'b1;
    endtask: reset_eBike

    task up_hill();

    endtask up_hill

endinterface;