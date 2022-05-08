`timescale 1ns/1ps
package eBike_tasks_postsyn_tb;

task automatic reset_DUT(ref clk, RST_n);
		@(negedge clk) RST_n = 0;
		@(negedge clk) RST_n = 1;
	endtask


task automatic TORQUE_task( ref logic signed [19:0]omega, input [11:0]TORQUE, ref reg clk,  input logic [19:0] omega_prev);
	begin
		
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    
		omega_test = omega;
        if(omega_test < omega_prev)begin
		$display("ERROR! avg_curr and omega didn't increase as torque increases");
		$stop;
		end
	end
endtask


task automatic DETORQUE_task( ref logic signed [19:0] omega, input [11:0]TORQUE, ref reg clk,  input[19:0] omega_prev);
	begin
		
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    
		omega_test = omega;
        if(omega_test > omega_prev)begin
		$display("ERROR! avg_curr and omega didn't decrease as torque decreases");
		$stop;
		end
	end
endtask



task automatic BRAKE_task( ref logic signed [19:0]omega, input [11:0]BRAKE, ref reg clk,  input[19:0] omega_prev);
	begin
		
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    
		omega_test = omega;
        if(omega_test > omega_prev)begin
		$display("ERROR! avg_curr and omega didn't decrease as BRAKE is hit");
		$stop;
		end
	end
endtask


task automatic BRAKE_release_task( ref logic signed [19:0]omega, input [11:0]BRAKE, ref reg clk,  input[19:0] omega_prev);
	begin
		
		logic [19:0] omega_test;
		repeat (2000000) @(posedge clk);
	    
		omega_test = omega;
        if(omega_test < omega_prev)begin
		$display("ERROR! avg_curr and omega didn't decrease as BRAKE is hit");
		$stop;
		end
	end
endtask
endpackage