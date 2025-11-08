add wave /MachineControl_tb/clk
add wave /MachineControl_tb/rstn

add wave /MachineControl_tb/mot_err
add wave /MachineControl_tb/fail_sensn

add wave /MachineControl_tb/dut/mc002_1/state

add wave /MachineControl_tb/mot_ena
add wave /MachineControl_tb/led_green
add wave /MachineControl_tb/led_red
view structure
view signals
run -all
wave zoom full