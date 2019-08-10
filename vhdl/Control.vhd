library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
    use work.Common.all;

entity Control is
  port (
    clk, rst, ready: in std_logic;
    data_in: in std_logic_vector(7 downto 0)
  );
end Control; 

architecture arch of Control is
    signal internal_ready: std_logic;
    signal current_state: State;
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
            current_state <= T1;
        end if;
    end process;
end architecture;