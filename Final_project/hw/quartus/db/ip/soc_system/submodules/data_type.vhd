library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package data_type is

    subtype fixed_point is signed(15 downto 0); -- Q7.8 (signed)
    subtype double_fixed_point is signed(31 downto 0); -- -- S15.16 (signed)
	type data_array_49bit is array(48 downto 0) of fixed_point; -- size of convolutional window
    type data_array_16bit is array(15 downto 0) of fixed_point; -- size of input of NN
	type data_array_3bit is array(2 downto 0) of fixed_point; -- size of output of NN
    type data_matrix is array(2 downto 0) of data_array_16bit;

end package data_type;
