library ieee;
use ieee.std_logic_1164.all;

entity fsm_control is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        insert_pulse : in  std_logic;
        buy_a_pulse  : in  std_logic;
        buy_b_pulse  : in  std_logic;
        sw_cancel    : in  std_logic;
        tick_1hz     : in  std_logic;
        balance      : in  std_logic_vector(2 downto 0);
        ge_price_a   : in  std_logic;
        ge_price_b   : in  std_logic;
        alu_op       : out std_logic;
        alu_b        : out std_logic_vector(2 downto 0);
        bal_load_en  : out std_logic;
        bal_clear    : out std_logic;
        coin_inc     : out std_logic;
        coin_clr     : out std_logic;
        start_timer  : out std_logic;
        state_out    : out std_logic_vector(2 downto 0);
        ledg         : out std_logic_vector(9 downto 0)
    );
end entity;

architecture rtl of fsm_control is
    type state_t is (S_IDLE, S_ACCEPT, S_DISPENSE_A, S_DISPENSE_B,
                     S_RETURN_CHANGE, S_INSUFFICIENT);
    signal cur, nxt : state_t := S_IDLE;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then cur <= S_IDLE;
            else cur <= nxt;
            end if;
        end if;
    end process;

    process(cur, insert_pulse, buy_a_pulse, buy_b_pulse, sw_cancel,
            tick_1hz, balance, ge_price_a, ge_price_b)
    begin
        nxt <= cur;
        case cur is
            when S_IDLE =>
                if insert_pulse = '1' then nxt <= S_ACCEPT; end if;
            when S_ACCEPT =>
                if sw_cancel = '1' then
                    nxt <= S_RETURN_CHANGE;
                elsif buy_a_pulse = '1' then
                    if ge_price_a = '1' then nxt <= S_DISPENSE_A;
                    else nxt <= S_INSUFFICIENT; end if;
                elsif buy_b_pulse = '1' then
                    if ge_price_b = '1' then nxt <= S_DISPENSE_B;
                    else nxt <= S_INSUFFICIENT; end if;
                end if;
            when S_DISPENSE_A | S_DISPENSE_B =>
                if tick_1hz = '1' then nxt <= S_RETURN_CHANGE; end if;
            when S_RETURN_CHANGE =>
                if balance = "000" then nxt <= S_IDLE;
                end if;
            when S_INSUFFICIENT =>
                if tick_1hz = '1' then nxt <= S_ACCEPT; end if;
        end case;
    end process;

    process(cur, insert_pulse, buy_a_pulse, buy_b_pulse, tick_1hz,
            balance, ge_price_a, ge_price_b)
    begin
        alu_op      <= '0';
        alu_b       <= "001";
        bal_load_en <= '0';
        bal_clear   <= '0';
        coin_inc    <= '0';
        coin_clr    <= '0';
        start_timer <= '0';
        ledg        <= (others => '0');

        case cur is
            when S_IDLE =>
                ledg(9) <= '1';
                coin_clr <= '1';
                if insert_pulse = '1' then
                    alu_op <= '0'; alu_b <= "001"; bal_load_en <= '1';
                end if;
            when S_ACCEPT =>
                if insert_pulse = '1' and balance /= "101" then
                    alu_op <= '0'; alu_b <= "001"; bal_load_en <= '1';
                elsif buy_a_pulse = '1' and ge_price_a = '1' then
                    alu_op <= '1'; alu_b <= "010"; bal_load_en <= '1';
                    start_timer <= '1';
                elsif buy_b_pulse = '1' and ge_price_b = '1' then
                    alu_op <= '1'; alu_b <= "011"; bal_load_en <= '1';
                    start_timer <= '1';
                elsif (buy_a_pulse = '1' and ge_price_a = '0') or
                      (buy_b_pulse = '1' and ge_price_b = '0') then
                    start_timer <= '1';
                end if;
            when S_DISPENSE_A =>
                ledg(0) <= '1';
            when S_DISPENSE_B =>
                ledg(1) <= '1';
            when S_RETURN_CHANGE =>
                if balance /= "000" and tick_1hz = '1' then
                    alu_op <= '1'; alu_b <= "001"; bal_load_en <= '1';
                    coin_inc <= '1';
                    ledg(3) <= '1';
                end if;
            when S_INSUFFICIENT =>
                ledg(2) <= '1';
        end case;
    end process;

    with cur select state_out <=
        "000" when S_IDLE,
        "001" when S_ACCEPT,
        "010" when S_DISPENSE_A,
        "011" when S_DISPENSE_B,
        "100" when S_RETURN_CHANGE,
        "101" when S_INSUFFICIENT;
end architecture;
