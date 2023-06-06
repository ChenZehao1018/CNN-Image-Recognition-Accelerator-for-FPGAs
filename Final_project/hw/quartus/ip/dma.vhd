library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity dma is
    port(
        --Global signals
        clk : in std_logic;
        reset_n : in std_logic;

        --Register Map Interface
        start_image_i: in std_logic;
        start_weight_i: in std_logic;
        image_addr_i: in std_logic_vector(31 downto 0);
        image_length_i: in std_logic_vector(31 downto 0);
        weight_addr_i: in std_logic_vector(31 downto 0);
        weight_length_i: in std_logic_vector(31 downto 0);

        --Avalon Master (AM) interface
        am_address : out std_logic_vector(31 downto 0);
        am_burstcount : out std_logic_vector(6 downto 0);
        am_read : out std_logic;
        am_readdatavalid : in std_logic;
        am_readdata : in std_logic_vector(15 downto 0);
        am_waitrequest : in std_logic;

        --Convolution Block Interface
        image_write_o: out std_logic;
        image_start_o: out std_logic;
	    image_cnt_o: out unsigned(3 downto 0);
        image_data_o: out data_array_49bit;

        --Fully Connect Layer Interface
        weight_write_o: out std_logic;
        weight_start_o: out std_logic;
        weight_cnt_o: out unsigned(3 downto 0);
        weight_data_o: out data_array_16bit
);
end dma;

architecture Behavioral of dma is

    constant burst_size_image: positive := 49;
    constant burst_size_weight: positive := 16;

type state_type is (IDLE, BurstImageStart, BurstImageWait, BurstImageRead, BurstWeightStart, BurstWeightWait, BurstWeightRead);

--Internal Registers
signal state_reg, state_next : state_type;

signal image_data_reg, image_data_next : data_array_49bit;
signal image_addr_reg, image_addr_next : unsigned(31 downto 0);
signal image_length_reg, image_length_next : unsigned(31 downto 0);
signal image_cnt_reg, image_cnt_next: unsigned(3 downto 0);
signal image_write_reg, image_write_next: std_logic;
signal image_start_reg, image_start_next: std_logic;

signal weight_data_reg, weight_data_next : data_array_16bit;
signal weight_addr_reg, weight_addr_next: unsigned(31 downto 0);
signal weight_length_reg, weight_length_next: unsigned(31 downto 0);
signal weight_cnt_reg, weight_cnt_next: unsigned(3 downto 0);
signal weight_write_reg, weight_write_next: std_logic;
signal weight_start_reg, weight_start_next: std_logic;

signal address_reg, address_next : std_logic_vector(31 downto 0);
signal burstcount_out_reg, burstcount_out_next : std_logic_vector(6 downto 0);
signal burstcount_reg, burstcount_next : unsigned(8 downto 0);
signal read_reg, read_next : std_logic;

signal word_cnt_reg, word_cnt_next : unsigned(16 downto 0);
signal burst_cnt_image_reg, burst_cnt_image_next : unsigned(8 downto 0);
signal burst_cnt_weight_reg, burst_cnt_weight_next : unsigned(8 downto 0);

