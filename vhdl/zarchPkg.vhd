------------------------------------------------------------------------------
-- ZIPPY global architecture declarations
--
-- Project     : 
-- File        : zarchPkg.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/06/28
-- Last changed: $LastChangedDate: 2005-04-07 11:17:51 +0200 (Thu, 07 Apr 2005) $
------------------------------------------------------------------------------
-- The zippy architecture is widely parameterized. The parameters that define
-- the architecture are declared in this package, e.g. data-width, size of 
-- array, number of contexts, FIFO sizes etc.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-08 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.AuxPkg.all;

package ZArchPkg is

  -- The user configurable architecture parameter have been moved to
  --  archConfigPkg

  constant IFWIDTH   : integer := 32;       -- interface width
  constant CCNTWIDTH : integer := IFWIDTH;  -- cycle counter width
  constant PARTWIDTH  : integer := IFWIDTH;  -- cfg. partition width

  constant N_CELLINPS : integer := 3;   -- no. of inputs of a cell
  constant N_LOCALCON : integer := 8;   -- no. local interconnect inputs

  -----------------------------------------------------------------------------
  -- FIXME: N_IOP must be set to 2, not fully configurable, since FIFO
  -- instantiation and decoder are hardcoded.
  -----------------------------------------------------------------------------
  constant N_IOP : integer := 2;        -- no. of input/output ports

  constant SIW_WRDWIDTH : integer := IFWIDTH;     -- sched. instr. word width
  constant SIW_CONWIDTH : integer := CNTXTWIDTH;  -- context field width
  constant SIW_CYCWIDTH : integer := 20;          -- cycle field width
  constant SIW_ADRWIDTH : integer := 7;           -- next addr. field width

  -- native data type of the zippy architecture, all data operations occur on
  -- signals of this data type
  subtype data_word is std_logic_vector(DATAWIDTH-1 downto 0);
  type    data_vector is array (natural range<>) of data_word;

  constant SL0 : std_logic := '0';      -- '0' constant in std_logic type
  constant SL1 : std_logic := '1';      -- '1' constant in std_logic type

  ----------------------------------------------------------------------------
  -- ZUnit Register Mapping and Functions:
  --   0   Reset                     W
  --   1   FIFO0                     R/W
  --   2   FIFO0 Level               R
  --   3   FIFO1                     R/W
  --   4   FIFO1 Level               R
  --   5   Run Cycle Counter         R/W
  --   6   CfgMemory0                W
  --   7   CfgMemory0 Pointer        W
  --   8   CfgMemory1                W
  --   9   CfgMemory1 Pointer        W
  --  10   CfgMemory2                W
  --  11   CfgMemory2 Pointer        W
  --  12   CfgMemory3                W
  --  13   CfgMemory3 Pointer        W
  --  14   CfgMemory4                W
  --  15   CfgMemory4 Pointer        W
  --  16   CfgMemory5                W
  --  17   CfgMemory5 Pointer        W
  --  18   CfgMemory6                W
  --  19   CfgMemory6 Pointer        W
  --  20   CfgMemory7                W
  --  21   CfgMemory7 Pointer        W
  --  22   Context SelReg wo/ clear  W
  --  23   Context SelReg w/ clear   W

  --  50   VirtualizationContextNo   W
  --       set number of virtualization contexts (used by TemporalPartitioning
  --       scheduler)
  --  51   ContextSchedulerSelect    W
  --       select which context scheduler type is used
  
  -- 125   Context Schedule Start    W
  -- 126   Context Schedule Status   R
  -- 127   Context Schedule Program  W
  -- 128   ""
  -- ...   ""
  -- 134   ""
