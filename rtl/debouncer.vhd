library ieee;
use ieee.std_logic_1164.all;

entity debouncer is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        sample_tick : in  std_logic;
        din         : in  std_logic;
        clean       : out std_logic;
        pulse       : out std_logic
    );
end entity;

architecture rtl of debouncer is
    signal shift  : std_logic_vector(3 downto 0) := (others => '0');
    signal clean_r, clean_prev : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                shift      <= (others => '0');
                clean_r    <= '0';
                clean_prev <= '0';
            else
                if sample_tick = '1' then
                    shift <= shift(2 downto 0) & din;
                    if shift = "1111" then
                        clean_r <= '1';
                    elsif shift = "0000" then
                        clean_r <= '0';
                    end if;
                end if;
                clean_prev <= clean_r;
            end if;
        end if;
    end process;

    clean <= clean_r;
    pulse <= clean_r and (not clean_prev);
end architecture;
