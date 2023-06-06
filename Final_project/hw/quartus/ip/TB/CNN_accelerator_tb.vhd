library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity CNN_accelerator_tb is
end CNN_accelerator_tb;

architecture sim of CNN_accelerator_tb is

component CNN_accelerator
    port(
        clk              : in std_logic;
        reset_n          : in std_logic;
        as_address       : in std_logic_vector(2 downto 0);
        as_read          : in std_logic;
        as_readdata      : out std_logic_vector(31 downto 0);
        as_write         : in std_logic;
        as_writedata     : in std_logic_vector(31 downto 0);
        am_address       : out std_logic_vector(31 downto 0);
        am_burstcount    : out std_logic_vector(6 downto 0);
        am_read          : out std_logic;
        am_readdatavalid : in std_logic;
        am_readdata      : in std_logic_vector(15 downto 0);
        am_waitrequest   : in std_logic
    );
end component;

signal clk               : std_logic := '0';
signal reset_n           : std_logic := '0';
signal as_address        : std_logic_vector(2 downto 0);
signal as_read           : std_logic;
signal as_readdata       : std_logic_vector(31 downto 0);
signal as_write          : std_logic;
signal as_writedata      : std_logic_vector(31 downto 0);
signal am_address        : std_logic_vector(31 downto 0);
signal am_burstcount     : std_logic_vector(6 downto 0);
signal am_read           : std_logic;
signal am_readdatavalid  : std_logic;
signal am_readdata       : std_logic_vector(15 downto 0);
signal am_waitrequest    : std_logic;

