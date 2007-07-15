------------------------------------------------------------------------------
-- Context scheduler
--
-- Project     : 
-- URL         : $URL: $
-- Author      : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Last changed: $Id: $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;

entity Scheduler is
  
  port (
    ClkxC                        : in  std_logic;
    RstxRB                       : in  std_logic;
    SchedulerSelectxSI           : in  std_logic;
    SchedContextSequencerxDI     : in  EngineScheduleControlType;
    SchedTemporalPartitioningxDI : in  EngineScheduleControlType;
    EngineScheduleControlxEO     : out EngineScheduleControlType
    );

begin

end Scheduler;

architecture arch of Scheduler is

begin  -- arch

  process (SchedContextSequencerxDI, SchedTemporalPartitioningxDI,
           SchedulerSelectxSI)
  begin
    if (SchedulerSelectxSI = '0') then
      EngineScheduleControlxEO <= SchedContextSequencerxDI;
    else
      EngineScheduleControlxEO <= SchedTemporalPartitioningxDI;
    end if;
  end process;
  
end arch;