----------------------------------------------------------------------------
  constant ZREG_RST           : integer := 0;
  constant ZREG_FIFO0         : integer := 1;
  constant ZREG_FIFO0LEV      : integer := 2;
  constant ZREG_FIFO1         : integer := 3;
  constant ZREG_FIFO1LEV      : integer := 4;
  constant ZREG_CYCLECNT      : integer := 5;
  constant ZREG_CFGMEM0       : integer := 6;
  constant ZREG_CFGMEM0PTR    : integer := 7;
  constant ZREG_CFGMEM1       : integer := 8;
  constant ZREG_CFGMEM1PTR    : integer := 9;
  constant ZREG_CFGMEM2       : integer := 10;
  constant ZREG_CFGMEM2PTR    : integer := 11;
  constant ZREG_CFGMEM3       : integer := 12;
  constant ZREG_CFGMEM3PTR    : integer := 13;
  constant ZREG_CFGMEM4       : integer := 14;
  constant ZREG_CFGMEM4PTR    : integer := 15;
  constant ZREG_CFGMEM5       : integer := 16;
  constant ZREG_CFGMEM5PTR    : integer := 17;
  constant ZREG_CFGMEM6       : integer := 18;
  constant ZREG_CFGMEM6PTR    : integer := 19;
  constant ZREG_CFGMEM7       : integer := 20;
  constant ZREG_CFGMEM7PTR    : integer := 21;
  constant ZREG_CONTEXTSEL    : integer := 22;
  constant ZREG_CONTEXTSELCLR : integer := 23;

  -- set number of contexts, used for cyclic context activation with
  -- temporal partitioning.
  constant ZREG_VIRTCONTEXTNO  : integer := 50;
  constant ZREG_CONTEXTSCHEDSEL : integer := 51;
  -- 0: context sequencer and cycle counter
  -- 1: temporal paritioning scheduler
  
  constant ZREG_SCHEDSTART   : integer := 125;  -- data: 0 store, 1 clr (context)
  constant ZREG_SCHEDSTATUS  : integer := 126;
  constant ZREG_SCHEDIWORD00 : integer := 127;
  constant ZREG_SCHEDIWORD01 : integer := 128;
  constant ZREG_SCHEDIWORD02 : integer := 129;
  constant ZREG_SCHEDIWORD03 : integer := 130;
  constant ZREG_SCHEDIWORD04 : integer := 131;
  constant ZREG_SCHEDIWORD05 : integer := 132;
  constant ZREG_SCHEDIWORD06 : integer := 133;
  constant ZREG_SCHEDIWORD07 : integer := 134;
  -- (8 will do for the moment ...)


  -- tstbitat0(a,b) out = ~0 if all 1bits of 'b' are 0 in word 'a', else 0
  -- tstbitat1(a,b) out = ~0 if all 1bits of 'b' are 1 in word 'a'  else 0
  -- mux(a,b,c)     out = 'a' if 'c(0)=0', else 'b'
  -- rom(a)         out = romdata[a]

  constant ALUOPWIDTH : integer := 6;   -- need to know for configuration

  subtype aluop_type is integer range 0 to 2**ALUOPWIDTH-1;

  -- FIXME: the following instructions are unnecessary
  -- ALU_PASS1
  -- ALU_NEG1 (even NEG0, since can be implemeted as const(0)-input
  -- ALU_SUBU
  -- ALU_ADDU
  -- ALU_OP_MULTULO
  -- ALU_OP_MULTUHI
  -- ALU_NOT1 (even NOT0, since can be implemented as xor with 111..1)

  constant ALU_OP_PASS0     : aluop_type := 0;
  constant ALU_OP_PASS1     : aluop_type := 1;
  constant ALU_OP_NEG0      : aluop_type := 2;
  constant ALU_OP_NEG1      : aluop_type := 3;
  constant ALU_OP_ADD       : aluop_type := 4;
  constant ALU_OP_SUB       : aluop_type := 5;
  constant ALU_OP_ADDU      : aluop_type := 6;
  constant ALU_OP_SUBU      : aluop_type := 7;
  constant ALU_OP_MULTHI    : aluop_type := 8;
  constant ALU_OP_MULTLO    : aluop_type := 9;
  constant ALU_OP_MULTUHI   : aluop_type := 10;
  constant ALU_OP_MULTULO   : aluop_type := 11;
  constant ALU_OP_AND       : aluop_type := 12;
  constant ALU_OP_NAND      : aluop_type := 13;
  constant ALU_OP_OR        : aluop_type := 14;
  constant ALU_OP_NOR       : aluop_type := 15;
  constant ALU_OP_XOR       : aluop_type := 16;
  constant ALU_OP_XNOR      : aluop_type := 17;
  constant ALU_OP_NOT0      : aluop_type := 18;
  constant ALU_OP_NOT1      : aluop_type := 19;
  constant ALU_OP_SLL       : aluop_type := 20;
  constant ALU_OP_SRL       : aluop_type := 21;
  constant ALU_OP_ROL       : aluop_type := 22;
  constant ALU_OP_ROR       : aluop_type := 23;
  constant ALU_OP_TSTBITAT0 : aluop_type := 24;
  constant ALU_OP_TSTBITAT1 : aluop_type := 25;
  constant ALU_OP_MUX       : aluop_type := 26;
  constant ALU_OP_ROM       : aluop_type := 27;
  constant ALU_OP_EQ        : aluop_type := 28;
  constant ALU_OP_NEQ       : aluop_type := 29;
  constant ALU_OP_LT        : aluop_type := 30;
  constant ALU_OP_GT        : aluop_type := 31;
  constant ALU_OP_LTE       : aluop_type := 32;
  constant ALU_OP_GTE       : aluop_type := 33;

  type opcodename_array is array (0 to 33) of string(1 to 9);
  constant opcode_name : opcodename_array := (
    0  => "pass0    ",
    1  => "pass1    ",
    2  => "neg0     ",
    3  => "neg1     ",
    4  => "add      ",
    5  => "sub      ",
    6  => "addu     ",
    7  => "subu     ",
    8  => "multhi   ",
    9  => "multlo   ",
    10 => "multuhi  ",
    11 => "multulo  ",
    12 => "and      ",
    13 => "nand     ",
    14 => "or       ",
    15 => "nor      ",
    16 => "xor      ",
    17 => "xnor     ",
    18 => "not0     ",
    19 => "not1     ",
    20 => "sll      ",
    21 => "srl      ",
    22 => "rol      ",
    23 => "ror      ",
    24 => "tstbitat0",
    25 => "tstbitat1",
    26 => "mux      ",
    27 => "rom      ",
    28 => "eq       ",
    29 => "neq      ",
    30 => "lt       ",
    31 => "gt       ",
    32 => "lte      ",
    33 => "gte      "
    );



  ----------------------------------------------------------------------------
  -- Configuration
  ----------------------------------------------------------------------------

  type procInputMuxArray is array (N_CELLINPS-1 downto 0) of
    std_logic_vector(2 downto 0);

  type procInputCtxRegSelectArray is array (N_CELLINPS-1 downto 0) of
    std_logic_vector(CNTXTWIDTH-1 downto 0);

  subtype procOutputMux is std_logic_vector(1 downto 0);
  subtype procOutputCtxRegSelect is std_logic_vector(CNTXTWIDTH-1 downto 0);

  -- FIXME find better names for record elements.
  -- for instance
  --   InputMuxS         instead of OpMuxS
  --   InputContextRegxS instead of OpCtxRegSelxS
  -- etc.

  type procConfigRec is
    record
      OpMuxS         : procInputMuxArray;
      OpCtxRegSelxS  : procInputCtxRegSelectArray;
      OutMuxS        : procOutputMux;
      OutCtxRegSelxS : procOutputCtxRegSelect;
      AluOpxS        : aluop_type;
      ConstOpxD      : data_word;
    end record;

  type cellInputRec is
    record
      LocalxDI : data_vector(N_LOCALCON-1 downto 0);
      HBusNxDI : data_vector(N_HBUSN-1 downto 0);
      HBusSxDI : data_vector(N_HBUSS-1 downto 0);
      VBusExDI : data_vector(N_VBUSE-1 downto 0);
    end record;

  type cellOutputRec is
    record
      LocalxDO : data_word;
      HBusNxDZ : data_vector(N_HBUSN-1 downto 0);
      HBusSxDZ : data_vector(N_HBUSS-1 downto 0);
      VBusExDZ : data_vector(N_VBUSE-1 downto 0);
    end record;

  type cellRoutingInputConfigRec is
    record
      LocalxE : std_logic_vector(N_LOCALCON-1 downto 0);
      HBusNxE : std_logic_vector(N_HBUSN-1 downto 0);
      HBusSxE : std_logic_vector(N_HBUSS-1 downto 0);
      VBusExE : std_logic_vector(N_VBUSE-1 downto 0);
    end record;

  type cellRoutingInputConfigRecArr is array (N_CELLINPS-1 downto 0) of
    cellRoutingInputConfigRec;
  
  type cellRoutingOutputConfigRec is
    record
      HBusNxE : std_logic_vector(N_HBUSN-1 downto 0);
      HBusSxE : std_logic_vector(N_HBUSS-1 downto 0);
      VBusExE : std_logic_vector(N_VBUSE-1 downto 0);
    end record;

  type routConfigRec is
    record
      i : cellRoutingInputConfigRecArr;  -- one cfg per input
      o : cellRoutingOutputConfigRec;
    end record;

  type cellConfigRec is
    record
      procConf : procConfigRec;
      routConf : routConfigRec;
    end record;

  type procelInputArray is array (N_CELLINPS-1 downto 0) of data_word;
  type engineInoutDataType is array (N_IOP-1 downto 0) of data_word;

  type engineHBusNorthArray is array (N_ROWS-1 downto 0) of
    data_vector(N_HBUSN-1 downto 0);
  type engineHBusSouthArray is array (N_ROWS-1 downto 0) of
    data_vector(N_HBUSS-1 downto 0);
  type engineVBusEastArray is array (N_COLS-1 downto 0) of
    data_vector(N_VBUSE-1 downto 0);

  -- hbdr(row)(hbus_n nr) enables driving input bus to horizontal
  -- north bus
  type HBusNorthDriverArray is array (N_ROWS-1 downto 0) of
    std_logic_vector(N_HBUSN-1 downto 0);

  type engineHBusNorthInputDriverArray is array (N_IOP-1 downto 0) of
    HBusNorthDriverArray;

  type engineHBusNorthOutputDriverArray is array (N_IOP-1 downto 0) of
    HBusNorthDriverArray;

  
  type rowConfigArray is array (N_COLS-1 downto 0) of cellConfigRec;
  type rowInputArray is array (N_COLS-1 downto 0) of cellInputRec;
  type rowOutputArray is array (N_COLS-1 downto 0) of cellOutputRec;

  type gridConfigArray is array (N_ROWS-1 downto 0) of rowConfigArray;
  type gridInputArray is array (N_ROWS-1 downto 0) of rowInputArray;
  type gridOutputArray is array (N_ROWS-1 downto 0) of rowOutputArray;

  type ioportConfigRec is
    record
      Cmp0MuxS    : std_logic;
      Cmp0ModusxS : std_logic;
      Cmp0ConstxD : std_logic_vector(CCNTWIDTH-1 downto 0);
      Cmp1MuxS    : std_logic;
      Cmp1ModusxS : std_logic;
      Cmp1ConstxD : std_logic_vector(CCNTWIDTH-1 downto 0);
      LUT4FunctxD : std_logic_vector(15 downto 0);
    end record;

  type engineInportConfigArray is array (N_IOP-1 downto 0) of ioportConfigRec;
  type engineOutportConfigArray is array (N_IOP-1 downto 0) of ioportConfigRec;
  type engineMemoryConfigArray is array (N_ROWS-1 downto 0) of
    data_vector(N_MEMDEPTH-1 downto 0);


  -------------------------------------------------------------------------------
  -- HELPER constants and functions for configuration specification
  -------------------------------------------------------------------------------

  -- convert a (singed) integer to a std_logic_vector, for specification of the
  -- constant operator ConstOpxD in the configuration file
  function i2cfgconst (i : integer) return data_word;

  -- convert an unsigned integer to a std_logic_vector, for
  -- specification of the input operand context registerselection
  -- OpCtxRegSelxS
  function i2ctx (i : natural) return std_logic_vector;

  -- select which cycle counter to use for comparison
  constant CFG_IOPORT_MUX_CYCLEUP   : std_logic := '0';  -- cycle up counter
  constant CFG_IOPORT_MUX_CYCLEDOWN : std_logic := '1';  -- cycle down counter

  -- select comparison mode
  constant CFG_IOPORT_MODUS_LARGER : std_logic := '0';  -- test larger
  constant CFG_IOPORT_MODUS_EQUAL  : std_logic := '1';  -- test equality

  -- select LUT function
  constant CFG_IOPORT_CMP1 : std_logic_vector(15 downto 0) := X"FF00";
  constant CFG_IOPORT_CMP0 : std_logic_vector(15 downto 0) := X"F0F0";

  constant CFG_IOPORT_ON  : std_logic_vector(15 downto 0) := X"FFFF";
  constant CFG_IOPORT_OFF : std_logic_vector(15 downto 0) := X"0000";

  -- constants for selecting local inputs from neighbors
  constant LOCAL_N  : natural := 0;
  constant LOCAL_NE : natural := 1;
  constant LOCAL_E  : natural := 2;
  constant LOCAL_SE : natural := 3;
  constant LOCAL_S  : natural := 4;
  constant LOCAL_SW : natural := 5;
  constant LOCAL_W  : natural := 6;
  constant LOCAL_NW : natural := 7;

  -- cell input / output configuration
  constant I_NOREG         : std_logic_vector(2 downto 0) := "000";
  constant I_CONST         : std_logic_vector(2 downto 0) := "010";
  constant I_REG           : std_logic_vector(2 downto 0) := "001";
  constant I_REG_CTX_THIS  : std_logic_vector(2 downto 0) := "001";
  constant I_REG_CTX_OTHER : std_logic_vector(2 downto 0) := "011";
  constant I_REG_FEEDBACK  : std_logic_vector(2 downto 0) := "100";
  
  constant O_NOREG         : std_logic_vector(1 downto 0) := "00";
  constant O_REG           : std_logic_vector(1 downto 0) := "01";
  constant O_REG_CTX_THIS  : std_logic_vector(1 downto 0) := "01";
  constant O_REG_CTX_OTHER : std_logic_vector(1 downto 0) := "11";

  type engineConfigRec is
    record
      gridConf         : gridConfigArray;
      inputDriverConf  : engineHBusNorthInputDriverArray;
      outputDriverConf : engineHBusNorthOutputDriverArray;
      inportConf       : engineInportConfigArray;
      outportConf      : engineOutportConfigArray;
      memoryConf       : engineMemoryConfigArray;
    end record;

  -----------------------------------------------------------------------------
  -- Context Scheduler
  -----------------------------------------------------------------------------

  type EngineScheduleControlType is
    record
      CExE         : std_logic;
      ClrContextxS : std_logic_vector(CNTXTWIDTH-1 downto 0);
      ClrContextxE : std_logic;
      ContextxS    : std_logic_vector(CNTXTWIDTH-1 downto 0);
      CycleDnCntxD : std_logic_vector(CCNTWIDTH-1 downto 0);
      CycleUpCntxD : std_logic_vector(CCNTWIDTH-1 downto 0);
    end record;


  
  ----------------------------------------------------------------------------
  -- Subprograms
  ----------------------------------------------------------------------------

  -- determines the length of a procConfig record
  function procConfig_length return integer;

  -- determines the length of a routConfig record
  function routConfig_length return integer;

  -- determines the length of a cellConfig record
  function cellConfig_length return integer;

  -- determines the length of a rowConfig array
  function rowConfig_length return integer;

  -- determines the length of a gridConfig array
  function gridConfig_length return integer;

  -- determines the length of a InputDriverConf array
  function inputDriverConfig_length return integer;

  -- determines the length of a OutputDriverConf array
  function outputDriverConfig_length return integer;

  -- determines the length of a InportConfig array
  function inportConfig_length return integer;

  -- determines the length of a InportConfig array
  function outportConfig_length return integer;

  -- determines the length of an ioportConfig record
  function ioportConfig_length return integer;

  -- determines the lenth of a MemoryConfig arrya
  function memoryConfig_length return integer;

  -- determines the length of an engineConfig record
  function engineConfig_length return integer;

  -- calculates the no. of partitions the configuration is partitioned into.
  function num_partitions (cfglen : integer; partwidth : integer)
    return integer;

end ZArchPkg;


package body ZArchPkg is

  function i2cfgconst (i : integer) return data_word is
    variable CfgxD : data_word;
  begin
    CfgxD := std_logic_vector(to_signed(i, CfgxD'length));
    return CfgxD;
  end function i2cfgconst;


  function i2ctx (i : natural) return std_logic_vector is
    variable CtxxD : std_logic_vector(CNTXTWIDTH-1 downto 0);
  begin
    CtxxD := std_logic_vector(to_unsigned(i, CtxxD'length));
    return CtxxD;
  end function i2ctx;

  -- determines the length of a procConfig record
  function procConfig_length return integer is
    variable Cfg : procConfigRec;
  begin
    return (Cfg.OpMuxS'length*Cfg.OpMuxS(0)'length +
            Cfg.OpCtxRegSelxS'length*Cfg.OpCtxRegSelxS(0)'length +
            Cfg.OutMuxS'length + Cfg.OutCtxRegSelxS'length +
            ALUOPWIDTH +
            Cfg.ConstOpxD'length);
  end procConfig_length;

  -- determines the length of a routConfig record
  function routConfig_length return integer is
    variable Cfg : routConfigRec;
  begin
    return (Cfg.i'length * (Cfg.i(0).LocalxE'length + Cfg.i(0).HBusNxE'length +
                            Cfg.i(0).HBusSxE'length + Cfg.i(0).VBusExE'length) +
            Cfg.o.HBusNxE'length + Cfg.o.HBusSxE'length + Cfg.o.VBusExE'length);
  end routConfig_length;

  -- determines the length of a cellConfig record
  function cellConfig_length return integer is
  begin
    return (procConfig_length + routConfig_length);
  end cellConfig_length;

  -- determines the length of a rowConfig array
  function rowConfig_length return integer is
  begin
    return (N_COLS * cellConfig_length);
  end rowConfig_length;

  -- determines the length of a gridConfig array
  function gridConfig_length return integer is
  begin
    return (N_ROWS * rowConfig_length);
  end gridConfig_length;

  -- determines the length of an ioportConfig record
  function ioportConfig_length return integer is
    variable Cfg : ioportConfigRec;
  begin
    return (4 + Cfg.Cmp0ConstxD'length + Cfg.Cmp1ConstxD'length +
            Cfg.LUT4FunctxD'length);
  end ioportConfig_length;

  -- determines the length of a inputDriverConf array
  function inputDriverConfig_length return integer is
  begin
    return (N_IOP * N_ROWS * N_HBUSN);
  end inputDriverConfig_length;

  -- determines the length of a outputDriverConf array
  function outputDriverConfig_length return integer is
  begin
    return (N_IOP * N_ROWS * N_HBUSN);
  end outputDriverConfig_length;

  -- determines the length of a inportConfig array
  function inportConfig_length return integer is
  begin
    return (N_IOP * ioportConfig_length);
  end inportConfig_length;

  -- determines the length of a inportConfig array
  function outportConfig_length return integer is
  begin
    return (N_IOP * ioportConfig_length);
  end outportConfig_length;

  -- determines the length of an engine memory config array
  function memoryConfig_length return integer is
    variable arr : engineMemoryConfigArray;
  begin
    return (arr'length*arr(0)'length*DATAWIDTH);
  end memoryConfig_length;

  -- determines the length of an engineConfig record
  function engineConfig_length return integer is
    variable Cfg : engineConfigRec;
  begin
    return (gridConfig_length +
            inputDriverConfig_length + outputDriverConfig_length +
            inportConfig_length + outportConfig_length +
            memoryConfig_length
            );
  end engineConfig_length;

  -- calculates the no. of partitions the configuration is partitioned into.
  function num_partitions (cfglen : integer; partwidth : integer)
    return integer
  is
  begin
    return (cfglen-1)/partwidth+1;
  end num_partitions;

end ZArchPkg;
