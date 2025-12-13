library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Baud rate generator
-- Generates baud_tick (1 tick per UART bit)
-- Generates sample_tick (oversampling tick, typically 16x baud)

entity baud_gen is
    generic(
        CLOCK_FREQ : integer := 50000000; -- system clock frequency
        BAUD_RATE  : integer := 9600;     -- UART baud rate
        OVERSAMPLE : integer := 16        -- oversampling factor
    );
    port(
        clk         : in  std_logic;      -- system clock
        rst         : in  std_logic;      -- synchronous reset
        sample_tick : out std_logic;      -- oversampling tick
        baud_tick   : out std_logic       -- baud rate tick
    );
end entity;

architecture rtl of baud_gen is

    -- clock divider value
    constant DIV : integer :=
        integer(CLOCK_FREQ / (BAUD_RATE * OVERSAMPLE));

    signal cnt        : integer range 0 to DIV-1 := 0;
    signal sample_cnt : integer range 0 to OVERSAMPLE-1 := 0;

    signal sample_p : std_logic := '0';
    signal baud_p   : std_logic := '0';

begin
    sample_tick <= sample_p;
    baud_tick   <= baud_p;

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                cnt        <= 0;
                sample_cnt <= 0;
                sample_p   <= '0';
                baud_p     <= '0';

            else
                sample_p <= '0';
                baud_p   <= '0';

                if cnt = DIV - 1 then
                    cnt <= 0;

                    if sample_cnt = OVERSAMPLE - 1 then
                        sample_cnt <= 0;
                        baud_p   <= '1';
                        sample_p <= '1';
                    else
                        sample_cnt <= sample_cnt + 1;
                        sample_p <= '1';
                    end if;

                else
                    cnt <= cnt + 1;
                end if;

            end if;

        end if;
    end process;

end architecture;
