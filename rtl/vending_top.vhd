library ieee;
use ieee.std_logic_1164.all;

entity vending_top is
    generic (
        CLK_HZ : integer := 50_000_000
    );
    port (
        clk  : in  std_logic;
        sw   : in  std_logic_vector(9 downto 0);
        btn  : in  std_logic_vector(2 downto 0);
        hex0 : out std_logic_vector(6 downto 0);
        hex1 : out std_logic_vector(6 downto 0);
        hex2 : out std_logic_vector(6 downto 0);
        hex3 : out std_logic_vector(6 downto 0);
        ledg : out std_logic_vector(9 downto 0)
    );
end entity;

architecture rtl of vending_top is
    signal rst         : std_logic;
    signal tick_1hz, tick_10ms : std_logic;
    signal start_timer : std_logic;

    signal btn0_pulse : std_logic;
    signal btn1_pulse : std_logic;
    signal btn2_pulse : std_logic;

    signal alu_a, alu_b, alu_y, balance : std_logic_vector(2 downto 0);
    signal alu_op : std_logic;
    signal bal_load_en, bal_clear : std_logic;
    signal bal_rst : std_logic;

    signal ge_price_a, ge_price_b : std_logic;

    signal coin_inc, coin_clr : std_logic;
    signal coin_cnt : std_logic_vector(2 downto 0);

    signal disp_src : std_logic_vector(2 downto 0);
    signal dollar, cent_high, cent_low : std_logic_vector(3 downto 0);

    signal ledg_int  : std_logic_vector(9 downto 0);

    -- helper for active-low button inputs
    signal btn0_n, btn1_n, btn2_n : std_logic;
begin
    rst <= sw(0);

    -- DE0 buttons are active-low; convert to active-high before debouncer
    btn0_n <= not btn(0);
    btn1_n <= not btn(1);
    btn2_n <= not btn(2);

    u_timer: entity work.timer_1hz
        generic map (CLK_HZ => CLK_HZ, SLOW_HZ => 1)
        port map (clk => clk, rst => rst, restart => start_timer,
                  tick_1hz => tick_1hz, tick_10ms => tick_10ms);

    u_deb0: entity work.debouncer
        port map (clk => clk, rst => rst, sample_tick => tick_10ms,
                  din => btn0_n, clean => open, pulse => btn0_pulse);
    u_deb1: entity work.debouncer
        port map (clk => clk, rst => rst, sample_tick => tick_10ms,
                  din => btn1_n, clean => open, pulse => btn1_pulse);
    u_deb2: entity work.debouncer
        port map (clk => clk, rst => rst, sample_tick => tick_10ms,
                  din => btn2_n, clean => open, pulse => btn2_pulse);

    alu_a <= balance;
    u_alu: entity work.alu_3bit
        port map (a => alu_a, b => alu_b, op => alu_op,
                  result => alu_y, cout => open);

    bal_rst <= rst or bal_clear;
    u_bal: entity work.reg_3bit
        port map (clk => clk, rst => bal_rst,
                  en => bal_load_en, d => alu_y, q => balance);

    u_cmp: entity work.comparator_3bit
        port map (balance => balance,
                  ge_price_a => ge_price_a, ge_price_b => ge_price_b);

    u_coin: entity work.counter_coin
        port map (clk => clk, rst => rst, clr => coin_clr,
                  inc => coin_inc, count => coin_cnt);

    u_fsm: entity work.fsm_control
        port map (
            clk          => clk,
            rst          => rst,
            insert_pulse => btn0_pulse,
            buy_a_pulse  => btn1_pulse,
            buy_b_pulse  => btn2_pulse,
            sw_cancel    => sw(9),
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
            state_out    => open,
            ledg         => ledg_int
        );

    disp_src <= coin_cnt when sw(8) = '1' else balance;
    u_bcd: entity work.hdu_to_bcd
        port map (hdu => disp_src,
                  dollar => dollar, cent_high => cent_high, cent_low => cent_low);

    u_seg2: entity work.seven_seg_decoder port map (bcd => dollar,    seg => hex2);
    u_seg1: entity work.seven_seg_decoder port map (bcd => cent_high, seg => hex1);
    u_seg0: entity work.seven_seg_decoder port map (bcd => cent_low,  seg => hex0);
    hex3 <= "1000000";

    ledg <= ledg_int;
end architecture;
