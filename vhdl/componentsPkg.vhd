-- Component declarations

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;
use work.AuxPkg.all;

package ComponentsPkg is

  component ZUnit
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
  end component;

  component Scheduler is
  
  port (
    ClkxC                        : in  std_logic;
    RstxRB                       : in  std_logic;
    SchedulerSelectxSI           : in  std_logic;
    SchedContextSequencerxDI     : in  EngineScheduleControlType;
    SchedTemporalPartitioningxDI : in  EngineScheduleControlType;
    EngineScheduleControlxEO     : out EngineScheduleControlType
    );
  end component;
  
  component SchedulerTemporalPartitioning is
  
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
end component;

    
  component ScheduleStore
    generic (
      WRDWIDTH : integer;
      CONWIDTH : integer;
      CYCWIDTH : integer;
      ADRWIDTH : integer);
    port (
      ClkxC      : in  std_logic;
      RstxRB     : in  std_logic;
      WExEI      : in  std_logic;
      IAddrxDI   : in  std_logic_vector(ADRWIDTH-1 downto 0);
      IWordxDI   : in  std_logic_vector(WRDWIDTH-1 downto 0);
      SPCclrxEI  : in  std_logic;
      SPCloadxEI : in  std_logic;
      ContextxDO : out std_logic_vector(CONWIDTH-1 downto 0);
      CyclesxDO  : out std_logic_vector(CYCWIDTH-1 downto 0);
      LastxSO    : out std_logic);
  end component;

  component ScheduleCtrl
    port (
      ClkxC      : in  std_logic;
      RstxRB     : in  std_logic;
      StartxEI   : in  std_logic;
      RunningxSI : in  std_logic;
      LastxSI    : in  std_logic;
      SwitchxEO  : out std_logic;
      BusyxSO    : out std_logic);
  end component;

  component ConfigMem
    generic (
      CFGWIDTH : integer;
      PTRWIDTH : integer;
      SLCWIDTH : integer);
    port (
      ClkxC           : in  std_logic;
      RstxRB          : in  std_logic;
      WExEI           : in  std_logic;
      CfgSlicexDI     : in  std_logic_vector(SLCWIDTH-1 downto 0);
      LoadSlicePtrxEI : in  std_logic;
      SlicePtrxDI     : in  std_logic_vector(PTRWIDTH-1 downto 0);
      ConfigWordxDO   : out std_logic_vector(CFGWIDTH-1 downto 0));
  end component;

  component ContextMux
    generic (
      NINP : integer);
    port (
      SelxSI : in  std_logic_vector(log2(NINP)-1 downto 0);
      InpxI  : in  contextArray;
      OutxDO : out contextType);
  end component;

  component ContextSelCtrl
    port (
      DecEnxEI     : in  std_logic;
      SchedEnxEI   : in  std_logic;
      SchedBusyxSI : in  std_logic;
      CSREnxEO     : out std_logic;
      CSRMuxSO     : out std_logic);
  end component;

  component Decoder
    generic (
      REGWIDTH : integer);
    port (
      RstxRB                    : in  std_logic;
      WrReqxEI                  : in  std_logic;
      RdReqxEI                  : in  std_logic;
      RegNrxDI                  : in  std_logic_vector(REGWIDTH-1 downto 0);
      SystRstxRBO               : out std_logic;
      CCloadxEO                 : out std_logic;
      VirtContextNoxEO          : out std_logic; 
      ContextSchedulerSelectxEO : out std_logic;
      Fifo0WExEO                : out std_logic;
      Fifo0RExEO                : out std_logic;
      Fifo1WExEO                : out std_logic;
      Fifo1RExEO                : out std_logic;
      CMWExEO                   : out std_logic_vector(N_CONTEXTS-1 downto 0);
      CMLoadPtrxEO              : out std_logic_vector(N_CONTEXTS-1 downto 0);
      CSRxEO                    : out std_logic;
      EngClrCntxtxEO            : out std_logic;
      SSWExEO                   : out std_logic;
      SSIAddrxDO                : out std_logic_vector(SIW_ADRWIDTH-1 downto 0);
      ScheduleStartxE           : out std_logic;
      DoutMuxSO                 : out std_logic_vector(2 downto 0));
  end component;

  component FifoCtrl
    port (
      RunningxSI    : in  std_logic;
      EngInPortxEI  : in  std_logic;
      EngOutPortxEI : in  std_logic;
      DecFifoWExEI  : in  std_logic;
      DecFifoRExEI  : in  std_logic;
      FifoMuxSO     : out std_logic;
      FifoWExEO     : out std_logic;
      FifoRExEO     : out std_logic);
  end component;

  component CycleDnCntr
    generic (
      CNTWIDTH : integer);
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      LoadxEI : in  std_logic;
      CinxDI  : in  std_logic_vector(CNTWIDTH-1 downto 0);
      OnxSO   : out std_logic;
      CoutxDO : out std_logic_vector(CNTWIDTH-1 downto 0));
  end component;

  component CycleCntCtrl
    port (
      DecLoadxEI   : in  std_logic;
      SchedLoadxEI : in  std_logic;
      SchedBusyxSI : in  std_logic;
      CCLoadxEO    : out std_logic;
      CCMuxSO      : out std_logic);
  end component;

  component Engine                      -- computation engine
    generic (
      DATAWIDTH : integer);
    port (
      ClkxC         : in  std_logic;
      RstxRB        : in  std_logic;
      CExEI         : in  std_logic;
      ConfigxI      : in  engineConfigRec;
      ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      ClrContextxEI : in  std_logic;
      ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      CycleDnCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
      CycleUpCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
      InPortxDI     : in  engineInoutDataType;
      OutPortxDO    : out engineInoutDataType;
      InPortxEO     : out std_logic_vector(N_IOP-1 downto 0);
      OutPortxEO    : out std_logic_vector(N_IOP-1 downto 0));
  end component;

  component EngClearCtrl
    port (
      ClkxC          : in  std_logic;
      RstxRB         : in  std_logic;
      DecEngClrxEI   : in  std_logic;
      SchedStartxEI  : in  std_logic;
      SchedSwitchxEI : in  std_logic;
      SchedBusyxSI   : in  std_logic;
      SchedEngClrxSI : in  std_logic;
      EngClrxEO      : out std_logic);
  end component;

  component IOPortCtrl                  -- I/O port controller
    generic (
      CCNTWIDTH : integer);
    port (
      ClkxC         : in  std_logic;
      RstxRB        : in  std_logic;
      ConfigxI      : in  ioportConfigRec;
      CycleDnCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
      CycleUpCntxDI : in  std_logic_vector(CCNTWIDTH-1 downto 0);
      PortxEO       : out std_logic);
  end component;

  component Row                         -- row of cells
    generic (
      DATAWIDTH : integer);
    port (
      ClkxC         : in  std_logic;
      RstxRB        : in  std_logic;
      CExEI         : in  std_logic;
      ConfigxI      : in  rowConfigArray;
      ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      ClrContextxEI : in  std_logic;
      ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      InpxI         : in  rowInputArray;
      OutxO         : out rowOutputArray;
      MemDataxDI    : in  data_vector(N_COLS-1 downto 0);
      MemAddrxDO    : out data_vector(N_COLS-1 downto 0);
      MemDataxDO    : out data_vector(N_COLS-1 downto 0);
      MemCtrlxSO    : out data_vector(N_COLS-1 downto 0)
      );
  end component;

  component Cell                        -- cell (routing + proc. element)
    generic (
      DATAWIDTH : integer);
    port (
      ClkxC         : in  std_logic;
      RstxRB        : in  std_logic;
      CExEI         : in  std_logic;
      ConfigxI      : in  cellConfigRec;
      ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      ClrContextxEI : in  std_logic;
      ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      -- data io signals
      InputxDI      : in  cellInputRec;
      OutputxZO     : out CellOutputRec;
      -- memory signals
      MemDataxDI    : in  data_word;
      MemAddrxDO    : out data_word;
      MemDataxDO    : out data_word;
      MemCtrlxSO    : out data_word
      );
  end component;

  component ProcEl                      -- processing element
    generic (
      DATAWIDTH : integer);
    port (
      ClkxC         : in  std_logic;
      RstxRB        : in  std_logic;
      CExEI         : in  std_logic;
      ConfigxI      : in  procConfigRec;
      ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      ClrContextxEI : in  std_logic;
      ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      -- data io signals
      InxDI         : in  procelInputArray;
      OutxDO        : out data_word;
      -- memory signals
      MemDataxDI    : in  data_word;
      MemAddrxDO    : out data_word;
      MemDataxDO    : out data_word;
      MemCtrlxSO    : out data_word
      );
  end component;

  component RoutEl                      -- routing element
    generic (
      DATAWIDTH : integer);
    port (
      ClkxC        : in  std_logic;
      RstxRB       : in  std_logic;
      ConfigxI     : in  routConfigRec;
      InputxDI     : in  cellInputRec;
      OutputxZO    : out CellOutputRec;
      ProcElInxDO  : out procelInputArray;
      ProcElOutxDI : in  data_word
      );
  end component;

  component CClkGating
    port (
      EnxEI     : in  std_logic;
      MClockxCI : in  std_logic;
      CClockxCO : out std_logic);
  end component;

  component Fifo
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
  end component;

  component UpDownCounter
    generic (
      WIDTH : integer);
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      LoadxEI : in  std_logic;
      CExEI   : in  std_logic;
      ModexSI : in  std_logic;
      CinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
      CoutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component FlipFlop
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      EnxEI   : in  std_logic;
      DinxDI  : in  std_logic;
      DoutxDO : out std_logic);
  end component;

  component FlipFlop_Clr
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      ClrxEI  : in  std_logic;
      EnxEI   : in  std_logic;
      DinxDI  : in  std_logic;
      DoutxDO : out std_logic);
  end component;

  component Reg_En
    generic (
      WIDTH : integer);
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      EnxEI   : in  std_logic;
      DinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
      DoutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component Reg_Clr_En
    generic (
      WIDTH : integer);
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      ClrxEI  : in  std_logic;
      EnxEI   : in  std_logic;
      DinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
      DoutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component Reg_AClr_En
    generic (
      WIDTH : integer);
    port (
      ClkxC   : in  std_logic;
      RstxRB  : in  std_logic;
      ClrxABI : in  std_logic;
      EnxEI   : in  std_logic;
      DinxDI  : in  std_logic_vector(WIDTH-1 downto 0);
      DoutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;


  component Rom is
    generic (
      DEPTH : integer
      );
    port (
      ConfigxI  : in  data_vector(DEPTH-1 downto 0);
      RdAddrxDI : in  data_word;
      RdDataxDO : out data_word
      );
  end component Rom;



  component ContextRegFile
    port (
      ClkxC         : in  std_logic;
      RstxRB        : in  std_logic;
      ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      ClrContextxEI : in  std_logic;
      ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
      EnxEI         : in  std_logic;
      DinxDI        : in  data_word;
      DoutxDO       : out data_word);
  end component;

  component Mux2to1
    generic (
      WIDTH : integer);
    port (
      SelxSI : in  std_logic;
      In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
      OutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component Mux4to1
    generic (
      WIDTH : integer);
    port (
      SelxSI : in  std_logic_vector(1 downto 0);
      In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In2xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In3xDI : in  std_logic_vector(WIDTH-1 downto 0);
      OutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component Mux8to1
    generic (
      WIDTH : integer);
    port (
      SelxSI : in  std_logic_vector(2 downto 0);
      In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In2xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In3xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In4xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In5xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In6xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In7xDI : in  std_logic_vector(WIDTH-1 downto 0);
      OutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component Mux16to1
    generic (
      WIDTH : integer);
    port (
      SelxSI : in  std_logic_vector(3 downto 0);
      In0xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In1xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In2xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In3xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In4xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In5xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In6xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In7xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In8xDI : in  std_logic_vector(WIDTH-1 downto 0);
      In9xDI : in  std_logic_vector(WIDTH-1 downto 0);
      InAxDI : in  std_logic_vector(WIDTH-1 downto 0);
      InBxDI : in  std_logic_vector(WIDTH-1 downto 0);
      InCxDI : in  std_logic_vector(WIDTH-1 downto 0);
      InDxDI : in  std_logic_vector(WIDTH-1 downto 0);
      InExDI : in  std_logic_vector(WIDTH-1 downto 0);
      InFxDI : in  std_logic_vector(WIDTH-1 downto 0);
      OutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component TristateBuf
    generic (
      WIDTH : integer);
    port (
      InxDI  : in  std_logic_vector(WIDTH-1 downto 0);
      OExEI  : in  std_logic;
      OutxZO : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component PullBus
    generic (
      WIDTH : integer);
    port (
      ModexSI : in  std_logic;
      BusxZO  : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component Pull
    port (
      ModexSI : in  std_logic;
      WirexZO : out std_logic);
  end component;

end ComponentsPkg;
