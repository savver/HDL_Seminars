module Counter 
#(
	//parameter PERIOD_ROW = 7,
	parameter PERIOD     = 100,
	parameter DUTY       = 30
)
(
	input 	CLK,
	input		RSTn,
	output	OUT
);

//localparam PERIOD = 100;
//localparam DUTY   = 30;

// 100 -> 128, 2**7
reg [$clog2(PERIOD) - 1:0]	counter;


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

assign OUT = (counter < DUTY) ? 1'b1 : 1'b0;

endmodule 