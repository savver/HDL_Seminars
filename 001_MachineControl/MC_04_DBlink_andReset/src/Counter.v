	`define USE_WIDTH_V1
 //`define USE_WIDTH_V2

module Counter 
#(
	parameter PERIOD     = 100,
	parameter DUTY       = 30
)
(
	input 	CLK,
	input		RSTn,
	output	OUT
);

`ifdef USE_WIDTH_V1
	// 100 -> 128, 2**7
	reg [$clog2(PERIOD) - 1:0]	counter;
`endif

`ifdef USE_WIDTH_V2
	// overkill safety
	localparam COUNTER_WIDTH = (PERIOD <= 1) ? 1 : $clog2(PERIOD);
	reg [COUNTER_WIDTH-1:0] counter;
`endif

always @(posedge CLK) 
begin

	if(!RSTn)    //~RSTn
		counter <= 0;
	else 
	begin
		if(counter == PERIOD-1)
			counter <= 0;
		else
			counter <= counter  + 1'b1;
	end

end

//assign OUT = (counter < DUTY) ? 1'b1 : 1'b0; - избыточно
  assign OUT = (counter < DUTY);

endmodule 