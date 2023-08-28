library ieee;
use ieee.std_logic_1164.all;

entity spi_slave is

  generic (
    WIDTH : integer := 8);

  port (
    rst_in     : in  std_logic;
    tx_valid_i : in  std_logic;
    tx_ready_o : out std_logic;
    tx_data_i  : in  std_logic_vector(WIDTH - 1 downto 0);
    rx_valid_o : out std_logic;
    rx_data_o  : out std_logic_vector(WIDTH - 1 downto 0);

    tx_transmitting_o : out std_logic;

    so   : out std_logic;
    si   : in  std_logic;
    sck  : in  std_logic;
    cs_n : in  std_logic);

end entity spi_slave;

architecture a1 of spi_slave is
  signal gated_sck : std_logic;
begin  -- architecture a1
  gated_sck <= '1' when sck = '1' and cs_n = '0' else '0';

  tx: entity work.spi_transmit
    generic map (
      WIDTH       => WIDTH,
      ALIGN_START => '1')
    port map (
      clk_i           => gated_sck,
      rst_in          => rst_in,
      transmit_data_i => tx_data_i,
      valid_i         => tx_valid_i,
      ready_o         => tx_ready_o,
      transmitting_o  => tx_transmitting_o,
      transmit_bit_o  => so);

  rx: entity work.spi_recv
    generic map (
      WIDTH => WIDTH)
    port map (
      clk_i       => gated_sck,
      rst_in      => rst_in,
      data_i      => si,
      recv_o      => rx_valid_o,
      recv_data_o => rx_data_o);

end architecture a1;
