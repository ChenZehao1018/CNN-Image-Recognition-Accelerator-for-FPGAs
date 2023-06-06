library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity ReLU is
    port(
        data_i     : in fixed_point := (others => '0');
        relu_res_o : out fixed_point
    );
end ReLU;

architecture Behavioral of ReLU is
    signal relu_res_reg: fixed_point := (others => '0');
begin
    process(data_i)
    begin
        if data_i >= 0 then
            relu_res_reg <= data_i;
        else
            relu_res_reg <= (others => '0');
        end if;
    end process;

    relu_res_o <= relu_res_reg;
end Behavioral;
