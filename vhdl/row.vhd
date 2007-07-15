------------------------------------------------------------------------------
-- ZIPPY row
--
-- Project     : 
-- File        : row.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/09/06
-- Last changed: $LastChangedDate: 2005-01-13 18:02:10 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- Row is a 1dimensional row of cells used in the engine.
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

entity Row is
  
  generic (
    DATAWIDTH : integer);

  port (
    ClkxC         : in  std_logic;
    RstxRB        : in  std_logic;
    CExEI         : in  std_logic;
    ConfigxI      : in  rowConfigArray;
    ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    ClrContextxEI : in  std_logic;
    ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    InpxI         : in  rowInputArray;
    OutxO         : out rowOutputArray;
    MemDataxDI    : in  data_vector(N_COLS-1 downto 0);
    MemAddrxDO    : out data_vector(N_COLS-1 downto 0);
    MemDataxDO    : out data_vector(N_COLS-1 downto 0);
    MemCtrlxSO    : out data_vector(N_COLS-1 downto 0)
  );

end Row;

architecture simple of Row is

begin  -- simple

  Gen_Cells : for c in N_COLS-1 downto 0 generate
    cell_i : Cell
      generic map (
        DATAWIDTH => DATAWIDTH)
      port map (
        ClkxC         => ClkxC,
        RstxRB        => RstxRB,
        CExEI         => CExEI,
        ConfigxI      => ConfigxI(c),
        ClrContextxSI => ClrContextxSI,
        ClrContextxEI => ClrContextxEI,
        ContextxSI    => ContextxSI,
        InputxDI      => InpxI(c),
        OutputxZO     => OutxO(c),
        MemDataxDI    => MemDataxDI(c),
        MemAddrxDO    => MemAddrxDO(c),
        MemDataxDO    => MemDataxDO(c),
        MemCtrlxSO    => MemCtrlxSO(c)
        );
  end generate Gen_Cells;

end simple;
