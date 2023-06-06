library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity conv_filter_tb is
-- Testbench has no ports
end conv_filter_tb;

architecture Behavioral of conv_filter_tb is

    -- component declaration for the unit under test
    component conv_filter
    port(
        --Convolution Block Interface
        image_read_i    : in std_logic;
        image_start_i   : in std_logic;
        image_data_i    : in data_array_49bit;
        convolved_res_o : out fixed_point
    );
    end component;

    -- input and output signals for unit under test
    signal tb_read_o       : std_logic;
    signal tb_start_o      : std_logic;
    signal tb_image_data_o : data_array_49bit;
    signal tb_result_i     : fixed_point;

begin
    -- instantiate unit under test
    uut: conv_filter
    port map(
        --Convolution Block Interface
        image_read_i  => tb_read_o,
        image_start_i => tb_start_o,
        image_data_i  => tb_image_data_o,
        convolved_res_o => tb_result_i
    );

    -- testbench stimulus process
    stimulus_proc: process
    begin
        -- Initialise to 0
        for i in tb_image_data_o'range loop
            tb_image_data_o(i)   <= to_signed(0, 16);
        end loop;
        tb_start_o <= '1';
        tb_read_o  <= '1';
        wait for 5 ns;
        tb_start_o <= '0';
        tb_read_o  <= '0';
        wait for 5 ns;

        -- Put 1 in each pixel
        for i in tb_image_data_o'range loop
            tb_image_data_o(i)   <= to_signed(1, 16);
        end loop;
        tb_start_o <= '1';
        tb_read_o  <= '1';
        wait for 5 ns;
        tb_start_o <= '0';
        tb_read_o  <= '0';
        wait for 5 ns;

        -- Put value of i in each pixel
        for i in tb_image_data_o'range loop
            tb_image_data_o(i)   <= to_signed(i, 16);
        end loop;
        tb_start_o <= '1';
        tb_read_o  <= '1';
        wait for 5 ns;
        tb_start_o <= '0';
        tb_read_o  <= '0';
        wait for 5 ns;

        wait;
    end process;
end Behavioral;
