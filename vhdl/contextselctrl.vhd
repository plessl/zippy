------------------------------------------------------------------------------
-- Controller of context select register
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/contextselctrl.vhd $
-- Authos      : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003-10-17
-- $Id: contextselctrl.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------
-- arbitrates between host interface decoder and the context
-- scheduler.  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ContextSelCtrl is
  
  port (
    DecEnxEI     : in  std_logic;
    SchedEnxEI   : in  std_logic;
    SchedBusyxSI : in  std_logic;
    CSREnxEO     : out std_logic;
    CSRMuxSO     : out std_logic);

end ContextSelCtrl;


architecture simple of ContextSelCtrl is

begin  -- simple

  -- CSR mux
  CSRMuxSO <=  SchedBusyxSI;

  -- CSR enable
  CSRenable: process (DecEnxEI, SchedEnxEI, SchedBusyxSI)
  begin  -- process CSRenable
    if SchedBusyxSI = '0' then
      CSREnxEO <= DecEnxEI;
    else
      CSREnxEO <= SchedEnxEI;
    end if;
  end process CSRenable;

end simple;
