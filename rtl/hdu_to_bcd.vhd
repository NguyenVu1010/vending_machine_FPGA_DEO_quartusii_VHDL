library ieee;
use ieee.std_logic_1164.all;

entity hdu_to_bcd is
    port (
        hdu        : in  std_logic_vector(2 downto 0);
        dollar     : out std_logic_vector(3 downto 0);
        cent_high  : out std_logic_vector(3 downto 0);
        cent_low   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of hdu_to_bcd is
begin
    cent_low <= "0000";

    process(hdu)
    begin
        case hdu is
            when "000" => dollar <= "0000"; cent_high <= "0000";
            when "001" => dollar <= "0000"; cent_high <= "0101";
            when "010" => dollar <= "0001"; cent_high <= "0000";
            when "011" => dollar <= "0001"; cent_high <= "0101";
            when "100" => dollar <= "0010"; cent_high <= "0000";
            when "101" => dollar <= "0010"; cent_high <= "0101";
            when others => dollar <= "1111"; cent_high <= "1111";
        end case;
    end process;
end architecture;
