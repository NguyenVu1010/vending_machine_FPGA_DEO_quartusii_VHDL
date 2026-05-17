library ieee;
use ieee.std_logic_1164.all;

entity full_adder_1bit is
    port (
        a, b, cin : in  std_logic;
        sum, cout : out std_logic
    );
end entity;

architecture dataflow of full_adder_1bit is
begin
    sum  <= a xor b xor cin;
    cout <= (a and b) or (cin and (a xor b));
end architecture;
