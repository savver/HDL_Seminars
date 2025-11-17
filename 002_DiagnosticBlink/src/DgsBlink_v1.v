module DgsBlink_v1
#(
   parameter FREQ_HZ    = 100*1000*1000,
	parameter PERIOD_US	= 1000*1000,
	parameter PULSE_US   = 100*1000
 //parameter QUANT_CNT  = 5
)
(
	input 		 				CLK,
	input 		 				RSTn,
	input [QUANT_CNT-1:0]	MASK,
	output 		 				LED_OUT
);

localparam PERIOD = (FREQ_HZ/(1000*1000)) * PERIOD_US;
localparam PULSE  = (FREQ_HZ/(1000*1000)) * PULSE_US;
localparam QUANT_CNT = (PERIOD_US / PULSE_US) / 2;

reg [$clog2(PERIOD)-1:0] cntr;
reg [QUANT_CNT-1:0]	    mask;

always @(posedge CLK)
begin
	if(!RSTn)
	  begin
		 cntr <= 0;
	  end
	else
	  begin
	    if(cntr == PERIOD-1)
		   begin
			  cntr <= 0;
			  mask <= MASK;
		   end 
		 else 
		    cntr <= cntr + 1'b1;
	  end
end

/*
   ___     ___     ___     ___     ___
__|   |___|   |___|   |___|   |___|   |___
  0   1   2   3   4   5   6   7   8   9   10
    1       2       3       4       5
*/
wire   led;
assign LED_OUT = (!RSTn) ? 1'b0 : led;
assign led = ((mask & (1<<0)) && ((cntr >= 0*PULSE) && (cntr < 1*PULSE))) ||
             ((mask & (1<<1)) && ((cntr >= 2*PULSE) && (cntr < 3*PULSE))) ||
				 ((mask & (1<<2)) && ((cntr >= 4*PULSE) && (cntr < 5*PULSE))) ||
				 ((mask & (1<<3)) && ((cntr >= 6*PULSE) && (cntr < 7*PULSE))) ||
				 ((mask & (1<<4)) && ((cntr >= 8*PULSE) && (cntr < 9*PULSE)));
				 			 
endmodule 