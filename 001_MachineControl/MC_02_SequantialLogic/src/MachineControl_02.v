module MachineControl_02
(
	input 		 CLK,
	input        RSTn,
	input  [4:0] MOT_ERR,
	input  [2:0] FAIL_SENSn,
	output [4:0] MOT_ENA,
	output 	    LED_GREEN,
	output 	    LED_RED
);

MachineControl_002_1   mc002_1
(
	.CLK				(CLK),
	.RSTn			   (RSTn),
	.MOT_ERR			(MOT_ERR),
	.FAIL_SENSn		(FAIL_SENSn),
	.MOT_ENA			(MOT_ENA),
	.LED_GREEN		(LED_GREEN),
	.LED_RED			(LED_RED)
);

endmodule 