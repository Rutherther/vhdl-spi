library ieee;
use ieee.std_logic_1164.all;

entity spi_transmit is

  generic (
    WIDTH : integer := 8);

  port (
    clk_i           : in  std_logic;    -- Clock
    rst_in          : in  std_logic;    -- Asynchronous reset, active low
    transmit_data_i : in  std_logic_vector(WIDTH - 1 downto 0);  -- The data to
                                                                 -- transmit.
                                                                 -- Change only
                                                                 -- if ready_o
                                                                 -- is '1'.
    transmit_i      : in  std_logic;    -- Pulse to signal new data are present
                                        -- in transmit_data. Data has to change
                                        -- only if ready_o is '1'
    ready_o         : out std_logic;    -- Signals that the transmitter is
                                        -- ready for new data on `transmit_data_i``.
    transmitting_o  : out std_logic;    -- Signals that the transmitter is
                                        -- currently transmitting data
    transmit_bit_o  : out std_logic);   -- The bit to transmit (on master MOSI)

end entity spi_transmit;

architecture a1 of spi_transmit is
  signal ready_reg : std_logic;         -- is the transmitter ready for new data?
  signal ready_next : std_logic;

  signal data_prepared_reg : std_logic;  -- is there data prepared for next transmission?
  signal data_prepared_next : std_logic;
  signal store_data_in_sr_reg : std_logic;  -- should data be stored in the
                                            -- shift register next clock cycle?
  signal store_data_in_sr_next : std_logic;

  signal data_bit_index_reg : integer range 0 to WIDTH;
  signal data_bit_index_next : integer range 0 to WIDTH;

  signal transmitting_reg : std_logic;  -- is there an ongoing transmission?
  signal transmitting_next : std_logic;

  signal continue_in_ongoing_transmission : std_logic;  -- at the end of
                                                        -- transmission, are
                                                        -- next data ready and
                                                        -- should the transmission continue?
begin  -- architecture a1
  ready_o <= ready_reg;
  transmitting_o <= transmitting_reg;

  ready_next <= '0' when ready_reg = '1' and transmit_i = '1' and transmitting_reg = '1' else
                '0' when ready_reg = '0' and data_prepared_next = '1' else
                '1';

  data_bit_index_next <= (data_bit_index_reg + 1) mod WIDTH when transmitting_reg = '1' else
                         0;

  continue_in_ongoing_transmission <= '1' when transmitting_reg = '1' and data_bit_index_next = 0 and store_data_in_sr_next = '1' else
                              '0';

  transmitting_next <= '1' when continue_in_ongoing_transmission = '1' else
                       '0' when transmitting_reg = '1' and data_bit_index_next = 0 else
                       '1' when transmitting_reg = '1' else
                       '1' when store_data_in_sr_next = '1' else
                       '0';

  store_data_in_sr_next <= '0' when store_data_in_sr_reg = '1' else
                           '1' when transmitting_reg = '0' and transmit_i = '1' else
                           '1' when transmitting_reg = '0' and data_prepared_reg = '1' else
                           '1' when transmitting_reg = '1' and data_bit_index_next = 0 and data_prepared_reg = '1' else
                           '0';

  data_prepared_next <= '1' when transmit_i = '1' and ready_reg = '1' and transmitting_reg = '1' else
                        '1' when data_prepared_reg = '1' and store_data_in_sr_next = '0' else
                        '0';

  store_next: process (clk_i) is
  begin  -- process store_next
    if rst_in = '0' then              -- synchronous reset (active low)
      ready_reg <= '0';
      data_prepared_reg <= '0';
      store_data_in_sr_reg <= '0';
      data_bit_index_reg <= 0;
      transmitting_reg <= '0';
    elsif rising_edge(clk_i) then          -- rising clock edge
      ready_reg <= ready_next;
      data_prepared_reg <= data_prepared_next;
      store_data_in_sr_reg <= store_data_in_sr_next;
      data_bit_index_reg <= data_bit_index_next;
      transmitting_reg <= transmitting_next;
    end if;
  end process store_next;

  sr: entity work.piso_shift_register
    generic map (
      WIDTH => WIDTH)
    port map (
      clk_i => clk_i,
      data_i => transmit_data_i,
      store_i => store_data_in_sr_next,
      q_o => transmit_bit_o
    );

end architecture a1;
