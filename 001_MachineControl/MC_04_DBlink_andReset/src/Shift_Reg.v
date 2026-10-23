module Shift_Reg
#(
   parameter BIT = 2  //must be >= 2
)
(
	input       CLK,
	input 		IN,
	output 		OUT
);

reg [BIT-1:0]   shift;

always @(posedge CLK) begin
	shift <= { shift[BIT-2:0], IN };
end

assign OUT = shift[BIT-1];

endmodule 