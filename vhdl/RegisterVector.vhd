library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity RegisterVector is
  generic (
      WIDTH: integer := 8
  );
  port (
    clk, rst, ce: in std_logic;
    d: in std_logic_vector (WIDTH-1 downto 0);
    q: out std_logic_vector (WIDTH-1 downto 0)
  );
end RegisterVector ; 

architecture arch of RegisterVector is
begin

    process(clk, rst)
    begin
        if rst = '1' then
            q <= STD_LOGIC_VECTOR(TO_UNSIGNED(0,WIDTH));
        elsif falling_edge(clk) then
            if ce = '1' then
                q <= d;
            end if;
        end if;
    end process;
end architecture;