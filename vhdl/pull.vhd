------------------------------------------------------------------------------
-- Pull-up and pull-down (on signals and busses)
--
-- Project    : 
-- File       : pull.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/10/23
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Pull-up, -down on signals
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Pull is
  
  port (
    ModexSI : in  std_logic;            --  '1': pull-up, '0': pull-down
    WirexZO : out std_logic);

end Pull;

architecture behav of Pull is

begin  -- behav

  WirexZO <= 'H' when ModexSI = '1' else 'L';

end behav;


------------------------------------------------------------------------------
-- Pull-up, -down on vectors/busses
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.ComponentsPkg.all;

entity PullBus is
  
  generic (
    WIDTH : integer);

  port (
    ModexSI : in  std_logic;            --  '1': pull-up, '0': pull-down
    BusxZO  : out std_logic_vector(WIDTH-1 downto 0));

end PullBus;

architecture behav of PullBus is

begin  -- behav

  Pulls : for i in BusxZO'range generate
    Pull_i : Pull
      port map (
        ModexSI => ModexSI,
        WirexZO => BusxZO(i));
  end generate Pulls;
  
end behav;
