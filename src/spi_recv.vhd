library ieee;
use ieee.std_logic_1164.all;

entity spi_recv is

  generic (
    WIDTH : integer := 8);

  port (
    clk_i : in std_logic;
    rst_in : in std_logic;
    data_i : in std_logic;
    recv_o : out std_logic;
    recv_data_o : out std_logic_vector(WIDTH - 1 downto 0));
end entity spi_recv;

architecture a1 of spi_recv is
  signal bit_index_reg : integer range 0 to WIDTH;
  signal bit_index_next : integer range 0 to WIDTH;
  signal initialized : std_logic;
begin  -- architecture a1
  recv_o <= '1' when bit_index_next = 1 and initialized = '1' else
            '0';

  bit_index_next <= (bit_index_reg + 1) mod WIDTH;

  set_bit_index: process (clk_i) is
  begin  -- process set_bit_index
    if rst_in = '0' then            -- synchronous reset (active low)
      bit_index_reg <= 0;
      initialized <= '0';
    elsif rising_edge(clk_i) then        -- rising clock edge
      if initialized = '0' and bit_index_reg = 0 then
        initialized <= '1';
      end if;
      bit_index_reg <= bit_index_next;
    end if;
  end process set_bit_index;

  sr: entity work.sipo_shift_register
    generic map (
      WIDTH => WIDTH)
    port map (
      clk_i  => clk_i,
      data_i => data_i,
      q_o => recv_data_o);

end architecture a1;
