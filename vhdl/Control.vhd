library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
    use work.Common.all;

entity Control is
  port (
    clk, rst, ready: in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    control_out: out ControlSignals
  );
end Control; 

architecture arch of Control is
    signal internal_ready: std_logic;
    signal current_state, next_state: State;
    signal instruction: Instruction;
begin

    process(rst,clk)
    begin
        if rst = '1' then
            internal_ready <= '0';
        elsif rising_edge(clk) then 
            internal_ready <= ready;
        end if;
    end process;

    process(rst,clk,internal_ready)
    begin
        if rst = '1' then
            current_state <= T0;
        elsif rising_edge(clk) and internal_ready = '1' then
            current_state <= next_state;
        end if;
    end process;

    process(clk,current_state)
    begin
        if rising_edge(clk) and next_state = T0 then
            instruction <= InstructionDecoder(data_in);
        else
            instruction <= instruction;
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
            control_out <= ('0','0', '0', ALU_NOP);
        elsif current_state = T0 then
            control_out <= ('1','1', '0', ALU_ADD);
        elsif current_state = T1 then
            control_out <= ('1','1', '1', ALU_ADD);
        else
            control_out <= ('0','0', '0', ALU_NOP);
        end if;
    end process;
end architecture;