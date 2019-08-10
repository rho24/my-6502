
set compiler vcom

if [ ! -d ./.work ]; then
    vlib ./.work
    vmap work ./.work
fi

vcom \
    ./vhdl/Common.vhd \
    ./vhdl/RegisterVector.vhd \
    ./vhdl/Alu.vhd \
    ./vhdl/P6502.vhd \
    ./vhdl/P6502_tb.vhd;
