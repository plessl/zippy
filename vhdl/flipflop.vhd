------------------------------------------------------------------------------
-- Flip-Flops
--
-- Project : 
-- File    : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/flipflop.vhd $
-- Authors : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--           Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- Created : 2003/03/07
-- $Id: flipflop.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity FlipFlop is

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    EnxEI   : in  std_logic;
    DinxDI  : in  std_logic;
    DoutxDO : out std_logic);

end FlipFlop;

architecture simple of FlipFlop is

begin  -- simple

  FF : process (ClkxC, RstxRB)
  begin  -- process Reg
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      DoutxDO <= '0';
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if EnxEI = '1' then
        DoutxDO <= DinxDI;
      end if;
    end if;
  end process FF;
  
end simple;


------------------------------------------------------------------------------
-- Flip-Flop with Clear
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity FlipFlop_Clr is

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    ClrxEI  : in  std_logic;
    EnxEI   : in  std_logic;
    DinxDI  : in  std_logic;
    DoutxDO : out std_logic);

end FlipFlop_Clr;

architecture simple of FlipFlop_Clr is

begin  -- simple

  FF : process (ClkxC, RstxRB)
  begin  -- process Reg
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      DoutxDO <= '0';
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if ClrxEI = '1' then                  -- clear has precedence
        DoutxDO <= '0';
      elsif EnxEI = '1' then
        DoutxDO <= DinxDI;
      end if;
    end if;
  end process FF;
  
end simple;
