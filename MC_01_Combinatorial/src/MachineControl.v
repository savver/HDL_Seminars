module MachineControl
(
	input [4:0]  MOT_ERR,
	input [2:0]  FAIL_SENSn,
	output [4:0] MOT_ENA,
	output 	     LED_GREEN,
	output 	     LED_RED
);

MachineControl_001_1   mc001_1
(
	.MOT_ERR			(MOT_ERR),
	.FAIL_SENSn		(FAIL_SENSn),
	.MOT_ENA			(MOT_ENA),
	.LED_GREEN		(LED_GREEN),
	.LED_RED			(LED_RED)
);

endmodule 