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
*/

  `define USE_ASSIGN_RED_VAR1
//`define USE_ASSIGN_RED_VAR2
//`define USE_ASSIGN_RED_VAR3

  `define USE_ASSIGN_GREEN_VAR1
//`define USE_ASSIGN_GREEN_VAR2
//`define USE_ASSIGN_GREEN_VAR3

module MachineControl_001_1
(
	input [4:0]  MOT_ERR,    //positive active, т.е. если 1, то сбой произошел
	input [2:0]  FAIL_SENSn, //negative active, т.е. если 0, то сбой произошел
	output [4:0] MOT_ENA,
	output 	     LED_GREEN,
	output 	     LED_RED
);

//---var 1 ----------------
`ifdef USE_ASSIGN_RED_VAR1

	assign LED_RED   = MOT_ERR[4]    | MOT_ERR[3]    | MOT_ERR[2]   | MOT_ERR[1] | MOT_ERR[0] |
							!FAIL_SENSn[2] | !FAIL_SENSn[1] | !FAIL_SENSn[0];
`endif	

//---var 2 ----------------			 
`ifdef USE_ASSIGN_RED_VAR2
	// |MOT_ERR    - OR всех битов MOT_ERR
	// ~FAIL_SENSn - инверсия всех бит шины

	assign LED_RED   = |MOT_ERR  |  |(~FAIL_SENSn);
`endif

//---var 3 ----------------
`ifdef USE_ASSIGN_RED_VAR3
	//FAIL_SENSn = 111 → ~& = 0   // все датчики OK
	//FAIL_SENSn = 110 → ~& = 1   // один FAIL
	//FAIL_SENSn = 101 → ~& = 1
	//FAIL_SENSn = 011 → ~& = 1
	//
	//~FAIL_SENSn[2] | ~FAIL_SENSn[1] | ~FAIL_SENSn[0] <=> ~&FAIL_SENSn
	
	assign LED_RED = |MOT_ERR  |  ~&FAIL_SENSn;
`endif				 


//---var 1 ----------------
`ifdef USE_ASSIGN_GREEN_VAR1
	assign LED_GREEN = !MOT_ERR[3]    & !MOT_ERR[2]    & !MOT_ERR[2]  & !MOT_ERR[1] & !MOT_ERR[0] &
							 FAIL_SENSn[2]  & FAIL_SENSn[1]  & FAIL_SENSn[0] ;
`endif	
//---var 2 ----------------
`ifdef USE_ASSIGN_GREEN_VAR2

	assign LED_GREEN = ~|MOT_ERR  &  &FAIL_SENSn;
`endif	
//---var 3 ----------------
`ifdef USE_ASSIGN_GREEN_VAR3		
	   
  assign LED_GREEN = !LED_RED;
`endif	

assign MOT_ENA[4:0] = LED_RED ? 4'b0000 : 4'b1111;

endmodule 