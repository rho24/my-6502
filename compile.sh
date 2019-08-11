
set compiler vcom

if [ ! -d ./.modelsim ]; then
    mkdir ./.modelsim
fi
cd ./.modelsim

if [ ! -d ./work ]; then
    vlib ./work
    vmap work ./work
fi

vcom \
    ../vhdl/Common.vhd \
    ../vhdl/RegisterVector.vhd \
    ../vhdl/LatchVector.vhd \
    ../vhdl/Alu.vhd \
    ../vhdl/Control.vhd \
    ../vhdl/P6502.vhd \
    ../vhdl/P6502_tb.vhd;
