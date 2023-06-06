library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity fully_connected_layer is
    port(
        --Global signals
        clk:                in std_logic;
        reset_n:            in std_logic;
        --Relu signals
        relu_read_i:        in std_logic;
        relu_data_i:        in data_array_16bit;
        --DMA signals
        weight_read_i:      in std_logic;
        start_i:            in std_logic;
        weight_cnt_i:       in unsigned(3 downto 0);
        weight_data_i:      in data_array_16bit;
        --argmax signals
		write_o:	    	out std_logic;
        data_o:             out data_array_3bit
    );
end fully_connected_layer;

architecture Behavioral of fully_connected_layer is

    signal relu_data_reg:   data_array_16bit;
    signal weight_data_reg: data_matrix;

	signal write_reg:		std_logic;
    signal data_neurons:    data_array_3bit;
    signal data_reg:        data_array_3bit := (others => (others => '0'));

    component neuron is
        port(
            data_i:         in data_array_16bit;
            weight_i:       in data_array_16bit;
            data_o:         out fixed_point
        );
    end component;

    begin

        gen_neurons:
        for i in 0 to 2 generate
            n: neuron
            port map (
                data_i => relu_data_reg,
                weight_i => weight_data_reg(i),
                data_o => data_neurons(i)
            );
        end generate;

        process(clk, reset_n)
        begin
            if reset_n = '0' then
				write_reg <= '0';
                relu_data_reg <= (others => (others => '0'));
                for i in 0 to 2 loop
                    weight_data_reg(i) <= (others => (others => '0'));
                end loop;

            elsif rising_edge(clk) then
				write_reg <= '0';

                if relu_read_i = '1' then
                    for i in 0 to 15 loop
                        relu_data_reg(i) <= relu_data_i(i);
                    end loop;

                elsif weight_read_i = '1' then
                    for i in 0 to 15 loop
                        weight_data_reg(to_integer(weight_cnt_i))(i) <= weight_data_i(i);
                    end loop;
				end if;

                if start_i = '1' then
					write_reg <= '1';
                end if;

            end if;
        end process;
		
		process(data_neurons)
		begin
		
			for i in 0 to 2 loop
                data_reg(i) <= data_neurons(i);
            end loop;
		
		end process;

		data_o <= data_reg;
		write_o <= write_reg;

end Behavioral;