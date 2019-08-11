library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
    use work.Common.all;

entity Control is
  port (
    clk1, clk2, rst, ready: in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    control_out: out ControlSignals
  );
end Control; 

architecture arch of Control is
    signal InstructionReg_clk, current_state_is_T1: std_logic;
    signal PreDecodeReg_q, InstructionReg_q: std_logic_vector(7 downto 0);
    signal current_state, next_state: State;
    signal instruction: Instruction;
begin

    PreDecodeReg: entity work.RegisterVector
    port map (
        clk     => clk2,
        rst     => rst,
        ce      => '1',
        d       => data_in,
        q       => PreDecodeReg_q
    );

    InstructionReg: entity work.RegisterVector
    port map (
        clk     => InstructionReg_clk,
        rst     => rst,
        ce      => '1',
        d       => PreDecodeReg_q,
        q       => InstructionReg_q
    );

    current_state_is_T1 <= '1' when current_state = T1 else '0';
    InstructionReg_clk <= current_state_is_T1 or ready or clk1;
    instruction <= InstructionDecoder(InstructionReg_q);

    process(rst,clk1)
    begin
        if rst = '1' then
            current_state <= T0;
        elsif rising_edge(clk1) and ready = '1' then
            current_state <= next_state;
        end if;
    end process;
    

    process(current_state,instruction)
    begin
        if current_state = T0 then
            if instruction.size = 1 then
                next_state <= T0;
            else
                next_state <= T1;
            end if;
        elsif current_state = T1 then
            if instruction.size = 2 then
                next_state <= T0;
            else
                next_state <= T2;
            end if;
        elsif current_state = T2 then
            if instruction.size = 3 then
                next_state <= T0;
            else
                next_state <= T3;
            end if;
        else
            next_state <= T0;
        end if;
    end process;

    process(rst,current_state,instruction)
    begin
        if rst = '1' or instruction.opcode = invalid_instruction then
            control_out <= ('0','0', '0', OpCodeToAluOperation(instruction.opcode));
        elsif current_state = T0 then
            control_out <= ('1','1', '0', OpCodeToAluOperation(instruction.opcode));
        elsif current_state = T1 then
            control_out <= ('1','1', '1', OpCodeToAluOperation(instruction.opcode));
        else
            control_out <= ('0','0', '0', OpCodeToAluOperation(instruction.opcode));
        end if;
    end process;
end architecture;