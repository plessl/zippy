library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;

entity SchedulerTemporalPartitioning is
  
  port (
    ClkxC             : in  std_logic;
    RstxRB            : in  std_logic;
    --
    ScheduleStartxEI  : in  std_logic;
    ScheduleDonexSO   : out std_logic;
    --   number of temporal contexts used in temporal partition
    NoTpContextsxSI   : in  unsigned(CNTXTWIDTH-1 downto 0);
    --   number of user clock-cycles to run
    NoTpUserCyclesxSI : in  unsigned(CCNTWIDTH-1 downto 0);
    -- signals to engine
    CExEO             : out std_logic;
    ClrContextxSO     : out std_logic_vector(CNTXTWIDTH-1 downto 0);
    ClrContextxEO     : out std_logic;
    ContextxSO        : out std_logic_vector(CNTXTWIDTH-1 downto 0);
    CycleDnCntxDO     : out std_logic_vector(CCNTWIDTH-1 downto 0);
    CycleUpCntxDO     : out std_logic_vector(CCNTWIDTH-1 downto 0)
    );
end SchedulerTemporalPartitioning;

architecture arch of SchedulerTemporalPartitioning is

  signal currentUserCycle : unsigned(CCNTWIDTH-1 downto 0);
  signal currentSubCycle  : unsigned(CNTXTWIDTH-1 downto 0);

  signal nextUserCycle : unsigned(CCNTWIDTH-1 downto 0);
  signal nextSubCycle  : unsigned(CNTXTWIDTH-1 downto 0);

  --signal scheduleStarted : std_logic;

  type   state_type is (sIdle, sRunning);
  signal StatexS, NextStatexS : state_type;

  
begin  -- arch

  
  process (NoTpContextsxSI, NoTpUserCyclesxSI, ScheduleStartxEI, StatexS,
           currentSubCycle, currentUserCycle)

  begin  -- process
    
    case StatexS is

      when sIdle =>

        ScheduleDonexSO <= '1';
        CExEO           <= '0';
        nextUserCycle   <= NoTpUserCyclesxSI;
        nextSubCycle    <= to_unsigned(0, currentSubCycle'length);

        if (ScheduleStartxEI = '1') then
          nextUserCycle   <= to_unsigned(0, currentUserCycle'length);
          NextStatexS <= sRunning;
        end if;

      when sRunning =>

        ScheduleDonexSO <= '0';
        CExEO           <= '1';

        -- stop schedule when last subcycle of last usercycle is reached
        if ((currentUserCycle = (NoTpUserCyclesxSI-1)) and
            (currentSubCycle = (NoTpContextsxSI-1))) then

          -- Set the nextUserCycle to the max number of user
          -- cycles. That way, the cycle down counter (CycleDnCntxDO)
          -- remains at 0 after the temporal partitioning scheduler
          -- has finished. This enables to detect the end of a run of
          -- the temporal partitioning sequencer.
          nextUserCycle   <= NoTpUserCyclesxSI;
          nextSubCycle    <= to_unsigned(0, currentSubCycle'length);
          NextStatexS   <= sIdle;

        elsif (currentSubCycle = (NoTpContextsxSI-1)) then

          -- increment currentSubCycles modulo number of Tp contexts,
          -- and increment user cycle whenever last context is reached

          nextUserCycle <= currentUserCycle + 1;
          nextSubCycle  <= to_unsigned(0, currentSubCycle'length);

        else

          nextSubCycle <= currentSubCycle + 1;

        end if;

      when others =>
        NextStatexS <= sIdle;

    end case;

  end process;


  process (ClkxC, RstxRB, currentSubCycle, currentUserCycle)
  begin
    if (RstxRB = '0') then
      StatexS          <= sIdle;
      currentUserCycle <= to_unsigned(0, currentUserCycle'length);
      currentSubCycle  <= to_unsigned(0, currentSubCycle'length);
    elsif (rising_edge(ClkxC)) then
      StatexS          <= NextStatexS;
      currentUserCycle <= nextUserCycle;
      currentSubCycle  <= nextSubCycle;
    end if;
  end process;

  ClrContextxEO <= '0';
  ClrContextxSO <= (others => '0');
  ContextxSO    <= std_logic_vector(currentSubCycle);
  CycleUpCntxDO <= std_logic_vector(currentUserCycle);
  CycleDnCntxDO <= std_logic_vector(NoTpUserCyclesxSI - currentUserCycle);

end arch;


-------------------------------------------------------------------------
-- port declaration of engine
-------------------------------------------------------------------------------

-- port (
--    ClkxC         : in  std_logic;
--    RstxRB        : in  std_logic;
--    CExEI         : in  std_logic;
--    ConfigxI      : in  engineConfigRec;
--    ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
--    ClrContextxEI : in  std_logic;
--    ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
--    CycleDnCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
--    CycleUpCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
--    InPortxDI     : in  engineInoutDataType;
--    OutPortxDO    : out engineInoutDataType;
--    InPortxEO     : out std_logic_vector(N_IOP-1 downto 0);
--    OutPortxEO    : out std_logic_vector(N_IOP-1 downto 0);
--    )
