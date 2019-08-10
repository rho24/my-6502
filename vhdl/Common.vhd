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

    type OpCode is (
        LDA, LDX, LDY,
        STA, STX, STY,
        ADC, SBC,
        INC, INX, INY,
        DEC, DEX, DEY,
        TAX, TAY, TXA, TYA,
        AAND, EOR, ORA,
        CMP, CPX, CPY, BITT,
        ASL, LSR, ROLL, RORR,
        JMP, BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS,
        TSX, TXS, PHA, PHP, PLA, PLP,
        CLC, CLD, CLI, CLV, SECi, SED, SEI,
        JSR, RTS, BRK, RTI, NOP,

        invalid_instruction
    );

    type Instruction is record
        opcode: OpCode;
        size: integer range 1 to 3;
    end record;

    function InstructionDecoder(data: in std_logic_vector(7 downto 0)) return Instruction;

    type ControlSignals is record
        PcReg_ce: std_logic;
        AddressReg_ce: std_logic;
        AccumulatorReg_ce: std_logic;
        AluOperation: ALU_Operation_type;
    end record;
end Common;

package body Common is
    function InstructionDecoder(data: in std_logic_vector(7 downto 0)) return Instruction is
        
        variable i: Instruction;

    begin
        case data is
            when x"69" => i.opcode := ADC; i.size := 2;
            when others => i.opcode := invalid_instruction;
        end case;
        return i;
    end InstructionDecoder;

end Common;