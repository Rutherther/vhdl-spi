library spi;
library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_piso_shift_register is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_piso_shift_register is
  signal data_i : std_logic_vector(7 downto 0);
  signal store_i : std_logic := '0';
  signal clk : std_logic := '0';
  signal q_o : std_logic;
begin
  uut: entity spi.piso_shift_register
    generic map (
      WIDTH => 8)
    port map (
      store_i  => store_i,
      data_i   => data_i,
      clk_i  => clk,
      q_o      => q_o);

  clk <= not clk after 1 ns;

  main: process
  begin
    -- test whole shift process
    test_runner_setup(runner, runner_cfg);
    show(get_logger(default_checker), display_handler, pass);

    while test_suite loop
      if run("just_once") then
        wait until falling_edge(clk);
        data_i <= "10101010";
        store_i <= '1';
        wait until falling_edge(clk);
        store_i <= '0';

        for i in 0 to 3 loop
          check_equal(q_o, '1');
          wait until falling_edge(clk);
          check_equal(q_o, '0');
          wait until falling_edge(clk);
        end loop;  -- i
      elsif run("reload_in_middle") then
    -- load some data, read few, load again, read...
        wait until falling_edge(clk);
        data_i <= "11001100";
        store_i <= '1';
        wait until falling_edge(clk);
        store_i <= '0';
        check_equal(q_o, '1');
        wait until falling_edge(clk);
        check_equal(q_o, '1');
        wait until falling_edge(clk);
        check_equal(q_o, '0');
        store_i <= '1';
        data_i <= "11111111";

        for i in 0 to 7 loop
          wait until falling_edge(clk);
          store_i <= '0';
          check_equal(q_o, '1');
        end loop;  -- i
      end if;
    end loop;

    wait until falling_edge(clk);
    test_runner_cleanup(runner);
  end process;
end architecture;
