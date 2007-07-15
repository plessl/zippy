------------------------------------------------------------------------------
-- Testbench for fifoctrl.vhd
--
-- Project    : 
-- File       : tb_fifoctrl.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/01/17
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_FifoCtrl is
end tb_FifoCtrl;

architecture arch of tb_FifoCtrl is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, ifwrite, ifread, engwrite, engread,
                          bothwrite, bothread);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- FIFO signals
  signal RunningxSI    : std_logic;
  signal EngInPortxEI  : std_logic;
  signal EngOutPortxEI : std_logic;
  signal DecFifoWExEI  : std_logic;
  signal DecFifoRExEI  : std_logic;
  signal FifoMuxSO     : std_logic;
  signal FifoWExEO     : std_logic;
  signal FifoRExEO     : std_logic;

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : FifoCtrl
    port map (
      RunningxSI    => RunningxSI,
      EngInPortxEI  => EngInPortxEI,
      EngOutPortxEI => EngOutPortxEI,
      DecFifoWExEI  => DecFifoWExEI,
      DecFifoRExEI  => DecFifoRExEI,
      FifoMuxSO     => FifoMuxSO,
      FifoWExEO     => FifoWExEO,
      FifoRExEO     => FifoRExEO);


  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    procedure init_stimuli (
      signal RunningxSI    : out std_logic;
      signal EngInPortxEI  : out std_logic;
      signal EngOutPortxEI : out std_logic;
      signal DecFifoWExEI  : out std_logic;
      signal DecFifoRExEI  : out std_logic) is
    begin
      RunningxSI    <= '0';
      EngInPortxEI  <= '0';
      EngOutPortxEI <= '0';
      DecFifoWExEI  <= '0';
      DecFifoRExEI  <= '0';
    end init_stimuli;

  begin  -- process stimuliTb

    tbStatus <= rst;
    init_stimuli(RunningxSI, EngInPortxEI, EngOutPortxEI, DecFifoWExEI,
                 DecFifoRExEI);

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus     <= ifwrite;            -- interface write
    DecFifoWExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(RunningxSI, EngInPortxEI, EngOutPortxEI, DecFifoWExEI,
                 DecFifoRExEI);
    wait for CLK_PERIOD;

    tbStatus     <= ifread;             -- interface read
    DecFifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(RunningxSI, EngInPortxEI, EngOutPortxEI, DecFifoWExEI,
                 DecFifoRExEI);
    wait for CLK_PERIOD;

    tbStatus      <= engwrite;          -- engine write
    EngOutPortxEI <= '1';
    wait for CLK_PERIOD;
    RunningxSI    <= '1';
    wait for CLK_PERIOD;
    RunningxSI    <= '0';
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(RunningxSI, EngInPortxEI, EngOutPortxEI, DecFifoWExEI,
                 DecFifoRExEI);
    wait for CLK_PERIOD;

    tbStatus     <= engread;            -- engine read
    EngInPortxEI <= '1';
    wait for CLK_PERIOD;
    RunningxSI   <= '1';
    wait for CLK_PERIOD;
    RunningxSI   <= '0';
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(RunningxSI, EngInPortxEI, EngOutPortxEI, DecFifoWExEI,
                 DecFifoRExEI);
    wait for CLK_PERIOD;

    tbStatus      <= bothwrite;         -- interface AND engine write
    DecFifoWExEI  <= '1';               -- (should be prevented...)
    EngOutPortxEI <= '1';
    wait for CLK_PERIOD;
    RunningxSI    <= '1';
    wait for CLK_PERIOD;
    RunningxSI    <= '0';
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(RunningxSI, EngInPortxEI, EngOutPortxEI, DecFifoWExEI,
                 DecFifoRExEI);
    wait for CLK_PERIOD;

    tbStatus     <= bothread;           -- interface AND engine read
    DecFifoRExEI <= '1';                -- (should be prevented...)
    EngInPortxEI <= '1';
    wait for CLK_PERIOD;
    RunningxSI   <= '1';
    wait for CLK_PERIOD;
    RunningxSI   <= '0';
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(RunningxSI, EngInPortxEI, EngOutPortxEI, DecFifoWExEI,
                 DecFifoRExEI);
    wait for 2*CLK_PERIOD;

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
