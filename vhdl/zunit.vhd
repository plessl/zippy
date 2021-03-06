------------------------------------------------------------------------------
-- multi-context ZIPPY unit
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/zunit.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/06/25
-- $Id: zunit.vhd 478 2006-03-21 13:37:54Z plessl $
------------------------------------------------------------------------------
-- Top level entity the defines the whole multi-context Zippy unit. All 
-- top-level comonents (Engine, Configuration memory, host interface decoder,
-- FIFOs, Controllers, context scheduler) are instantiated and connected.
-------------------------------------------------------------------------------

-- TODO: Check for all occurences of RunningxS and CycleDnCntxD whether they
-- are used to control activities of the zunit. These signals are generated by
-- the old scheduler, and should be replaced by the corresponding signals that
-- are generated by the new generic Scheduler component.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;

entity ZUnit is
  
  generic (
    IFWIDTH   : integer;
    DATAWIDTH : integer;
    CCNTWIDTH : integer;
    FIFODEPTH : integer);
  port (
    ClkxC   : in  std_logic;
    RstxRB  : in  std_logic;
    WExEI   : in  std_logic;
    RExEI   : in  std_logic;
    AddrxDI : in  std_logic_vector(IFWIDTH-1 downto 0);
    DataxDI : in  std_logic_vector(IFWIDTH-1 downto 0);
    DataxDO : out std_logic_vector(IFWIDTH-1 downto 0));

begin
  -- assert statements (is there a better place for this?)
  SIWformat : assert SIW_WRDWIDTH >= SIW_CONWIDTH+SIW_CYCWIDTH+SIW_ADRWIDTH+1
    report "ERROR: incorrect SIW format definition"
    severity error;

end ZUnit;


architecture simple of ZUnit is

  -- Interface Signals
  signal IFWExE      : std_logic;
  signal IFRExE      : std_logic;
  signal IFAddrxD    : std_logic_vector(IFWIDTH-1 downto 0);
  signal IFDataInxD  : std_logic_vector(IFWIDTH-1 downto 0);
  signal IFDataOutxD : std_logic_vector(IFWIDTH-1 downto 0);

  -- Decoded Control Signals
  signal DecRstxRB                   : std_logic;
  signal DecLoadCCxE                 : std_logic;
  signal DecFifo0WExE                : std_logic;
  signal DecFifo0RExE                : std_logic;
  signal DecFifo1WExE                : std_logic;
  signal DecFifo1RExE                : std_logic;
  signal DecCMWExE                   : std_logic_vector(N_CONTEXTS-1 downto 0);
  signal DecCMLoadPtrxE              : std_logic_vector(N_CONTEXTS-1 downto 0);
  signal DecCSRxE                    : std_logic;
  signal DecEngClrCntxtxE            : std_logic;
  signal DecDoutMuxS                 : std_logic_vector(2 downto 0);
  signal DecSSWExE                   : std_logic;
  signal DecSSIAddrxD                : std_logic_vector(SIW_ADRWIDTH-1 downto 0);
  signal DecScheduleStartxE          : std_logic;
  signal DecContextSchedulerSelectxE : std_logic;

  -- signals for context sequencer
  signal SchedContextSequencerxD     : EngineScheduleControlType;
  signal SchedTemporalPartitioningxD : EngineScheduleControlType;
  signal EngineScheduleControlxE     : EngineScheduleControlType;

  -- indicates that the currently selected context scheduler has done
  -- its work
  signal ContextSchedulerDonexS : std_logic;


  -- 0: old context sequencer/cycle counter scheduler
  -- 1: temporal partitioning scheduler
  signal ContextSchedulerSelectxD : std_logic;

  signal TPSchedulerStartxE : std_logic;
  signal TPSchedulerDonexS  : std_logic;

  -- signals for virtualization support (temporal partitioning)
  signal dummy0, dummy1      : std_logic;
  signal DecVirtContextNoxE  : std_logic;
  signal VirtContextNoxD     : std_logic_vector(IFWIDTH-1 downto 0);
  signal VirtContextNoxDus   : unsigned(CNTXTWIDTH-1 downto 0);
  signal VirtUserCycleNoxD   : std_logic_vector(IFWIDTH-1 downto 0);
  signal VirtUserCycleNoxDus : unsigned(IFWIDTH-1 downto 0);


  -- Misc. Signals
  signal CSSchedulerRunningxS : std_logic;
  signal CCLoadxE             : std_logic;
  signal CCMuxS               : std_logic;
  signal IFCCinxD             : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal CCinxD               : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal CycleDnCntxD         : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal CycleUpCntxD         : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal ContextxS            : std_logic_vector(CNTXTWIDTH-1 downto 0);
  signal Contexts             : contextArray;
  signal DataInxD             : data_word;
  signal IFCSRinxD            : std_logic_vector(CNTXTWIDTH-1 downto 0);
  signal CSRinxD              : std_logic_vector(CNTXTWIDTH-1 downto 0);
  signal CSREnxE              : std_logic;
