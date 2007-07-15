------------------------------------------------------------------------------
-- Controller of the cycle counters
--
-- Project    : 
-- File       : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/cyclecntctrl.vhd $
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--              Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003-10-17
-- $Id: 
------------------------------------------------------------------------------
-- The loading of the cycle down counter needs to be arbitrated
-- between the host interface and the context scheduler. The
-- CycleCntCtrl controller arbitrates between these accesses.
-------------------------------------------------------------------------------

    
library ieee;
use ieee.std_logic_1164.all;

entity CycleCntCtrl is
  
  port (
    DecLoadxEI   : in  std_logic;
    SchedLoadxEI : in  std_logic;
    SchedBusyxSI : in  std_logic;
    CCLoadxEO    : out std_logic;
    CCMuxSO      : out std_logic);

end CycleCntCtrl;


architecture simple of CycleCntCtrl is

begin  -- simple

  -- CC down  mux
  CCMuxSO <= SchedBusyxSI;

  -- CC load
  CCload : process (DecLoadxEI, SchedBusyxSI, SchedLoadxEI)
  begin  -- process CCload
    if SchedBusyxSI = '0' then
      CCLoadxEO <= DecLoadxEI;
    else
      CCLoadxEO <= SchedLoadxEI;
    end if;
  end process CCload;

end simple;
