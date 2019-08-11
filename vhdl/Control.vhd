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
    signal rdy, InstructionReg_clk, current_state_is_T0: std_logic;
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

    current_state_is_T0 <= '1' when current_state = T0 else '0';
    InstructionReg_clk <= current_state_is_T0 and rdy and clk1;
    instruction <= InstructionDecoder(InstructionReg_q);

    process(rst,clk1,rdy)
    begin
        if rst = '1' then
            current_state <= T0;
        elsif rising_edge(clk1) and rdy = '1' then
            current_state <= next_state;
        end if;
    end process;

    process(rst,clk1)
    begin
        if rst = '1' then
            rdy <= '0';
        elsif rising_edge(clk1) then
            rdy <= ready;
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

    process(rdy,current_state,instruction)
    begin
        control_out.PcLowReg_ce <= '0';
        control_out.PcHighReg_ce <= '0';
        control_out.AddressLowReg_ce <= '0';
        control_out.AddressHighReg_ce <= '0';
        control_out.AInputReg_ce <= '0';
        control_out.BInputReg_ce <= '0';
        control_out.AccumulatorReg_ce <= '0';
        control_out.address_bus_low_mux <= 0;
        control_out.address_bus_high_mux <= 0;
        control_out.data_bus_mux <= 0;
        control_out.stack_bus_mux <= 0;
        control_out.a_input_mux <= 0;
        control_out.b_input_mux <= 0;
        control_out.AluOperation <= OpCodeToAluOperation(instruction.opcode);

        if rdy = '1' and instruction.opcode /= invalid_instruction then
            control_out.PcLowReg_ce <= '1';
            control_out.PcHighReg_ce <= '1';
            case current_state is
                when T0 =>
                            control_out.AddressLowReg_ce <= '1';
                            control_out.AddressHighReg_ce <= '1';
                            control_out.address_bus_low_mux <= 2;
                            control_out.address_bus_high_mux <= 2;
                when T1 =>  
                            if instruction.address_mode = ZeroPage then
                                control_out.AddressLowReg_ce <= '1';
                                control_out.AddressHighReg_ce <= '1';
                                control_out.address_bus_low_mux <= 2;
                                control_out.address_bus_high_mux <= 2;
                                control_out.AccumulatorReg_ce <= '1';
                            else
                                control_out.AddressLowReg_ce <= '1';
                                control_out.AddressHighReg_ce <= '1';
                                control_out.address_bus_low_mux <= 2;
                                control_out.address_bus_high_mux <= 2;
                                control_out.data_bus_mux <= 4;
                                control_out.stack_bus_mux <= 4;
                                control_out.AccumulatorReg_ce <= '1';
                            end if;
                when others => null;
            end case;
        end if;
    end process;
end architecture;