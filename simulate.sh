

if [ ! -d ./.vsim ]; then
    mkdir ./.vsim
fi
cd ./.vsim
vsim P6502_tb -do simulation.do > /dev/null &