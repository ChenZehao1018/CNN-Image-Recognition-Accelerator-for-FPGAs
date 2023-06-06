library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.data_type.all;

entity argmax is
    port(
		clk:		  in std_logic;
		reset_n:	  in std_logic;
		
		read_i:		  in std_logic;
        data_i:       in data_array_3bit;
        data_o:       out std_logic_vector(31 downto 0)
    );
end argmax;

architecture Behavioral of argmax is

    signal max_val_reg:	  fixed_point := X"0000";
    signal max_idx_reg:	  natural := 0;

begin

    process(clk, reset_n)
        variable max_val_temp: fixed_point;
        variable max_idx_temp: natural;
    begin
        if reset_n = '0' then
            max_val_reg <= (others => '0');
            max_idx_reg <= 0;
        elsif rising_edge(clk) then
            if read_i = '1' then
                max_val_temp := max_val_reg;
                max_idx_temp := max_idx_reg;
                for i in 0 to 2 loop
                    if data_i(i) >= max_val_temp then
                        max_val_temp := data_i(i);
                        max_idx_temp := i;
                    end if;
                end loop;
                max_val_reg <= max_val_temp;
                max_idx_reg <= max_idx_temp;
            end if;
        end if;
    end process;
	
    data_o <= std_logic_vector(to_unsigned(max_idx_reg, data_o'length));

end Behavioral;
