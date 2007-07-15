------------------------------------------------------------------------------
-- Schedule controller; implemented as a Mealy FSM
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/schedulectrl.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003-10-16
-- $Id: schedulectrl.vhd 242 2005-04-07 09:17:51Z plessl $
------------------------------------------------------------------------------
-- The schedule controller implements the sequencing of the contexts. The
-- sequence is specified in the context sequence program store (see Rolfs PhD
-- thesis pp 77ff).
--
-- The controller stays in idle mode, until the sequencing is
-- acitvated (StartxEI = '1'). After activation it switches to the
-- first context and executes it (run state) until the number of
-- execution cycles for this context has been reached (RunningSI =
-- '0'). If the last context has been executed (LastxSI=0) the
-- scheduler is stopped, otherwise the scheduler switches to the next
-- context as specified with the next address field in the instruction
-- word.
--
-- FIXME: Maybe the switch context state could be removed, thus the
-- context could be switched in a single cycle. While this doesn't
-- make much of a difference in performance when contexts are executed
-- for many cycles, it makes a differenece when the context has to be switched
-- every cycle, which is the case for certain virtualization modes.
--
-- FIXME: The sequencer could be extended to provide a little more microcode
-- features. E.g. the ability to run a certain schedule repeatedly.
--
-- FIXME: Rolf mentioned something about status flags, that can be polled from
-- CPUs. What flags can be polled?
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity ScheduleCtrl is
  
  port (
    ClkxC      : in  std_logic;
    RstxRB     : in  std_logic;
    StartxEI   : in  std_logic;
    RunningxSI : in  std_logic;
    LastxSI    : in  std_logic;
    SwitchxEO  : out std_logic;         -- initiate context switch
    BusyxSO    : out std_logic);        -- busy status flag

end ScheduleCtrl;


architecture simple of ScheduleCtrl is

  type   state is (idle, switch, run);
  signal currstate : state;
  signal nextstate : state;
  
begin  -- simple

  --
  -- computation of next state and current outputs
  --
  process (LastxSI, RunningxSI, StartxEI, currstate)
  begin  -- process
    -- default assignments
    nextstate <= currstate;
    SwitchxEO <= '0';
    BusyxSO   <= '0';

    -- non-default transitions and current outputs
    case currstate is
      when idle =>
        if StartxEI = '1' then
          SwitchxEO <= '1';
          BusyxSO   <= '1';
          nextstate <= switch;
        end if;
      when switch =>
        BusyxSO   <= '1';
        nextstate <= run;
      when run =>
        BusyxSO   <= '1';
        if (RunningxSI = '0') and (LastxSI = '0') then
          SwitchxEO <= '1';
          nextstate <= switch;
        elsif (RunningxSI = '0') and (LastxSI = '1') then
          nextstate <= idle;
        end if;
      -- have all parasitic states flow into idle state
      when others =>
        nextstate <= idle;
    end case;
  end process;

  --
  -- updating of state
  --
  process (ClkxC, RstxRB)
  begin  -- process
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      currstate <= idle;
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      currstate <= nextstate;
    end if;
  end process;

end simple;