--  signal CSRMuxS              : std_logic;

  -- FIFO signals
  signal Fifo0MuxS   : std_logic;
  signal Fifo0WExE   : std_logic;
  signal Fifo0RExE   : std_logic;
  signal Fifo0InxD   : data_word;
  signal Fifo0OutxD  : data_word;
  signal Fifo0FillxD : std_logic_vector(log2(FIFODEPTH) downto 0);
  signal Fifo1MuxS   : std_logic;
  signal Fifo1WExE   : std_logic;
  signal Fifo1RExE   : std_logic;
  signal Fifo1InxD   : data_word;
  signal Fifo1OutxD  : data_word;
  signal Fifo1FillxD : std_logic_vector(log2(FIFODEPTH) downto 0);

  -- computation engine signals
  signal EngCfg        : engineConfigRec;
  signal EngCfgxD      : contextType;
  signal EngInPort0xE  : std_logic;
  signal EngInPort1xE  : std_logic;
  signal EngOutPort0xE : std_logic;
  signal EngOutPort1xE : std_logic;
  signal EngOut0xD     : data_word;
  signal EngOut1xD     : data_word;
  signal EngClrCntxtxE : std_logic;

  -- FIXME: make more generic, works only for N_IOP=2, FIFOs hardcoded
  signal FifoOutxD    : engineInoutDataType;
  signal EngOutxD     : engineInoutDataType;
  signal EngInPortxE  : std_logic_vector(N_IOP-1 downto 0);
  signal EngOutPortxE : std_logic_vector(N_IOP-1 downto 0);

  -- context scheduler signals (controller and store)
  signal SchedSwitchxE     : std_logic;
  signal SchedBusyxS       : std_logic;
  signal NotSchedBusyxS    : std_logic;
  signal CSSchedulerDonexS : std_logic;
  signal SchedLastxS       : std_logic;
  signal SSLastxS          : std_logic;
  signal SSIWordxD         : std_logic_vector(SIW_WRDWIDTH-1 downto 0);
  signal SSContextxD       : std_logic_vector(SIW_CONWIDTH-1 downto 0);
  signal SSCyclesxD        : std_logic_vector(SIW_CYCWIDTH-1 downto 0);
  signal SSCSRinxD         : std_logic_vector(CNTXTWIDTH-1 downto 0);
  signal SSCCinxD          : std_logic_vector(CCNTWIDTH-1 downto 0);

  -- resized output mux signals
  signal Fifo0OutResxD               : std_logic_vector(IFWIDTH-1 downto 0);
  signal Fifo1OutResxD               : std_logic_vector(IFWIDTH-1 downto 0);
  signal Fifo0FillResxD              : std_logic_vector(IFWIDTH-1 downto 0);
  signal Fifo1FillResxD              : std_logic_vector(IFWIDTH-1 downto 0);
  signal CycleDnCntResxD             : std_logic_vector(IFWIDTH-1 downto 0);
  signal ContextSchedulerStatusResxD : std_logic_vector(IFWIDTH-1 downto 0);

  -- Aux. signals
  signal NCsignxS : std_logic;                             -- not connected
  signal NCdataxS : data_word;                             -- not connected
  signal NCifxS   : std_logic_vector(IFWIDTH-1 downto 0);  -- not connected

