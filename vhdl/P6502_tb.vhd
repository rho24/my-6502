
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--  A testbench has no ports.
entity P6502_tb is
end P6502_tb;


architecture behavioral of P6502_tb is
  --  Declaration of the component that will be instantiated.
  component P6502
      port( 
        clk, rst, ready : in std_logic;
        nmi, nres, irq  : in std_logic;   -- Interrupt lines (active low)
        data_in         : in std_logic_vector(7 downto 0);  -- Data from memory
        data_out        : out std_logic_vector(7 downto 0); -- Data to memory
        address_out     : out std_logic_vector(15 downto 0);-- Address bus to memory
        we  : out std_logic -- Access control to data memory ('0' for Reads, '1' for Writes)
    );
  end component;
  constant tick : time := 10 ns;
  constant PC_INIT : UNSIGNED(15 downto 0) := x"4000";
  signal clk : std_logic := '1';
  signal rst, ready, nmi, nres, irq : std_logic := '0';
  signal we : std_logic;
  signal data_in: std_logic_vector(7 downto 0) := x"00";
  signal data_out: std_logic_vector(7 downto 0);
  signal address_out: std_logic_vector(15 downto 0);

begin

  cpu : entity work.P6502
    generic map (
        PC_INIT => PC_INIT
    )
    port map(
      clk     => clk,
      rst     => rst,
      ready   => ready,
      nmi   => nmi,
      nres   => nres,
      irq   => irq,
      data_in => data_in,
      data_out => data_out,
      address_out => address_out,
      we => we
    );

    rst <= '1', '0' after 1*tick;
    ready <= '0', '1' after 2*tick;
    clk <= not clk after tick/2;    -- 100 MHz
    
    process(address_out)
    begin
      case address_out is
        when x"0000" => data_in <= x"EA";
        when x"0001" => data_in <= x"09";
        when x"0002" => data_in <= x"03";
        when x"0003" => data_in <= x"05";
        when x"0004" => data_in <= x"F1";
        when x"0005" => data_in <= x"69";
        when x"0006" => data_in <= x"01";
        when x"0007" => data_in <= x"EA";
        when x"0008" => data_in <= x"EA";
        when x"0009" => data_in <= x"EA";
        when x"000A" => data_in <= x"EA";
        when x"00f1" => data_in <= x"04";
        when others  => data_in <= x"00";
      end case;
    end process;
end behavioral;