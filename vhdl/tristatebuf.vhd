------------------------------------------------------------------------------
-- Tristate buffer
--
-- Project    : 
-- File       : tristatebuf.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/10/14
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity TristateBuf is
  
  generic (
    WIDTH : integer);

  port (
    InxDI  : in  std_logic_vector(WIDTH-1 downto 0);
    OExEI  : in  std_logic;
    OutxZO : out std_logic_vector(WIDTH-1 downto 0));

end TristateBuf;


architecture simple of TristateBuf is

begin  -- simple

  OutxZO <= InxDI when OExEI = '1' else (others => 'Z');

end simple;