begin  -- simple

  Decdr : Decoder
    generic map (
      REGWIDTH => IFWIDTH)
    port map (
      RstxRB                    => RstxRB,
      WrReqxEI                  => IFWExE,
      RdReqxEI                  => IFRExE,
      RegNrxDI                  => IFAddrxD,
      SystRstxRBO               => DecRstxRB,
      CCloadxEO                 => DecLoadCCxE,
      VirtContextNoxEO          => DecVirtContextNoxE,
      ContextSchedulerSelectxEO => DecContextSchedulerSelectxE,
      Fifo0WExEO                => DecFifo0WExE,
      Fifo0RExEO                => DecFifo0RExE,
      Fifo1WExEO                => DecFifo1WExE,
      Fifo1RExEO                => DecFifo1RExE,
      CMWExEO                   => DecCMWExE,
      CMLoadPtrxEO              => DecCMLoadPtrxE,
      CSRxEO                    => DecCSRxE,
      EngClrCntxtxEO            => DecEngClrCntxtxE,
      SSWExEO                   => DecSSWExE,
      SSIAddrxDO                => DecSSIAddrxD,
      ScheduleStartxE           => DecScheduleStartxE,
      DoutMuxSO                 => DecDoutMuxS);

  MCMem : for i in N_CONTEXTS-1 downto 0 generate
    CfgMem_i : ConfigMem
      generic map (
        CFGWIDTH => ENGN_CFGLEN,
        PTRWIDTH => IFWIDTH,            -- FIXME: too wide, but ok for now
        SLCWIDTH => IFWIDTH)
      port map (
        ClkxC           => ClkxC,
        RstxRB          => DecRstxRB,
        WExEI           => DecCMWExE(i),
        CfgSlicexDI     => IFDataInxD,
        LoadSlicePtrxEI => DecCMLoadPtrxE(i),
        SlicePtrxDI     => IFDataInxD,
        ConfigWordxDO   => Contexts(i));
  end generate MCMem;

  VirtContextNoxDus   <= resize(unsigned(VirtContextNoxD), CNTXTWIDTH);
  VirtUserCycleNoxDus <= unsigned(VirtUserCycleNoxD);

  TPSchedulerStartxE <= DecScheduleStartxE when (ContextSchedulerSelectxD = '1') else '0';

  ContextSchedulerTp : SchedulerTemporalPartitioning
    port map (
      ClkxC             => ClkxC,
      RstxRB            => RstxRB,
      ScheduleStartxEI  => TPSchedulerStartxE,
      ScheduleDonexSO   => TPSchedulerDonexS,
      NoTpContextsxSI   => VirtContextNoxDus,
      NoTpUserCyclesxSI => VirtUserCycleNoxDus,
      CExEO             => SchedTemporalPartitioningxD.CExE,
      ClrContextxSO     => SchedTemporalPartitioningxD.ClrContextxS,
      ClrContextxEO     => SchedTemporalPartitioningxD.ClrContextxE,
      ContextxSO        => SchedTemporalPartitioningxD.ContextxS,
      CycleUpCntxDO     => SchedTemporalPartitioningxD.CycleUpCntxD,
      CycleDnCntxDO     => SchedTemporalPartitioningxD.CycleDnCntxD
      );

  ContextScheduler : Scheduler
    port map (
      ClkxC                        => ClkxC,
      RstxRB                       => RstxRB,
      SchedulerSelectxSI           => ContextSchedulerSelectxD,
      SchedContextSequencerxDI     => SchedContextSequencerxD,
      SchedTemporalPartitioningxDI => SchedTemporalPartitioningxD,
      EngineScheduleControlxEO     => EngineScheduleControlxE);

  ContSelReg : Reg_En
    generic map (
      WIDTH => CNTXTWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => DecRstxRB,
      EnxEI   => CSREnxE,
      DinxDI  => CSRinxD,
      DoutxDO => ContextxS);  -- context select for old context scheduler

  -- context de-multiplexer. select one of the contexts that is fed to
  -- the engine
  EngCfgxD <= Contexts(to_integer(unsigned(EngineScheduleControlxE.ContextxS)));
  
  -- FIXME: find a better name for Fifo0MuxS
  
  -- Select source for FIFO input, either data from host interface of data
  -- generated by engine.
  Fifo0InxD <= DataInxD when (Fifo0MuxS = '0') else EngOut0xD;
  
  Fifo0 : Fifo
    generic map (
      WIDTH => DATAWIDTH,
      DEPTH => FIFODEPTH)
    port map (
      ClkxC        => ClkxC,
      RstxRB       => DecRstxRB,
      WExEI        => Fifo0WExE,
      RExEI        => Fifo0RExE,
      DinxDI       => Fifo0InxD,
      DoutxDO      => Fifo0OutxD,
      EmptyxSO     => NCsignxS,
      FullxSO      => NCsignxS,
      FillLevelxDO => Fifo0FillxD);

  Fifo0Ctrl : FifoCtrl
    port map (
      RunningxSI    => EngineScheduleControlxE.CExE,
      EngInPortxEI  => EngInPort0xE,
      EngOutPortxEI => EngOutPort0xE,
      DecFifoWExEI  => DecFifo0WExE,
      DecFifoRExEI  => DecFifo0RExE,
      FifoMuxSO     => Fifo0MuxS,
      FifoWExEO     => Fifo0WExE,
      FifoRExEO     => Fifo0RExE);

  -- FIXME: find a better name for Fifo0MuxS
  
  -- Select source for FIFO input, either data from host interface of data
  -- generated by engine.
  Fifo1InxD <= DataInxD when (Fifo1MuxS = '0') else EngOut1xD;
  
  Fifo1 : Fifo
    generic map (
      WIDTH => DATAWIDTH,
      DEPTH => FIFODEPTH)
    port map (
      ClkxC        => ClkxC,
      RstxRB       => DecRstxRB,
      WExEI        => Fifo1WExE,
      RExEI        => Fifo1RExE,
      DinxDI       => Fifo1InxD,
      DoutxDO      => Fifo1OutxD,
      EmptyxSO     => NCsignxS,
      FullxSO      => NCsignxS,
      FillLevelxDO => Fifo1FillxD);

  Fifo1Ctrl : FifoCtrl
    port map (
      RunningxSI    => EngineScheduleControlxE.CExE,
      EngInPortxEI  => EngInPort1xE,
      EngOutPortxEI => EngOutPort1xE,
      DecFifoWExEI  => DecFifo1WExE,
      DecFifoRExEI  => DecFifo1RExE,
      FifoMuxSO     => Fifo1MuxS,
      FifoWExEO     => Fifo1WExE,
      FifoRExEO     => Fifo1RExE);


  -- connect signals from FIFOs to engine inputs (arrays). This is a workaround,
  -- since the FIFOs and the corresponding signals are not generated
  -- automatically generated.

  
  FifoOutxD(0) <= Fifo0OutxD;
  FifoOutxD(1) <= Fifo1OutxD;

  EngOut0xD <= EngOutxD(0);
  EngOut1xD <= EngOutxD(1);

  EngInPort1xE <= EngInPortxE(1);
  EngInPort0xE <= EngInPortxE(0);

  EngOutPort1xE <= EngOutPortxE(1);
  EngOutPort0xE <= EngOutPortxE(0);

  CompEng : Engine
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC         => ClkxC,
      RstxRB        => DecRstxRB,
      CExEI         => EngineScheduleControlxE.CExE,          -- RunningxS,
      ConfigxI      => EngCfg,
      ClrContextxSI => EngineScheduleControlxE.ClrContextxS,  -- CSRinxD,
      ClrContextxEI => EngineScheduleControlxE.ClrContextxE,  -- EngClrCntxtxE,
      ContextxSI    => EngineScheduleControlxE.ContextxS,     -- ContextxS,
      CycleDnCntxDI => EngineScheduleControlxE.CycleDnCntxD,  -- CycleDnCntxD,
      CycleUpCntxDI => EngineScheduleControlxE.CycleUpCntxD,  -- CycleUpCntxD,
      InPortxDI     => FifoOutxD,
      OutPortxDO    => EngOutxD,
      InPortxEO     => EngInPortxE,
      OutPortxEO    => EngOutPortxE);

  -- Rename the signals at the right hand side of the following assignments, to
  -- better fit the new concept of a generic scheduler, that can implement many
  -- context scheduling schemes.
  -- FIXME: or better propagate the signal names in the component
  -- instantiations
  -- FIXME: even better, try to collect all context sequencer related code into
  -- a SchedulerContextSequencer component
  
  SchedContextSequencerxD.CExE         <= CSSchedulerRunningxS;
  SchedContextSequencerxD.ClrContextxS <= CSRinxD;

  -----------------------------------------------------------------------------
  -- TODO: FIXES for ADPCM temporal partitioning
  -----------------------------------------------------------------------------
  
  -- directly use the decoded signal instead of the output of Enzler's
  -- context sequencer. Otherwise, we cannot use the context clear feature of
  -- the architecture (ZREG_CONTEXTSELCLR).
  
  SchedContextSequencerxD.ClrContextxE <= DecEngClrCntxtxE;
  --  SchedContextSequencerxD.ClrContextxE <= EngClrCntxtxE;
  
  -- CHANGE: always use register interface input and not the output of
  -- the context scheduler
  
  --  CSRinxD <= IFCSRinxD when (SchedBusyxS = '0') else SSCSRinxD;
  CSRinxD <= IFCSRinxD;
