library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.Common.all;

entity P6502 is
    port( 
        clk, rst, ready : in std_logic;
        nmi, nres, irq  : in std_logic;   -- Interrupt lines (active low)
        data_in         : in std_logic_vector(7 downto 0);  -- Data from memory
        data_out        : out std_logic_vector(7 downto 0); -- Data to memory
        address_out     : out std_logic_vector(15 downto 0);-- Address bus to memory
        we              : out std_logic -- Access control to data memory ('0' for Reads, '1' for Writes)
    );
end P6502;

architecture arch of P6502 is
    signal clk1, clk2: std_logic;
    signal control_out: ControlSignals;

    signal address_bus_low, address_bus_high: std_logic_vector(7 downto 0);
    signal data_bus, stack_bus: std_logic_vector(7 downto 0);
    signal PcLowReg_d, PcHighReg_d, PcLowReg_q, PcHighReg_q: std_logic_vector(7 downto 0);
    signal AddressLowReg_q, AddressHighReg_q: std_logic_vector(7 downto 0);
    signal InputDataLatch_q, AccumulatorReg_d, AccumulatorReg_q, StatusReg_d, StatusReg_q, StackPointerReg_q: std_logic_vector(7 downto 0);
    signal AInputReg_d, AInputReg_q, BInputReg_d, BInputReg_q, AdderHoldReg_d, AdderHoldReg_q: std_logic_vector(7 downto 0);
    signal XReg_q, YReg_q: std_logic_vector(7 downto 0);
    signal operation: ALU_Operation_type;

    signal PC: std_logic_vector(15 downto 0);
