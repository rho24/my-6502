delete wave *
restart -force

add wave -noupdate -format Logic -radix hexadecimal P6502_tb/clk P6502_tb/rst P6502_tb/ready
add wave -divider
add wave -noupdate -format Logic -radix hexadecimal P6502_tb/data_in P6502_tb/data_out P6502_tb/address_out
add wave -divider
add wave -noupdate -format Logic -radix hexadecimal sim:/p6502_tb/cpu/AccumulatorReg_q
add wave -divider
add wave -noupdate -format Logic -radix hexadecimal sim:/p6502_tb/cpu/Control/current_state sim:/p6502_tb/cpu/Control/next_state
add wave -noupdate -format Logic -radix hexadecimal sim:/p6502_tb/cpu/Control/instruction
add wave -noupdate -format Logic -radix hexadecimal sim:/p6502_tb/cpu/Control/control_out
add wave -divider
add wave -noupdate -format Logic -radix hexadecimal sim:/p6502_tb/cpu/Control/PreDecodeReg_q sim:/p6502_tb/cpu/Control/InstructionReg_q

run 200 ns

wave zoom full