library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity CNN_accelerator is
    port(
        --Global signals
        clk              : in std_logic;
        reset_n          : in std_logic;

        -- Avalon Slave interface
        as_address       : in std_logic_vector(2 downto 0);
        as_read          : in std_logic;
        as_readdata      : out std_logic_vector(31 downto 0) := (others => '0');
        as_write         : in std_logic;
        as_writedata     : in std_logic_vector(31 downto 0);

        --Avalon Master (AM) interface
        am_address       : out std_logic_vector(31 downto 0);
        am_burstcount    : out std_logic_vector(6 downto 0);
        am_read          : out std_logic;
        am_readdatavalid : in std_logic;
        am_readdata      : in std_logic_vector(15 downto 0);
        am_waitrequest   : in std_logic
);
end CNN_accelerator;

architecture Behavioral of CNN_accelerator is

    -- Register Map <-> DMA Interface
    signal start_image   : std_logic;
    signal start_weight  : std_logic;
    signal image_addr    : std_logic_vector(31 downto 0);
    signal image_length  : std_logic_vector(31 downto 0);
    signal weight_addr   : std_logic_vector(31 downto 0);
    signal weight_length : std_logic_vector(31 downto 0);

    -- Convolution Block <-> DMA Interface
    signal image_write : std_logic;
    signal image_start : std_logic;
    signal image_cnt   : unsigned(3 downto 0);
    signal image_data  : data_array_49bit;

    -- NN <-> DMA Interface
    signal weight_write : std_logic;
    signal weight_start : std_logic;
    signal weight_cnt   : unsigned(3 downto 0);
    signal weight_data  : data_array_16bit;

    -- Convolution Block <-> NN Interface
    signal relu_regs_ready : std_logic;
    signal relu_res_regs   : data_array_16bit;
	
	-- NN Interface <-> ARGMAX Interface
	signal predictions	   		: data_array_3bit;
	signal predictions_ready	: std_logic;

    -- ARGMAX Interface <-> REGSTER MAP Interface
    signal prediction  : std_logic_vector(31 downto 0);
	

    component register_map
        port(
            clk             : in std_logic;
            reset_n         : in std_logic;
            -- Avalon Slave interface
            as_address      : in std_logic_vector(2 downto 0);
            as_read         : in std_logic;
            as_readdata     : out std_logic_vector(31 downto 0) := (others => '0');
            as_write        : in std_logic;
            as_writedata    : in std_logic_vector(31 downto 0);
            -- DMA Interface
            start_image_o   : out std_logic;
            start_weight_o  :     out std_logic;
            image_addr_o    : out std_logic_vector(31 downto 0);
            image_length_o  : out std_logic_vector(31 downto 0);
            weight_addr_o   : out std_logic_vector(31 downto 0);
            weight_length_o : out std_logic_vector(31 downto 0);
            -- Output Interface
			predictions_i	: in data_array_3bit;
            prediction_i    : in std_logic_vector(31 downto 0)
        );
    end component;

    component dma
        port(
            --Global signals
            clk              : in std_logic;
            reset_n          : in std_logic;

            --Register Map Interface
            start_image_i    : in std_logic;
            start_weight_i   : in std_logic;
            image_addr_i     : in std_logic_vector(31 downto 0);
            image_length_i   : in std_logic_vector(31 downto 0);
            weight_addr_i    : in std_logic_vector(31 downto 0);
            weight_length_i  : in std_logic_vector(31 downto 0);

            --Avalon Master (AM) interface
            am_address       : out std_logic_vector(31 downto 0);
            am_burstcount    : out std_logic_vector(6 downto 0);
            am_read          : out std_logic;
            am_readdatavalid : in std_logic;
            am_readdata      : in std_logic_vector(15 downto 0);
            am_waitrequest   : in std_logic;

            --Convolution Block Interface
            image_write_o    : out std_logic;
            image_start_o    : out std_logic;
            image_cnt_o      : out unsigned(3 downto 0);
            image_data_o     : out data_array_49bit;

            --Fully Connect Layer Interface
            weight_write_o   : out std_logic;
            weight_start_o   : out std_logic;
            weight_cnt_o     : out unsigned(3 downto 0);
            weight_data_o    : out data_array_16bit
        );
    end component;

    component conv_block is
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
    end component;

    component fully_connected_layer
        port(
            --Global signals
            clk           : in std_logic;
            reset_n       : in std_logic;
            --Relu signals
            relu_read_i   : in std_logic;
            relu_data_i   : in data_array_16bit;
            --DMA signals
            weight_read_i : in std_logic;
            start_i       : in std_logic;
            weight_cnt_i  : in unsigned(3 downto 0);
            weight_data_i : in data_array_16bit;
            --Prediction output
			write_o		  : out std_logic;
            data_o        : out data_array_3bit
        );
    end component;

    component argmax
        port(
			--Global signals
			clk:		  in std_logic;
			reset_n:	  in std_logic;
			--NN signals
			read_i:	      in std_logic;
            data_i:       in data_array_3bit;
			--REGSTER MAP signals
            data_o:       out std_logic_vector(31 downto 0)
        );
    end component;

