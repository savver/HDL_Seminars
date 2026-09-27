`timescale 1ns/1ps

/*
-------------------------------------------------------------------------------
Тестбенч для примера 002_DiagnosticBlink.

Проверяются:
  1) DgsBlink_v1   - исходная реализация по маске;
  2) DgsBlink_v1m2 - универсальная реализация по маске;
  3) DgsBlink_v2   - реализация по количеству первых вспышек;

Для ускорения моделирования:
    FREQ_HZ   = 2 МГц
    PERIOD_US = 10 мкс
    PULSE_US  = 1 мкс

Отсюда:
    Tclk                = 0.5 мкс;
    PERIOD              = 20 тактов;
    PULSE               = 2 такта;
    длительность кванта = 4 такта (2 ON + 2 OFF);
    QUANT_CNT           = 5.

Эталонная модель testbench считает фазу независимо от внутренних счетчиков DUT.
Выходы проверяются на каждом negedge CLK.

┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   initial                                                    │
│   ┌─────────────────────────────┐                            │
│   │ Сценарий тестирования       │                            │
│   │                             │                            │
│   │ reset                       │                            │
│   │ wait_clocks(...)            │                            │
│   │ set_commands(...)           │                            │
│   │ wait_clocks(...)            │                            │
│   │ set_commands(...)           │                            │
│   │ ...                         │                            │
│   └──────────────┬──────────────┘                            │
│                  │                                           │
│                  │ задание                                   │
│                  ▼                                           │
│       ┌──────────────────────┐                               │
│       │ входные сигналы DUT  │                               │
│       │                      │                               │
│       │ MASK                 │──────────────┐                │
│       │ BLINK_CNT            │              │                │
│       │ RSTn                 │              │                │
│       └──────────┬───────────┘              │                │
│                  │                          │                │
│                  ▼                          ▼                │
│         ┌─────────────────┐       ┌─────────────────────┐    │
│         │       DUT       │       │  Reference model    │    │
│         │                 │       │                     │    │
│         │ DgsBlink_v1     │       │ ref_phase           │    │
│         │ DgsBlink_v1_2   │       │ ref_mask            │    │
│         │ DgsBlink_v2     │       │ ref_blink_cnt       │    │
│         └────────┬────────┘       └──────────┬──────────┘    │
│                  │                           │               │
│                  │ actual                    │ expected      │
│                  ▼                           ▼               │
│              ┌─────────────────────────────────┐             │
│              │           COMPARE               │             │
│              │                                 │             │
│              │ actual !== expected             │             │
│              └──────────────┬──────────────────┘             │
│                             │                                │
│                        PASS / ERROR                          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
-------------------------------------------------------------------------------
*/

module DiagnosticBlink_tb;

// Основная конфигурация тестов
localparam [63:0] FREQ_HZ_TB   = 64'd2_000_000;
localparam [63:0] PERIOD_US_TB = 64'd10;
localparam [63:0] PULSE_US_TB  = 64'd1;

// Эталонные значения задаем явно и не вычисляем той же формулой, что DUT.
localparam integer PERIOD_CYCLES = 20;   //период индикации модуля мигания, в тактах
localparam integer PULSE_CYCLES  = 2;    //интервал, когда лед горит, в тактах
localparam integer QUANT_CYCLES  = 4;    //длительность кванта, в тактах
localparam integer QUANT_CNT     = 5;

// Дополнительная конфигурация DgsBlink_v1m2:
// PERIOD=12 мкс, PULSE=2 мкс -> 3 кванта, 24 такта на полный период.
localparam [63:0] ALT_PERIOD_US = 64'd12;
localparam [63:0] ALT_PULSE_US  = 64'd2;
localparam integer ALT_PERIOD_CYCLES = 24;  //период индикации модуля мигания, в тактах
localparam integer ALT_PULSE_CYCLES  = 4;   //интервал, когда лед горит, в тактах
localparam integer ALT_QUANT_CYCLES  = 8;   //длительность кванта, в тактах
localparam integer ALT_QUANT_CNT     = 3;

// CLK = 2 МГц -> полупериод 250 нс.
localparam integer CLK_HALF_PERIOD_NS = 250;

reg rstn;

integer checks;
integer errors;
integer printed_errors;

// -----------------------------------------------------------------------------
// Генератор тактовой частоты.
// -----------------------------------------------------------------------------
reg clk;

initial begin
    clk = 1'b0;
    forever #CLK_HALF_PERIOD_NS clk = ~clk;
end

// -----------------------------------------------------------------------------
// DUT #1: исходная версия по маске
// -----------------------------------------------------------------------------
reg  [QUANT_CNT-1:0] task_as_mask_4dut_v1;  //'задание' на индикацию, мы его меняем в initial блоке
wire                 led_v1;                // рез-т, мигание

DgsBlink_v1 #( .FREQ_HZ   (FREQ_HZ_TB),
               .PERIOD_US (PERIOD_US_TB),
               .PULSE_US  (PULSE_US_TB) ) 
dut_v1 
(
    .CLK     (clk),
    .RSTn    (rstn),
    .MASK    (task_as_mask_4dut_v1),
    .LED_OUT (led_v1)
);


// -----------------------------------------------------------------------------
// DUT #2: универсальная версия по маске, 5 квантов
// -----------------------------------------------------------------------------
reg  [QUANT_CNT-1:0] task_as_mask_4dut_v1m2;
wire                 led_v1m2;

DgsBlink_v1m2 #( .FREQ_HZ   (FREQ_HZ_TB),
                 .PERIOD_US (PERIOD_US_TB),
                 .PULSE_US  (PULSE_US_TB) ) 
dut_v1m2 
(
    .CLK     (clk),
    .RSTn    (rstn),
    .MASK    (task_as_mask_4dut_v1m2),
    .LED_OUT (led_v1m2)
);


// -----------------------------------------------------------------------------
// DUT #3: версия по количеству вспышек
// -----------------------------------------------------------------------------
reg  [$clog2(QUANT_CNT)-1:0] task_as_blink_cnt_4dut_v2;  //'задание' на индикацию, мы его меняем в initial блоке
wire                         led_v2;

DgsBlink_v2 #( .FREQ_HZ    (FREQ_HZ_TB),
               .PERIOD_US  (PERIOD_US_TB),
               .PULSE_US   (PULSE_US_TB),
               .QUANT_CNT  (QUANT_CNT) ) 
dut_v2 
(
    .CLK       (clk),
    .RSTn      (rstn),
    .BLINK_CNT (task_as_blink_cnt_4dut_v2),
    .LED_OUT   (led_v2)
);


// -----------------------------------------------------------------------------
// Эталонная модель для основной конфигурации.
// Новая команда-задание фиксируется только на границе полного периода.
// -----------------------------------------------------------------------------
// Состояние независимой эталонной модели
integer                    ref_phase;       //номер текущего такта внутри диагностического периода
                                            //PERIOD = 20 тактов -> ref_phase = 0,1,2,...19

reg    [QUANT_CNT-1:0]     ref_task_as_mask_4dut_v1;     //эталонное значение задания, которое должно быть активно в текущей диагностической серии.
                                                         //даже если task_as_mask_4dut_v1 изменится, ref_task_as_mask_4dut_v1 ещё остаётся старым до следующей границы периода
reg    [QUANT_CNT-1:0]     ref_task_as_mask_4dut_v1m2;
integer                    ref_task_as_blink_cnt_4dut_v2;

// task_xxx - постоянно меняется в initial, а тут мы его 'запоминаем' на период индикации

always @(posedge clk) begin
    if (!rstn) begin
        ref_phase                     <= 0;
        ref_task_as_mask_4dut_v1      <= task_as_mask_4dut_v1;
        ref_task_as_mask_4dut_v1m2    <= task_as_mask_4dut_v1m2;
        ref_task_as_blink_cnt_4dut_v2 <= task_as_blink_cnt_4dut_v2;
    end
    else begin
        if (ref_phase == PERIOD_CYCLES - 1) begin
            ref_phase                     <= 0;
            ref_task_as_mask_4dut_v1      <= task_as_mask_4dut_v1;
            ref_task_as_mask_4dut_v1m2    <= task_as_mask_4dut_v1m2;
            ref_task_as_blink_cnt_4dut_v2 <= task_as_blink_cnt_4dut_v2;
        end
        else begin
            ref_phase <= ref_phase + 1;
        end
    end
end


// -----------------------------------------------------------------------------
// Вывод ошибки. Чтобы одна грубая ошибка DUT не забила Transcript тысячами
// строк, показываются только первые 30 сообщений, но счетчик errors продолжает
// учитывать все несовпадения.
// -----------------------------------------------------------------------------
task print_error;
    input [8*32-1:0] signal_name;
    input            actual_value;   //фактический на выходе модуля мигания
    input            expected_value; //'ожидаемый'
begin
    errors = errors + 1;

    if (printed_errors < 30) begin
        $display("ERROR t=%0t: %0s=%b, expected=%b",
                 $time, signal_name, actual_value, expected_value);
        printed_errors = printed_errors + 1;
    end
    else if (printed_errors == 30) begin
        $display("Further identical error messages are hidden...");
        printed_errors = printed_errors + 1;
    end
end
endtask


// -----------------------------------------------------------------------------
// Автоматическая проверка выходов.
// Проверяем на negedge CLK, то есть после завершения обновлений DUT на posedge.
// -----------------------------------------------------------------------------
/*
             DUT обновляется
              ...↓
CLK: ________/‾‾‾‾‾\________
             ↑       ↑
          posedge   negedge
                       ↑
                   проверяем
						 
						 
             actual
DUT ─────────────────────┐
                         │
                         ▼
                       compare ──> ERROR
                         ▲
                         │
Reference model ─────────┘
             expected				 
			
			
 ref_phase:

 0  1  2  3 | 4  5  6  7 | 8  9 10 11 | 12 13 14 15 | 16 17 18 19
-------------+-------------+-------------+-------------+--------------
  quant 0    |  quant 1    |  quant 2    |  quant 3    |  quant 4
-------------+-------------+-------------+-------------+--------------
 ON ON OFF OFF  ON ON OFF OFF ...
 
 PERIOD_CYCLES = 20;   //период индикации модуля мигания, в тактах
 QUANT_CYCLES  = 4;    //длительность кванта, в тактах
 QUANT_CNT     = 5;
 PULSE_CYCLES  = 2;    //интервал, когда лед горит, в тактах
 
*/

integer quant_index;
integer quant_index_alt;
reg expected_led_v1;
reg expected_led_v1m2;
reg expected_led_v2;
reg expected_led_v1m2_alt;

always @(negedge clk) begin
    #1;                      //дополнительный отступ после negedge, чтобы логика устаканилась

    checks = checks + 4;

    if (!rstn) begin
        expected_led_v1       = 1'b0;
        expected_led_v1m2     = 1'b0;
        expected_led_v2       = 1'b0;
    end
    else begin
        // Основная конфигурация: 5 квантов.
        quant_index = ref_phase / QUANT_CYCLES;

		  // в кванте 4 интервала, если есть индикация, то первые 2 интервала  != 0
		  // если нет индикации, все 4 интервала == 0
		  // итого, последние 2 интервала всегда == 0, а первые 2 или равно 1, или 0, надо смотреть задание
		  //
        if ((ref_phase % QUANT_CYCLES) < PULSE_CYCLES) begin
				//берем по одному биту из задания, которое запомнили в начале периода индикации
            expected_led_v1   = ref_task_as_mask_4dut_v1[quant_index];   
            expected_led_v1m2 = ref_task_as_mask_4dut_v1m2[quant_index];
            expected_led_v2   = (quant_index < ref_task_as_blink_cnt_4dut_v2);
        end
        else begin
		      //последние 2 интервала всегда == 0
            expected_led_v1   = 1'b0; 
            expected_led_v1m2 = 1'b0;
            expected_led_v2   = 1'b0;
        end
    end

    // !== ловит также X и Z.
	 // сравниваем выход dut с ожидаемым значением
	 //
    if (led_v1 !== expected_led_v1)
        print_error("led_v1", led_v1, expected_led_v1);

    if (led_v1m2 !== expected_led_v1m2)
        print_error("led_v1m2", led_v1m2, expected_led_v1m2);

    if (led_v2 !== expected_led_v2)
        print_error("led_v2", led_v2, expected_led_v2);
end

// -----------------------------------------------------------------------------
// Ожидание заданного количества положительных фронтов CLK.
// -----------------------------------------------------------------------------
task wait_clocks;
    input integer count;
    integer i;
begin
    for (i = 0; i < count; i = i + 1)
        @(posedge clk);
end
endtask


// -----------------------------------------------------------------------------
// Изменение команд выполняем после negedge CLK, чтобы testbench сам не создавал
// гонку с DUT. DUT должен принять новую команду только на следующей границе
// диагностической последовательности.
// -----------------------------------------------------------------------------
task set_task_4duts;
    input [QUANT_CNT-1:0]     new_task_as_mask_4dut_v1;
    input [QUANT_CNT-1:0]     new_task_as_mask_4dut_v1m2;
    input integer             new_task_as_blink_cnt_4dut_v2;
    input [ALT_QUANT_CNT-1:0] new_task_as_mask_4dut_v1m2_alt;
begin
    @(negedge clk);
    #50;

    task_as_mask_4dut_v1       = new_task_as_mask_4dut_v1;
    task_as_mask_4dut_v1m2     = new_task_as_mask_4dut_v1m2;
    task_as_blink_cnt_4dut_v2  = new_task_as_blink_cnt_4dut_v2;

    $display("t=%0t: new tasks for duts: MASK1=%b MASK1_2=%b BLINK=%0d",
             $time, task_as_mask_4dut_v1, task_as_mask_4dut_v1m2, task_as_blink_cnt_4dut_v2);
end
endtask


// -----------------------------------------------------------------------------
// Основная последовательность тестов
// -----------------------------------------------------------------------------
initial begin
    checks         = 0;
    errors         = 0;
    printed_errors = 0;

    rstn = 1'b0;

    ref_phase                      = 0;
    ref_task_as_mask_4dut_v1       = 0;
    ref_task_as_mask_4dut_v1m2     = 0;
    ref_task_as_blink_cnt_4dut_v2  = 0;

    $display("");
    $display("============================================================");
    $display("project '002_DiagnosticBlink' automatic test");
    $display("============================================================");

    //--- ТЕСТ 1. Reset и первые последовательности.
	 
	 //'задания' на индикацию
    task_as_mask_4dut_v1       = 5'b00111; //task_as_mask_4dut_v1
    task_as_mask_4dut_v1m2     = 5'b01111;
    task_as_blink_cnt_4dut_v2  = 3'd3;     //в dut_v2 задание - колво вспышек, а не маска
	 
    $display("");
    $display("TEST 1: reset and first diagnostic sequence");

    wait_clocks(3);
    @(negedge clk);
    #50;
    rstn = 1'b1;
    wait_clocks(50);

    //--- ТЕСТ 2. Меняем команды посреди серии.
    $display("");
    $display("TEST 2: command change inside current sequence");

    wait_clocks(7);
    set_task_4duts(5'b10101, 5'b10010, 4, 3'b011);
    wait_clocks(55);

    //--- ТЕСТ 3. Ноль вспышек.
    $display("");
    $display("TEST 3: zero flashes");

    set_task_4duts(5'b00000, 5'b00000, 0, 3'b000);
    wait_clocks(55);

    //--- ТЕСТ 4. Максимальное количество вспышек.
    $display("");
    $display("TEST 4: maximum flash count");

    set_task_4duts(5'b11111, 5'b11111, 5, 3'b111);
    wait_clocks(55);

    //--- ТЕСТ 5. Reset прямо во время активной вспышки.
    $display("");
    $display("TEST 5: reset during active flash");

    while ((led_v1m2 !== 1'b1) || (led_v2 !== 1'b1))
        @(negedge clk);

    #50;
    rstn = 1'b0;
    #1;

    checks = checks + 4;

    if (led_v1 !== 1'b0)
        print_error("led_v1 reset", led_v1, 1'b0);

    if (led_v1m2 !== 1'b0)
        print_error("led_v1m2 reset", led_v1m2, 1'b0);

    if (led_v2 !== 1'b0)
        print_error("led_v2 reset", led_v2, 1'b0);

    wait_clocks(3);
    @(negedge clk);
    #50;
    rstn = 1'b1;
    wait_clocks(35);

    // Итог.
    $display("");
    $display("============================================================");
    $display("Checks: %0d", checks);

    if (errors == 0)
        $display("RESULT: PASS - no errors detected");
    else
        $display("RESULT: FAIL - errors detected: %0d", errors);

    $display("============================================================");
    $display("");

    $stop;
end

endmodule