-------------------------------------------------------------------------------
  
  SchedContextSequencerxD.ContextxS    <= ContextxS;
  SchedContextSequencerxD.CycleDnCntxD <= CycleDnCntxD;
  SchedContextSequencerxD.CycleUpCntxD <= CycleUpCntxD;



  
  process (ContextSchedulerSelectxD, CSSchedulerDonexS, TPSchedulerDonexS)
  begin  -- process 
    if (ContextSchedulerSelectxD = '0') then
      ContextSchedulerDonexS <= CSSchedulerDonexS;
    else
      ContextSchedulerDonexS <= TPSchedulerDonexS;
    end if;
  end process;

  OutMux : Mux8to1
    generic map (
      WIDTH => IFWIDTH)
    port map (
      SelxSI => DecDoutMuxS,
      In0xDI => Fifo0OutResxD,
      In1xDI => Fifo0FillResxD,
      In2xDI => Fifo1OutResxD,
      In3xDI => Fifo1FillResxD,
      In4xDI => VirtContextNoxD,
      In5xDI => NCifxS,
      In6xDI => ContextSchedulerStatusResxD,
      In7xDI => EngineScheduleControlxE.CycleDnCntxD,
      OutxDO => IFDataOutxD);

  CycleDnCnt : CycleDnCntr
    generic map (
      CNTWIDTH => CCNTWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => DecRstxRB,
      LoadxEI => CCLoadxE,
      CinxDI  => CCinxD,
      OnxSO   => CSSchedulerRunningxS,
      CoutxDO => CycleDnCntxD);

  CycleUpCnt : UpDownCounter
    generic map (
      WIDTH => CCNTWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => DecRstxRB,
      LoadxEI => CCLoadxE,
      CExEI   => CSSchedulerRunningxS,
      ModexSI => '0',
      CinxDI  => (others => '0'),
      CoutxDO => CycleUpCntxD);

  CtxSchedSelReg : process (ClkxC, RstxRB)
  begin
    if RstxRB = '0' then
      ContextSchedulerSelectxD <= '0';
    elsif rising_edge(ClkxC) then
      if (DecContextSchedulerSelectxE = '1') then
        ContextSchedulerSelectxD <= IFDataInxD(0);
      end if;
    end if;
  end process;


  -- FIXME: move these two registers into the scheduler components
  VirtContextReg : Reg_En
    generic map (
      WIDTH => IFWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      EnxEI   => DecVirtContextNoxE,
      DinxDI  => IFDataInxD,
      DoutxDO => VirtContextNoxD);

  VirtUserCycleReg : Reg_En
    generic map (
      WIDTH => IFWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      EnxEI   => DecLoadCCxE,
      DinxDI  => IFDataInxD,
      DoutxDO => VirtUserCycleNoxD);

  SchedStore : ScheduleStore
    generic map (
      WRDWIDTH => SIW_WRDWIDTH,
      CONWIDTH => SIW_CONWIDTH,
      CYCWIDTH => SIW_CYCWIDTH,
      ADRWIDTH => SIW_ADRWIDTH)
    port map (
      ClkxC      => ClkxC,
      RstxRB     => RstxRB,
      WExEI      => DecSSWExE,
      IAddrxDI   => DecSSIAddrxD,
      IWordxDI   => SSIWordxD,
      SPCclrxEI  => NotSchedBusyxS,
      SPCloadxEI => SchedSwitchxE,
      ContextxDO => SSContextxD,
      CyclesxDO  => SSCyclesxD,
      LastxSO    => SSLastxS);

  SchedCtrl : ScheduleCtrl
    port map (
      ClkxC      => ClkxC,
      RstxRB     => RstxRB,
      StartxEI   => DecScheduleStartxE,
      RunningxSI => CSSchedulerRunningxS,
      LastxSI    => SchedLastxS,
      SwitchxEO  => SchedSwitchxE,
      BusyxSO    => SchedBusyxS);




  CSREnxE <= DecCSRxE when (SchedBusyxS = '0') else SchedSwitchxE;
