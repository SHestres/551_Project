module PID_tb();

logic clk, rst_n, not_pedaling;
logic [11:0] drv_mag;
logic [12:0] error;
logic test_over;

plant_PID plant(.clk(clk), .rst_n(rst_n), .drv_mag(drv_mag), .error(error), .not_pedaling(not_pedaling), .test_over(test_over));
PID #(.FAST_SIM (1))iDUT(.clk(clk), .rst_n(rst_n), .drv_mag(drv_mag), .error(error), .not_pedaling(not_pedaling));

always
	#5 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	#1 rst_n = 1;

while(!test_over) @(posedge clk);

$stop();
end

endmodule