constant clk_period : time := 10 ns;
type array_type_784 is array(783 downto 0) of std_logic_vector(15 downto 0);
type array_type_47 is array(47 downto 0) of std_logic_vector(15 downto 0);
constant image_data : array_type_784 := 
(X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0018", X"00E2", X"00C8", X"0000", X"0000", X"0000", X"0000", X"002A", X"00FC", X"00FC", X"0000", X"0000", X"0000", X"0000", X"0004", X"0087", X"00FB", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0032", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0078", X"0000", X"0000", X"0000", X"0000", X"0015", X"0054", X"00F7", X"0064", X"0000", X"0010", X"0076", X"00C9", X"00FD", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0054", X"0054", X"0054", X"0054", X"0054", X"0000", X"0000", X"00FC", X"00FC", X"00FC", X"00FC", X"00FD", X"00C1", X"0000", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"00A1", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"001E", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0005", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0015", 
 X"00FC", X"00FD", X"00A8", X"00E7", X"00FC", X"00FC", X"00FD", X"00DA", X"0100", X"00FD", X"00FD", X"00FD", X"00E3", X"0069", X"00A8", X"00FD", X"00FC", X"00FC", X"00FC", X"00FC", X"00A5", X"0085", X"00FD", X"00FC", X"00FC", X"00FC", X"00FC", X"00FD", X"009F", X"00FD", X"00D7", X"0016", X"004A", X"0099", X"00E9", X"00BD", X"00FD", X"008D", X"0000", X"0000", X"0000", X"0000", X"00FD", X"0100", X"006B", X"0000", X"0000", X"0000", X"0000", 
 X"00FC", X"00FC", X"00FC", X"00FC", X"00FD", X"00D3", X"0000", X"002B", X"002B", X"0033", X"00DA", X"00FE", X"00D4", X"0000", X"0093", X"0093", X"00F4", X"00FC", X"00FD", X"00B1", X"0000", X"00FC", X"00FC", X"00FC", X"00FC", X"00DA", X"0000", X"0000", X"00E8", X"00E8", X"00B4", X"007F", X"004B", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0009", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 
 X"00CB", X"00FD", X"006A", X"0000", X"0000", X"0000", X"0000", X"00A8", X"00FD", X"006A", X"0000", X"0000", X"0000", X"0000", X"00A8", X"00FD", X"009E", X"0000", X"0000", X"0000", X"0000", X"008E", X"00FD", X"00D3", X"0000", X"0000", X"0000", X"0000", X"0025", X"00ED", X"00E5", X"001B", X"0000", X"0000", X"0000", X"0000", X"0059", X"00FC", X"00D9", X"000D", X"0000", X"0000", X"0000", X"0000", X"00B6", X"00FC", X"008E", X"001C", X"0000", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0018", X"00E2", X"0000", X"0000", X"0000", X"0000", X"0046", X"00C7", X"00FC", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0061", X"0096", X"003E", X"0000", X"0000", X"0000", X"0000", X"00FC", X"00FC", X"0094", X"0000", X"0000", X"0000", X"0000", X"00FC", X"00C5", X"0037", X"0000", X"0000", X"0000", X"0000", 
 X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 
 X"0000", X"0000", X"0015", X"00D4", X"00FC", X"00EE", X"0090", X"0000", X"0000", X"0000", X"001C", X"00BA", X"00FC", X"00FD", X"0000", X"0000", X"0000", X"0000", X"0004", X"0071", X"00C1", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 
 X"0015", X"0015", X"0015", X"00A0", X"00FA", X"00FC", X"00F6", X"00FC", X"00FC", X"00FC", X"00FC", X"00FD", X"00C7", X"0039", X"00FD", X"00FD", X"00FD", X"00E3", X"0069", X"0012", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 
 X"0080", X"0008", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000");

constant weight_data : array_type_47 := 
(X"FF0F", X"0038", X"FFE4", X"FFE9", X"0044", X"00B3", X"004E", X"0095", X"0008", X"0003", X"FF9D", X"0010", X"FE48", X"FFBA", X"008C", X"FFC3", 
 X"012A", X"FFC7", X"FFB8", X"0034", X"006D", X"FE6C", X"003E", X"FF6C", X"FFED", X"FF6F", X"0005", X"FF9B", X"015F", X"FFD6", X"FF60", X"0095", 
 X"FF63", X"FFFC", X"008D", X"FF8A", X"FF09", X"00C9", X"FF32", X"00B1", X"FFEF", X"0039", X"003A", X"004D", X"FFEF", X"FFDE", X"FFE4", X"FED5");
begin
    uut: CNN_accelerator port map(
        clk              => clk,
        reset_n          => reset_n,
        as_address       => as_address,
        as_read          => as_read,
        as_readdata      => as_readdata,
        as_write         => as_write,
        as_writedata     => as_writedata,
        am_address       => am_address,
        am_burstcount    => am_burstcount,
        am_read          => am_read,
        am_readdatavalid => am_readdatavalid,
        am_readdata      => am_readdata,
        am_waitrequest   => am_waitrequest
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;
    
    stimulus : process
    begin
        reset_n <= '0';
        wait for clk_period;
		
		reset_n <= '1';
        wait for clk_period;
		
		as_write <= '1';
		as_address <= std_logic_vector(to_unsigned(2, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(10, as_writedata'length));
		wait for clk_period;
		
		as_write <= '1';
		as_address <= std_logic_vector(to_unsigned(3, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(784, as_writedata'length));
		wait until rising_edge(clk);
		
		as_write <= '1';
		am_waitrequest <= '0';
		as_address <= std_logic_vector(to_unsigned(0, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(1, as_writedata'length));
		
		
		for i in 0 to 15 loop
			wait until am_read = '1';
			wait until rising_edge(clk);
			for j in 0 to 48 loop
				am_readdata <= image_data(j + 49 * i);
				am_readdatavalid <= '1';
				wait for clk_period;
			end loop;
		
		end loop;
		
		as_write <= '1';
		as_address <= std_logic_vector(to_unsigned(0, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(0, as_writedata'length));
		
		
		wait for (clk_period * 60);
		
		
		-- weight data
		
		as_write <= '1';
		am_readdatavalid <= '0';
		as_address <= std_logic_vector(to_unsigned(4, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(900, as_writedata'length));
		wait for clk_period;
		
		as_write <= '1';
		as_address <= std_logic_vector(to_unsigned(5, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(48, as_writedata'length));
		wait until rising_edge(clk);
		
		as_write <= '1';
		am_waitrequest <= '0';
		as_address <= std_logic_vector(to_unsigned(1, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(1, as_writedata'length));
		wait until rising_edge(clk);
		
		for i in 0 to 2 loop
			wait until am_read = '1';
			wait until rising_edge(clk);
			for j in 0 to 15 loop
				am_readdata <= weight_data(j + 16 * i);
				am_readdatavalid <= '1';
				wait for clk_period;
			end loop;
				
		end loop;
		
		as_write <= '1';
		am_readdatavalid <= '0';
		as_address <= std_logic_vector(to_unsigned(1, as_address'length));
		as_writedata <= std_logic_vector(to_unsigned(0, as_writedata'length));
		wait for (clk_period * 50);
		
        assert false report "End of simulation" severity failure;
    end process;

end sim;
