
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--  A testbench has no ports.
entity P6502_tb is
end P6502_tb;


architecture behav of P6502_tb is
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
  constant half_period : time := 5 us;
  constant PC_INIT : UNSIGNED(15 downto 0) := x"4000";
  signal clk, finished : std_logic := '0'; -- make sure you initialise!
  signal rst, ready, nmi, nres, irq : std_logic := '0';
  signal we : std_logic;
  signal data_in: std_logic_vector(7 downto 0) := x"00";
  signal data_out: std_logic_vector(7 downto 0);
  signal address_out: std_logic_vector(15 downto 0);

begin

  clk <= not clk after half_period when finished /= '1' else '0';

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

  process
  begin

    wait for 100 * half_period;

    assert false report "end of test" severity note;
    finished <= '1';
    wait;
  end process;
end behav;