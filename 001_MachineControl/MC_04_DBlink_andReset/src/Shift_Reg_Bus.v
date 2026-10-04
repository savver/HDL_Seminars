module Shift_Reg_Bus
#(
   parameter BIT   = 2,
	parameter WIDTH = 4
)
(
	input       			CLK,
	input  [WIDTH-1:0]	IN,
	output [WIDTH-1:0]	OUT
);

reg [BIT-1:0]   shift[WIDTH-1:0];

always @(posedge CLK) begin
	shift <= { shift[BIT-2:0], IN };
end

assign OUT = shift[BIT-1];

endmodule 