begin
    
    clk1 <= not clk;
    clk2 <= not clk1;

    InputDataLatch: entity work.LatchVector
    port map (
        load => clk2,
        rst => rst,
        d => data_in,
        q => InputDataLatch_q
    );

    PcLowReg: entity work.RegisterVector
    port map (
            clk     => clk2,
            rst     => rst,
            ce      => control_out.PcLowReg_ce,
            d       => PcLowReg_d,
            q       => PcLowReg_q
    );

    PcHighReg: entity work.RegisterVector
    port map (
            clk     => clk2,
            rst     => rst,
            ce      => control_out.PcHighReg_ce,
            d       => PcHighReg_d,
            q       => PcHighReg_q
    );

    AddressLowReg: entity work.RegisterVector
    port map (
            clk     => clk1,
            rst     => rst,
            ce      => control_out.AddressLowReg_ce,
            d       => address_bus_low,
            q       => AddressLowReg_q
    );

    AddressHighReg: entity work.RegisterVector
    port map (
            clk     => clk1,
            rst     => rst,
            ce      => control_out.AddressHighReg_ce,
            d       => address_bus_high,
            q       => AddressHighReg_q
    );
    
    AccumulatorReg: entity work.RegisterVector
    port map (
            clk     => clk1,
            rst     => rst,
            ce      => control_out.AccumulatorReg_ce,
            d       => AccumulatorReg_d,
            q       => AccumulatorReg_q
    );
    
    AInputReg: entity work.RegisterVector
    port map (
            clk     => clk1,
            rst     => rst,
            ce      => control_out.AInputReg_ce,
            d       => AInputReg_d,
            q       => AInputReg_q
    );
    
    BInputReg: entity work.RegisterVector
    port map (
            clk     => clk1,
            rst     => rst,
            ce      => control_out.BInputReg_ce,
            d       => BInputReg_d,
            q       => BInputReg_q
    );
    
    AdderHoldReg: entity work.RegisterVector
    port map (
            clk     => clk2,
            rst     => rst,
            ce      => '1',
            d       => AdderHoldReg_d,
            q       => AdderHoldReg_q
    );

    Alu: entity work.Alu
    port map (
        a => AInputReg_q,
        b => BInputReg_q,
        carry_in => StatusReg_q(CARRY),
        operation => control_out.AluOperation,
        result => AdderHoldReg_d,
        carry_out => StatusReg_d(CARRY),
        overflow => StatusReg_d(OVERFLOW)
    );

    Control: entity work.Control
    port map (
        clk1 => clk1,
        clk2 => clk2,
        rst => rst,
        ready => ready,
        data_in => data_in,
        control_out => control_out
    );

    StatusReg_q <= (others => '0');
    PcLowReg_d <= STD_LOGIC_VECTOR(UNSIGNED(address_bus_low) + 1);
    PcHighReg_d <= address_bus_high;
    PC <= PcHighReg_q & PcLowReg_q;
    
    process(control_out.address_bus_low_mux,PcLowReg_q,InputDataLatch_q,StackPointerReg_q)
    begin
        case control_out.address_bus_low_mux is
            when 0 => address_bus_low <= (others => '0');
            when 1 => address_bus_low <= (others => '1');
            when 2 => address_bus_low <= PcLowReg_q;
            when 3 => address_bus_low <= InputDataLatch_q;
            when 4 => address_bus_low <= AdderHoldReg_q;
            when 5 => address_bus_low <= StackPointerReg_q;
        end case;
    end process;
    
    process(control_out.address_bus_high_mux,PcHighReg_q,InputDataLatch_q,stack_bus)
    begin
        case control_out.address_bus_high_mux is
            when 0 => address_bus_high <= (others => '0');
            when 1 => address_bus_high <= (others => '1');
            when 2 => address_bus_high <= PcHighReg_q;
            when 3 => address_bus_high <= InputDataLatch_q;
            when 4 => address_bus_high <= AdderHoldReg_q;
            when 5 => address_bus_high <= stack_bus;
        end case;
    end process;
    
    process(control_out.data_bus_mux,PcLowReg_q,PcHighReg_q,InputDataLatch_q,AccumulatorReg_q,StatusReg_q,stack_bus)
    begin
        case control_out.data_bus_mux is
            when 0 => data_bus <= (others => '0');
            when 1 => data_bus <= (others => '1');
            when 2 => data_bus <= PcLowReg_q;
            when 3 => data_bus <= PcHighReg_q;
            when 4 => data_bus <= InputDataLatch_q;
            when 5 => data_bus <= AccumulatorReg_q;
            when 6 => data_bus <= StatusReg_q;
            when 7 => data_bus <= stack_bus;
        end case;
    end process;
    
    process(control_out.stack_bus_mux,StackPointerReg_q,AdderHoldReg_q,AccumulatorReg_q,XReg_q,YReg_q,data_bus,address_bus_high)
    begin
        case control_out.stack_bus_mux is
            when 0 => stack_bus <= (others => '0');
            when 1 => stack_bus <= (others => '1');
            when 2 => stack_bus <= StackPointerReg_q;
            when 3 => stack_bus <= AdderHoldReg_q;
            when 4 => stack_bus <= AccumulatorReg_q;
            when 5 => stack_bus <= XReg_q;
            when 6 => stack_bus <= YReg_q;
            when 7 => stack_bus <= data_bus;
            when 8 => stack_bus <= address_bus_high;
        end case;
    end process;
    
    
    process(control_out.a_input_mux,stack_bus)
    begin
        case control_out.a_input_mux is
            when 0 => AInputReg_d <= (others => '0');
            when 1 => AInputReg_d <= stack_bus;
        end case;
    end process;
    
    process(control_out.b_input_mux,address_bus_low,data_bus)
    begin
        case control_out.b_input_mux is
            when 0 => BInputReg_d <= address_bus_low;
            when 1 => BInputReg_d <= data_bus;
            when 2 => BInputReg_d <= not data_bus;
        end case;
    end process;

    AccumulatorReg_d <= stack_bus;

    address_out <= AddressHighReg_q & AddressLowReg_q;
    data_out <= AccumulatorReg_q;
end architecture;