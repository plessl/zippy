-- -*- vhdl -*-

-------------------------------------------------------------------------------
-- DUT (define in zunit.vhd)
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- CLK GENERATOR
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity clkdrv is
  
  port (
    ClkxC : out std_logic
    );
end clkdrv;

architecture arch of clkdrv is

begin  -- arch

  clkgen : process
  begin
    ClkxC <= '0';
    wait for 50 ns;
    ClkxC <= '1';
    wait for 50 ns;
  end process;

end arch;

-------------------------------------------------------------------------------
-- DRIVER
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity driver is
  port(
    WExEI   : out bit;
    RExEI   : out bit;
    DataxDI : out integer;
    DataxDO : in  integer;
    AddrxDI : out natural
    );
end driver;


architecture arch of driver is
  attribute foreign         : string;
  attribute foreign of arch : architecture is "server_init server.so";
begin


end arch;


-------------------------------------------------------------------------------
-- TESTBENCH
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.archConfigPkg.all;
use work.ZarchPkg.all;
use work.ComponentsPkg.all;

entity verification is
end verification;

architecture arch of verification is

  component driver
    port(
      WExEI   : out bit;
      RExEI   : out bit;
      DataxDI : out integer;
      DataxDO : in  integer;
      AddrxDI : out integer
      );
  end component;

  component clkdrv
    port (
      ClkxC : out std_logic
      );
  end component;

  signal ClkxC : std_logic := '0';
  signal RstxRB : std_logic := '0';
  
  signal FromDriver_DataxDI : integer := 0;
  signal FromDriver_AddrxDI : natural := 0;
  signal ToDriver_DataxDO   : integer := 0;
  signal FromDriver_WExEI   : bit     := '0';
  signal FromDriver_RExEI   : bit     := '0';


  signal ToDut_DataxDI   : std_logic_vector(IFWIDTH-1 downto 0) := (others => '0');
  signal ToDut_AddrxDI   : std_logic_vector(IFWIDTH-1 downto 0) := (others => '0');
  signal FromDut_DataxDO : std_logic_vector(IFWIDTH-1 downto 0) := (others => '0');
  signal ToDut_WExEI     : std_logic                     := '0';
  signal ToDut_RExEI     : std_logic                     := '0';

begin

  RstxRB <= '0', '1' after 1 ns;

  i_dut : ZUnit
    generic map (
      IFWIDTH   => IFWIDTH,
      DATAWIDTH => DATAWIDTH,
      CCNTWIDTH => CCNTWIDTH,
      FIFODEPTH => FIFODEPTH)
    port map (
      WExEI   => ToDut_WExEI,
      RExEI   => ToDut_RExEI,
      DataxDI => ToDut_DataxDI,         -- std_logic_vector
      DataxDO => FromDut_DataxDO,       -- std_logic_vector
      AddrxDI => ToDut_AddrxDI,         -- std_logic_vector
      ClkxC   => ClkxC,
      RstxRB  => RstxRB
      );

  i_driver : driver
    port map (
      WExEI   => FromDriver_WExEI,
      RExEI   => FromDriver_RExEI,
      DataxDI => FromDriver_DataxDI,    -- integer
      DataxDO => ToDriver_DataxDO,      -- integer
      AddrxDI => FromDriver_AddrxDI     -- natural
      );

  i_clkdrv : clkdrv
    port map (
      ClkxC => ClkxC);

  ToDut_DataxDI    <= std_logic_vector(TO_SIGNED(FromDriver_DataxDI, IFWIDTH));
  ToDut_AddrxDI    <= std_logic_vector(TO_UNSIGNED(FromDriver_AddrxDI, IFWIDTH));
  ToDriver_DataxDO <= TO_INTEGER(signed(FromDut_DataxDO));
  ToDut_WExEI      <= to_stdulogic(FromDriver_WExEI);
  ToDut_RExEI      <= to_stdulogic(FromDriver_RExEI);
  
end arch;

