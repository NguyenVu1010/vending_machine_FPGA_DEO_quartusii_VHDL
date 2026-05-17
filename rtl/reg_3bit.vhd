library ieee;
use ieee.std_logic_1164.all;

entity reg_3bit is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        en     : in  std_logic;
        d      : in  std_logic_vector(2 downto 0);
        q      : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of reg_3bit is
    signal q_r : std_logic_vector(2 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q_r <= (others => '0');
            elsif en = '1' then
                q_r <= d;
            end if;
        end if;
    end process;
    q <= q_r;
end architecture;