begin
        am_address <= address_reg;
        am_burstcount <= burstcount_out_reg;
        am_read <= read_reg;

        image_write_o <= image_write_reg;
        image_start_o <= image_start_reg;
 	    image_cnt_o <= image_cnt_reg;
        image_data_o <= image_data_reg;

        weight_write_o <= weight_write_reg;
        weight_start_o <= weight_start_reg;
        weight_cnt_o <= weight_cnt_reg;
        weight_data_o <= weight_data_reg;


    process(clk,reset_n)
    begin
        if reset_n = '0' then
            state_reg <= IDLE;
            image_data_reg <= (others => (others => '0'));
            image_addr_reg <= (others => '0');
            image_length_reg <= (others => '0');
	        image_cnt_reg <= (others => '1');
            image_write_reg <= '0';
            image_start_reg <= '0';

            weight_data_reg <= (others => (others => '0'));
            weight_addr_reg <= (others => '0');
            weight_length_reg <= (others => '0');
            weight_cnt_reg <= (others => '1');
            weight_write_reg <= '0';
            weight_start_reg <= '0';

            address_reg <= (others => '0');
            burstcount_out_reg <= (others => '0');
            burstcount_reg <= (others => '0');
            read_reg <= '0';

            word_cnt_reg <= (others => '0');
	        burst_cnt_image_reg <= (others => '0');
            burst_cnt_weight_reg <= (others => '0');



        elsif rising_edge(clk) then
            state_reg <= state_next;
            image_data_reg <= image_data_next;
            image_addr_reg <= image_addr_next;
            image_length_reg <= image_length_next;
	        image_cnt_reg <= image_cnt_next;
            image_write_reg <= image_write_next;
            image_start_reg <= image_start_next;

            weight_data_reg <= weight_data_next;
            weight_addr_reg <= weight_addr_next;
            weight_length_reg <= weight_length_next;
            weight_cnt_reg <= weight_cnt_next;
            weight_write_reg <= weight_write_next;
            weight_start_reg <= weight_start_next;

            address_reg <= address_next;
            burstcount_out_reg <= burstcount_out_next;
            burstcount_reg <= burstcount_next;
            read_reg <= read_next;

            word_cnt_reg <= word_cnt_next;
	        burst_cnt_image_reg <= burst_cnt_image_next;
            burst_cnt_weight_reg <= burst_cnt_weight_next;
        end if;
    end process;


    AM:process(state_reg, start_image_i, start_weight_i, am_waitrequest, burst_cnt_weight_reg, word_cnt_reg, am_readdatavalid)
    begin
        state_next <= state_reg;
        image_data_next <= image_data_reg;
        image_addr_next <= image_addr_reg;
        image_length_next <= image_length_reg;
	    image_cnt_next <= image_cnt_reg;
        image_write_next <= image_write_reg;
        image_start_next <= image_start_reg;

        weight_data_next <= weight_data_reg;
        weight_addr_next <= weight_addr_reg;
        weight_length_next <= weight_length_reg;
        weight_cnt_next <= weight_cnt_reg;
        weight_write_next <= weight_write_reg;
        weight_start_next <= weight_start_reg;

        address_next <= address_reg;
        burstcount_out_next <= burstcount_out_reg;
        burstcount_next <= burstcount_reg;
        read_next <= read_reg;

        word_cnt_next <= word_cnt_reg;
	    burst_cnt_image_next <= burst_cnt_image_reg;
        burst_cnt_weight_next <= burst_cnt_weight_reg;

        case state_reg is
            when IDLE =>
            state_next <= IDLE;
            image_data_next <= (others => (others => '0'));
            image_addr_next <= (others => '0');
            image_length_next <= (others => '0');
	        image_cnt_next <= (others => '1');
            image_write_next <= '0';
            image_start_next <= '0';

            weight_data_next <= (others => (others => '0'));
            weight_addr_next <= (others => '0');
            weight_length_next <= (others => '0');
            weight_cnt_next <= (others => '1');
            weight_write_next <= '0';
            weight_start_next <= '0';

            address_next <= (others => '0');
            burstcount_out_next <= (others => '0');
            burstcount_next <= (others => '0');
            read_next <= '0';

            word_cnt_next <= (others => '0');
	        burst_cnt_image_next <= (others => '0');
            burst_cnt_weight_next <= (others => '0');

                if start_image_i = '1' then
                    image_addr_next <= unsigned(image_addr_i);
                    image_length_next <= unsigned(image_length_i);
                    burstcount_next(6 downto 0) <= to_unsigned(burst_size_image, 7);
                    state_next <= BurstImageStart;
                elsif start_weight_i = '1' then
                    weight_addr_next <= unsigned(weight_addr_i);
                    weight_length_next <= unsigned(weight_length_i);
                    burstcount_next(6 downto 0) <= to_unsigned(burst_size_weight, 7);
                    state_next <= BurstWeightStart;
                end if;

            when BurstImageStart =>
		        image_write_next <= '0';
                read_next <= '1';
                address_next <= std_logic_vector(image_addr_reg);
                burstcount_out_next <= std_logic_vector(burstcount_reg(6 downto 0));
                state_next <= BurstImageWait;

            when BurstImageWait =>
                if am_waitrequest = '1' then
                    state_next <= BurstImageWait;
                else
                    read_next <= '0';
                    burstcount_out_next <= (others => '0');
                    state_next <= BurstImageRead;
                end if;

            when BurstImageRead =>
                if am_readdatavalid = '1' then
                    image_data_next(to_integer(burst_cnt_image_reg)) <= signed(am_readdata);
		            burst_cnt_image_next <= burst_cnt_image_reg + 1;
                    word_cnt_next <= word_cnt_reg + 1;

                    if word_cnt_reg = image_length_reg - 1 or burstcount_reg = 0 then -- whole transfer finished
                        image_start_next <= '1';
			            image_write_next <= '1';
						image_cnt_next <= image_cnt_reg + 1;
                        state_next <= IDLE;

		    elsif burst_cnt_image_reg = burstcount_reg(6 downto 0) - 1 then -- one burst done
                        image_addr_next <= image_addr_reg + burstcount_reg;
                        burst_cnt_image_next <= (others => '0');
                        word_cnt_next <= word_cnt_reg + 1;
                        image_cnt_next <= image_cnt_reg + 1;
                        image_write_next <= '1';
                        state_next <= BurstImageStart;
                    end if;
                else
                    state_next <= BurstImageRead;
                end if;

            when BurstWeightStart =>
		        weight_write_next <= '0';
                read_next <= '1';
                address_next <= std_logic_vector(weight_addr_reg);
                burstcount_out_next <= std_logic_vector(burstcount_reg(6 downto 0));
                state_next <= BurstWeightWait;

            when BurstWeightWait =>
                if am_waitrequest = '1' then
                    state_next <= BurstWeightWait;
                else
                    read_next <= '0';
                    burstcount_out_next <= (others => '0');
                    state_next <= BurstWeightRead;
                end if;

            when BurstWeightRead =>
                if am_readdatavalid = '1' then
                    weight_data_next(to_integer(burst_cnt_weight_reg)) <= signed(am_readdata);
                    burst_cnt_weight_next <= burst_cnt_weight_reg + 1;
                    word_cnt_next <= word_cnt_reg + 1;

                    if word_cnt_reg = weight_length_reg - 1 or burstcount_reg = 0 then -- whole transfer finished
                        weight_start_next <= '1';
			            weight_write_next <= '1';
						weight_cnt_next <= weight_cnt_reg + 1;
                        state_next <= IDLE;

                    elsif burst_cnt_weight_reg = burstcount_reg(6 downto 0) - 1 then -- one burst done
                        weight_addr_next <= weight_addr_reg + burstcount_reg;
                        burst_cnt_weight_next <= (others => '0');
                        word_cnt_next <= word_cnt_reg + 1;
                        weight_cnt_next <= weight_cnt_reg + 1;
                        weight_write_next <= '1';
                        state_next <= BurstWeightStart;
                    end if;
                else
                    state_next <= BurstWeightRead;
                end if;

            when others => null;

        end case;
    end process;



end Behavioral;