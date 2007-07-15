------------------------------------------------------------------------------
-- ZIPPY configuration memory (consisting of slices of equal width)
--
-- Project     : 
-- File        : configmem.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/10/09
-- Last changed: $LastChangedDate: 2004-10-07 11:06:32 +0200 (Thu, 07 Oct 2004) $
------------------------------------------------------------------------------
-- Configuration memory for one single context
--
-- The configuration memory is written in some sort of DMA mode, i.e.
-- the configuration data is divided into slices of equal width which
-- are transfered one after the other. The start address can be
-- configured by setting the slice pointer. After a slice has been
-- written, the slice pointer is incremented automatically. This feature
-- can be used for efficient partial reconfiguration.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-06 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ZArchPkg.all;

entity ConfigMem is
  
  generic (
    CFGWIDTH : integer;
    PTRWIDTH : integer;
    SLCWIDTH : integer);
  port (
    ClkxC           : in  std_logic;
    RstxRB          : in  std_logic;
    WExEI           : in  std_logic;
    CfgSlicexDI     : in  std_logic_vector(SLCWIDTH-1 downto 0);
    LoadSlicePtrxEI : in  std_logic;
    SlicePtrxDI     : in  std_logic_vector(PTRWIDTH-1 downto 0);
    ConfigWordxDO   : out std_logic_vector(CFGWIDTH-1 downto 0));

end ConfigMem;

architecture simple of ConfigMem is

  constant NSLICES  : integer := (CFGWIDTH-1)/SLCWIDTH+1;
  constant MEMWIDTH : integer := NSLICES*SLCWIDTH;

  signal CfgWordxD    : std_logic_vector(MEMWIDTH-1 downto 0);
  signal SlcPtrxD     : unsigned(PTRWIDTH-1 downto 0);
  signal HiPtr, LoPtr : integer;
  signal LastxS       : std_logic;
  
begin  -- simple

  LoPtr <= (to_integer(SlcPtrxD))*SLCWIDTH;
  HiPtr <= LoPtr+SLCWIDTH-1;

  ConfigReg : process (ClkxC, RstxRB)
  begin  -- process ConfigReg
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      CfgWordxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if WExEI = '1' then
        CfgWordxD(HiPtr downto LoPtr) <= CfgSlicexDI;
      end if;
    end if;
  end process ConfigReg;

  PtrCnt : process (ClkxC, RstxRB)
  begin  -- process PtrCnt
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      SlcPtrxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if LoadSlicePtrxEI = '1' then
        SlcPtrxD <= unsigned(SlicePtrxDI);
      elsif WExEI = '1' then
        if LastxS = '1' then
          SlcPtrxD <= (others => '0');
        else
          SlcPtrxD <= SlcPtrxD+1;
        end if;
      end if;
    end if;
  end process PtrCnt;

  DetectLast : process (SlcPtrxD)
  begin  -- process DetectLast
    if SlcPtrxD < NSLICES-1 then
      LastxS <= '0';
    else
      LastxS <= '1';
    end if;
  end process DetectLast;

  ConfigWordxDO <= CfgWordxD(CFGWIDTH-1 downto 0);

end simple;
