------------------------------------------------------------------------------------------------
-- DESIGN UNIT  : 6502 Package                                                                --
-- DESCRIPTION  : Decodable instructions enumeration and control signals grouping             --
-- AUTHOR       : Everton Alceu Carara and Bernardo Favero Andreeti                           --
-- CREATED      : June 3rd, 2015                                                              --
-- VERSION      : 0.5                                                                         --
------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;

package Common is

    -- Constant flags
    constant CARRY     : integer := 0;
    constant ZERO      : integer := 1;
    constant INTERRUPT : integer := 2;
    constant DECIMAL   : integer := 3;
    constant BREAKF    : integer := 4;
    constant UNUSED    : integer := 5;
    constant OVERFLOW  : integer := 6;
    constant NEGATIVE  : integer := 7;

    -- Instructions execution cycle
    type State is (T0, T1, T2, T3, T4, T5, T6, T7);

    type ALU_Operation_type is (
        ALU_AND, ALU_OR, ALU_XOR,
        ALU_A, ALU_B, ALU_ADD, ALU_ADC, 
        ALU_DEC, ALU_DECHC, ALU_ASL, ALU_LSR, 
        ALU_ROL, ALU_ROR, ALU_NOP
    );

end Common;
