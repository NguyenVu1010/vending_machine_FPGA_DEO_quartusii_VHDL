library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fsm is end entity;

architecture sim of tb_fsm is
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal insert_p    : std_logic := '0';
    signal buy_a_p     : std_logic := '0';
    signal buy_b_p     : std_logic := '0';
    signal cancel      : std_logic := '0';
    signal tick_1hz    : std_logic := '0';
    signal balance     : std_logic_vector(2 downto 0) := "000";
    signal ge_price_a  : std_logic;
    signal ge_price_b  : std_logic;
    signal alu_op      : std_logic;
    signal alu_b       : std_logic_vector(2 downto 0);
    signal bal_load_en : std_logic;
    signal bal_clear   : std_logic;
    signal coin_inc    : std_logic;
    signal coin_clr    : std_logic;
    signal start_timer : std_logic;
    signal state_out   : std_logic_vector(2 downto 0);
    signal ledg        : std_logic_vector(9 downto 0);
    constant T : time := 20 ns;
begin
    ge_price_a <= '1' when unsigned(balance) >= 2 else '0';
    ge_price_b <= '1' when unsigned(balance) >= 3 else '0';

    dut: entity work.fsm_control
        port map (
            clk => clk, rst => rst,
            insert_pulse => insert_p,
            buy_a_pulse  => buy_a_p,
            buy_b_pulse  => buy_b_p,
            sw_cancel    => cancel,
            tick_1hz     => tick_1hz,
            balance      => balance,
            ge_price_a   => ge_price_a,
            ge_price_b   => ge_price_b,
            alu_op       => alu_op,
            alu_b        => alu_b,
            bal_load_en  => bal_load_en,
            bal_clear    => bal_clear,
            coin_inc     => coin_inc,
            coin_clr     => coin_clr,
            start_timer  => start_timer,
            state_out    => state_out,
            ledg         => ledg
        );

    clk <= not clk after T/2;

    stim: process
    begin
        wait for 2*T; rst <= '0'; wait for T;
        assert state_out = "000" report "FAIL: not IDLE after reset" severity error;
        assert ledg(9) = '1' report "FAIL: LEDG9 not on in IDLE" severity error;

        insert_p <= '1'; wait for T; insert_p <= '0';
        balance  <= "001";
        wait for T;
        assert state_out = "001" report "FAIL: expected S_ACCEPT" severity error;

        buy_a_p <= '1'; wait for T; buy_a_p <= '0';
        wait for T;
        assert state_out = "101" report "FAIL: expected S_INSUFFICIENT" severity error;
        assert ledg(2) = '1' report "FAIL: LEDG2 not on" severity error;

        tick_1hz <= '1'; wait for T; tick_1hz <= '0'; wait for T;
        assert state_out = "001" report "FAIL: back to S_ACCEPT" severity error;

        balance <= "100";
        buy_b_p <= '1'; wait for T; buy_b_p <= '0'; wait for T;
        assert state_out = "011" report "FAIL: expected S_DISPENSE_B" severity error;
        assert ledg(1) = '1' report "FAIL: LEDG1 not on" severity error;

        balance <= "001";
        tick_1hz <= '1'; wait for T; tick_1hz <= '0'; wait for T;
        assert state_out = "100" report "FAIL: expected S_RETURN_CHANGE" severity error;

        balance <= "000";
        tick_1hz <= '1'; wait for T; tick_1hz <= '0'; wait for T;
        assert state_out = "000" report "FAIL: expected IDLE" severity error;

        report "tb_fsm: ALL CASES PASSED" severity note;
        wait;
    end process;
end architecture;
