library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_vending_top is end entity;

architecture sim of tb_vending_top is
    signal clk      : std_logic := '0';
    signal sw       : std_logic_vector(9 downto 0) := (others => '0');
    signal btn      : std_logic_vector(2 downto 0) := (others => '1');
    signal hex0     : std_logic_vector(6 downto 0);
    signal hex1     : std_logic_vector(6 downto 0);
    signal hex2     : std_logic_vector(6 downto 0);
    signal hex3     : std_logic_vector(6 downto 0);
    signal ledg     : std_logic_vector(9 downto 0);

    constant T : time := 20 ns;
    constant SIM_CLK_HZ : integer := 10_000;

    procedure press(signal b : out std_logic_vector(2 downto 0); idx : integer) is
    begin
        b(idx) <= '0';
        wait for 10 us;
        b(idx) <= '1';
        wait for 20 us;  -- enough for debouncer to detect release (needs >=8us at 2us tick)
    end procedure;
begin
    clk <= not clk after T/2;

    dut: entity work.vending_top
        generic map (CLK_HZ => SIM_CLK_HZ)
        port map (
            clk     => clk,
            sw      => sw,
            btn     => btn,
            hex0    => hex0,
            hex1    => hex1,
            hex2    => hex2,
            hex3    => hex3,
            ledg    => ledg
        );

    stim: process
    begin
        sw(0) <= '1'; wait for 100 ns; sw(0) <= '0';
        wait for 5*T;

        report "=== Scenario 1: happy path A ($1.00) ===" severity note;
        press(btn, 0);
        press(btn, 0);
        press(btn, 1);
        wait for 210 us;
        assert ledg(9) = '1'
            report "FAIL scenario 1: not back to IDLE" severity error;

        report "=== Scenario 2: buy B voi thoi $0.50 ===" severity note;
        press(btn, 0); press(btn, 0); press(btn, 0); press(btn, 0);
        press(btn, 2);
        wait for 420 us;
        assert ledg(9) = '1'
            report "FAIL scenario 2: not back to IDLE" severity error;

        report "=== Scenario 3: insufficient ===" severity note;
        press(btn, 0);
        press(btn, 1);
        wait for 200 us;
        assert ledg(2) = '0'
            report "FAIL scenario 3: LEDG2 van sang" severity error;

        report "=== Scenario 4: cancel ===" severity note;
        press(btn, 0); press(btn, 0);  -- balance already 1 from sc3, now total 3
        sw(9) <= '1'; wait for 200 ns; sw(9) <= '0';
        wait for 600 us;
        assert ledg(9) = '1'
            report "FAIL scenario 4: cancel chua ve IDLE" severity error;

        report "=== Scenario 5: clamp o $2.50 ===" severity note;
        press(btn, 0); press(btn, 0); press(btn, 0);
        press(btn, 0); press(btn, 0);

        report "tb_vending_top: ALL SCENARIOS COMPLETED" severity note;
        wait;
    end process;
end architecture;
