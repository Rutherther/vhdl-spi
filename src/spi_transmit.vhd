library ieee;
use ieee.std_logic_1164.all;

entity spi_transmit is

  generic (
    WIDTH : integer := 8;
    ALIGN_START : std_logic := '1');

  port (
    clk_i           : in  std_logic;    -- Clock
    rst_in          : in  std_logic;    -- Asynchronous reset, active low
    transmit_data_i : in  std_logic_vector(WIDTH - 1 downto 0);  -- The data to
                                                                 -- transmit.
                                                                 -- Change only
                                                                 -- if ready_o
                                                                 -- is '1'.
    valid_i      : in  std_logic;    -- Pulse to signal new data are present
                                        -- in transmit_data. Data has to change
                                        -- only if ready_o is '1'
    ready_o         : out std_logic;    -- Signals that the transmitter is
                                        -- ready for new data on `transmit_data_i``.
    transmitting_o  : out std_logic;    -- Signals that the transmitter is
                                        -- currently transmitting data
    transmit_bit_o  : out std_logic);   -- The bit to transmit (on master MOSI)

end entity spi_transmit;

architecture a1 of spi_transmit is
  signal store_data_in_sr : std_logic;  -- should data be stored in the
                                            -- shift register next clock cycle?

  signal transmit_bit_falling : std_logic;
  signal sr_q_o : std_logic;

  signal data_bit_index_reg : integer range 0 to WIDTH;
  signal data_bit_index_next : integer range 0 to WIDTH;

  type state is (IDLE, WAITING, SINGLE_TRANSMISSION, CONTINUOUS_TRANSMISSION);
  -- IDLE - not sending anything
  -- WAITING - waiting for the right moment to send - data_bit_index = 0
  -- SINGLE_TRANSMISSION - just one data currently loaded into the shift register
  -- CONTINUOUS_TRANSMISSION - one data currently being sent, and another data
  -- loaded into the shift register, and another ready to be sent

  signal state_reg : state;
  signal state_next : state;

  signal can_begin_transmission_next : std_logic;
begin  -- architecture a1
  transmit_bit_o <= sr_q_o when state_reg = SINGLE_TRANSMISSION and data_bit_index_reg = 1 else
                    transmit_bit_falling when state_reg /= IDLE else
                    sr_q_o;

  can_begin_transmission_next <= '1' when data_bit_index_reg = 0 else '0';

  -- in IDLE, go to
  --   -- SINGLE_TRANSMISSION if data valid, and can start transmission
  --   -- WAITING if data valid, and cannot start transmission
  --   -- IDLE
  -- in WAITING, go to
  --   -- SINGLE_TRANSMISSION if can start transmission
  --   -- WAITING
  -- in SINGLE_TRANSMISSION, go to
  --   -- CONTINUOUS_TRANSMISSION if data valid and cannot begin new transmission
  --   -- SINGLE_TRANSMISSION if data valid and can begin new transmission
  --   -- IDLE if transmission done
  --   -- SINGLE_TRANSMISSION if transmission ongoing
  -- in CONTINUOUS_TRANSMISSION, go to
  --   -- CONTINUOUS_TRANSMISSION if cannot begin new transmission
  --   -- SINGLE_TRANSMISSION if can begin new transmission

  state_next <= SINGLE_TRANSMISSION when state_reg = IDLE and valid_i = '1' and can_begin_transmission_next = '1' else
                WAITING when state_reg = IDLE and valid_i = '1' else
                SINGLE_TRANSMISSION when state_reg = WAITING and can_begin_transmission_next = '1'  else
                WAITING when state_reg = WAITING else
                SINGLE_TRANSMISSION when state_reg = SINGLE_TRANSMISSION and valid_i = '1' and can_begin_transmission_next = '1' else
                CONTINUOUS_TRANSMISSION when state_reg = SINGLE_TRANSMISSION and valid_i = '1' else
                SINGLE_TRANSMISSION when state_reg = SINGLE_TRANSMISSION and data_bit_index_reg /= 0 else
                CONTINUOUS_TRANSMISSION when state_reg = CONTINUOUS_TRANSMISSION and can_begin_transmission_next = '0' else
                SINGLE_TRANSMISSION when state_reg = CONTINUOUS_TRANSMISSION and can_begin_transmission_next = '1' else
                IDLE;

  store_data_in_sr <= '1' when data_bit_index_reg = 0 and state_next /= IDLE else '0';
  ready_o <= '1' when state_reg /= CONTINUOUS_TRANSMISSION else '0';
  transmitting_o <= '1' when state_next = SINGLE_TRANSMISSION or state_next = CONTINUOUS_TRANSMISSION else '0';

  data_bit: if ALIGN_START = '1' generate
    data_bit_index_next <= (data_bit_index_reg + 1) mod WIDTH;
  else generate
    data_bit_index_next <= (data_bit_index_reg + 1) mod WIDTH when state_reg /= IDLE else
                           0;
  end generate data_bit;

  store_next: process (clk_i) is
  begin  -- process store_next
    if rst_in = '0' then              -- synchronous reset (active low)
      data_bit_index_reg <= 0;
      state_reg <= IDLE;
    elsif rising_edge(clk_i) then          -- rising clock edge
      data_bit_index_reg <= data_bit_index_next;
      state_reg <= state_next;
    end if;
  end process store_next;

  store_falling: process (clk_i) is
  begin  -- process store_falling
    if falling_edge(clk_i) then
      transmit_bit_falling <= sr_q_o;
    end if;
  end process store_falling;

  sr: entity work.piso_shift_register
    generic map (
      WIDTH => WIDTH)
    port map (
      clk_i => clk_i,
      data_i => transmit_data_i,
      store_i => store_data_in_sr,
      q_o => sr_q_o
    );

end architecture a1;
