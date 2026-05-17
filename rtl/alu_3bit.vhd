library ieee;
use ieee.std_logic_1164.all;

entity alu_3bit is
    port (
        a, b   : in  std_logic_vector(2 downto 0);
        op     : in  std_logic;
        result : out std_logic_vector(2 downto 0);
        cout   : out std_logic
    );
end entity;

architecture structural of alu_3bit is
    signal b_xor : std_logic_vector(2 downto 0);
begin
    b_xor(0) <= b(0) xor op;
    b_xor(1) <= b(1) xor op;
    b_xor(2) <= b(2) xor op;

    add: entity work.adder_3bit
        port map (a => a, b => b_xor, cin => op, sum => result, cout => cout);
end architecture;
