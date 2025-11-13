`timescale 1 ns / 1 ps

module MachineControl_tb;

reg  [4:0] mot_err;
reg  [2:0] fail_sensn;
reg        clk;
reg        rstn;
wire [4:0] mot_ena;
wire       led_green;
wire       led_red;

//assign 	mot_err   = 5'b11111;
//assign 	fail_sens = 3'b111;

MachineControl_02   dut
(
	.CLK			(clk),
	.RSTn			(rstn),
	.MOT_ERR		(mot_err),
	.FAIL_SENSn	(fail_sensn),
	.MOT_ENA		(mot_ena),
	.LED_GREEN	(led_green),
	.LED_RED		(led_red)
);

initial begin
   clk = 0;
	forever
	  #5 clk = ~clk; 
end

initial begin
	rstn = 1'b0;
	mot_err    = 5'b00000;
	fail_sensn = 3'b111;
	
	#10
	rstn       = 1'b1;
	
	//wait for green led blinking (then no errors
	//emulate error after this delay
	#2000	
	mot_err    = 5'b00001;
	
	#100
	mot_err    = 5'b00000;
	#100
	fail_sensn = 3'b110;
	#100
	mot_err    = 5'b00000;
	fail_sensn = 3'b111;
	#15000
	$stop; //$finish; 
end

endmodule 