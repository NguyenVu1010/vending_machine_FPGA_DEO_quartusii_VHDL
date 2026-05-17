library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer_1hz is
    generic (
        CLK_HZ : integer := 50_000_000;
        SLOW_HZ : integer := 1
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        restart    : in  std_logic;
        tick_1hz   : out std_logic;
        tick_10ms  : out std_logic
    );
end entity;

architecture rtl of timer_1hz is
    constant N_1HZ   : integer := CLK_HZ / SLOW_HZ;
    constant N_10MS  : integer := CLK_HZ / 100;
    signal cnt_1hz   : unsigned(31 downto 0) := (others => '0');
    signal cnt_10ms  : unsigned(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or restart = '1' then
                cnt_1hz  <= (others => '0');
                cnt_10ms <= (others => '0');
                tick_1hz  <= '0';
                tick_10ms <= '0';
            else
                if cnt_1hz = to_unsigned(N_1HZ - 1, 32) then
                    cnt_1hz  <= (others => '0');
                    tick_1hz <= '1';
                else
                    cnt_1hz  <= cnt_1hz + 1;
                    tick_1hz <= '0';
                end if;
                if cnt_10ms = to_unsigned(N_10MS - 1, 32) then
                    cnt_10ms  <= (others => '0');
                    tick_10ms <= '1';
                else
                    cnt_10ms  <= cnt_10ms + 1;
                    tick_10ms <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture;
