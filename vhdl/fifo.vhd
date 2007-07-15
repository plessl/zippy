------------------------------------------------------------------------------
-- FIFO with fill level status output
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/fifo.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/06/25
-- $Id: fifo.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------
-- FIFO: Data at RdDataxDO is not registered but a direct combinational
-- result of the read address RdAddrxDI.
-- The FIFO uses separate read and write address ports and data ports
--
-- The FIFO provides the followign status flags:
--   EmptyxSO      FIFO is empty
--   FullxSO       FIFO is full
--   FillLevelxDO  Number of words in FIFO
-------------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- FIFO memory block (1 read port / 1 write port)
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;

entity FifoMem is

  generic (
    WIDTH : integer;
    DEPTH : integer);
  port (
    ClkxC     : in  std_logic;
    RstxRB    : in  std_logic;
    WExEI     : in  std_logic;
    WrAddrxDI : in  std_logic_vector(log2(DEPTH)-1 downto 0);
    WrDataxDI : in  std_logic_vector(WIDTH-1 downto 0);
    RdAddrxDI : in  std_logic_vector(log2(DEPTH)-1 downto 0);
    RdDataxDO : out std_logic_vector(WIDTH-1 downto 0));

end FifoMem;

architecture simple of FifoMem is

  type memArray is array (DEPTH-1 downto 0) of
    std_logic_vector(WIDTH-1 downto 0);
  signal MemBlock : memArray;
  
begin  -- simple

  RdDataxDO <= MemBlock(to_integer(unsigned(RdAddrxDI)));

  WriteMemBlock : process (ClkxC, RstxRB)
  begin
    if RstxRB = '0' then
      for i in MemBlock'range loop
        MemBlock(i) <= (others => '0');
      end loop;
    elsif ClkxC'event and ClkxC = '1' then
      if WExEI = '1' then
        MemBlock(to_integer(unsigned(WrAddrxDI))) <= WrDataxDI;
      end if;
    end if;
  end process WriteMemBlock;

end simple;


-----------------------------------------------------------------------------
-- FIFO
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.AuxPkg.all;

entity Fifo is

  generic (
    WIDTH : integer;
    DEPTH : integer);
  port (
    ClkxC        : in  std_logic;
    RstxRB       : in  std_logic;
    WExEI        : in  std_logic;
    RExEI        : in  std_logic;
    DinxDI       : in  std_logic_vector(WIDTH-1 downto 0);
    DoutxDO      : out std_logic_vector(WIDTH-1 downto 0);
    EmptyxSO     : out std_logic;
    FullxSO      : out std_logic;
    FillLevelxDO : out std_logic_vector(log2(DEPTH) downto 0));

end Fifo;

