`timescale 1ns/1ps
package eBike_tasks_tb;

task automatic reset_DUT(ref clk, RST_n);
		@(negedge clk) RST_n = 0;
		@(negedge clk) RST_n = 1;
	endtask

task automatic check_batt_task(input int BATT, input logic signed [11:0]error);
    begin
	
        if(BATT < 12'hA98 && error !==0)begin
            $display("ERROR shoule be 0 now");
			$stop;
        end else begin
            $display("BATT Test passed!");
        end
    end
endtask

task automatic TORQUE_task(ref logic [11:0]avg_curr, ref logic signed [19:0]omega, input [11:0]TORQUE, ref reg clk, input logic [11:0] avg_curr_prev, input logic [19:0] omega_prev);
	begin
		logic [11:0] avg_curr_test;
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    avg_curr_test = avg_curr;
		omega_test = omega;
        if(avg_curr_test <  avg_curr_prev || omega_test < omega_prev)begin
		$display("ERROR! avg_curr and omega didn't increase as torque increases");
		$stop;
		end
	end
endtask


task automatic DETORQUE_task(ref logic [11:0]avg_curr, ref logic signed [19:0] omega, input [11:0]TORQUE, ref reg clk, input[11:0] avg_curr_prev, input[19:0] omega_prev);
	begin
		logic [11:0] avg_curr_test;
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    avg_curr_test = avg_curr;
		omega_test = omega;
        if(avg_curr_test >  avg_curr_prev || omega_test > omega_prev)begin
		$display("ERROR! avg_curr and omega didn't decrease as torque decreases");
		$stop;
		end
	end
endtask



task automatic BRAKE_task(ref logic [11:0]avg_curr, ref logic signed [19:0]omega, input [11:0]BRAKE, ref reg clk, input[11:0] avg_curr_prev, input[19:0] omega_prev);
	begin
		logic [11:0] avg_curr_test;
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    avg_curr_test = avg_curr;
		omega_test = omega;
        if(avg_curr_test >  avg_curr_prev || omega_test > omega_prev)begin
		$display("ERROR! avg_curr and omega didn't decrease as BRAKE is hit");
		$stop;
		end
	end
endtask


task automatic BRAKE_release_task(ref logic [11:0]avg_curr, ref logic signed [19:0]omega, input [11:0]BRAKE, ref reg clk, input[11:0] avg_curr_prev, input[19:0] omega_prev);
	begin
		logic [11:0] avg_curr_test;
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    avg_curr_test = avg_curr;
		omega_test = omega;
        if(avg_curr_test <  avg_curr_prev || omega_test < omega_prev)begin
		$display("ERROR! avg_curr and omega didn't decrease as BRAKE is hit");
		$stop;
		end
	end
endtask
endpackage