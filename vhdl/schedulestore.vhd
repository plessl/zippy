------------------------------------------------------------------------------
-- Schedule store
--
-- Project     : 
-- File        : schedulestore.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003-10-16
-- Last changed: $LastChangedDate: 2004-10-07 11:06:32 +0200 (Thu, 07 Oct 2004) $
------------------------------------------------------------------------------
-- Schedule store implements the RAM used for storing the context scheduler
-- entries. Further the schedule store decodes the information in the schedule
-- RAM i.e. it provides the current context, cycles and next context address
-- to the context scheduler.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-06 CP added documentation
-------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- memory block
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.auxPkg.all;

entity ScheduleStoreMem is
  
  generic (
    WIDTH : integer;
    DEPTH : integer);                   -- context width

  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    WExEI   : in  std_logic;
    AddrxDI : in  std_logic_vector(log2(DEPTH)-1 downto 0);
    DataxDI : in  std_logic_vector(WIDTH-1 downto 0);
    DataxDO : out std_logic_vector(WIDTH-1 downto 0));

end ScheduleStoreMem;


architecture simple of ScheduleStoreMem is

  type memArray is array (DEPTH-1 downto 0) of
    std_logic_vector(WIDTH-1 downto 0);
  signal MemBlock : memArray;

begin  -- simple

  DataxDO <= MemBlock(to_integer(unsigned(AddrxDI)));

  WriteMemBlock : process (ClkxC, RstxRB)
  begin
    if RstxRB = '0' then
      for i in MemBlock'range loop
        MemBlock(i) <= (others => '0');
      end loop;
    elsif ClkxC'event and ClkxC = '1' then
      if WExEI = '1' then
        MemBlock(to_integer(unsigned(AddrxDI))) <= DataxDI;
      end if;
    end if;
  end process WriteMemBlock;

end simple;


-----------------------------------------------------------------------------
-- Schedule Store
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity ScheduleStore is
  
  generic (
    WRDWIDTH : integer;                 -- width of instruction word
    CONWIDTH : integer;                 -- width of context field
    CYCWIDTH : integer;                 -- width of cycles field
    ADRWIDTH : integer);                -- width of address field
                                        -- (defines depth of schedule store)
  port (
    ClkxC      : in  std_logic;
    RstxRB     : in  std_logic;
    WExEI      : in  std_logic;
    IAddrxDI   : in  std_logic_vector(ADRWIDTH-1 downto 0);
    IWordxDI   : in  std_logic_vector(WRDWIDTH-1 downto 0);
    SPCclrxEI  : in  std_logic;
    SPCloadxEI : in  std_logic;
    ContextxDO : out std_logic_vector(CONWIDTH-1 downto 0);
    CyclesxDO  : out std_logic_vector(CYCWIDTH-1 downto 0);
    LastxSO    : out std_logic);

end ScheduleStore;


architecture simple of ScheduleStore is

  component ScheduleStoreMem
    generic (
      WIDTH : integer;
      DEPTH : integer);
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      WExEI   : in  std_logic;
      AddrxDI : in  std_logic_vector(log2(DEPTH)-1 downto 0);
      DataxDI : in  std_logic_vector(WIDTH-1 downto 0);
      DataxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  signal InstxD        : std_logic_vector(WRDWIDTH-1 downto 0);
  signal AddrxD        : std_logic_vector(ADRWIDTH-1 downto 0);
  signal SPCAddrxD     : std_logic_vector(ADRWIDTH-1 downto 0);
  signal SPCNextAddrxD : std_logic_vector(ADRWIDTH-1 downto 0);

begin  -- simple

  SchedStoreMem : ScheduleStoreMem
    generic map (
      WIDTH => WRDWIDTH,
      DEPTH => 2**ADRWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      WExEI   => WExEI,
      AddrxDI => AddrxD,
      DataxDI => IWordxDI,
      DataxDO => InstxD);

  SchedPC : Reg_Clr_En
    generic map (
      WIDTH => ADRWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      ClrxEI  => SPCclrxEI,
      EnxEI   => SPCloadxEI,
      DinxDI  => SPCNextAddrxD,
      DoutxDO => SPCAddrxD);

  AdrMux : Mux2to1
    generic map (
      WIDTH => ADRWIDTH)
    port map (
      SelxSI => WExEI,
      In0xDI => SPCAddrxD,
      In1xDI => IAddrxDI,
      OutxDO => AddrxD);

  -- instruction word decoding
  ContextxDO    <= InstxD(CONWIDTH+CYCWIDTH+ADRWIDTH downto CYCWIDTH+ADRWIDTH+1);
  CyclesxDO     <= InstxD(CYCWIDTH+ADRWIDTH downto ADRWIDTH+1);
  SPCNextAddrxD <= InstxD(ADRWIDTH downto 1);
  LastxSO       <= InstxD(0);

end simple;
