library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity register_map is
    port(
        clk:                    in std_logic;
        reset_n:                in std_logic;

        -- Avalon Slave interface
        as_address:             in std_logic_vector(2 downto 0);
        as_read:                in std_logic;
        as_readdata:            out std_logic_vector(31 downto 0) := (others => '0');
        as_write:               in std_logic;
        as_writedata:           in std_logic_vector(31 downto 0);

        -- signals to dma
        start_image_o:          out std_logic;
        start_weight_o:         out std_logic;
        image_addr_o:           out std_logic_vector(31 downto 0);
        image_length_o:         out std_logic_vector(31 downto 0);
        weight_addr_o:          out std_logic_vector(31 downto 0);
        weight_length_o:        out std_logic_vector(31 downto 0);

        -- Output Interface
		predictions_i	: in data_array_3bit;
        prediction_i    : in std_logic_vector(31 downto 0)
    );
end register_map;

architecture Behavioral of register_map is

    signal start_image_reg:     std_logic;
    signal start_weight_reg:    std_logic;
    signal image_addr_reg:      std_logic_vector(31 downto 0);
    signal image_length_reg:    std_logic_vector(31 downto 0);
    signal weight_addr_reg:     std_logic_vector(31 downto 0);
    signal weight_length_reg:   std_logic_vector(31 downto 0);
	signal prediction0_reg:		std_logic_vector(31 downto 0);
	signal prediction1_reg:		std_logic_vector(31 downto 0);
	signal prediction2_reg:		std_logic_vector(31 downto 0);

begin

-------------------------------------------------------------------------------
-- CONTROL AND STATUS REGISTERS
-------------------------------------------------------------------------------

-- control and status registers
--
-- address map
--  000             			0x00
--  001                     		0x04
--  010                 		0x08
--  011                			0x0C
--  100             			0X10
--  101                     		0X14
--  110             			0X18
-------------------------------------------------------------------------------


    -- Avalon Slave write
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            start_image_reg <= '0';
			start_weight_reg <= '0';
        elsif rising_edge(clk) then
            start_image_reg <= '0';
			start_weight_reg <= '0';
			prediction0_reg <= X"0000" & std_logic_vector(predictions_i(0));
			prediction1_reg <= X"0000" & std_logic_vector(predictions_i(1));
			prediction2_reg <= X"0000" & std_logic_vector(predictions_i(2));
            if as_write = '1' then
                case as_address is
                    when "000" => start_image_reg <= as_writedata(0);
                    when "001" => start_weight_reg <= as_writedata(0);
                    when "010" => image_addr_reg <= as_writedata;
                    when "011" => image_length_reg <= as_writedata;
                    when "100" => weight_addr_reg <= as_writedata;
                    when "101" => weight_length_reg <= as_writedata;
					when "110" => null;
					when others => null;
                end case;
            end if;
        end if;
    end process;

    --Avalon Slave read
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            as_readdata <= (others => '0');
        elsif rising_edge(clk) then
            if as_read = '1' then
                case as_address is
                    when "000" => as_readdata <= prediction_i;
                    when "001" => as_readdata <= prediction0_reg;
                    when "010" => as_readdata <= image_addr_reg;
                    when "011" => as_readdata <= image_length_reg;
                    when "100" => as_readdata <= weight_addr_reg;
                    when "101" => as_readdata <= weight_length_reg;
					when "110" => as_readdata <= prediction1_reg;
					when "111" => as_readdata <= prediction2_reg;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    start_image_o <= start_image_reg;
    start_weight_o <= start_weight_reg;
    image_addr_o <= image_addr_reg;
    weight_addr_o <= weight_addr_reg;
    image_length_o <= image_length_reg;
    weight_length_o <= weight_length_reg;
    
end Behavioral;