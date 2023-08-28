library ieee;
use ieee.std_logic_1164.all;

entity sipo_shift_register is

  generic (
    WIDTH : integer := 8);              -- The width of the register,  in bits

  port (
    clk_i : in std_logic;
    data_i : in std_logic;
    q_o : out std_logic_vector(WIDTH - 1 downto 0));

end entity sipo_shift_register;

architecture a1 of sipo_shift_register is
    signal q_reg : std_logic_vector(WIDTH - 1 downto 0);
    signal q_next : std_logic_vector(WIDTH - 1 downto 0);
begin  -- architecture a1
  q_next <= q_reg(WIDTH - 2 downto 0) & data_i;
  q_o <= q_reg;

  -- purpose: Set the q_reg
  -- type   : sequential
  -- inputs : clock_i, reset_in
  -- outputs: q_reg
  set_q_reg: process (clk_i) is
  begin  -- process set_q_reg
    if rising_edge(clk_i) then        -- rising clock edge
      q_reg <= q_next;
    end if;
  end process set_q_reg;

end architecture a1;