--  CSRMuxS <= SchedBusyxS;


  CCinxD <= IFCCinxD when (SchedBusyxS = '0') else SSCCinxD;

  CycleCounterCtrl : CycleCntCtrl
    port map (
      DecLoadxEI   => DecLoadCCxE,
      SchedLoadxEI => SchedSwitchxE,
      SchedBusyxSI => SchedBusyxS,
      CCLoadxEO    => CCLoadxE,
      CCMuxSO      => CCMuxS);

  LastContextStatusFF : FlipFlop_Clr
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      ClrxEI  => NotSchedBusyxS,
      EnxEI   => SchedSwitchxE,
      DinxDI  => SSLastxS,
      DoutxDO => SchedLastxS);

  ScheduleBusyStatusFF : FlipFlop
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      EnxEI   => '1',
      DinxDI  => SchedBusyxS,
      DoutxDO => CSSchedulerDonexS);


  -- If the context scheduler is started the LSB of the DataInxD determines,
  -- whether the context registers get cleared (1) or not (0).
  -- SchedEngClrxSI => IFDataInxD(0)
  EngClrCntxtCtrl : EngClearCtrl
    port map (
      ClkxC          => ClkxC,
      RstxRB         => RstxRB,
      DecEngClrxEI   => DecEngClrCntxtxE,
      SchedStartxEI  => DecScheduleStartxE,
      SchedSwitchxEI => SchedSwitchxE,
      SchedBusyxSI   => SchedBusyxS,
      SchedEngClrxSI => IFDataInxD(0),
      EngClrxEO      => EngClrCntxtxE);

  NotSchedBusyxS <= not SchedBusyxS;

  -- interface signals
  IFWExE     <= WExEI;
  IFRExE     <= RExEI;
  IFAddrxD   <= AddrxDI;
  IFDataInxD <= DataxDI;
  DataxDO    <= IFDataOutxD;

  -- configuration format conversion
  EngCfg <= to_engineConfig_rec(EngCfgxD);

  -- interface signal conversion/resizing
  IFCCinxD  <= std_logic_vector(resize(unsigned(IFDataInxD), CCNTWIDTH));
  IFCSRinxD <= std_logic_vector(resize(unsigned(IFDataInxD), CNTXTWIDTH));
  DataInxD  <= std_logic_vector(resize(unsigned(IFDataInxD), DATAWIDTH));
  SSIWordxD <= std_logic_vector(resize(unsigned(IFDataInxD), SIW_WRDWIDTH));

  Fifo0OutResxD   <= std_logic_vector(resize(signed(Fifo0OutxD), IFWIDTH));
  Fifo1OutResxD   <= std_logic_vector(resize(signed(Fifo1OutxD), IFWIDTH));
  Fifo0FillResxD  <= std_logic_vector(resize(unsigned(Fifo0FillxD), IFWIDTH));
  Fifo1FillResxD  <= std_logic_vector(resize(unsigned(Fifo1FillxD), IFWIDTH));
  CycleDnCntResxD <= std_logic_vector(resize(unsigned(CycleDnCntxD), IFWIDTH));


  ContextSchedulerStatusResxD(IFWIDTH-1 downto 1) <= (others => '0');
  ContextSchedulerStatusResxD(0)                  <= ContextSchedulerDonexS;

  -- SIW format resizing
  SIWContextRes : process (SSContextxD)
  begin  -- process SIWContextRes
    if SIW_CONWIDTH > CNTXTWIDTH then
      SSCSRinxD <= SSContextxD(CNTXTWIDTH-1 downto 0);
    else
      SSCSRinxD(CNTXTWIDTH-1 downto SIW_CONWIDTH) <= (others => '0');
      SSCSRinxD(SIW_CONWIDTH-1 downto 0)          <= SSContextxD;
    end if;
  end process SIWContextRes;

  -- SIW format resizing
  SIWCyclesRes : process (SSCyclesxD)
  begin  -- process SIWCyclesRes
    if SIW_CYCWIDTH > CCNTWIDTH then
      SSCCinxD <= SSCyclesxD(CNTXTWIDTH-1 downto 0);
    else
      SSCCinxD(CCNTWIDTH-1 downto SIW_CYCWIDTH) <= (others => '0');
      SSCCinxD(SIW_CYCWIDTH-1 downto 0)         <= SSCyclesxD;
    end if;
  end process SIWCyclesRes;

  
end simple;
