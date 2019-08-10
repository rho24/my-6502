
if [ ! -d ./.vsim ]; then
    mkdir ./.vsim
fi
cd ./.vsim
vmap work ../.work
vsim P6502_tb -do ../modelsim/wave.do > /dev/null &