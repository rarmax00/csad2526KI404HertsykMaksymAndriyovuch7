library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- UART Receiver module
-- Uses 16x oversampling to reliably detect incoming bits
-- Detects start bit, samples data bits and validates stop bit

entity uart_rx is
    port(
        clk         : in  std_logic;                     -- system clock
        rst         : in  std_logic;                     -- synchronous reset
        sample_tick : in  std_logic;                     -- oversampling tick (16x baud)
        rx_line     : in  std_logic;                     -- UART RX line
        data_out    : out std_logic_vector(7 downto 0);  -- received byte
        data_ready  : out std_logic                      -- reception complete flag
    );
end entity;

architecture rtl of uart_rx is

    -- FSM states for UART reception
    type rx_state_t is (IDLE, START_CHECK, READ_BITS, STOP_CHECK);
    signal state : rx_state_t := IDLE;

    signal bit_index    : integer range 0 to 7 := 0;   -- received bit index
    signal sample_count : integer range 0 to 15 := 0;  -- oversampling counter

    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal ready_reg : std_logic := '0';

begin
    data_out   <= shift_reg;
    data_ready <= ready_reg;

    process(clk)
    begin
        if rising_edge(clk) then

            -- data_ready is asserted for one clock cycle
            ready_reg <= '0';

            if rst = '1' then
                state        <= IDLE;
                bit_index    <= 0;
                sample_count <= 0;

            else
                case state is

                    -- wait for start bit detection
                    when IDLE =>
                        if rx_line = '0' then
                            sample_count <= 0;
                            state <= START_CHECK;
                        end if;

                    -- validate start bit in the middle of bit period
                    when START_CHECK =>
                        if sample_tick = '1' then
                            if sample_count = 7 then
                                if rx_line = '0' then
                                    bit_index <= 0;
                                    sample_count <= 0;
                                    state <= READ_BITS;
                                else
                                    state <= IDLE;
                                end if;
                            else
                                sample_count <= sample_count + 1;
                            end if;
                        end if;

                    -- sample data bits
                    when READ_BITS =>
                        if sample_tick = '1' then
                            if sample_count = 15 then
                                shift_reg(bit_index) <= rx_line;
                                sample_count <= 0;

                                if bit_index = 7 then
                                    state <= STOP_CHECK;
                                else
                                    bit_index <= bit_index + 1;
                                end if;

                            else
                                sample_count <= sample_count + 1;
                            end if;
                        end if;

                    -- check stop bit and complete reception
                    when STOP_CHECK =>
                        if sample_tick = '1' then
                            if sample_count = 15 then
                                ready_reg <= '1';
                                state <= IDLE;
                                sample_count <= 0;
                            else
                                sample_count <= sample_count + 1;
                            end if;
                        end if;

                end case;
            end if;

        end if;
    end process;

end architecture;
