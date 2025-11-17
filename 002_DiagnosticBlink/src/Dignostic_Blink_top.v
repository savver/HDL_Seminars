module Dignostic_Blink_top
(
	input 		 CLK,
	input 		 RSTn,
	output [2:0] LEDs
);

defparam dsg_blink_1.FREQ_HZ	 = 100*1000*1000;
defparam dsg_blink_1.PERIOD_US = 10;
defparam dsg_blink_1.PULSE_US =  1;
//
DgsBlink_v1			dsg_blink_1
(
	.CLK		(CLK),
	.RSTn		(RSTn),
	.MASK		(5'b00111),
	.LED_OUT	(LEDs[0])
);

endmodule 