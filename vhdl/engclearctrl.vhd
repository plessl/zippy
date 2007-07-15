------------------------------------------------------------------------------
-- Engine clear controller; implemented as a Mealy FSM
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/engclearctrl.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003-10-18
-- $Id: engclearctrl.vhd 242 2005-04-07 09:17:51Z plessl $
------------------------------------------------------------------------------
-- FIXME: purpose of this code is not entierly clear to me
--
-- If a context switch is initiated via the registerface, the state of a
-- context can be either reset (cleared) or retained (store). This controller
-- performs the clearing or storing of state, when the context sequencer is used.
--
-- decmode: decode mode (idle?)
-- storemode: store state of current context on context switch
-- clearmode: clear state of context at context switch
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity EngClearCtrl is
  
  port (
    ClkxC          : in  std_logic;
    RstxRB         : in  std_logic;
    DecEngClrxEI   : in  std_logic;
    SchedStartxEI  : in  std_logic;
    SchedSwitchxEI : in  std_logic;
    SchedBusyxSI   : in  std_logic;
    SchedEngClrxSI : in  std_logic;
    EngClrxEO      : out std_logic);

end EngClearCtrl;


architecture simple of EngClearCtrl is

  type   state is (decmode, schedstoremode, schedclearmode);
  signal currstate : state;
  signal nextstate : state;

begin  -- simple

  --
  -- computation of next state and current outputs
  --
  process (DecEngClrxEI, SchedBusyxSI, SchedEngClrxSI, SchedStartxEI,
           SchedSwitchxEI, currstate)
  begin  -- process
    -- default assignments
    nextstate <= currstate;
    EngClrxEO <= DecEngClrxEI;
    -- non-default transitions and current outputs
    case currstate is
      
      when decmode =>

        if SchedStartxEI = '1' then
          if SchedEngClrxSI = '0' then
            EngClrxEO <= '0';
            nextstate <= schedstoremode;
          else
            EngClrxEO <= SchedSwitchxEI;
            nextstate <= schedclearmode;
          end if;
        end if;

      when schedstoremode =>

        if SchedBusyxSI = '1' then
          EngClrxEO <= '0';
        else
          nextstate <= decmode;
        end if;

      when schedclearmode =>

        if SchedBusyxSI = '1' then
          EngClrxEO <= SchedSwitchxEI;
        else
          nextstate <= decmode;
        end if;

      when others =>                    -- take care of parasitic states

        nextstate <= decmode;

    end case;
    
  end process;

  --
  -- updating of state
  --
  process (ClkxC, RstxRB)
  begin  -- process
    if RstxRB = '0' then                    -- asynchronous reset (active low)
      currstate <= decmode;
    elsif ClkxC'event and ClkxC = '1' then  -- rising clock edge
      currstate <= nextstate;
    end if;
  end process;

end simple;
