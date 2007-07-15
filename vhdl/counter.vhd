------------------------------------------------------------------------------
-- Up/down counters
--
-- Project : 
-- File    : $Id: counter.vhd 173 2004-11-17 15:57:19Z plessl $
-- Authors : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--           Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- Created : 2002/10/17
-- Changed : $LastChangedDate: 2004-11-17 16:57:19 +0100 (Wed, 17 Nov 2004) $
------------------------------------------------------------------------------
-- Loadable up counter with enable and reset
--   RstxRB resets the counter to low
--   On assertion of LoadxEI the counter is synchrounously loaded with
--     with CinxDI
--   Counting is enabled when CExEI is asserted
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-05 CP added documentation
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UpCounter is
  
  generic (
    WIDTH   : integer);

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    LoadxEI : in  std_logic;
    CExEI   : in  std_logic;
    CinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
    CoutxDO : out std_logic_vector(WIDTH-1 downto 0));

end UpCounter;

architecture simple of UpCounter is

  signal CountxD    : unsigned(WIDTH-1 downto 0);

begin  -- simple

  Count : process (ClkxC, RstxRB)
  begin  -- process Count
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      CountxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if LoadxEI = '1' then
        CountxD <= unsigned(CinxDI);
      elsif CExEI = '1' then
        CountxD <= CountxD + 1;
      end if;
    end if;
  end process Count;

  CoutxDO <= std_logic_vector(CountxD);

end simple;


------------------------------------------------------------------------------
-- Up/down counter
--
-- Project    : 
-- File       : updowncounter.vhd
-- Authors    : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--              Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/01/21
-- Last changed: $LastChangedDate: 2004-11-17 16:57:19 +0100 (Wed, 17 Nov 2004) $
------------------------------------------------------------------------------
-- Loadable up/down counter with enable and reset
--   RstxRB resets the counter to low
--   On assertion of LoadxEI the counter is synchrounously loaded with
--     with CinxDI
--   Counting is enabled when CExEI is asserted
--   ModexSI = 0 enables counting up, ModexSI=1 enables counting down
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-05 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UpDownCounter is
  
  generic (
    WIDTH : integer);

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    LoadxEI : in  std_logic;
    CExEI   : in  std_logic;
    ModexSI : in  std_logic;
    CinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
    CoutxDO : out std_logic_vector(WIDTH-1 downto 0));

end UpDownCounter;

architecture simple of UpDownCounter is

  signal CountxD : signed(WIDTH-1 downto 0);

begin  -- simple

  Count : process (ClkxC, RstxRB)
  begin  -- process Count
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      CountxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if (LoadxEI = '1') then               -- load counter
        CountxD <= signed(CinxDI);
      elsif (CExEI = '1') then              -- enable counter
        if (ModexSI = '0') then
          CountxD <= CountxD + 1;           -- count up
        else
          CountxD <= CountxD - 1;           -- count down
        end if;
      end if;
    end if;
  end process Count;

  CoutxDO <= std_logic_vector(CountxD);

end simple;