begin

    register_inst : register_map port map(
        clk             => clk,
        reset_n         => reset_n,
        -- Avalon Slave interface
        as_address      => as_address,
        as_read         => as_read,
        as_readdata     => as_readdata,
        as_write        => as_write,
        as_writedata    => as_writedata,
        -- DMA interface
        start_image_o   => start_image,
        start_weight_o  => start_weight,
        image_addr_o    => image_addr,
        image_length_o  => image_length,
        weight_addr_o   => weight_addr,
        weight_length_o => weight_length,
        -- Output Interface
		predictions_i	   => predictions,
        prediction_i   => prediction
    );

    dma_inst : dma port map(
        clk              => clk,
        reset_n          => reset_n,

        -- Register Map Interface
        start_image_i    => start_image,
        start_weight_i   => start_weight,
        image_addr_i     => image_addr,
        image_length_i   => image_length,
        weight_addr_i    => weight_addr,
        weight_length_i  => weight_length,

        --Avalon Master (AM) Interface
        am_address       => am_address,
        am_burstcount    => am_burstcount,
        am_read          => am_read,
        am_readdatavalid => am_readdatavalid,
        am_readdata      => am_readdata,
        am_waitrequest   => am_waitrequest,

        --Convolution Block Interface
        image_write_o    => image_write,
        image_start_o    => image_start,
        image_cnt_o      => image_cnt,
        image_data_o     => image_data,

        --Fully Connect Layer Interface
        weight_write_o   => weight_write,
        weight_start_o   => weight_start,
        weight_cnt_o     => weight_cnt,
        weight_data_o    => weight_data
    );

    conv_block_inst : conv_block port map(
        --Global signals
        clk               => clk,
        reset_n           => reset_n,
        --DMA Interface
        image_read_i      => image_write,
        image_start_i     => image_start,
        image_data_i      => image_data,
        image_cnt_i       => image_cnt,--Counts to 16 windows within image
        --NN Interface
        relu_regs_ready_o => relu_regs_ready,
        convolved_regs_o  => relu_res_regs
    );

    NN_inst : fully_connected_layer port map(
        --Global signals
        clk           => clk,
        reset_n       => reset_n,
        --Conv block signals
        relu_read_i   => relu_regs_ready,
        relu_data_i   => relu_res_regs,
        --DMA signals
        weight_read_i => weight_write,
        start_i       => weight_start,
        weight_cnt_i  => weight_cnt,
        weight_data_i => weight_data,
        --Prediction output
        data_o        => predictions,
		write_o		  => predictions_ready
    );

    argmax_inst : argmax port map(
		--Global signals
		clk => clk,
		reset_n       => reset_n,
		--NN Interface 
        data_i => predictions,
		read_i => predictions_ready,
		--REGSTER Interface
        data_o => prediction
    );

end Behavioral;