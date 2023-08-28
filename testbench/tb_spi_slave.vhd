library ieee;
use ieee.std_logic_1164.all;

library spi;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_spi_slave is

  generic (
    runner_cfg : string);

end entity tb_spi_slave;

architecture tb of tb_spi_slave is
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal tx_valid, tx_ready, rx_valid, tx_transmitting : std_logic;
  signal tx_data, rx_data : std_logic_vector(7 downto 0);

  signal gated_si : std_logic;
  signal so : std_logic;
  signal cs_n : std_logic := '1';

  signal loopback : std_logic := '0';
  signal si : std_logic := '0';
begin  -- architecture tb
  uut: entity spi.spi_slave
    generic map (
      WIDTH => 8)
    port map (
      rst_in => rst,
      tx_valid_i => tx_valid,
      tx_ready_o => tx_ready,
      tx_data_i => tx_data,
      rx_valid_o => rx_valid,
      rx_data_o => rx_data,
      tx_transmitting_o => tx_transmitting,
      so  => so,
      si  => gated_si,
      sck => clk,
      cs_n => cs_n);

  clk <= not clk after 1 ns;
  rst <= '1' after 6 ns;

  gated_si <= so when loopback = '1' else si;

  main: process is
  begin  -- process main
    wait until rst = '1';
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("one_byte_loopback") then
        loopback <= '1';
        cs_n <= '0';
        tx_data <= "11100010";
        tx_valid <= '1';
        wait until falling_edge(clk);
        tx_valid <= '0';

        wait until falling_edge(clk);
        wait until rx_valid = '1';
        wait until falling_edge(clk);
        check_equal(rx_data, std_logic_vector'("11100010"));
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process main;

end architecture tb;
