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
    signal control_out: ControlSignals;
    signal PcReg_d, PcReg_q, AddressReg_d, AddressReg_q: std_logic_vector(15 downto 0);
    signal AluAReg_d, AluAReg_q, AluBReg_d, AluBReg_q, AccumulatorReg_d, AccumulatorReg_q, StatusReg_d, StatusReg_q: std_logic_vector(7 downto 0);
    signal AluResult: std_logic_vector(7 downto 0);
    signal operation: ALU_Operation_type;
begin

    PcReg: entity work.RegisterVector
    generic map (
        WIDTH => 16
    )
    port map (
            clk     => clk,
            rst     => rst,
            ce      => control_out.PcReg_ce,
            d       => PcReg_d,
            q       => PcReg_q
    );

    AddressReg: entity work.RegisterVector
    generic map (
        WIDTH => 16
    )
    port map (
            clk     => clk,
            rst     => rst,
            ce      => control_out.AddressReg_ce,
            d       => AddressReg_d,
            q       => AddressReg_q
    );
    
    AluAReg: entity work.RegisterVector
    port map (
            clk     => clk,
            rst     => rst,
            ce      => '1',
            d       => AluAReg_d,
            q       => AluAReg_q
    );
    
    AluBReg: entity work.RegisterVector
    port map (
            clk     => clk,
            rst     => rst,
            ce      => '1',
            d       => AluBReg_d,
            q       => AluBReg_q
    );
    
    AccumulatorReg: entity work.RegisterVector
    port map (
            clk     => clk,
            rst     => rst,
            ce      => control_out.AccumulatorReg_ce,
            d       => AccumulatorReg_d,
            q       => AccumulatorReg_q
    );

    Alu: entity work.Alu
    port map (
        a => AluAReg_q,
        b => AluBReg_q,
        carry_in => StatusReg_q(CARRY),
        operation => control_out.AluOperation,
        result => AluResult,
        carry_out => StatusReg_d(CARRY),
        overflow => StatusReg_d(OVERFLOW)
    );

    Control: entity work.Control
    port map (
        clk => clk,
        rst => rst,
        ready => ready,
        data_in => data_in,
        control_out => control_out
    );

    PcReg_d <= STD_LOGIC_VECTOR(UNSIGNED(PcReg_q) + 1);
    AddressReg_d <= PcReg_q;

    AluAReg_d <= AccumulatorReg_q;
    AluBReg_d <= data_in;

    AccumulatorReg_d <= AluResult;

    address_out <= AddressReg_q;
end architecture;