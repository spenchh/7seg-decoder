library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity decode is
    generic(
        G_REFRESH_TICK : positive := 100_000 -- 100Hz refresh rate
    );
    port(
        i_clk     :   in  std_logic;
        o_anode_n :   out std_logic_vector(3 downto 0);
        o_seg_n   :   out std_logic_vector(6 downto 0)
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
    
    signal counter : unsigned(counter_width(G_REFRESH_TICK)-1 downto 0) := (others => '0');
    signal mode : unsigned(1 downto 0) := (others => '0');

begin
    -- Anode & Cathodes are Active Low
    process (mode)
    begin

        case mode is -- mode switches between the LED
            when "00" => 
                o_anode_n <= (0 =>'0', others => '1');
                o_seg_n   <= (1 => '0', 2 => '0', others => '1');

            when "01" => 
                o_anode_n <= (1 => '0', others => '1');
                o_seg_n   <= (0 => '0', 1 => '0', 3 => '0', 4 => '0', 6 => '0', others => '1');
                
            when "10" => 
                o_anode_n <= (2 => '0', others => '1');
                o_seg_n   <= (4 => '1', 5 => '1', others => '0');

            when "11" =>
                o_anode_n <= (3 => '0', others => '1');
                o_seg_n   <= (0 => '1', 3 => '1', 4 => '1', others => '0');

            when others => 
                o_anode_n <= (others => '1');
                o_seg_n   <= (others => '1');

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