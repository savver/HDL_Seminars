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
              Задача_001.2: Модернизация
				  
2) Если станок вошел в аварию, то из этого состояния уже 
не выходит.
3) Если нет аварии, то зеленая лампочка не просто горит,
а мигает. Аналогично, при аварии - мигает красная лампочка
Т.о. тут уже последовательная логика, появляются триггеры
*/


 //`define USE_ASSIGN_MOT_ENA_V1
 //`define USE_ASSIGN_MOT_ENA_V2
	`define USE_ASSIGN_MOT_ENA_V3_OK
	
	
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

wire 	fault_now;
reg 	fault_latched;  //0 = аварии нет, 1 = авария защёлкнута

assign fault_now = (|MOT_ERR) | (~&FAIL_SENSn);


always @(posedge CLK) begin

    if (!RSTn)
        fault_latched <= 1'b0;
		  
    else if (fault_now)
        fault_latched <= 1'b1;
end


wire  led_green;
wire 	led_red;

Counter 		counter_led_green
(
	.RSTn		(RSTn),
	.CLK		(CLK),
	.OUT		(led_green)
);

Counter #(150, 100)	counter_led_red
(
	.RSTn		(RSTn),
	.CLK		(CLK),
	.OUT		(led_red)
);

assign LED_GREEN = !fault_latched ? led_green : 1'b0;
assign LED_RED   =  fault_latched ? led_red   : 1'b0;

//--- v1
`ifdef USE_ASSIGN_MOT_ENA_V1
	assign MOT_ENA[4:0] = fault_latched ? 5'b0000 : 5'b1111;
`endif
//--- v2
`ifdef USE_ASSIGN_MOT_ENA_V2
	assign MOT_ENA = {5{!fault_latched}};
`endif
//--- v3
`ifdef USE_ASSIGN_MOT_ENA_V3_OK
	assign MOT_ENA = {5{RSTn & !fault_latched}};
`endif

endmodule 