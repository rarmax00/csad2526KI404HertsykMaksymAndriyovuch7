library ieee;
use ieee.std_logic_1164.all;

-- Top-level UART module
-- Integrates baud generator, transmitter and receiver

entity uart_top is
    port(
        clk        : in  std_logic;                     -- system clock
        rst        : in  std_logic;                     -- reset

        tx_start   : in  std_logic;                     -- start transmission
        data_in    : in  std_logic_vector(7 downto 0);  -- data to transmit

        tx_line    : out std_logic;                     -- UART TX output
        data_out   : out std_logic_vector(7 downto 0);  -- received data
        data_ready : out std_logic                      -- reception flag
    );
end entity;

architecture structural of uart_top is

    signal sample_t    : std_logic; -- oversampling tick
    signal baud_t      : std_logic; -- baud rate tick
    signal tx_line_int : std_logic; -- internal TX line

begin

    -- baud rate generator instance
    baud_inst : entity work.baud_gen
        port map(
            clk         => clk,
            rst         => rst,
            sample_tick => sample_t,
            baud_tick   => baud_t
        );

    -- UART transmitter instance
    tx_inst : entity work.uart_tx
        port map(
            clk       => clk,
            rst       => rst,
            baud_tick => baud_t,
            tx_start  => tx_start,
            data_in   => data_in,
            tx_line   => tx_line_int,
            tx_busy   => open
        );

    -- UART receiver instance
    rx_inst : entity work.uart_rx
        port map(
            clk         => clk,
            rst         => rst,
            sample_tick => sample_t,
            rx_line     => tx_line_int,
            data_out    => data_out,
            data_ready  => data_ready
        );

    -- connect internal TX line to top-level output
    tx_line <= tx_line_int;

end architecture;
