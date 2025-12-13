library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- UART Transmitter module
-- Implements asynchronous serial data transmission
-- Frame format: 1 start bit, 8 data bits (LSB first), 1 stop bit
-- Transmission timing is controlled by baud_tick signal

entity uart_tx is
    port(
        clk       : in  std_logic;                     -- system clock
        rst       : in  std_logic;                     -- synchronous reset
        baud_tick : in  std_logic;                     -- baud rate tick (1 tick per bit)
        tx_start  : in  std_logic;                     -- start transmission signal
        data_in   : in  std_logic_vector(7 downto 0);  -- byte to transmit
        tx_line   : out std_logic;                     -- UART TX line
        tx_busy   : out std_logic                      -- transmitter busy flag
    );
end entity;

architecture rtl of uart_tx is

    -- FSM states for UART transmission
    type tx_state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : tx_state_t := IDLE;

    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0'); -- shift register
    signal bit_index : integer range 0 to 7 := 0;                       -- transmitted bit index

    signal tx_reg   : std_logic := '1'; -- internal TX signal (idle = '1')
    signal busy_reg : std_logic := '0'; -- internal busy flag

begin
    tx_line <= tx_reg;
    tx_busy <= busy_reg;

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                -- reset transmitter to idle state
                state     <= IDLE;
                tx_reg    <= '1';
                busy_reg  <= '0';
                bit_index <= 0;

            else
                case state is

                    -- waiting for transmission request
                    when IDLE =>
                        busy_reg <= '0';
                        tx_reg   <= '1';
                        if tx_start = '1' then
                            shift_reg <= data_in;
                            bit_index <= 0;
                            busy_reg  <= '1';
                            state     <= START_BIT;
                        end if;

                    -- transmit start bit ('0')
                    when START_BIT =>
                        tx_reg <= '0';
                        if baud_tick = '1' then
                            state <= DATA_BITS;
                        end if;

                    -- transmit data bits (LSB first)
                    when DATA_BITS =>
                        tx_reg <= shift_reg(0);
                        if baud_tick = '1' then
                            shift_reg <= '0' & shift_reg(7 downto 1);
                            if bit_index = 7 then
                                state <= STOP_BIT;
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        end if;

                    -- transmit stop bit ('1')
                    when STOP_BIT =>
                        tx_reg <= '1';
                        if baud_tick = '1' then
                            state <= IDLE;
                        end if;

                end case;
            end if;

        end if;
    end process;

end architecture;
