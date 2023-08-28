library ieee;
use ieee.std_logic_1164.all;

library spi;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_spi_transmit is

  generic (
    runner_cfg : string);

end entity tb_spi_transmit;

architecture a1 of tb_spi_transmit is
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal transmit_data : std_logic_vector(7 downto 0);
  signal valid_pulse : std_logic;

  signal ready : std_logic;
  signal transmitting : std_logic;
  signal mosi : std_logic;
begin  -- architecture a1
  uut: entity spi.spi_transmit
    generic map (
      WIDTH => 8)
    port map (
      clk_i  => clk,
      rst_in => rst,
      transmit_data_i => transmit_data,
      valid_i => valid_pulse,
      ready_o => ready,
      transmitting_o => transmitting,
      transmit_bit_o => mosi);

  clk <= not clk after 1 ns;
  rst <= '1' after 6 ns;

  main: process is
  begin  -- process
    wait until rst = '1';
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("one_byte") then
        check_equal(ready, '1');
        valid_pulse <= '1';
        transmit_data <= "11100010";
        wait until falling_edge(clk);
        valid_pulse <= '0';

        for i in 0 to 2 loop
          check_equal(ready, '1');
          check_equal(transmitting, '1');
          check_equal(mosi, '1');
          wait until falling_edge(clk);
        end loop;  -- i

        for i in 0 to 2 loop
          check_equal(ready, '1');
          check_equal(transmitting, '1');
          check_equal(mosi, '0');
          wait until falling_edge(clk);
        end loop;  -- i

        check_equal(ready, '1');
        check_equal(transmitting, '1');
        check_equal(mosi, '1');
        wait until falling_edge(clk);
        check_equal(ready, '1');
        check_equal(transmitting, '0');
        check_equal(mosi, '0');
        wait until falling_edge(clk);
        check_equal(ready, '1');
        check_equal(transmitting, '0');
      elsif run("more_bytes") then
        valid_pulse <= '1';
        transmit_data <= "11100010";
        wait until falling_edge(clk);
        check_equal(ready, '1');
        valid_pulse <= '1';
        transmit_data <= "00011101";
        wait until falling_edge(clk);
        check_equal(ready, '0');
        valid_pulse <= '0';

        for i in 0 to 1 loop
          check_equal(ready, '0');
          check_equal(transmitting, '1');
          check_equal(mosi, '1');
          wait until falling_edge(clk);
        end loop;  -- i

        for i in 0 to 2 loop
          check_equal(ready, '0');
          check_equal(transmitting, '1');
          check_equal(mosi, '0');
          wait until falling_edge(clk);
        end loop;  -- i

        check_equal(ready, '0');
        check_equal(transmitting, '1');
        check_equal(mosi, '1');
        wait until falling_edge(clk);

        check_equal(ready, '0');
        check_equal(transmitting, '1');
        check_equal(mosi, '0');
        wait until falling_edge(clk);

        -- starting to send second byte
        for i in 0 to 2 loop
          check_equal(ready, '1');
          check_equal(transmitting, '1');
          check_equal(mosi, '0');
          wait until falling_edge(clk);
        end loop;  -- i

        for i in 0 to 2 loop
          check_equal(ready, '1');
          check_equal(transmitting, '1');
          check_equal(mosi, '1');
          wait until falling_edge(clk);
        end loop;  -- i

        check_equal(ready, '1');
        check_equal(transmitting, '1');
        check_equal(mosi, '0');
        wait until falling_edge(clk);

        check_equal(ready, '1');
        check_equal(transmitting, '0');
        check_equal(mosi, '1');

        wait until falling_edge(clk);
        check_equal(ready, '1');
        check_equal(transmitting, '0');
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

end architecture a1;
