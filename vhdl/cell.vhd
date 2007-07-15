------------------------------------------------------------------------------
-- ZIPPY cell (processing element + routing element)
--
-- Project     : 
-- File        : cell.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/09/06
-- Last changed: $LastChangedDate: 2005-01-13 18:02:10 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- A cell is a computation/routing unit used in the engine. It is composed by
-- a computation element (procel) and a routing element (routel).
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-07 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;

entity Cell is
  
  generic (
    DATAWIDTH : integer);

  port (
    ClkxC         : in  std_logic;
    RstxRB        : in  std_logic;
    CExEI         : in  std_logic;
    ConfigxI      : in  cellConfigRec;
    ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    ClrContextxEI : in  std_logic;
    ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    -- data io signals
    InputxDI      : in  cellInputRec;
    OutputxZO     : out CellOutputRec;
    -- memory signals
    MemDataxDI    : in  data_word;
    MemAddrxDO    : out data_word;
    MemDataxDO    : out data_word;
    MemCtrlxSO    : out data_word
    );
end Cell;

architecture simple of Cell is

  signal ProcElInxD  : procelInputArray;
  signal ProcElOutxD : data_word;

begin  -- simple

  ProcElement : ProcEl
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC         => ClkxC,
      RstxRB        => RstxRB,
      CExEI         => CExEI,
      ConfigxI      => ConfigxI.procConf,
      ClrContextxSI => ClrContextxSI,
      ClrContextxEI => ClrContextxEI,
      ContextxSI    => ContextxSI,
      InxDI         => ProcElInxD,
      OutxDO        => ProcElOutxD,
      MemDataxDI    => MemDataxDI,
      MemAddrxDO    => MemAddrxDO,
      MemDataxDO    => MemDataxDO,
      MemCtrlxSO    => MemCtrlxSO
      );

  RoutElement : RoutEl
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC        => ClkxC,
      RstxRB       => RstxRB,
      ConfigxI     => ConfigxI.routConf,
      InputxDI     => InputxDI,
      OutputxZO    => OutputxZO,
      ProcElInxDO  => ProcElInxD,
      ProcElOutxDI => ProcElOutxD);

end simple;
