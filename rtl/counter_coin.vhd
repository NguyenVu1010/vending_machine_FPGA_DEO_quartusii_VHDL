library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_coin is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        clr   : in  std_logic;
        inc   : in  std_logic;
        count : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of counter_coin is
    signal cnt : unsigned(2 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or clr = '1' then
                cnt <= (others => '0');
            elsif inc = '1' and cnt /= "111" then
                cnt <= cnt + 1;
            end if;
        end if;
    end process;
    count <= std_logic_vector(cnt);
end architecture;
