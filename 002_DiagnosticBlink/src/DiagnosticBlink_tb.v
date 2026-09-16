`timescale 1ns/1ps

/*
-------------------------------------------------------------------------------
Тестбенч для примера 002_DiagnosticBlink.

Проверяются:
  1) DgsBlink_v1   - исходная реализация по маске;
  2) DgsBlink_v1_2 - универсальная реализация по маске;
  3) DgsBlink_v2   - реализация по количеству первых вспышек;
  4) второй экземпляр DgsBlink_v1_2 с 3 квантами вместо 5 - для проверки
     реальной параметризации универсальной версии.

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
Выходы проверяются на каждом negedge CLK. Оператор !== намеренно используется
вместо !=, поэтому X и Z также считаются ошибкой.

ВАЖНО:
В присланном DgsBlink_v1.v сейчас есть опечатка:

    localparam [63:0] PULSE =
        (FREQ_HZ * PERIOD_US) / 1_000_000;

Здесь должен использоваться PULSE_US. Пока строка не исправлена, тест v1
ожидаемо покажет FAIL. Это полезно: testbench должен находить ошибку DUT.
-------------------------------------------------------------------------------
*/

module DiagnosticBlink_tb;

// Основная конфигурация тестов
localparam [63:0] FREQ_HZ_TB   = 64'd2_000_000;
localparam [63:0] PERIOD_US_TB = 64'd10;
localparam [63:0] PULSE_US_TB  = 64'd1;

// Эталонные значения задаем явно и не вычисляем той же формулой, что DUT.
localparam integer PERIOD_CYCLES = 20;
localparam integer PULSE_CYCLES  = 2;
localparam integer QUANT_CYCLES  = 4;
localparam integer QUANT_CNT     = 5;

// Дополнительная конфигурация DgsBlink_v1_2:
// PERIOD=12 мкс, PULSE=2 мкс -> 3 кванта, 24 такта на полный период.
localparam [63:0] ALT_PERIOD_US = 64'd12;
localparam [63:0] ALT_PULSE_US  = 64'd2;
localparam integer ALT_PERIOD_CYCLES = 24;
localparam integer ALT_PULSE_CYCLES  = 4;
localparam integer ALT_QUANT_CYCLES  = 8;
localparam integer ALT_QUANT_CNT     = 3;

// CLK = 2 МГц -> полупериод 250 нс.
localparam integer CLK_HALF_PERIOD_NS = 250;

reg clk;
reg rstn;

reg  [QUANT_CNT-1:0] mask_v1;
wire                 led_v1;

reg  [QUANT_CNT-1:0] mask_v1_2;
wire                 led_v1_2;

reg  [$clog2(QUANT_CNT)-1:0] blink_cnt_v2;
wire                         led_v2;

reg  [ALT_QUANT_CNT-1:0] mask_v1_2_alt;
wire                     led_v1_2_alt;

integer checks;
integer errors;
integer printed_errors;

// Состояние независимой эталонной модели.
integer 							ref_phase;
integer 							ref_phase_alt;
reg    [QUANT_CNT-1:0]     ref_mask_v1;
reg    [QUANT_CNT-1:0]     ref_mask_v1_2;
integer                 	ref_blink_cnt_v2;
reg    [ALT_QUANT_CNT-1:0] ref_mask_v1_2_alt;

integer quant_index;
integer quant_index_alt;
reg expected_led_v1;
reg expected_led_v1_2;
reg expected_led_v2;
reg expected_led_v1_2_alt;


// -----------------------------------------------------------------------------
// DUT #1: исходная версия по маске
// -----------------------------------------------------------------------------
DgsBlink_v1 #( .FREQ_HZ   (FREQ_HZ_TB),
               .PERIOD_US (PERIOD_US_TB),
               .PULSE_US  (PULSE_US_TB) ) 
dut_v1 
(
    .CLK     (clk),
    .RSTn    (rstn),
    .MASK    (mask_v1),
    .LED_OUT (led_v1)
);


// -----------------------------------------------------------------------------
// DUT #2: универсальная версия по маске, 5 квантов
// -----------------------------------------------------------------------------
DgsBlink_v1_2 #( .FREQ_HZ   (FREQ_HZ_TB),
                 .PERIOD_US (PERIOD_US_TB),
                 .PULSE_US  (PULSE_US_TB) ) 
dut_v1_2 
(
    .CLK     (clk),
    .RSTn    (rstn),
    .MASK    (mask_v1_2),
    .LED_OUT (led_v1_2)
);


// -----------------------------------------------------------------------------
// DUT #3: версия по количеству вспышек
// -----------------------------------------------------------------------------
DgsBlink_v2 #( .FREQ_HZ    (FREQ_HZ_TB),
					.PERIOD_US  (PERIOD_US_TB),
					.PULSE_US   (PULSE_US_TB),
					.QUANT_CNT  (QUANT_CNT) ) 
dut_v2 
(
    .CLK       (clk),
    .RSTn      (rstn),
    .BLINK_CNT (blink_cnt_v2),
    .LED_OUT   (led_v2)
);


// -----------------------------------------------------------------------------
// DUT #4: универсальная версия с 3 квантами
// -----------------------------------------------------------------------------
DgsBlink_v1_2 #( .FREQ_HZ   (FREQ_HZ_TB),
					  .PERIOD_US (ALT_PERIOD_US),
					  .PULSE_US  (ALT_PULSE_US) ) 
dut_v1_2_alt 
(
    .CLK     (clk),
    .RSTn    (rstn),
    .MASK    (mask_v1_2_alt),
    .LED_OUT (led_v1_2_alt)
);


// Генератор тактовой частоты.
initial begin
    clk = 1'b0;
    forever #CLK_HALF_PERIOD_NS clk = ~clk;
end


// -----------------------------------------------------------------------------
// Эталонная модель для основной конфигурации.
// Новая команда фиксируется только на границе полного периода.
// -----------------------------------------------------------------------------
always @(posedge clk) begin
    if (!rstn) begin
        ref_phase        <= 0;
        ref_mask_v1      <= mask_v1;
        ref_mask_v1_2    <= mask_v1_2;
        ref_blink_cnt_v2 <= blink_cnt_v2;
    end
    else begin
        if (ref_phase == PERIOD_CYCLES - 1) begin
            ref_phase        <= 0;
            ref_mask_v1      <= mask_v1;
            ref_mask_v1_2    <= mask_v1_2;
            ref_blink_cnt_v2 <= blink_cnt_v2;
        end
        else begin
            ref_phase <= ref_phase + 1;
        end
    end
end


// Эталонная модель дополнительного экземпляра v1_2 с тремя квантами.
always @(posedge clk) begin
    if (!rstn) begin
        ref_phase_alt     <= 0;
        ref_mask_v1_2_alt <= mask_v1_2_alt;
    end
    else begin
        if (ref_phase_alt == ALT_PERIOD_CYCLES - 1) begin
            ref_phase_alt     <= 0;
            ref_mask_v1_2_alt <= mask_v1_2_alt;
        end
        else begin
            ref_phase_alt <= ref_phase_alt + 1;
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
    input            actual_value;
    input            expected_value;
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
always @(negedge clk) begin
    #1;

    checks = checks + 4;

    if (!rstn) begin
        expected_led_v1       = 1'b0;
        expected_led_v1_2     = 1'b0;
        expected_led_v2       = 1'b0;
        expected_led_v1_2_alt = 1'b0;
    end
    else begin
        // Основная конфигурация: 5 квантов.
        quant_index = ref_phase / QUANT_CYCLES;

        if ((ref_phase % QUANT_CYCLES) < PULSE_CYCLES) begin
            expected_led_v1   = ref_mask_v1[quant_index];
            expected_led_v1_2 = ref_mask_v1_2[quant_index];
            expected_led_v2   = (quant_index < ref_blink_cnt_v2);
        end
        else begin
            expected_led_v1   = 1'b0;
            expected_led_v1_2 = 1'b0;
            expected_led_v2   = 1'b0;
        end

        // Дополнительная конфигурация v1_2: 3 кванта.
        quant_index_alt = ref_phase_alt / ALT_QUANT_CYCLES;

        if ((ref_phase_alt % ALT_QUANT_CYCLES) < ALT_PULSE_CYCLES)
            expected_led_v1_2_alt = ref_mask_v1_2_alt[quant_index_alt];
        else
            expected_led_v1_2_alt = 1'b0;
    end

    // !== ловит также X и Z.
    if (led_v1 !== expected_led_v1)
        print_error("led_v1", led_v1, expected_led_v1);

    if (led_v1_2 !== expected_led_v1_2)
        print_error("led_v1_2", led_v1_2, expected_led_v1_2);

    if (led_v2 !== expected_led_v2)
        print_error("led_v2", led_v2, expected_led_v2);

    if (led_v1_2_alt !== expected_led_v1_2_alt)
        print_error("led_v1_2_alt", led_v1_2_alt, expected_led_v1_2_alt);
end


// Ожидание заданного количества положительных фронтов CLK.
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
task set_commands;
    input [QUANT_CNT-1:0]     new_mask_v1;
    input [QUANT_CNT-1:0]     new_mask_v1_2;
    input integer             new_blink_cnt_v2;
    input [ALT_QUANT_CNT-1:0] new_mask_v1_2_alt;
begin
    @(negedge clk);
    #50;

    mask_v1       = new_mask_v1;
    mask_v1_2     = new_mask_v1_2;
    blink_cnt_v2  = new_blink_cnt_v2;
    mask_v1_2_alt = new_mask_v1_2_alt;

    $display("t=%0t: new commands: MASK1=%b MASK1_2=%b BLINK=%0d MASKalt=%b",
             $time, mask_v1, mask_v1_2, blink_cnt_v2, mask_v1_2_alt);
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

    mask_v1       = 5'b00111;
    mask_v1_2     = 5'b01111;
    blink_cnt_v2  = 3'd3;
    mask_v1_2_alt = 3'b101;

    ref_phase         = 0;
    ref_phase_alt     = 0;
    ref_mask_v1       = 0;
    ref_mask_v1_2     = 0;
    ref_blink_cnt_v2  = 0;
    ref_mask_v1_2_alt = 0;

    $display("");
    $display("============================================================");
    $display("project '002_DiagnosticBlink' automatic test");
    $display("============================================================");

    // ТЕСТ 1. Reset и первые последовательности.
    $display("");
    $display("TEST 1: reset and first diagnostic sequence");

    wait_clocks(3);
    @(negedge clk);
    #50;
    rstn = 1'b1;
    wait_clocks(50);

    // ТЕСТ 2. Меняем команды посреди серии.
    $display("");
    $display("TEST 2: command change inside current sequence");

    wait_clocks(7);
    set_commands(5'b10101, 5'b10010, 4, 3'b011);
    wait_clocks(55);

    // ТЕСТ 3. Ноль вспышек.
    $display("");
    $display("TEST 3: zero flashes");

    set_commands(5'b00000, 5'b00000, 0, 3'b000);
    wait_clocks(55);

    // ТЕСТ 4. Максимальное количество вспышек.
    $display("");
    $display("TEST 4: maximum flash count");

    set_commands(5'b11111, 5'b11111, 5, 3'b111);
    wait_clocks(55);

    // ТЕСТ 5. Reset прямо во время активной вспышки.
    $display("");
    $display("TEST 5: reset during active flash");

    while ((led_v1_2 !== 1'b1) || (led_v2 !== 1'b1))
        @(negedge clk);

    #50;
    rstn = 1'b0;
    #1;

    checks = checks + 4;

    if (led_v1 !== 1'b0)
        print_error("led_v1 reset", led_v1, 1'b0);

    if (led_v1_2 !== 1'b0)
        print_error("led_v1_2 reset", led_v1_2, 1'b0);

    if (led_v2 !== 1'b0)
        print_error("led_v2 reset", led_v2, 1'b0);

    if (led_v1_2_alt !== 1'b0)
        print_error("led_v1_2_alt reset", led_v1_2_alt, 1'b0);

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
