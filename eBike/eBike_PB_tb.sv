task eBike_PB_tb(input clk, output reg tgglMd);

  begin
	//Test PB_intf
	$display("here4");
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
	
	$display("All PB_intf tasks passed");
	//repeat(100000) @(posedge clk);
  end

endtask