-------------------------------------------------------------------------------
-- Title      : Testbench for design "SchedulerTemporalPartitioning"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : SchedulerTemporalPartitioning_tb.vhd
-- Author     : Christian Plessl  <plessl@tik.ee.ethz.ch>
-- Company    : Computer Engineering Lab, ETH Zurich
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.auxPkg.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;

-------------------------------------------------------------------------------

entity SchedulerTemporalPartitioning_tb is

end SchedulerTemporalPartitioning_tb;

-------------------------------------------------------------------------------

architecture arch of SchedulerTemporalPartitioning_tb is

  component SchedulerTemporalPartitioning
    port (
      ClkxC               : in  std_logic;
      RstxRB              : in  std_logic;
      ScheduleStartxEI    : in  std_logic;
      ScheduleDonexSO     : out std_logic;
      NoTpContextsxSI   : in  unsigned(CNTXTWIDTH-1 downto 0);
      NoTpUserCyclesxSI : in  unsigned(CCNTWIDTH-1 downto 0);
      CExEO               : out std_logic;
      ClrContextxSO       : out std_logic_vector(CNTXTWIDTH-1 downto 0);
      ClrContextxEO       : out std_logic;
      ContextxSO          : out std_logic_vector(CNTXTWIDTH-1 downto 0);
      CycleDnCntxDO       : out std_logic_vector(CCNTWIDTH-1 downto 0);
      CycleUpCntxDO       : out std_logic_vector(CCNTWIDTH-1 downto 0));
  end component;

  -- component ports
  signal ClkxC              : std_logic := '1';
  signal RstxRB             : std_logic;
  signal ScheduleStartxE    : std_logic;
  signal ScheduleDonexS     : std_logic;
  signal NoTpContextsxS   : unsigned(CNTXTWIDTH-1 downto 0);
  signal NoTpUserCyclesxS : unsigned(CCNTWIDTH-1 downto 0);
  signal CExE               : std_logic;
  signal ClrContextxS       : std_logic_vector(CNTXTWIDTH-1 downto 0);
  signal ClrContextxE       : std_logic;
  signal ContextxS          : std_logic_vector(CNTXTWIDTH-1 downto 0);
  signal CycleDnCntxD       : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal CycleUpCntxD       : std_logic_vector(CCNTWIDTH-1 downto 0);

begin  -- arch

  -- component instantiation
  DUT : SchedulerTemporalPartitioning
    port map (
      ClkxC               => ClkxC,
      RstxRB              => RstxRB,
      ScheduleStartxEI    => ScheduleStartxE,
      ScheduleDonexSO     => ScheduleDonexS,
      NoTpContextsxSI     => NoTpContextsxS,
      NoTpUserCyclesxSI   => NoTpUserCyclesxS,
      CExEO               => CExE,
      ClrContextxSO       => ClrContextxS,
      ClrContextxEO       => ClrContextxE,
      ContextxSO          => ContextxS,
      CycleDnCntxDO       => CycleDnCntxD,
      CycleUpCntxDO       => CycleUpCntxD);

  -- clock generation
  ClkxC <= not ClkxC after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    wait until ClkxC = '1';

    NoTpUserCyclesxS <= to_unsigned(20, NoTpUserCyclesxS'length);
    NoTpContextsxS   <= to_unsigned(3, NoTpContextsxS'length);

    RstxRB <= '0';
    wait for 20 ns;
    RstxRB <= '1';

    ScheduleStartxE <= '1';
    wait for 20 ns;
    ScheduleStartxE <= '0';
    
    wait for 1300 ns;

    assert false report "simulation terminated" severity failure;
    
  end process WaveGen_Proc;

end arch;
