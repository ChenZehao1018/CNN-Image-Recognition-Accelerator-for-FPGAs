library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity dma_tb is
end dma_tb;

architecture Behavioral of dma_tb is
    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';
    
    --Register Map Interface
    signal start_image_i: std_logic := '0';
    signal start_weight_i: std_logic := '0';
    signal image_addr_i: std_logic_vector(31 downto 0) := (others => '0');
    signal image_length_i: std_logic_vector(31 downto 0) := (others => '0');
    signal weight_addr_i: std_logic_vector(31 downto 0) := (others => '0');
    signal weight_length_i: std_logic_vector(31 downto 0) := (others => '0');
    
    --Avalon Master (AM) interface
    signal am_address : std_logic_vector(31 downto 0);
    signal am_burstcount : std_logic_vector(6 downto 0);
    signal am_read : std_logic;
    signal am_readdatavalid : std_logic := '0';
    signal am_readdata : std_logic_vector(15 downto 0);
    signal am_waitrequest : std_logic := '0';

    --Convolution Block Interface
    signal image_write_o: std_logic;
    signal image_start_o: std_logic;
    signal image_cnt_o: unsigned(3 downto 0);
    signal image_data_o: data_array_49bit;

    --Fully Connect Layer Interface
    signal weight_write_o: std_logic;
    signal weight_start_o: std_logic;
    signal weight_cnt_o: unsigned(3 downto 0);
    signal weight_data_o: data_array_16bit;

    component dma is
        port(
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
    end component;

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin
    DUT : dma
        port map(
            clk => clk,
            reset_n => reset_n,
            start_image_i => start_image_i,
            start_weight_i => start_weight_i,
            image_addr_i => image_addr_i,
            image_length_i => image_length_i,
            weight_addr_i => weight_addr_i,
            weight_length_i => weight_length_i,
            am_address => am_address,
            am_burstcount => am_burstcount,
            am_read => am_read,
            am_readdatavalid => am_readdatavalid,
            am_readdata => am_readdata,
            am_waitrequest => am_waitrequest,
            image_write_o => image_write_o,
	    image_start_o => image_start_o,
	    image_cnt_o => image_cnt_o,
            image_data_o => image_data_o,
            weight_write_o => weight_write_o,
            weight_start_o => weight_start_o,
            weight_cnt_o => weight_cnt_o,
            weight_data_o => weight_data_o
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
		reset_n <= '0';
        wait for clk_period;
		
		reset_n <= '1';
        wait for clk_period;
		
		-- Insert stimulus here
		-- Start the reading of image
		start_image_i <= '1';
		am_waitrequest <= '0';
		image_addr_i <= std_logic_vector(to_unsigned(10, image_addr_i'length));
		image_length_i <= std_logic_vector(to_unsigned(4, image_length_i'length));
		wait for clk_period;
		
		start_image_i <= '0';  -- Clear the start signal
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for clk_period;
		
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for clk_period;
		
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for clk_period;
		
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for (clk_period*7);

		-- Start the reading of weight
		start_weight_i <= '1';
		weight_addr_i <= std_logic_vector(to_unsigned(20, weight_addr_i'length));
		weight_length_i <= std_logic_vector(to_unsigned(4, weight_length_i'length));
		wait for clk_period;

		start_weight_i <= '0';  -- Clear the start signal
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for clk_period;
		
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for clk_period;
		
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for clk_period;
		
		am_readdata <= std_logic_vector(to_unsigned(255, am_readdata'length));
		am_readdatavalid <= '1';
		wait for clk_period;


        -- insert stimulus here 
        wait;
    end process;
end Behavioral;
