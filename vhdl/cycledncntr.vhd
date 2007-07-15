------------------------------------------------------------------------------
-- Cycles Down Counter
--
-- Project     : 
-- File        : cycledncntr.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--              Christian Plessl <plessl@tik.ee.ethz.ch> 
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/06/26
-- Last changed: $LastChangedDate: 2004-10-07 11:06:32 +0200 (Thu, 07 Oct 2004) $
------------------------------------------------------------------------------
--  Loadable cycle counter that controls the execution of the
--  array. The counter value is decreased until it reaches zero. It
--  cannot be loaded while counting down.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-05 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CycleDnCntr is
  
  generic (
    CNTWIDTH : integer);

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    LoadxEI : in  std_logic;
    CinxDI  : in  std_logic_vector(CNTWIDTH-1 downto 0);
    OnxSO   : out std_logic;
    CoutxDO : out std_logic_vector(CNTWIDTH-1 downto 0));

end CycleDnCntr;


architecture simple of CycleDnCntr is

  signal CountxD   : unsigned(CNTWIDTH-1 downto 0);
  signal NotZeroxS : std_logic;

begin  -- simple
  
  Comparator : process (CountxD)
  begin  -- process Comparator
    if CountxD > 0 then
      NotZeroxS <= '1';
    else
      NotZeroxS <= '0';
    end if;
  end process Comparator;

  Counter : process (ClkxC, RstxRB)
  begin  -- process Counter
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      CountxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if NotZeroxS = '1' then
        CountxD <= CountxD - 1;
      elsif LoadxEI = '1' then              -- only loadable if count > 0
        CountxD <= unsigned(CinxDI);
      end if;
    end if;
  end process Counter;

  CoutxDO <= std_logic_vector(CountxD);
  OnxSO   <= NotZeroxS;

end simple;
