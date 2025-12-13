library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end entity;

architecture sim of uart_tb is

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';

    signal tx_start  : std_logic := '0';
    signal data_in   : std_logic_vector(7 downto 0) := (others => '0');

    signal tx_line   : std_logic;
    signal data_out  : std_logic_vector(7 downto 0);
    signal ready     : std_logic;

begin

    clk <= not clk after 10 ns; -- 50 MHz

    uut : entity work.uart_top
        port map(
            clk       => clk,
            rst       => rst,
            tx_start  => tx_start,
            data_in   => data_in,
            tx_line   => tx_line,
            data_out  => data_out,
            data_ready => ready
        );

    process
    begin
        rst <= '1';
        wait for 200 ns;
        rst <= '0';

        wait for 300 ns;
        data_in <= x"41";
        tx_start <= '1';
        wait for 20 ns;
        tx_start <= '0';

        wait for 20 ms;

        wait;
    end process;

end architecture;
