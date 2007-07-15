------------------------------------------------------------------------------
-- Testbench for schedulectrl.vhd
--
-- Project    : 
-- File       : tb_schedulectrl.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003-10-17
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_ScheduleCtrl is
end tb_ScheduleCtrl;

architecture arch of tb_ScheduleCtrl is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done ,fsm_idle, fsm_startswitch,
                          fsm_runswitch, fsm_run, fsm_last);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal StartxEI   : std_logic;
  signal RunningxSI : std_logic;
  signal LastxSI    : std_logic;
  signal SwitchxEO  : std_logic;
  signal BusyxSO    : std_logic;

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : ScheduleCtrl
    port map (
      ClkxC      => ClkxC,
      RstxRB     => RstxRB,
      StartxEI   => StartxEI,
      RunningxSI => RunningxSI,
      LastxSI    => LastxSI,
      SwitchxEO  => SwitchxEO,
      BusyxSO    => BusyxSO);


  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    procedure init_stimuli (
      signal StartxEI   : out std_logic;
      signal RunningxSI : out std_logic;
      signal LastxSI    : out std_logic
      ) is
    begin
      StartxEI   <= '0';
      RunningxSI <= '0';
      LastxSI    <= '0';
    end init_stimuli;

  begin  -- process stimuliTb

    tbStatus <= rst;
    init_stimuli(StartxEI, RunningxSI, LastxSI);

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= idle;
    init_stimuli(StartxEI, RunningxSI, LastxSI);
    wait for CLK_PERIOD;

    tbStatus   <= fsm_idle;
    RunningxSI <= '0';
    LastxSI    <= '0';
    wait for CLK_PERIOD;
    RunningxSI <= '1';
    LastxSI    <= '0';
    wait for CLK_PERIOD;
    RunningxSI <= '0';
    LastxSI    <= '1';
    wait for CLK_PERIOD;
    RunningxSI <= '1';
    LastxSI    <= '1';
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(StartxEI, RunningxSI, LastxSI);
    wait for CLK_PERIOD;

    tbStatus   <= fsm_startswitch;
    StartxEI   <= '1';
    wait for CLK_PERIOD;
    tbStatus   <= fsm_run;
    StartxEI   <= '0';
    RunningxSI <= '1';                  -- supposed to go high
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= fsm_runswitch;
    StartxEI   <= '0';
    RunningxSI <= '0';                  -- goes low
    wait for CLK_PERIOD;
    tbStatus   <= fsm_run;
    StartxEI   <= '0';
    RunningxSI <= '1';                  -- supposed to go high
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
  
    tbStatus <= fsm_last;
    StartxEI   <= '0';
    RunningxSI <= '0';                  -- goes low
    LastxSI    <= '1';                  -- is high
    wait for CLK_PERIOD;
    tbStatus   <= fsm_idle;
    StartxEI   <= '0';
    RunningxSI <= '0';
    LastxSI    <= '1';                  -- is high
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;


    tbStatus <= done;
    init_stimuli(StartxEI, RunningxSI, LastxSI);
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
