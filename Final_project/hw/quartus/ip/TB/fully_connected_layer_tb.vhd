library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity fully_connected_layer_tb is
end fully_connected_layer_tb;

architecture behavioral of fully_connected_layer_tb is
    signal clk:           std_logic := '0';
    signal reset_n:       std_logic := '1';
    signal relu_read_i:   std_logic := '0';
    signal relu_data_i:   data_array_16bit;
    signal weight_read_i: std_logic := '0';
    signal start_i:       std_logic := '0';
    signal weight_cnt_i:  unsigned(3 downto 0) := (others => '0');
    signal weight_data_i: data_array_16bit;
    signal data_o:        data_array_3bit;

    component fully_connected_layer is
        port(
            clk:                in std_logic;
            reset_n:            in std_logic;
            relu_read_i:        in std_logic;
            relu_data_i:        in data_array_16bit;
            weight_read_i:      in std_logic;
            start_i:            in std_logic;
            weight_cnt_i:       in unsigned(3 downto 0);
            weight_data_i:      in data_array_16bit;
            data_o:             out data_array_3bit
        );
    end component;

    begin
        uut: fully_connected_layer
            port map (
                clk           => clk,
                reset_n       => reset_n,
                relu_read_i   => relu_read_i,
                relu_data_i   => relu_data_i,
                weight_read_i => weight_read_i,
                start_i       => start_i,
                weight_cnt_i  => weight_cnt_i,
                weight_data_i => weight_data_i,
                data_o        => data_o
            );

        clk <= not clk after 10 ns;

        stimulus_process: process
		begin
			-- Reset the system
			reset_n <= '0';
			wait for 20 ns;
			reset_n <= '1';
			wait for 10 ns;

			-- Provide some relu data
			relu_read_i <= '1';
			relu_data_i <= (2 => "0000000011111111", 
							1 => "0000000011111111", 
							0 => "0000000011111111",
							others => (others => '0'));
			wait for 20 ns;
			relu_read_i <= '0';

			-- Provide some weights
			weight_read_i <= '1';
			weight_data_i <= (2 => "0000000011111111", 
							  1 => "0000000011111111", 
							  0 => "0000000011111111",
							  others => (others => '0'));
			weight_cnt_i <= "0000";

			wait for 20 ns;

			weight_data_i <= (2 => "0000000011111111", 
							  1 => "0000000011111111", 
							  0 => "0000000011111111",
							  others => (others => '0'));
			weight_cnt_i <= "0001";

			wait for 20 ns;

			weight_data_i <= (2 => "0000000011111111", 
							  1 => "0000000011111111", 
							  0 => "0000000011111111",
							  others => (others => '0'));
			weight_cnt_i <= "0010";

			wait for 20 ns;
			weight_read_i <= '0';

			-- Start the computation
			start_i <= '1';
			wait for 20 ns;
			start_i <= '0';

			wait;
			end process stimulus_process;


end behavioral;