architecture simple of Fifo is

  component FifoMem
    generic (
      WIDTH : integer;
      DEPTH : integer);
    port (
      ClkxC     : in  std_logic;
      RstxRB    : in  std_logic;
      WExEI     : in  std_logic;
      WrAddrxDI : in  std_logic_vector(log2(DEPTH)-1 downto 0);
      WrDataxDI : in  std_logic_vector(WIDTH-1 downto 0);
      RdAddrxDI : in  std_logic_vector(log2(DEPTH)-1 downto 0);
      RdDataxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  signal ReadPtrxD   : std_logic_vector(log2(DEPTH)-1 downto 0);
  signal WritePtrxD  : std_logic_vector(log2(DEPTH)-1 downto 0);
  signal FillLevelxD : unsigned(log2(DEPTH) downto 0);
  signal MemOutxD    : std_logic_vector(WIDTH-1 downto 0);
  signal EmptyxS     : std_logic;
  signal FullxS      : std_logic;
  signal ReadCondxS  : std_logic;       -- read condition status
  signal WriteCondxS : std_logic;       -- write condition status
  signal ClearxE     : std_logic;

begin  -- simple

  FMem : FifoMem
    generic map (
      WIDTH => WIDTH,
      DEPTH => DEPTH)
    port map (
      ClkxC     => ClkxC,
      RstxRB    => RstxRB,
      WExEI     => WriteCondxS,
      WrAddrxDI => WritePtrxD,
      WrDataxDI => DinxDI,
      RdAddrxDI => ReadPtrxD,
      RdDataxDO => MemOutxD);

  OutReg : Reg_clr_en
    generic map (
      WIDTH => WIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      ClrxEI  => ClearxE,
      EnxEI   => ReadCondxS,
      DinxDI  => MemOutxD,
      DoutxDO => DoutxDO);

  ReadPtr : process (ClkxC, RstxRB)
  begin
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      ReadPtrxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if (ReadCondxS = '1') then
        ReadPtrxD <= std_logic_vector(unsigned(ReadPtrxD) + 1);
      end if;
    end if;
  end process ReadPtr;

  WritePtr : process (ClkxC, RstxRB)
  begin
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      WritePtrxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      if (WriteCondxS = '1') then
        WritePtrxD <= std_logic_vector(unsigned(WritePtrxD) + 1);
      end if;
    end if;
  end process WritePtr;

  FillLevel : process (ClkxC, RstxRB)
  begin
    if RstxRB = '0' then                -- asynchronous reset (active low)
      FillLevelxD <= (others => '0');
    elsif ClkxC'event and ClkxC = '1' then                -- rising clock edge
      if (ReadCondxS = '1') and (WriteCondxS = '0') then  -- read
        FillLevelxD <= FillLevelxD - 1;
      end if;
      if (WriteCondxS = '1') and (ReadCondxS = '0') then  -- write
        FillLevelxD <= FillLevelxD + 1;
      end if;
      -- if read/write: do nothing
    end if;
  end process FillLevel;

  -- combinational logic
  EmptyxS <= '1' when (FillLevelxD = 0) else '0';
  FullxS  <= FillLevelxD(FillLevelxD'high);

  ReadCondxS  <= '1' when (RExEI = '1' and EmptyxS = '0') else '0';
  WriteCondxS <= '1' when (WExEI = '1' and FullxS = '0')  else '0';

  -- Previous versions used a very strange implementation of the FIFO, which
  -- did explicitly reset the FIFO output register after a word was read. Now
  -- the FIFO output remains constant until a new word is requested.
  --
  -- ClearxE <= not ReadCondxS;
  --
  -- NOTE:
  -- Be aware that the new word is available only with one cycle of delay due
  -- to the register. While this is not a problem for single context
  -- configuration where a word is read from the FIFO in every cycle,
  -- difficulties arise for virtualized circuits: If the first context requests
  -- a new word, the word is available only in the next cycle, thus context 0
  -- operates on the old value of the FIFO, where subsequent contexts operate
  -- on the next FIFO value. This leads to problems, if a primary output (FIFO
  -- output) is read be other contexts than the first context, since the
  -- contexts operate not on the same primary input in that case!
  --
  -- This problem can be solved, if the last (instead of the first) context is
  -- requesting a new word from the FIFO. Like this, the last context operates
  -- still on the 'last' FIFO output value, while the new FIFO output will be
  -- available when context 0 is activated.
  --
  ClearxE <= '0';

  
  -- outputs
  FullxSO      <= FullxS;
  EmptyxSO     <= EmptyxS;
  FillLevelxDO <= std_logic_vector(FillLevelxD);

  Observe : process (ClkxC)
  begin
    if ClkxC'event and ClkxC = '1' then  -- rising clock edge
      -- read on empty
      assert (RExEI = '1') nand (EmptyxS = '1')
        report "read request on empty FIFO"
        severity warning;
      -- write on full
      assert (WExEI = '1') nand (FullxS = '1')
        report "write request on full FIFO"
        severity warning;
    end if;
  end process Observe;
  
end simple;

