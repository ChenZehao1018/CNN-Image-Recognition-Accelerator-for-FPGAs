library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type.all;

entity neuron_tb is
-- Testbench has no ports
end neuron_tb;

architecture Behavioral of neuron_tb is

    -- component declaration for the unit under test
    component neuron
    port(
        data_i:   in  data_array_16bit;
        weight_i: in  data_array_16bit;
        data_o:   out signed(15 downto 0)
    );
    end component;

    -- input and output signals for unit under test
    signal tb_data_i:   data_array_16bit;
    signal tb_weight_i: data_array_16bit;
    signal tb_data_o:   signed(15 downto 0);

begin
    -- instantiate unit under test
    uut: neuron port map (
        data_i   => tb_data_i,
        weight_i => tb_weight_i,
        data_o   => tb_data_o
    );

    -- testbench stimulus process
    stimulus_proc: process
    begin 
        -- insert stimulus here 
        for i in tb_data_i'range loop
            tb_data_i(i)   <= to_signed(0, 16);
            tb_weight_i(i) <= to_signed(0, 16);
        end loop;
        wait for 10 ns;

        for i in tb_data_i'range loop
            tb_data_i(i)   <= to_signed(255, 16);
            tb_weight_i(i) <= to_signed(255, 16);
        end loop;
        wait for 10 ns;

        -- add more tests as needed

        wait;
    end process;
end Behavioral;
