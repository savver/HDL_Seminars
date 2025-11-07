module MachineControl_tb;

reg [4:0] mot_err;
reg [2:0] fail_sensn;
wire [4:0] mot_ena;
wire       led_green;
wire       led_red;

//assign 	mot_err   = 5'b11111;
//assign 	fail_sens = 3'b111;

MachineControl   dut
(
	.MOT_ERR		(mot_err),
	.FAIL_SENSn	(fail_sensn),
	.MOT_ENA		(mot_ena),
	.LED_GREEN	(led_green),
	.LED_RED		(led_red)
);

initial begin
	mot_err    = 5'b00000;
	fail_sensn = 3'b111;
	#100
	mot_err    = 5'b00001;
	#100
	mot_err    = 5'b00000;
	#100
	fail_sensn = 3'b110;
	#100
	mot_err    = 5'b00000;
	fail_sensn = 3'b111;
	#100
	$finish; 
end

endmodule 