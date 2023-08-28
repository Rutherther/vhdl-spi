library ieee;
use ieee.std_logic_1164.all;

library spi;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_sipo_shift_register is

  generic (
    runner_cfg : string);

end entity tb_sipo_shift_register;

architecture tb of tb_sipo_shift_register is
  signal clk : std_logic := '0';

  signal data_i : std_logic := '0';
  signal q_o : std_logic_vector(7 downto 0);
begin  -- architecture tb
  uut: entity spi.sipo_shift_register
    generic map (
      WIDTH => 8)
    port map (
      clk_i  => clk,
      data_i =>  data_i,
      q_o =>  q_o);

  clk <= not clk after 1 ns;

  main: process is
  begin  -- process main
    test_runner_setup(runner, runner_cfg);
    show(get_logger(default_checker), display_handler, pass);

    while test_suite loop
      if run("just_one") then
        wait until falling_edge(clk);
        data_i <= '1';
        wait until falling_edge(clk);
        data_i <= '0';
        for i in 0 to 6 loop
            wait until falling_edge(clk);
        end loop;  -- i

        check_equal(q_o, std_logic_vector'("10000000"));
      elsif run("one zero") then
        for i in 0 to 3 loop
            wait until falling_edge(clk);
            data_i <= '1';
            wait until falling_edge(clk);
            data_i <= '0';
        end loop;  -- i

        wait until falling_edge(clk);
        check_equal(q_o, std_logic_vector'("10101010"));
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process main;

end architecture tb;
