library ieee;
use ieee.std_logic_1164.all;

library spi;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_spi_recv is

  generic (
    runner_cfg : string);

end entity tb_spi_recv;

architecture tb of tb_spi_recv is
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal pass_clk : std_logic := '0';

  signal in_data_bit : std_logic := '0';
  signal recv_flag : std_logic;
  signal recv_data : std_logic_vector(7 downto 0);
  signal uut_clk : std_logic;
begin  -- architecture tb

  clk <= not clk after 1 ns;
  rst <= '1' after 6 ns;

  uut_clk <= clk and pass_clk;

  uut: entity spi.spi_recv
    generic map (
      WIDTH => 8)
    port map (
      clk_i  => uut_clk,
      rst_in => rst,
      data_i => in_data_bit,
      recv_o => recv_flag,
      recv_data_o => recv_data);

  main: process is
  begin  -- process main
    wait until rst = '1';

    test_runner_setup(runner, runner_cfg);
    show(get_logger(default_checker), display_handler, pass);

    while test_suite loop
      if run("one_byte") then
        wait until falling_edge(clk);
        pass_clk <= '1';

        for i in 0 to 3 loop
          in_data_bit <= '1';
          check_equal(recv_flag, '0');
          wait until falling_edge(clk);
        end loop;  -- i

        for i in 0 to 3 loop
          in_data_bit <= '0';
          check_equal(recv_flag, '0');
          wait until falling_edge(clk);
        end loop;  -- i

        check_equal(recv_flag, '1');
        check_equal(recv_data, std_logic_vector'("11110000"));
        wait until falling_edge(clk);
        check_equal(recv_flag, '0');
      elsif run("more_bytes") then
        wait until falling_edge(clk);
        pass_clk <= '1';

        for j in 0 to 3 loop
          for i in 0 to 3 loop
            in_data_bit <= '1';
            if i /= 0 or j = 0 then
              check_equal(recv_flag, '0');
            end if;
            wait until falling_edge(clk);
          end loop;  -- i

          for i in 0 to 3 loop
            in_data_bit <= '0';
            check_equal(recv_flag, '0');
            wait until falling_edge(clk);
          end loop;  -- i

          in_data_bit <= '1';
          check_equal(recv_flag, '1');
          check_equal(recv_data, std_logic_vector'("11110000"));
        end loop;  -- j
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process main;

end architecture tb;
