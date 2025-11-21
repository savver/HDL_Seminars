/*
  | quant | quant | quant | quant | quant |
   ___     ___     ___     ___     ___
__|   |___|   |___|   |___|   |___|   |___
  0   1   2   3   4   5   6   7   8   9   10
    1       2       3       4       5
	 
BLINK_CNT - кол-во коротких вспышек
кол-во квантов рассчитывается автоматом исходя из
заданного периода и длительности вспышки
*/

module DgsBlink_v2
#(
   parameter FREQ_HZ    = 100*1000*1000,
	parameter PERIOD_US	= 10,
	parameter PULSE_US   = 1,
	
   parameter QUANT_CNT = (PERIOD_US / PULSE_US) / 2
)
(
	input 		 				      CLK,
	input 		 				      RSTn,
	input [$clog2(QUANT_CNT)-1:0]	BLINK_CNT,
	output 		 				      LED_OUT
);

localparam PERIOD = (FREQ_HZ/(1000*1000)) * PERIOD_US;
localparam PULSE  = (FREQ_HZ/(1000*1000)) * PULSE_US;
localparam QUANT_PERIOD  = 2 * PULSE;

reg [$clog2(QUANT_PERIOD-1)-1:0] cntr;
reg [$clog2(QUANT_CNT)-1:0]	 blink_cnt;
reg [$clog2(QUANT_CNT)-1:0]	 quant_cnt;

always @(posedge CLK)
begin
	if(!RSTn)
	  begin
		 cntr      <= 0;
		 blink_cnt <= BLINK_CNT;
		 quant_cnt <= QUANT_CNT - 1;
	  end
	else
	  begin
	    if(cntr == QUANT_PERIOD-1)
		   begin
			
			  cntr <= 0;
			  
			  if(blink_cnt != 0) 
			    blink_cnt = blink_cnt - 1'b1;
				 
			  if(quant_cnt != 0) 
			    quant_cnt = quant_cnt - 1'b1;
			  else
			    begin
				   blink_cnt <= BLINK_CNT;
		         quant_cnt <= QUANT_CNT - 1;
				 end	
				 
		   end 
		 else 
		    cntr <= cntr + 1'b1;
	  end
end


wire   led;
assign LED_OUT = (!RSTn) ? 1'b0 : led;
assign led = ((cntr < PULSE) && (blink_cnt != 0)) ? 1 : 0;
				 			 
endmodule 

/* calculations:

FREQ_HZ = 100*1000*1000
PERIOD_US = 10
PULSE_US = 1

PERIOD = (FREQ_HZ/(1000*1000)) * PERIOD_US
PULSE  = (FREQ_HZ/(1000*1000)) * PULSE_US
QUANT_CNT = (PERIOD_US / PULSE_US) / 2

PERIOD
1000.0

PULSE
100.0

QUANT_CNT
5.0

math.log2(PERIOD-1)
9.964340867792417
*/