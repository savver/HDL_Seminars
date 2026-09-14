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

Задачи ПЛИС: --> см 'MachineControl_001_1'
*/

module MachineControl_top
(
	input [4:0]  MOT_ERR,
	input [2:0]  FAIL_SENSn,
	output [4:0] MOT_ENA,
	output 	     LED_GREEN,
	output 	     LED_RED
);

MachineControl_001_1   mc001_1
(
	.MOT_ERR			(MOT_ERR),
	.FAIL_SENSn		(FAIL_SENSn),
	.MOT_ENA			(MOT_ENA),
	.LED_GREEN		(LED_GREEN),
	.LED_RED			(LED_RED)
);

endmodule 