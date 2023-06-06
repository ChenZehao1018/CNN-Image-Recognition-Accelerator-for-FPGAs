library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.data_type.all;

entity argmax_tb is
end argmax_tb;

architecture tb of argmax_tb is

    -- Instantiate the unit under test (UUT)
    component argmax
    port(
        clk:      in std_logic;
        reset_n:  in std_logic;
		read_i:	  in std_logic;
        data_i:   in data_array_3bit;
        data_o:   out std_logic_vector(31 downto 0)
    );
    end component;

    -- Local signals
    signal clk: std_logic := '0';
    signal reset_n: std_logic := '0';
	signal read_i: std_logic := '0';
    signal data_i: data_array_3bit;
    signal data_o: std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clk_period: time := 10 ns; -- Clock period

begin

    -- Instantiate UUT
    uut: argmax port map (
        clk => clk,
        reset_n => reset_n,
		read_i => read_i,
        data_i => data_i,
        data_o => data_o
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset pulse
        reset_n <= '0';
        wait for clk_period;

        reset_n <= '1';
        wait for clk_period;
		
		read_i <= '0';
		wait for clk_period/2;
        -- Insert stimulus here 
		data_i <= (X"0001", X"0002", X"0001"); 
		read_i <= '1';
		wait for clk_period;
		read_i <= '0';
		wait for clk_period;
		--
        data_i <= (X"0002", X"0004", X"0003"); 
		read_i <= '1';
		wait for clk_period;
		read_i <= '0';
		wait for clk_period;
		--
        data_i <= (X"0001", X"0000", X"0005");
		read_i <= '1';
		wait for clk_period;
		read_i <= '0';
		wait for clk_period;
		--
        data_i <= (X"0007", X"0006", X"0004");
		read_i <= '1';
		wait for clk_period;
		read_i <= '0';
		wait for clk_period;
		--
        

        wait;
    end process;

end tb;
