------------------------------------------------------------------------------
-- Context multiplexer (behavioral)
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/contextmux.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003/01/15
-- $Id: contextmux.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------
-- The context multiplexer is used to select one particular
-- configuration (context) from the configuration memory.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ConfigPkg.all;
use work.AuxPkg.all;

entity ContextMux is
  
  generic (
    NINP : integer);                    -- no. of inputs

  port (
    SelxSI : in  std_logic_vector(log2(NINP)-1 downto 0);
    InpxI  : in  contextArray;
    OutxDO : out contextType);

end ContextMux;


architecture behav of ContextMux is

begin  -- behav

  OutxDO <= InpxI(to_integer(unsigned(SelxSI)));

end behav;
