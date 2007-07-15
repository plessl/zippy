------------------------------------------------------------------------------
-- I/O port controller of ZIPPY engine
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/ioportctrl.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003/01/20
-- $Id: ioportctrl.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------
-- I/O port controller controls the read/write enables of the FIFOs. Each IO
-- port controller features a 4LUT that computes any boolean function of the
-- following 4 signals:
--   LUT(0) : bit 0 of the cycle counter (up counter)
--   LUT(1) : bit 1 of the cycle counter (up counter)
--   LUT(2) : result 0 of cycle up/dwn counter greater/equal constant Cmp0
--   LUT(3) : result 1 of cycle up/dwn counter greater/equal constant Cmp1
-------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- compare unit
------------------------------------------------------------------------------
-- 2 modi: greater than (GT), equal (EQ)
library ieee;
use ieee.std_logic_1164.all;

entity IOP_Compare is
  
  generic (
    OPWIDTH : integer);

  port (
    ConfigxS : in  std_logic;
    Op0xDI   : in  std_logic_vector(OPWIDTH-1 downto 0);
    Op1xDI   : in  std_logic_vector(OPWIDTH-1 downto 0);
    CmpxDO   : out std_logic);

end IOP_Compare;

architecture simple of IOP_Compare is

begin  -- simple

  Compare : process (ConfigxS, Op0xDI, Op1xDI)
  begin
    if (ConfigxS = '0') then            -- GT modus
      if (Op0xDI > Op1xDI) then
        CmpxDO <= '1';
      else
        CmpxDO <= '0';
      end if;
    else                                -- EQ modus
      if (Op0xDI = Op1xDI) then
        CmpxDO <= '1';
      else
        CmpxDO <= '0';
      end if;
    end if;
  end process Compare;

end simple;

------------------------------------------------------------------------------
-- 4-LUT
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LookUpTable4to1 is
  
  port (
    ConfigxDI : in  std_logic_vector(15 downto 0);
    In0xDI    : in  std_logic;
    In1xDI    : in  std_logic;
    In2xDI    : in  std_logic;
    In3xDI    : in  std_logic;
    OutxDO    : out std_logic);

end LookUpTable4to1;

architecture simple of LookUpTable4to1 is

  signal AddrxD : std_logic_vector(3 downto 0);
  
begin  -- simple

  AddrxD <= In3xDI & In2xDI & In1xDI & In0xDI;
  OutxDO <= ConfigxDI(to_integer(unsigned(AddrxD)));
  
end simple;

------------------------------------------------------------------------------
-- IO port controller
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;

entity IOPortCtrl is
  
  generic (
    CCNTWIDTH : integer);

  port (
    ClkxC         : in  std_logic;
    RstxRB        : in  std_logic;
    ConfigxI      : in  ioportConfigRec;
    CycleDnCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
    CycleUpCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
    PortxEO       : out std_logic);

end IOPortCtrl;


architecture simple of IOPortCtrl is

  component IOP_Compare
    generic (
      OPWIDTH : integer);
    port (
      ConfigxS : in  std_logic;
      Op0xDI   : in  std_logic_vector(OPWIDTH-1 downto 0);
      Op1xDI   : in  std_logic_vector(OPWIDTH-1 downto 0);
      CmpxDO   : out std_logic);
  end component;

  component LookUpTable4to1
    port (
      ConfigxDI : in  std_logic_vector(15 downto 0);
      In0xDI    : in  std_logic;
      In1xDI    : in  std_logic;
      In2xDI    : in  std_logic;
      In3xDI    : in  std_logic;
      OutxDO    : out std_logic);
  end component;

  signal Cmp0InxD  : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal Cmp1InxD  : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal Cmp0OutxD : std_logic;
  signal Cmp1OutxD : std_logic;
  
begin  -- simple

  Cmp0Mux : Mux2to1
    generic map (
      WIDTH => CCNTWIDTH)
    port map (
      SelxSI => ConfigxI.Cmp0MuxS,
      In0xDI => CycleUpCntxDI,
      In1xDI => CycleDnCntxDI,
      OutxDO => Cmp0InxD);
  
  Cmp0 : IOP_Compare
    generic map (
      OPWIDTH => CCNTWIDTH)
    port map (
      ConfigxS => ConfigxI.Cmp0ModusxS,
      Op0xDI   => Cmp0InxD,
      Op1xDI   => ConfigxI.Cmp0ConstxD,
      CmpxDO   => Cmp0OutxD);

  Cmp1Mux : Mux2to1
    generic map (
      WIDTH => CCNTWIDTH)
    port map (
      SelxSI => ConfigxI.Cmp1MuxS,
      In0xDI => CycleUpCntxDI,
      In1xDI => CycleDnCntxDI,
      OutxDO => Cmp1InxD);
  
  Cmp1 : IOP_Compare
    generic map (
      OPWIDTH => CCNTWIDTH)
    port map (
      ConfigxS => ConfigxI.Cmp1ModusxS,
      Op0xDI   => Cmp1InxD,
      Op1xDI   => ConfigxI.Cmp1ConstxD,
      CmpxDO   => Cmp1OutxD);

  Lut4 : LookUpTable4to1
    port map (
      ConfigxDI => ConfigxI.LUT4FunctxD,
      In0xDI    => CycleUpCntxDI(0),
      In1xDI    => CycleUpCntxDI(1),
      In2xDI    => Cmp0OutxD,
      In3xDI    => Cmp1OutxD,
      OutxDO    => PortxEO);

end simple;
