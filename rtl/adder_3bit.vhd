library ieee;
use ieee.std_logic_1164.all;

entity adder_3bit is
    port (
        a, b : in  std_logic_vector(2 downto 0);
        cin  : in  std_logic;
        sum  : out std_logic_vector(2 downto 0);
        cout : out std_logic
    );
end entity;

architecture structural of adder_3bit is
    signal c1, c2 : std_logic;
begin
    fa0: entity work.full_adder_1bit
        port map (a => a(0), b => b(0), cin => cin,  sum => sum(0), cout => c1);
    fa1: entity work.full_adder_1bit
        port map (a => a(1), b => b(1), cin => c1,   sum => sum(1), cout => c2);
    fa2: entity work.full_adder_1bit
        port map (a => a(2), b => b(2), cin => c2,   sum => sum(2), cout => cout);
end architecture;
