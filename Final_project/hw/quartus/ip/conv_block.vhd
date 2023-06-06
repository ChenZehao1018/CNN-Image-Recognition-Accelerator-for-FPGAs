library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity conv_block is
    port(
        --Global signals
        clk               : in std_logic;
        reset_n           : in std_logic;
        --DMA Interface
        image_read_i      : in std_logic;
        image_start_i     : in std_logic;
        image_data_i      : in data_array_49bit;
        image_cnt_i       : in unsigned(3 downto 0); --Counts to 16 windows within image
        --NN Interface
        relu_regs_ready_o : out std_logic;
        convolved_regs_o  : out data_array_16bit
    );
end conv_block;

architecture Behavioral of conv_block is

    component conv_filter
        port(
            -- Convolution Block Interface
            image_read_i    : in std_logic;
            image_start_i   : in std_logic;
            image_data_i    : in data_array_49bit;
            convolved_res_o : out fixed_point
        );
    end component;

    component ReLU
        port(
            data_i     : in fixed_point;
            relu_res_o : out fixed_point
        );
    end component;

	signal relu_regs_ready_reg: std_logic;
    signal convolved_res : fixed_point := (others => '0');
    signal relu_res      : fixed_point := (others => '0');
    signal conv_regs     : data_array_16bit; -- Regs that contain result of convolution and ReLU

begin

    conv_filter_inst : conv_filter port map(
        --DMA Interface
        image_read_i    => image_read_i,
        image_start_i   => image_start_i,
        image_data_i    => image_data_i,
        --ReLU Interface
        convolved_res_o => convolved_res
    );

    ReLU_inst : ReLU port map(
        -- Convolution filter Interface
        data_i     => convolved_res,
        --NN Interface
        relu_res_o => relu_res
    );

    regs : process(reset_n, clk)
    begin
        if reset_n = '0' then
			relu_regs_ready_reg <= '0';
            conv_regs <= (others => (others => '0'));
        elsif rising_edge(clk) then
			relu_regs_ready_reg <= '0';
            if image_read_i = '1' then
                if image_cnt_i >= 0 and image_cnt_i <= 15 then --check that it fits in the array
                    conv_regs(to_integer(image_cnt_i)) <= relu_res;
                end if;

                if image_start_i = '1' then --signal that all convolutions have been computed !!! might need to be the cycle after
                    relu_regs_ready_reg <= '1';
                end if;
            end if;
        end if;
    end process regs;

    convolved_regs_o <= conv_regs;
	relu_regs_ready_o <= relu_regs_ready_reg;

end Behavioral;