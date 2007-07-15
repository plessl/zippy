------------------------------------------------------------------------------
-- Various registers for the usage in the zippy architecture
--
-- Project : 
-- File    : $Id: $
-- Authors : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--           Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- Created : 2002/06/26
-- Changed : $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------
-- Merged all files that defined registers.
------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity Reg_En is
  
  generic (
    WIDTH : integer);

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    EnxEI   : in  std_logic;
    DinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
    DoutxDO : out std_logic_vector(WIDTH-1 downto 0));

end Reg_En;

architecture simple of Reg_En is

begin  -- simple

  Reg : process (ClkxC, RstxRB)
  begin  -- process Reg
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      DoutxDO <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if EnxEI = '1' then
        DoutxDO <= DinxDI;
      end if;
    end if;
  end process Reg;
  
end simple;


------------------------------------------------------------------------------
-- Register with synchronous clear and enable (clear has precedence)
------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity Reg_Clr_En is
  
  generic (
    WIDTH : integer);

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    ClrxEI  : in  std_logic;
    EnxEI   : in  std_logic;
    DinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
    DoutxDO : out std_logic_vector(WIDTH-1 downto 0));

end Reg_Clr_En;

architecture simple of Reg_Clr_En is

begin  -- simple

  Reg : process (ClkxC, RstxRB)
  begin  -- process Reg
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      DoutxDO <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if ClrxEI = '1' then                  -- clear has precedence
        DoutxDO <= (others => '0');
      elsif EnxEI = '1' then
        DoutxDO <= DinxDI;
      end if;
    end if;
  end process Reg;
  
end simple;


------------------------------------------------------------------------------
-- Register with asynchronous clear and synchronous enable
------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity Reg_AClr_En is
  
  generic (
    WIDTH : integer);

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    ClrxABI : in  std_logic;
    EnxEI   : in  std_logic;
    DinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
    DoutxDO : out std_logic_vector(WIDTH-1 downto 0));

end Reg_AClr_En;

architecture simple of Reg_AClr_En is

begin  -- simple

  Reg : process (ClkxC, RstxRB, ClrxABI)
  begin  -- process Reg
    if RstxRB = '0' or ClrxABI = '0' then   -- asynchronous reset (active low)
      DoutxDO <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if EnxEI = '1' then
        DoutxDO <= DinxDI;
      end if;
    end if;
  end process Reg;
  
end simple;
