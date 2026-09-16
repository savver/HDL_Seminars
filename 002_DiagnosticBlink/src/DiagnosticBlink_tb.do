# -----------------------------------------------------------------------------
# Скрипт для Quartus NativeLink / ModelSim.
#
# Этот файл НЕ компилирует проект и НЕ запускает ModelSim.
# Quartus NativeLink уже выполняет компиляцию и запускает DiagnosticBlink_tb.
# Здесь только настраивается окно Wave и выполняется run -all.
#
# В Tcl/ModelSim комментарий начинается с символа #.
# -----------------------------------------------------------------------------

# Основные сигналы testbench
add wave /DiagnosticBlink_tb/clk
add wave /DiagnosticBlink_tb/rstn

# DgsBlink_v1 - исходная версия
add wave -divider "DgsBlink_v1"
add wave -radix binary   /DiagnosticBlink_tb/mask_v1
add wave                 /DiagnosticBlink_tb/led_v1
add wave -radix unsigned /DiagnosticBlink_tb/dut_v1/cntr
add wave -radix binary   /DiagnosticBlink_tb/dut_v1/mask

# DgsBlink_v1_2 - универсальная версия с 5 квантами
add wave -divider "DgsBlink_v1_2_5_quant"
add wave -radix binary   /DiagnosticBlink_tb/mask_v1_2
add wave                 /DiagnosticBlink_tb/led_v1_2
add wave -radix unsigned /DiagnosticBlink_tb/dut_v1_2/pulse_cntr
add wave -radix unsigned /DiagnosticBlink_tb/dut_v1_2/quant_cntr
add wave -radix binary   /DiagnosticBlink_tb/dut_v1_2/mask

# DgsBlink_v2 - количество первых вспышек
add wave -divider "DgsBlink_v2"
add wave -radix unsigned /DiagnosticBlink_tb/blink_cnt_v2
add wave                 /DiagnosticBlink_tb/led_v2
add wave -radix unsigned /DiagnosticBlink_tb/dut_v2/cntr
add wave -radix unsigned /DiagnosticBlink_tb/dut_v2/blink_cnt
add wave -radix unsigned /DiagnosticBlink_tb/dut_v2/quant_cnt

# Дополнительный DgsBlink_v1_2 с 3 квантами
add wave -divider "DgsBlink_v1_2_3_quant"
add wave -radix binary   /DiagnosticBlink_tb/mask_v1_2_alt
add wave                 /DiagnosticBlink_tb/led_v1_2_alt
add wave -radix unsigned /DiagnosticBlink_tb/dut_v1_2_alt/pulse_cntr
add wave -radix unsigned /DiagnosticBlink_tb/dut_v1_2_alt/quant_cntr
add wave -radix binary   /DiagnosticBlink_tb/dut_v1_2_alt/mask

# Сигналы эталонной модели testbench
add wave -divider "Reference_model"
add wave -radix unsigned /DiagnosticBlink_tb/ref_phase
add wave -radix unsigned /DiagnosticBlink_tb/ref_phase_alt
add wave -radix unsigned /DiagnosticBlink_tb/errors
add wave -radix unsigned /DiagnosticBlink_tb/checks

# Стандартные окна ModelSim
view structure
view signals

# Выполняем моделирование до $stop в testbench
run -all

# Показываем весь интервал моделирования
wave zoom full
