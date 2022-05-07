// module telemetry_tb();

// // Input to the uart receive module
// logic clk, rst_n;
// // Output from the uart receive module
// logic rdy;
// logic [7:0] rx_data;

// // Input for the telemetry module
// logic [11:0] batt_v, avg_curr, avg_torque;
// // Output from the telemetry module
// logic tx;

// // Generate clock signal
// always begin
//     clk = ~clk;
//     #5;
// end

// // Instantiate the telemetry module
// telemetry iDUT(.clk(clk), .rst_n(rst_n), .batt_v(batt_v), .avg_curr(avg_curr), .avg_torque(avg_torque), .TX(tx));

// // Instantiate teh UART_rcv module to test the output
// UART_rcv uartrcv(.clk(clk), .rst_n(rst_n), .RX(tx), .rdy(rdy), .rx_data(rx_data), .clr_rdy(rdy));

// // First, clear the inputs
// initial begin
//     clk = 0;
//     @(negedge clk)
//     rst_n = 0;
//     @(posedge clk)
//     rst_n = 1;
//     batt_v = 12'hABC;
//     avg_curr = 12'hABC;
//     avg_torque = 12'hABC;
//     #320;
//     if (rdy && (rx_data == 8'hAA)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         $display("should be 8'hAA, but got %h", rx_data);
//         // $stop();
//     end
//     #320;
//     if (rdy && (rx_data == 8'h55)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         // $stop();
//     end
//     #320;
//     if (rdy && (rx_data == 8'h0A)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         $stop();
//     end
//     #320;
//     if (rdy && (rx_data == 8'hBC)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         $stop();
//     end
//     #320;
//     if (rdy && (rx_data == 8'h0A)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         $stop();
//     end
//     #320;
//     if (rdy && (rx_data == 8'hBC)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         $stop();
//     end
//     #320;
//     if (rdy && (rx_data == 8'h0A)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         $stop();
//     end
//     #320;
//     if (rdy && (rx_data == 8'hBC)) begin
//         $display("passed");
//     end
//     else begin
//         $display("failed");
//         $stop();
//     end
//     $stop();
// end

// // test the behavior of telemetry

// endmodule

module telemetry_tb();
logic clk, rst_n, tx;
logic [11:0] batt_v, avg_curr, avg_torque;

telemetry iDUT(.clk(clk), .rst_n(rst_n), .batt_v(batt_v), .avg_curr(avg_curr), .avg_torque(avg_torque), .TX(tx));

int cnt = 0;

initial begin
    clk = 0;
    rst_n = 0;
    batt_v = 11'h001;
    avg_curr = 11'h002;
    avg_torque = 11'h003;

    @(posedge clk);

    @(negedge clk);
    rst_n = 1;
        
    repeat(100000) @(posedge clk) cnt+=1;
    if (cnt % 6 == 0) begin
        batt_v += 1'd1;
    end
    $stop();
end

always
	#5 clk = ~ clk;

endmodule
