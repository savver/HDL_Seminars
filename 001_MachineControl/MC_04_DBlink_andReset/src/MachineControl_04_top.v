/* 	         Задача_001: контроллер станка

Есть станок, у которого 5 блоков драйверов двигателей.
Каждый драйвер имеет вход разрешения работы ENA, и 
выход ERR, показывающий, что произошла внтуренная ошибка
и драйвер прекратил управление двигателем (остановил его).
Есть 2 лампочки: GREEN (все хорошо), RED (авария).
Есть 3 входа от других аварийных датчиков FAIL_SENS, если 
на них 0, значит произошле какой-то сбой, и надо выключить 
все двигатели.
ПЛИС будет выполнять ряд задач по контролю и индикации.

Задачи ПЛИС: см 'MachineControl_004'
*/

module MachineControl_04_top
(
	input 		 CLK,
	input        RSTn,
	input        ERR_CLR,
	input  [4:0] MOT_ERR,
	input  [2:0] FAIL_SENSn,
	output [4:0] MOT_ENA,
	output 	    LED_GREEN,
	output 	    LED_RED
);

//-------------------------------------------------------------
// борьба с метастабильностью для внешних асинхронных сигналов
//-------------------------------------------------------------

wire       err_clr;
wire [4:0] mot_err;
wire [2:0] fail_sensn;

Shift_Reg #(2) 
sr_ERR_CLR
(
	.CLK	(CLK),
	.IN	(ERR_CLR),
	.OUT	(err_clr)
);

Shift_Reg_Bus #( .BIT   (2),
                 .WIDTH (5) ) 
sr_MOT_ERR
(
	.CLK	(CLK),
	.IN	(MOT_ERR),
	.OUT	(mot_err)
);

Shift_Reg_Bus #( .BIT   (2),
                 .WIDTH (3) ) 
sr_FAIL_SENSn
(
	.CLK	(CLK),
	.IN	(FAIL_SENSn),
	.OUT	(fail_sensn)
);

//-------------------------------------------------------------
// основная логика
//-------------------------------------------------------------

MachineControl_004   mc
(
	.CLK				(CLK),
	.RSTn			   (RSTn),
	.ERR_CLR			(err_clr),
	.MOT_ERR			(mot_err),
	.FAIL_SENSn		(fail_sensn),
	.MOT_ENA			(MOT_ENA),
	.LED_GREEN		(LED_GREEN),
	.LED_RED			(LED_RED)
);

endmodule 