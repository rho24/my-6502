delete wave *
add wave -noupdate -format Logic -radix hexadecimal P6502_tb/clk P6502_tb/rst P6502_tb/ready
add wave -divider
add wave -noupdate -format Logic -radix hexadecimal P6502_tb/data_in P6502_tb/data_out P6502_tb/address
add wave -divider
add wave -position end  sim:/p6502_tb/cpu/Control/internal_ready
add wave -position end  sim:/p6502_tb/cpu/Control/current_state

restart -force
run 200 ns

wave zoom full