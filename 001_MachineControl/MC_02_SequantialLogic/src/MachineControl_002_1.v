module MachineControl_002_1
(
   input        RSTn,
	input        CLK,
	input  [4:0] MOT_ERR,
	input  [2:0] FAIL_SENSn,
	output [4:0] MOT_ENA,
	output 	    LED_GREEN,
	output 	    LED_RED
);

reg state; // 1 - no crash

always @(posedge CLK) begin

  if(!RSTn)
    state <= 1'b1;
  else 
    state <= (!MOT_ERR[4]    &  !MOT_ERR[3]    & !MOT_ERR[2]     & !MOT_ERR[1] & !MOT_ERR[0] &
               FAIL_SENSn[2] &   FAIL_SENSn[1] &  FAIL_SENSn[0]) &
				 (state == 1'b1) ; 

end

wire 		led_green;
Counter 		counter_led_green
(
	.RSTn		(RSTn),
	.CLK		(CLK),
	.OUT		(led_green)
);
assign LED_GREEN = state ? led_green : 1'b0;


wire 	led_red;
Counter #(150, 100)	counter_led_red
(
	.RSTn		(RSTn),
	.CLK		(CLK),
	.OUT		(led_red)
);
assign LED_RED = !state ? led_red : 1'b0;


assign MOT_ENA[4:0] = !state ? 4'b0000 : 4'b1111;

endmodule 