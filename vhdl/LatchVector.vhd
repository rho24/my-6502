library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity LatchVector is
  generic (
      WIDTH: integer := 8
  );
  port (
    load, rst: in std_logic;
    d: in std_logic_vector (WIDTH-1 downto 0);
    q: out std_logic_vector (WIDTH-1 downto 0)
  );
end LatchVector ; 

architecture arch of LatchVector is
begin
    process(load,rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif load = '1' then
            q <= d;
        end if;
    end process;
end architecture;