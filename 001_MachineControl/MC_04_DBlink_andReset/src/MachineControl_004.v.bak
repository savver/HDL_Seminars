/* 	         Задача_001.1: контроллер станка

Есть станок, у которого 5 блоков драйверов двигателей.
Каждый драйвер имеет вход разрешения работы ENA, и 
выход ERR, показывающий, что произошла внтуренная ошибка
и драйвер прекратил управление двигателем (остановил его).
Есть 2 лампочки: GREEN (все хорошо), RED (авария).
Есть 3 входа от других аварийных датчиков FAIL_SENS, если 
на них 0, значит произошле какой-то сбой, и надо выключить 
все двигатели.
ПЛИС будет выполнять ряд задач по контролю и индикации.
Задачи ПЛИС:
1) если нет срабатываний аварийных датчиков, и сигналов 
ошибок с драйверов моторов, то горит зеленая лампочка,
надо подать сигналы разрешения работы на драйверы моторов.
В противном случае - надо погасить зеленую, зажечь 
красную лампочку, выключить все драйвера моторов.
-----------------------------------------------
              Задача_001.3: Модернизация
				  
2) Если станок вошел в аварию, то из этого состояния уже 
не выходит.
3) Если нет аварии, то зеленая лампочка не просто горит,
а мигает. Аналогично, при аварии - мигает красная лампочка

(!) и красная лампочка кодом мигания показывает номер сбоя


Код неисправности или другое событие - кодируется кол-вом коротких вспышек.
примеры:

отказ 1-ого мотора - одна вспышка
   ___    
__|   |____________________________________
  0   1   2   3   4   5   6   7   8   9   10
...
отказ 3-ого мотора - три вспышки
   ___     ___     ___   
__|   |___|   |___|   |_____________________
  0   1   2   3   4   5   6   7   8   9   10

считаем что одновременно впервые произойдет отказ чего-то одного,
его и выводим на дисплей
  
*/


 //`define USE_ASSIGN_MOT_ENA_V1
 //`define USE_ASSIGN_MOT_ENA_V2
	`define USE_ASSIGN_MOT_ENA_V3_OK
	
	
module MachineControl_003
(
   input        RSTn,
	input        CLK,
	input  [4:0] MOT_ERR,
	input  [2:0] FAIL_SENSn,
	output [4:0] MOT_ENA,
	output 	    LED_GREEN,
	output 	    LED_RED
);

//-------------------------------------------------
// FAULT detect logic
//-------------------------------------------------
wire 	    fault_now;
reg 	    fault_latched;  //0 = аварии нет, 1 = авария защёлкнута

reg [3:0] fault_code_reg;
reg [7:0] fault_mask_reg;

assign fault_now = (|MOT_ERR) | (~&FAIL_SENSn);

always @(posedge CLK) begin

    if (!RSTn) begin
        fault_latched   <= 1'b0;
		  fault_code_reg  <= 4'd0;
		  fault_mask_reg  <= 8'd0;
    end
		  
    else if (fault_now) begin
        fault_latched <= 1'b1;
		  fault_code_reg  <= fault_code;
		  fault_mask_reg  <= fault_mask;
    end
end

//-------------------------------------------------
// GREEN indication
//-------------------------------------------------
wire  led_green;

defparam counter_led_green.PERIOD  = 20;
defparam counter_led_green.DUTY = 10;
//
Counter 		counter_led_green
(
	.RSTn		(RSTn),
	.CLK		(CLK),
	.OUT		(led_green)
);

assign LED_GREEN = !fault_latched ? led_green : 1'b0;

//-------------------------------------------------
// MOTOR Work Enable
//-------------------------------------------------
//--- v1
`ifdef USE_ASSIGN_MOT_ENA_V1
	assign MOT_ENA[4:0] = fault_latched ? 5'b00000 : 5'b11111;
`endif
//--- v2
`ifdef USE_ASSIGN_MOT_ENA_V2
	assign MOT_ENA = {5{!fault_latched}};
`endif
//--- v3
`ifdef USE_ASSIGN_MOT_ENA_V3_OK
	assign MOT_ENA = {5{RSTn & !fault_latched}};
`endif

//-------------------------------------------------
// Error Reason
//-------------------------------------------------
/*
приоритетный шифратор (priority encoder): 
получаем номер канала, на котором сбой

	MOT_ERR[0]   -> 1
	MOT_ERR[1]   -> 2
	MOT_ERR[2]   -> 3
	MOT_ERR[3]   -> 4
	MOT_ERR[4]   -> 5

	FAIL_SENS[0] -> 6
	FAIL_SENS[1] -> 7
	FAIL_SENS[2] -> 8
*/

wire [7:0] faults;
wire [3:0] fault_code;

assign faults     = {~FAIL_SENSn[2:0], MOT_ERR[4:0]};
assign fault_code = FaultEncoder(faults);


function [3:0] FaultEncoder;
    input [7:0] faults;
begin
    if      (faults[0]) FaultEncoder = 4'd1;
    else if (faults[1]) FaultEncoder = 4'd2;
    else if (faults[2]) FaultEncoder = 4'd3;
    else if (faults[3]) FaultEncoder = 4'd4;
    else if (faults[4]) FaultEncoder = 4'd5;
    else if (faults[5]) FaultEncoder = 4'd6;
    else if (faults[6]) FaultEncoder = 4'd7;
    else if (faults[7]) FaultEncoder = 4'd8;
    else                FaultEncoder = 4'd0;

end
endfunction

/*
получить не номер ошибочного канала, а маску:

	MOT_ERR[0]   -> 0000_0001
	MOT_ERR[1]   -> 0000_0011
	...
	MOT_ERR[4]   -> 0001_1111
	...
	FAIL_SENS[2] -> 1111_1111

MASK = 2^N - 1
*/

wire [7:0] fault_mask;
assign     fault_mask = FaultMask(fault_code);

function [7:0] FaultMask;
    input [3:0] fault_code;
begin
    if (fault_code == 0)
        FaultMask = 8'b0000_0000;
    else
        FaultMask = (9'b1 << fault_code) - 1'b1;

end
endfunction

//-------------------------------------------------
// RED blink
//-------------------------------------------------
wire [15:0] fault_mask_ext;
assign fault_mask_ext = { 8'd0, fault_mask_reg };

defparam red_blink.FREQ_HZ	 = 2*1000*1000;
defparam red_blink.PERIOD_US = 10;
defparam red_blink.PULSE_US  = 1;
defparam red_blink.QUANT_CNT = 10;
//
DgsBlink_v1			red_blink
(
	.CLK		(CLK),
	.RSTn		(RSTn),
	.MASK		(fault_mask_ext),
	.LED_OUT	(LED_RED)
);

endmodule 