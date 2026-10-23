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

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1)
    begin : gen_shift

        Shift_Reg  #( .BIT(BIT) )
        shift_one_signal
        (
            .CLK (CLK),
            .IN  (IN[i]),
            .OUT (OUT[i])
        );

    end
endgenerate

endmodule 