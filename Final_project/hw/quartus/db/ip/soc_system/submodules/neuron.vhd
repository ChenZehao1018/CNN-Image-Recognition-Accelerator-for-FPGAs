library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity neuron is
    port(
        data_i:     in data_array_16bit;
        weight_i:   in data_array_16bit;
        data_o:     out signed(15 downto 0)
    );
end  neuron;

architecture Behavioral of neuron is

signal tmp_reg: fixed_point;

begin

    process(data_i, weight_i)

    variable tmp: signed(15 downto 0);
    variable mult: signed(31 downto 0);

    begin

        mult := (others => '0');
        for i in 0 to 15 loop
            mult := mult + signed(weight_i(i)) * signed(data_i(i));
        end loop;
        tmp := mult(31) & mult(22 downto 8);

        tmp_reg <= tmp;
    end process;

	data_o <= tmp_reg;

end Behavioral;