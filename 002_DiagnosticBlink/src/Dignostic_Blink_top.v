/* Модулю, отвечающему за мигание светодиодом передается или кол-во коротких миганий,
или шаблон мигания. Часто такая схема используется при диагностике не исправности.
Например, не включается ноутбук и по характеру мигания леда на кнопке питания
можно судить и типе неисправности.
Код неисправности или другое событие - кодируется кол-вом коротких вспышек.
Применительно к проекту 001_MachineControl можно было бы так:
отказ 1-ого мотора - одна вспышка
   ___    
__|   |____________________________________
  0   1   2   3   4   5   6   7   8   9   10
...
отказ 3-ого мотора - три вспышки
   ___     ___     ___   
__|   |___|   |___|   |_____________________
  0   1   2   3   4   5   6   7   8   9   10

*/
module Dignostic_Blink_top
(
	input 		 CLK,
	input 		 RSTn,
	output [2:0] LEDs
);

defparam dsg_blink_1.FREQ_HZ	 = 100*1000*1000;
defparam dsg_blink_1.PERIOD_US = 10;
defparam dsg_blink_1.PULSE_US =  1;
//
DgsBlink_v1			dsg_blink_1
(
	.CLK		(CLK),
	.RSTn		(RSTn),
	.MASK		(5'b00111),
	.LED_OUT	(LEDs[0])
);

defparam dsg_blink_2.FREQ_HZ	 = 100*1000*1000;
defparam dsg_blink_2.PERIOD_US = 10;
defparam dsg_blink_2.PULSE_US =  1;
//
DgsBlink_v2			dsg_blink_2
(
	.CLK			(CLK),
	.RSTn			(RSTn),
	.BLINK_CNT	(2),
	.LED_OUT		(LEDs[1])
);

endmodule 