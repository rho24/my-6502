if [ ! -d ./.modelsim ]; then
    mkdir ./.modelsim
fi
cd ./.modelsim

if [ ! -d ./work ]; then
    vlib ./work
    vmap work ./work
fi

vsim P6502_tb -do ../modelsim/wave.do > /dev/null &