------------------------------------------------------------------------------
-- Computation clock generation unit; clock gating of main clock; clock enabled
-- if run cycle counter is not NULL
--
-- Project    : 
-- File       : cclkgating.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/06/26
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CClkGating is
  
  port (
    EnxEI     : in  std_logic;
    MClockxCI : in  std_logic;
    CClockxCO : out std_logic);

end CClkGating;

architecture simple of CClkGating is

begin  -- simple

  CClockxCO <= MClockxCI and EnxEI;

end simple;
