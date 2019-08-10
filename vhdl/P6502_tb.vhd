
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
        address     : out std_logic_vector(15 downto 0);-- Address bus to memory
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
  signal address: std_logic_vector(15 downto 0);

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
      address => address,
      we => we
    );


    rst <= '1', '0' after 1*tick;
    ready <= '0', '1' after 2*tick;
    -- clk <= not clk after 5 ns;    -- 100 MHz
    clk <= not clk after tick/2;    -- 100 MHz

    data_in <= x"69", x"0f" after 5*tick;
    
end behavioral;