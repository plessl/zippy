------------------------------------------------------------------------------
-- Memory blocks
--
-- Generic RAM and ROM components
--
-- Project     : 
-- File        : memory.vhd
-- Authors     : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/11/11
-- Last changed: $LastChangedDate: 2004-10-07 11:06:32 +0200 (Thu, 07 Oct 2004) $
------------------------------------------------------------------------------



-----------------------------------------------------------------------------
-- generic ROM block (1 read port)
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ZArchPkg.all;
use work.AuxPkg.all;

entity Rom is

  generic (
    DEPTH : integer
    );
  port (
    ConfigxI  : in  data_vector(DEPTH-1 downto 0);
    RdAddrxDI : in  data_word;
    RdDataxDO : out data_word
    );

end Rom;

architecture behavioral of Rom is

  constant ADRWIDTH : integer := log2(DEPTH);
  signal fromInd , toInd : integer;
  signal RdAddr : std_logic_vector(log2(DEPTH)-1 downto 0);
  
begin

  RdAddr <= RdAddrxDI(ADRWIDTH-1 downto 0);
  RdDataxDO <= ConfigxI(to_integer(unsigned(RdAddr)));
  
end behavioral;
