------------------------------------------------------------------------------
-- Testbench for schedulestore.vhd
--
-- Project    : 
-- File       : tb_schedulestore.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003-10-16
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_ScheduleStore is
end tb_ScheduleStore;

architecture arch of tb_ScheduleStore is

  constant WRDWIDTH : integer := 32;
  constant CONWIDTH : integer := 8;
  constant CYCWIDTH : integer := 8;
  constant ADRWIDTH : integer := 6;

  constant FILLWIDTH : integer := WRDWIDTH-(CONWIDTH+CYCWIDTH+ADRWIDTH+1);

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, progSchedule, loadSPC, resetSPC);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal SPCclrxEI  : std_logic;
  signal SPCloadxEI : std_logic;
  signal WExEI      : std_logic;
  signal IAddrxDI   : std_logic_vector(ADRWIDTH-1 downto 0);
  signal IWordxDI   : std_logic_vector(WRDWIDTH-1 downto 0);
  signal ContextxDO : std_logic_vector(CONWIDTH-1 downto 0);
  signal CyclesxDO  : std_logic_vector(CYCWIDTH-1 downto 0);
  signal LastxSO    : std_logic;

  -- testbench signals
  signal IContextxD : std_logic_vector(CONWIDTH-1 downto 0);
  signal ICyclesxD  : std_logic_vector(CYCWIDTH-1 downto 0);
  signal INextAdrxD : std_logic_vector(ADRWIDTH-1 downto 0);
  signal ILastxD    : std_logic;
  signal IFillxD    : std_logic_vector(FILLWIDTH-1 downto 0) := (others => '0');
  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : ScheduleStore
    generic map (
      WRDWIDTH => WRDWIDTH,
      CONWIDTH => CONWIDTH,
      CYCWIDTH => CYCWIDTH,
      ADRWIDTH => ADRWIDTH)
    port map (
      ClkxC      => ClkxC,
      RstxRB     => RstxRB,
      WExEI      => WExEI,
      IAddrxDI   => IAddrxDI,
      IWordxDI   => IWordxDI,
      SPCclrxEI  => SPCclrxEI,
      SPCloadxEI => SPCloadxEI,
      ContextxDO => ContextxDO,
      CyclesxDO  => CyclesxDO,
      LastxSO    => LastxSO);

  ----------------------------------------------------------------------------
  -- instruction word encoding
  ----------------------------------------------------------------------------
  IWordxDI <= IFillxD & IContextxD & ICyclesxD & INextAdrxD & ILastxD;

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    procedure init_stimuli (
      signal WExEI      : out std_logic;
      signal IAddrxDI   : out std_logic_vector(ADRWIDTH-1 downto 0);
      signal IContextxD : out std_logic_vector(CONWIDTH-1 downto 0);
      signal ICyclesxD  : out std_logic_vector(CYCWIDTH-1 downto 0);
      signal INextAdrxD : out std_logic_vector(ADRWIDTH-1 downto 0);
      signal ILastxD    : out std_logic;
      signal SPCclrxEI  : out std_logic;
      signal SPCloadxEI : out std_logic) is
    begin
      WExEI      <= '0';
      IAddrxDI   <= (others => '0');
      IContextxD <= (others => '0');
      ICyclesxD  <= (others => '0');
      INextAdrxD <= (others => '0');
      ILastxD    <= '0';
      SPCclrxEI  <= '0';
      SPCloadxEI <= '0';
    end init_stimuli;

  begin  -- process stimuliTb

    tbStatus <= rst;
    init_stimuli(WExEI, IAddrxDI, IContextxD, ICyclesxD, INextAdrxD, ILastxD, SPCclrxEI, SPCloadxEI);

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= idle;
    init_stimuli(WExEI, IAddrxDI, IContextxD, ICyclesxD, INextAdrxD, ILastxD, SPCclrxEI, SPCloadxEI);
    wait for CLK_PERIOD;

    --
    -- program schedule into schedule store
    --
    
    tbStatus   <= progSchedule;
    IAddrxDI   <= std_logic_vector(to_unsigned(0, ADRWIDTH));
    IContextxD <= std_logic_vector(to_unsigned(10, CONWIDTH));
    ICyclesxD  <= std_logic_vector(to_unsigned(100, CYCWIDTH));
    INextAdrxD <= std_logic_vector(to_unsigned(1, ADRWIDTH));
    ILastxD    <= '0';
    WExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= progSchedule;
    IAddrxDI   <= std_logic_vector(to_unsigned(1, ADRWIDTH));
    IContextxD <= std_logic_vector(to_unsigned(11, CONWIDTH));
    ICyclesxD  <= std_logic_vector(to_unsigned(101, CYCWIDTH));
    INextAdrxD <= std_logic_vector(to_unsigned(2, ADRWIDTH));
    ILastxD    <= '0';
    WExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= progSchedule;
    IAddrxDI   <= std_logic_vector(to_unsigned(2, ADRWIDTH));
    IContextxD <= std_logic_vector(to_unsigned(12, CONWIDTH));
    ICyclesxD  <= std_logic_vector(to_unsigned(102, CYCWIDTH));
    INextAdrxD <= std_logic_vector(to_unsigned(3, ADRWIDTH));
    ILastxD    <= '0';
    WExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= progSchedule;
    IAddrxDI   <= std_logic_vector(to_unsigned(3, ADRWIDTH));
    IContextxD <= std_logic_vector(to_unsigned(13, CONWIDTH));
    ICyclesxD  <= std_logic_vector(to_unsigned(103, CYCWIDTH));
    INextAdrxD <= std_logic_vector(to_unsigned(4, ADRWIDTH));
    ILastxD    <= '0';
    WExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(WExEI, IAddrxDI, IContextxD, ICyclesxD, INextAdrxD, ILastxD, SPCclrxEI, SPCloadxEI);
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    --
    -- load schedule PC n times
    --
    
    for i in 0 to 3 loop
      tbStatus <= loadSPC;
      SPCloadxEI <= '1';
      wait for CLK_PERIOD;
    end loop;  -- i


    --
    -- reset schedule PC (points to store address 0)
    --
    
    tbStatus <= idle;
    init_stimuli(WExEI, IAddrxDI, IContextxD, ICyclesxD, INextAdrxD, ILastxD, SPCclrxEI, SPCloadxEI);
    wait for CLK_PERIOD;

    tbStatus <= resetSPC;
    SPCclrxEI <= '1';
    wait for CLK_PERIOD;

    
    tbStatus <= idle;
    init_stimuli(WExEI, IAddrxDI, IContextxD, ICyclesxD, INextAdrxD, ILastxD, SPCclrxEI, SPCloadxEI);
    wait for CLK_PERIOD;

    -- stop simulation
    wait until (ClkxC'event and ClkxC = '1');
    assert false
      report "stimuli processed; sim. terminated after " & int2str(ccount) &
      " cycles"
      severity failure;
    
  end process stimuliTb;

  ----------------------------------------------------------------------------
  -- clock and reset generation
  ----------------------------------------------------------------------------
  ClkxC  <= not ClkxC after CLK_PERIOD/2;
  RstxRB <= '0', '1'  after CLK_PERIOD*1.25;

  ----------------------------------------------------------------------------
  -- cycle counter
  ----------------------------------------------------------------------------
  cyclecounter : process (ClkxC)
  begin
    if (ClkxC'event and ClkxC = '1') then
      ccount <= ccount + 1;
    end if;
  end process cyclecounter;

end arch;
