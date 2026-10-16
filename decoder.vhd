library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity decode is
    generic(
        G_REFRESH_TICK : positive := 100_000 -- 250 Hz full-display refresh at a 100 MHz clock,
    );
    port(
        i_clk         :   in  std_logic;
        i_digit0      :   in  std_logic_vector(3  downto 0); -- Right most digit
        i_digit1      :   in  std_logic_vector(3  downto 0);
        i_digit2      :   in  std_logic_vector(3  downto 0);
        i_digit3      :   in  std_logic_vector(3  downto 0); -- Left most digit
        o_anode_n     :   out std_logic_vector(3  downto 0);
        o_seg_n       :   out std_logic_vector(6  downto 0)
    );
end decode;

architecture rtl of decode is
    function counter_width(count : positive) return positive is -- function for calculating width
    begin

        if count = 1 then
            return 1;
        else
            return integer(ceil(log2(real(count))));
        end if;

    end function;
    
    signal counter        : unsigned(counter_width(G_REFRESH_TICK)-1 downto 0) := (others => '0');
    signal mode           : unsigned(1 downto 0) := (others => '0');
    signal selected_digit : std_logic_vector(3 downto 0);

begin
    -- Anode & Cathodes are Active Low
    process (mode, i_digit0, i_digit1, i_digit2, i_digit3)
    begin

        case mode is -- mode switches between the LED
            when "00" => 
                o_anode_n      <= "1110"; -- Enables anode[0]
                selected_digit <= i_digit0; -- sel digit takes value of i_digit

            when "01" => 
                o_anode_n      <= "1101"; -- Enables anode[1]
                selected_digit <= i_digit1;
                
            when "10" => 
                o_anode_n      <= "1011"; -- Enables anode[2]
                selected_digit <= i_digit2;

            when "11" =>
                o_anode_n      <= "0111"; -- Enables anode[3]
                selected_digit <= i_digit3;

            when others => 
                o_anode_n      <= (others => '1');
                selected_digit <= (others => '0');

        end case;

    end process;

    process (i_clk)
    begin

        if rising_edge(i_clk) then

            if (counter = G_REFRESH_TICK - 1) then
                counter <= (others => '0');
                mode <= mode + 1;
            else
                counter <= counter + 1;
            end if;

        end if;
    end process;
end architecture rtl;
