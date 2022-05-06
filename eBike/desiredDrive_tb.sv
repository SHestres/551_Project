module desiredDrive_tb();

logic [11:0] avgtq, tar_cur;
logic [4:0] cd;
logic np;
logic [12:0] inc;
logic [2:0] sc;
logic clk, rst_n;

desiredDrive iDUT (.avg_torque(avgtq), .cadence(cd), .not_pedaling(np), .incline(inc), .scale(sc), .target_curr(tar_cur), .clk(clk), .rst_n(rst_n));

initial begin
    clk = 0;
    rst_n = 0;
    rst_n = 1;
    avgtq = 12'h800;
    cd = 5'h10;
    inc = 13'h0150;
    sc = 3'h3;
    np = 1'b0;
    #50;
    if (tar_cur !== 12'hA1A)
        begin
            $display("error present in test1\n");
            $display("target_curr value should be: %h\nwhile target_curr value is: %d\n", 12'hA1A, tar_cur);
        end


    avgtq = 12'h800;
    cd = 5'h10;
    inc = 13'h1F22;
    sc = 3'h5;
    np = 1'b0;
    #25;
    if (tar_cur !== 12'h11E)
        begin
            $display("error present in test2\n");
            $display("target_curr value should be: %h\nwhile target_curr value is: %d\n", 12'h11E, tar_cur);
        end


    avgtq = 12'h360;
    cd = 5'h10;
    inc = 13'h0C0;
    sc = 3'h5;
    np = 1'b0;
    #50;
    if (tar_cur !== 12'h000)
        begin
            $display("error present in test3\n");
            $display("target_curr value should be: %h\nwhile target_curr value is: %d\n", 12'hA1A, tar_cur);
        end


    avgtq = 12'h800;
    cd = 5'h18;
    inc = 13'h1EF0;
    sc = 3'h5;
    np = 0;
    #50;
    if (tar_cur != 12'h000)
        begin
            $display("error present in test4\n");
            $display("target_curr value should be: %h\nwhile target_curr value is: %d\n", 12'h000, tar_cur);
        end


    avgtq = 12'h7E0;
    cd = 5'h18;
    inc = 13'h0000;
    sc = 3'h7;
    np = 0;
    #50;
    if (tar_cur != 12'hD66)
        begin
            $display("error present in test5\n");
            $display("target_curr value should be: %h\nwhile target_curr value is: %d\n", 12'hD66, tar_cur);
        end


    avgtq = 12'h7E0;
    cd = 5'h18;
    inc = 13'h0080;
    sc = 3'h7;
    np = 0;
    #50;
    if (tar_cur != 12'hFFF)
        begin
            $display("error present in test6\n");
            $display("target_curr value should be: %h\nwhile target_curr value is: %d\n", 12'hFFF, tar_cur);
        end

    avgtq = 12'h7E0;
    cd = 5'h18;
    inc = 13'h0080;
    sc = 3'h7;
    np = 1;
    #50;
    if (tar_cur != 12'h000)
        begin
            $display("error present in test7\n");
            $display("target_curr value should be: %h\nwhile target_curr value is: %d\n", 12'h000, tar_cur);
        end
    $display("Yahoo, test passed!");
    $stop();
end

always begin
    clk = ~clk;
    #5;
end

endmodule