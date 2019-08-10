library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.Common.all;

entity Alu is
  port (
      a, b: in std_logic_vector(7 downto 0);
      carry_in: std_logic;
      operation: ALU_Operation_type;
      result: out std_logic_vector(7 downto 0);
      carry_out, overflow: out std_logic
  );
end Alu; 

architecture arch of Alu is
    signal sum_ext, a_ext, b_ext: unsigned(9 downto 0);
    signal result_internal: std_logic_vector(7 downto 0);
begin

  a_ext <= UNSIGNED('0' & a & '1'); 
  b_ext <= UNSIGNED('0' & b & carry_in) when operation = ALU_ADC or operation = ALU_DECHC else UNSIGNED('0' & b & '0');

  sum_ext <= (a_ext + b_ext)     when (operation = ALU_ADC or operation = ALU_ADD)   else
             (a_ext + b_ext - 2) when (operation = ALU_DEC or operation = ALU_DECHC) else
             "0000000000";
  
  result_internal <= a and b when operation = ALU_AND else
            a or b when operation = ALU_OR else
            a xor b when operation = ALU_XOR else
            a when operation = ALU_A else
            b when operation = ALU_B else
            STD_LOGIC_VECTOR(sum_ext(8 downto 1)) when operation = ALU_ADD else
            STD_LOGIC_VECTOR(sum_ext(8 downto 1)) when operation = ALU_ADC else
            STD_LOGIC_VECTOR(sum_ext(8 downto 1)) when operation = ALU_DEC else
            STD_LOGIC_VECTOR(sum_ext(8 downto 1)) when operation = ALU_DECHC else
            b(6 downto 0) & '0' when operation = ALU_ASL else
            '0' & b(7 downto 1) when operation = ALU_LSR else
            b(6 downto 0) & carry_in when operation = ALU_ROL else
            carry_in & b(7 downto 1) when operation = ALU_ROR else
            "00000000" when operation = ALU_NOP else
            "00000000";

    -- Overflow flag (Operands with the same signal but different from the result's signal)
    overflow <= '1' when a(7) = b(7) and a(7) /= result_internal(7) else '1' when (b(6) = '1' and operation = ALU_B) else '0';     -- Behavioral
    
    -- Carry flag
    carry_out <= b(7) when (operation = ALU_ASL or operation = ALU_ROL) else b(0) when (operation = ALU_LSR or operation = ALU_ROR) else sum_ext(9);

    result <= result_internal;

end architecture;