------------------------------------------------------------------------------
-- ZIPPY routing element (8 inputs, 1 output, 3 tristate outputs)
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/routel.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/09/06
-- $Id: routel.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------
-- Routing element in engine. Route input data from interconnect to
-- processing element.
-- Each routing element has 8 inputs (local interconect and bus taps) and 
-- 1 output that can be connected to the neighbor cells direct inputs as well
-- as 3 outputs with tristate buffers (that are used to drive the south buses).
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;

entity RoutEl is
  
  generic (
    DATAWIDTH : integer);

  port (
    ClkxC        : in  std_logic;
    RstxRB       : in  std_logic;
    ConfigxI     : in  routConfigRec;
    -- access to routing
    InputxDI     : in  cellInputRec;
    OutputxZO    : out CellOutputRec;
    -- access to processing element
    ProcElInxDO  : out procelInputArray;  -- inputs to processing element
    ProcElOutxDI : in  std_logic_vector(DATAWIDTH-1 downto 0));  -- output of PE
end RoutEl;

architecture simple of RoutEl is

begin  -- simple


  -----------------------------------------------------------------------------
  -- INPUT DRIVERS to processing element
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Generate input drivers that drive the cell inputs signals to the
  -- processing element inputs. The desired input for a procel input is
  -- selected by enabling tristate buffers on a bus (not with a multiplexer, as
  -- used in the initial versions of the code)
  -----------------------------------------------------------------------------

  gen_inputdrivers : for inp in ConfigxI.i'range generate

    -- generate drivers for local interconnect inputs
    gen_local : for localcon in ConfigxI.i(inp).LocalxE'range generate
      localcondrvin : TristateBuf
        generic map (
          WIDTH => DATAWIDTH)
        port map (
          InxDI  => InputxDI.LocalxDI(localcon),
          OExEI  => ConfigxI.i(inp).LocalxE(localcon),
          OutxZO => ProcelInxDO(inp)
          );
    end generate gen_local;

    -- generate drivers for HBusN inputs
    gen_hbusn : for hbusn in ConfigxI.i(inp).HBusNxE'range generate
      hbusndrvin : TristateBuf
        generic map (
          WIDTH => DATAWIDTH)
        port map (
          InxDI  => InputxDI.HBusNxDI(hbusn),
          OExEI  => ConfigxI.i(inp).HBusNxE(hbusn),
          OutxZO => ProcelInxDO(inp)
          );
    end generate gen_hbusn;

    -- generate drivers for HBusS inputs
    gen_hbuss : for hbuss in ConfigxI.i(inp).HBusSxE'range generate
      hbussdrvin : TristateBuf
        generic map (
          WIDTH => DATAWIDTH)
        port map (
          InxDI  => InputxDI.HBusSxDI(hbuss),
          OExEI  => ConfigxI.i(inp).HBusSxE(hbuss),
          OutxZO => ProcelInxDO(inp)
          );
    end generate gen_hbuss;

    -- generate drivers for VBusE inputs
    gen_vbuse : for vbuse in ConfigxI.i(inp).VBusExE'range generate
      vbusedrvin : TristateBuf
        generic map (
          WIDTH => DATAWIDTH)
        port map (
          InxDI  => InputxDI.VBusExDI(vbuse),
          OExEI  => ConfigxI.i(inp).VBusExE(vbuse),
          OutxZO => ProcelInxDO(inp)
          );
    end generate gen_vbuse;
    
  end generate gen_inputdrivers;

  -----------------------------------------------------------------------------
  -- OUTPUT DRIVERS from processing elements
  -----------------------------------------------------------------------------

  -- direct output path
  OutputxZO.LocalxDO <= ProcElOutxDI;

  -- generate drivers for HBusN outputs
  gen_drvouthbusn : for hbusn in ConfigxI.o.HBusNxE'range generate
    hbusndrvout : TristateBuf
      generic map (
        WIDTH => DATAWIDTH)
      port map (
        InxDI  => ProcElOutxDI,
        OExEI  => ConfigxI.o.HBusNxE(hbusn),
        OutxZO => OutputxZO.HBusNxDZ(hbusn)
        );
  end generate gen_drvouthbusn;

  -- generate drivers for HBusS outputs
  gen_drvouthbuss : for hbuss in ConfigxI.o.HBusSxE'range generate
    hbussdrvout : TristateBuf
      generic map (
        WIDTH => DATAWIDTH)
      port map (
        InxDI  => ProcElOUtxDI,
        OExEI  => ConfigxI.o.HBusSxE(hbuss),
        OutxZO => OutputxZO.HBusSxDZ(hbuss)
        );
  end generate gen_drvouthbuss;

  -- generate drivers for VBusE inputs
  gen_drvoutvbuse : for vbuse in ConfigxI.o.VBusExE'range generate
    vbusedrvout : TristateBuf
      generic map (
        WIDTH => DATAWIDTH)
      port map (
        InxDI  => ProcElOUtxDI,
        OExEI  => ConfigxI.o.VBusExE(vbuse),
        OutxZO => OutputxZO.VBusExDZ(vbuse)
        );
  end generate gen_drvoutvbuse;

end simple;
