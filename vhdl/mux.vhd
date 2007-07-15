------------------------------------------------------------------------------
-- Various multiplexers for the usage in the Zippy architecture
--
-- Project    : 
-- File       : $Id: $
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;


entity GMux is
  
  generic (
    NINP  : integer;                    -- no. of inputs
    WIDTH : integer);                   -- input width

  port (
    SelxSI : in  std_logic_vector(log2(NINP)-1 downto 0);
    InxDI  : in  std_logic_vector(NINP*WIDTH-1 downto 0);
    OutxDO : out std_logic_vector(WIDTH-1 downto 0));

end GMux;


architecture behav of GMux is

  type inpArray is array (NINP-1 downto 0) of
    std_logic_vector(WIDTH-1 downto 0);
  signal Inp : inpArray;
  
begin  -- behav

  InputArray: for i in Inp'range generate
    Inp(i) <= InxDI((i+1)*WIDTH-1 downto i*WIDTH);
  end generate InputArray;
  
  OutxDO <= Inp(to_integer(unsigned(SelxSI)));

end behav;

------------------------------------------------------------------------------
-- 2:1 Multiplexer
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux2to1 is
  
  generic (
    WIDTH : integer);

  port (
    SelxSI : in  std_logic;
    In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
    OutxDO : out std_logic_vector(WIDTH-1 downto 0));

end Mux2to1;


architecture simple of Mux2to1 is

begin

  with SelxSI select
    OutxDO <=
    In0xDI when '0',
    In1xDI when '1',
    In0xDI when others;

end simple;
------------------------------------------------------------------------------
-- 4:1 Multiplexer
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux4to1 is
  
  generic (
    WIDTH : integer);

  port (
    SelxSI : in  std_logic_vector(1 downto 0);
    In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In2xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In3xDI : in  std_logic_vector(WIDTH-1 downto 0);
    OutxDO : out std_logic_vector(WIDTH-1 downto 0));

end Mux4to1;


architecture simple of Mux4to1 is

begin  -- simple

  with SelxSI select
    OutxDO <=
    In0xDI when "00",
    In1xDI when "01",
    In2xDI when "10",
    In3xDI when "11",
    In0xDI when others;

end simple;
------------------------------------------------------------------------------
-- 8:1 Multiplexer
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Mux8to1 is
  
  generic (
    WIDTH : integer);

  port (
    SelxSI : in  std_logic_vector(2 downto 0);
    In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In2xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In3xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In4xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In5xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In6xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In7xDI : in  std_logic_vector(WIDTH-1 downto 0);
    OutxDO : out std_logic_vector(WIDTH-1 downto 0));

end Mux8to1;


architecture simple of Mux8to1 is

begin  -- simple

  with SelxSI select
    OutxDO <=
    In0xDI when O"0",
    In1xDI when O"1",
    In2xDI when O"2",
    In3xDI when O"3",
    In4xDI when O"4",
    In5xDI when O"5",
    In6xDI when O"6",
    In7xDI when O"7",
    In0xDI when others;

end simple;
------------------------------------------------------------------------------
-- 16:1 Multiplexer
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Mux16to1 is
  
  generic (
    WIDTH : integer);

  port (
    SelxSI : in  std_logic_vector(3 downto 0);
    In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In2xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In3xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In4xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In5xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In6xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In7xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In8xDI : in  std_logic_vector(WIDTH-1 downto 0);
    In9xDI : in  std_logic_vector(WIDTH-1 downto 0);
    InAxDI : in  std_logic_vector(WIDTH-1 downto 0);
    InBxDI : in  std_logic_vector(WIDTH-1 downto 0);
    InCxDI : in  std_logic_vector(WIDTH-1 downto 0);
    InDxDI : in  std_logic_vector(WIDTH-1 downto 0);
    InExDI : in  std_logic_vector(WIDTH-1 downto 0);
    InFxDI : in  std_logic_vector(WIDTH-1 downto 0);
    OutxDO : out std_logic_vector(WIDTH-1 downto 0));

end Mux16to1;


architecture simple of Mux16to1 is

begin  -- simple

  with SelxSI select
    OutxDO <=
    In0xDI when "0000",
    In1xDI when "0001",
    In2xDI when "0010",
    In3xDI when "0011",
    In4xDI when "0100",
    In5xDI when "0101",
    In6xDI when "0110",
    In7xDI when "0111",
    In8xDI when "1000",
    In9xDI when "1001",
    InAxDI when "1010",
    InBxDI when "1011",
    InCxDI when "1100",
    InDxDI when "1101",
    InExDI when "1110",
    InFxDI when "1111",
    In0xDI when others;

end simple;
