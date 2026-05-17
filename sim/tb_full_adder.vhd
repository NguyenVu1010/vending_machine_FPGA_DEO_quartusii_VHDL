library ieee;
use ieee.std_logic_1164.all;

entity tb_full_adder is end entity;

architecture sim of tb_full_adder is
    signal a, b, cin, sum, cout : std_logic := '0';
    type vec_t is record
        a, b, cin, sum, cout : std_logic;
    end record;
    type vec_arr is array (0 to 7) of vec_t;
    constant cases : vec_arr := (
        ('0','0','0','0','0'), ('0','0','1','1','0'),
        ('0','1','0','1','0'), ('0','1','1','0','1'),
        ('1','0','0','1','0'), ('1','0','1','0','1'),
        ('1','1','0','0','1'), ('1','1','1','1','1')
    );
begin
    dut: entity work.full_adder_1bit
        port map (a => a, b => b, cin => cin, sum => sum, cout => cout);

    stim: process
    begin
        for i in cases'range loop
            a   <= cases(i).a;
            b   <= cases(i).b;
            cin <= cases(i).cin;
            wait for 10 ns;
            assert sum = cases(i).sum
                report "FAIL sum: i=" & integer'image(i) severity error;
            assert cout = cases(i).cout
                report "FAIL cout: i=" & integer'image(i) severity error;
        end loop;
        report "tb_full_adder: ALL CASES PASSED" severity note;
        wait;
    end process;
end architecture;
