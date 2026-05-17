library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator_3bit is
    port (
        balance     : in  std_logic_vector(2 downto 0);
        ge_price_a  : out std_logic;
        ge_price_b  : out std_logic
    );
end entity;

architecture rtl of comparator_3bit is
    constant PRICE_A : unsigned(2 downto 0) := "010";
    constant PRICE_B : unsigned(2 downto 0) := "011";
begin
    ge_price_a <= '1' when unsigned(balance) >= PRICE_A else '0';
    ge_price_b <= '1' when unsigned(balance) >= PRICE_B else '0';
end architecture;
