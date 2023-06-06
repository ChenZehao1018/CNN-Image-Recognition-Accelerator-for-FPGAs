library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity conv_filter is
    port(
        --Convolution Block Interface
        image_read_i    : in std_logic;
        image_start_i   : in std_logic;
        image_data_i    : in data_array_49bit;
        convolved_res_o : out fixed_point
    );
end conv_filter;

architecture Behavioral of conv_filter is

signal conv_reg: fixed_point;
constant conv_weights : data_array_49bit := (X"0121", X"FFF9", X"FFFC", X"0073", X"0053", X"0027", X"001D", 
											 X"00B0", X"FFC3", X"0017", X"0031", X"FFD5", X"FFD5", X"0031", 
											 X"0132", X"0016", X"0032", X"0029", X"001D", X"FFE5", X"0017", 
											 X"0181", X"001F", X"0055", X"0008", X"FFED", X"FFC4", X"0005", 
											 X"01D2", X"0042", X"0026", X"0004", X"FFD2", X"FFE0", X"0016", 
											 X"0120", X"0037", X"0007", X"FFA9", X"FFE5", X"FF94", X"FFBE", 
											 X"0088", X"0024", X"00E8", X"005F", X"0049", X"FFBB", X"FEDF");
constant conv_bias : double_fixed_point := X"0001_DA4C";

begin

    conv_filter: process(image_read_i, image_start_i)

    variable tmp: fixed_point;
    variable conv_res: double_fixed_point;

    begin
        conv_res := conv_bias;

        for i in 0 to (conv_weights'length)-1 loop
            conv_res := conv_res + signed(conv_weights(i)) * signed(image_data_i(i));
        end loop;

        conv_reg <= conv_res(31) & conv_res(22 downto 8);
    end process conv_filter;

    convolved_res_o <= conv_reg;

end Behavioral;