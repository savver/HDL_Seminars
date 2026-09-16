/*
  | quant | quant | quant | quant | quant |
   ___     ___     ___     ___     ___
__|   |___|   |___|   |___|   |___|   |___
  0   1   2   3   4   5   6   7   8   9   10
    1       2       3       4       5
MASK - маска выспышек, кажды бит отвечает за свой квант
кол-во квантов рассчитывается автоматом исходя из
заданного периода и длительности вспышки
*/

module DgsBlink_v1_2
#(
    parameter [63:0] FREQ_HZ   = 100*1000*1000,
    parameter [63:0] PERIOD_US = 10,
    parameter        PULSE_US  = 1,

    parameter QUANT_CNT = (PERIOD_US / PULSE_US) / 2
)
(
    input                   CLK,
    input                   RSTn,
    input  [QUANT_CNT-1:0]  MASK,
    output                  LED_OUT
);


localparam [63:0] PULSE = (FREQ_HZ / 1_000_000) * PULSE_US;
localparam [63:0] QUANT_PERIOD = 2 * PULSE;

localparam PULSE_CNTR_WIDTH = $clog2(QUANT_PERIOD);
localparam QUANT_CNTR_WIDTH = $clog2(QUANT_CNT);

reg [PULSE_CNTR_WIDTH-1:0] pulse_cntr;
reg [QUANT_CNTR_WIDTH-1:0] quant_cntr;

reg [QUANT_CNT-1:0] mask;


always @(posedge CLK)
begin

    if (!RSTn)
    begin

        pulse_cntr <= 0;
        quant_cntr <= 0;
        mask       <= MASK;

    end
    else
    begin

        if (pulse_cntr == QUANT_PERIOD - 1)
        begin

            pulse_cntr <= 0;

            if (quant_cntr == QUANT_CNT - 1)
            begin

                quant_cntr <= 0;
                mask       <= MASK;

            end
            else
            begin

                quant_cntr <= quant_cntr + 1'b1;

            end

        end
        else
        begin

            pulse_cntr <= pulse_cntr + 1'b1;

        end

    end

end


wire led;

assign led =
    mask[quant_cntr] &&
    (pulse_cntr < PULSE);

assign LED_OUT =
    (!RSTn) ? 1'b0 : led;


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