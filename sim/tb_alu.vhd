library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is end entity;

architecture sim of tb_alu is
    signal a, b, result : std_logic_vector(2 downto 0) := (others => '0');
    signal op           : std_logic := '0';
    signal cout         : std_logic;
begin
    dut: entity work.alu_3bit
        port map (a => a, b => b, op => op, result => result, cout => cout);

    stim: process
        variable exp : integer;
    begin
        -- ADD: a in 0..5, b=1, expect a+1 (giới hạn 3-bit)
        for av in 0 to 5 loop
            a  <= std_logic_vector(to_unsigned(av, 3));
            b  <= "001";
            op <= '0';
            wait for 10 ns;
            exp := (av + 1) mod 8;
            assert to_integer(unsigned(result)) = exp
                report "FAIL ADD a=" & integer'image(av) severity error;
        end loop;

        -- SUB: a in 1..5, b=1, expect a-1
        for av in 1 to 5 loop
            a  <= std_logic_vector(to_unsigned(av, 3));
            b  <= "001";
            op <= '1';
            wait for 10 ns;
            exp := av - 1;
            assert to_integer(unsigned(result)) = exp
                report "FAIL SUB a=" & integer'image(av) severity error;
        end loop;

        -- SUB lớn hơn để kiểm tra trừ giá A (b=2) và giá B (b=3)
        a <= "100"; b <= "010"; op <= '1'; wait for 10 ns;  -- 4-2=2
        assert to_integer(unsigned(result)) = 2 report "FAIL SUB 4-2" severity error;
        a <= "100"; b <= "011"; op <= '1'; wait for 10 ns;  -- 4-3=1
        assert to_integer(unsigned(result)) = 1 report "FAIL SUB 4-3" severity error;
        a <= "101"; b <= "011"; op <= '1'; wait for 10 ns;  -- 5-3=2
        assert to_integer(unsigned(result)) = 2 report "FAIL SUB 5-3" severity error;

        report "tb_alu: ALL CASES PASSED" severity note;
        wait;
    end process;
end architecture;
