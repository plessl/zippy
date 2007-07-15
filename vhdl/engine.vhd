------------------------------------------------------------------------------
-- ZIPPY engine: - 2 input ports, 2 output ports (with enables)
--               - interconnect: some neighbours + busses
--
-- Project     : 
-- File        : $Id: engine.vhd 241 2005-04-07 08:50:55Z plessl $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/10/02
-- $Id: engine.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------
-- The engine is the core of the zippy architecture. It combines the cells
-- that form a grid, the local and bus interconnect between the cells, the io
-- ports and the corresponding io port controllers.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.txt_util.all;

entity Engine is
  
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

end Engine;


architecture simple of Engine is

  signal GridInp : gridInputArray;      -- GridInp(#row)(#cell).Inp*xD
  signal GridOut : gridOutputArray;     -- GridOut(#row)(#cell).Out*x{D,Z}

  signal HBusNxZ : engineHBusNorthArray;  -- all horiz north buses
  signal HBusSxZ : engineHBusSouthArray;  -- all horiz south buses
  signal VBusExZ : engineVBusEastArray;   -- all vertical east buses

  type gridRomIOArray is array (N_ROWS-1 downto 0) of
    data_vector(N_COLS-1 downto 0);

  signal cellMemDataxDI : gridRomIOArray;
  signal cellMemDataxDO : gridRomIOArray;
  signal cellMemAddrxDO : gridRomIOArray;
  signal cellMemCtrlxSO : gridRomIOArray;

  -- IO signals to attach the ROM blocks, a ROM block is shared betweed all
  -- cells in a row
  signal RowRomRdAddrxZ : data_vector(N_ROWS-1 downto 0);
  --signal RowRomWrDataxZ : data_vector(N_ROWS-1 downto 0);
  --signal RowRomCtrlxZ   : data_vector(N_ROWS-1 downto 0);
  signal RowRomRdDataxZ : data_vector(N_ROWS-1 downto 0);

begin  -- simple

  -----------------------------------------------------------------------------
  -- connect an ioport controller to every input and output of the
  -- engine
  -----------------------------------------------------------------------------
  IOPortCtrlPort_gen : for prt in N_IOP-1 downto 0 generate

    InPortCtrl : IOPortCtrl
      generic map (
        CCNTWIDTH => CCNTWIDTH)
      port map (
        ClkxC         => ClkxC,
        RstxRB        => RstxRB,
        ConfigxI      => ConfigxI.inportConf(prt),
        CycleDnCntxDI => CycleDnCntxDI,
        CycleUpCntxDI => CycleUpCntxDI,
        PortxEO       => InPortxEO(prt));

    OutPortCtrl : IOPortCtrl
      generic map (
        CCNTWIDTH => CCNTWIDTH)
      port map (
        ClkxC         => ClkxC,
        RstxRB        => RstxRB,
        ConfigxI      => ConfigxI.outportConf(prt),
        CycleDnCntxDI => CycleDnCntxDI,
        CycleUpCntxDI => CycleUpCntxDI,
        PortxEO       => OutPortxEO(prt));

  end generate IOPortCtrlPort_gen;


  Gen_Rows : for i in N_ROWS-1 downto 0 generate
    row_i : Row
      generic map (
        DATAWIDTH => DATAWIDTH)
      port map (
        ClkxC         => ClkxC,
        RstxRB        => RstxRB,
        CExEI         => CExEI,
        ConfigxI      => ConfigxI.gridConf(i),
        ClrContextxSI => ClrContextxSI,
        ClrContextxEI => ClrContextxEI,
        ContextxSI    => ContextxSI,
        InpxI         => GridInp(i),
        OutxO         => GridOut(i),
        MemDataxDI    => cellMemDataxDI(i),  -- input from MEM
        MemAddrxDO    => cellMemAddrxDO(i),  -- addr output to MEM
        MemDataxDO    => cellMemDataxDO(i),  -- data output to MEM
        MemCtrlxSO    => cellMemCtrlxSO(i)   -- ctrl output to MEM
        );
  end generate Gen_Rows;


  Gen_Roms : for r in N_ROWS-1 downto 0 generate
    rom_i : Rom
      generic map (
        DEPTH => N_MEMDEPTH)
      port map (
        ConfigxI  => ConfigxI.memoryConf(r),
        RdAddrxDI => RowRomRdAddrxZ(r),
        RdDataxDO => RowRomRdDataxZ(r));
  end generate Gen_Roms;

  -----------------------------------------------------------------------------
  -- create tristate buffers for driving the HBusN buses from the input ports,
  -- and add tristate buffers for driving the results from the HBusN buses to
  -- the output ports
  -----------------------------------------------------------------------------
  TBufPort_gen : for prt in N_IOP-1 downto 0 generate
    TBufrow_gen : for row in N_ROWS-1 downto 0 generate
      TBufHBusN_gen : for hbusn in N_HBUSN-1 downto 0 generate

        -- connect input ports to HBusN
        InpTBuf : TristateBuf
          generic map (
            WIDTH => DATAWIDTH)
          port map (
            InxDI  => InPortxDI(prt),
            OExEI  => ConfigxI.inputDriverConf(prt)(row)(hbusn),
            OutxZO => HBusNxZ(row)(hbusn));

        -- connect HBusN to output ports
        OutpTristateBuf : TristateBuf
          generic map (
            WIDTH => DATAWIDTH)
          port map (
            InxDI  => HBusNxZ(row)(hbusn),
            OExEI  => ConfigxI.outputDriverConf(prt)(row)(hbusn),
            OutxZO => OutPortxDO(prt));

      end generate TBufHBusN_gen;
    end generate TBufrow_gen;
  end generate TBufPort_gen;


  -------------------------------------------------------------------------------
  --  CELL OUTPUTS
  -------------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- create bus drivers the allow to write data from the cells to HBusN, HBusS
  -- and VBusE buses.
  -----------------------------------------------------------------------------

  TBufConHBusRow_gen : for r in N_ROWS-1 downto 0 generate
    TBufConHBusCol_gen : for c in N_COLS-1 downto 0 generate

      -- output to HBusN
      -- cells in row r drive the HBusN of row r+1
      TBufConHBusHBusN_gen : for hbusn in N_HBUSN-1 downto 0 generate
        HBusNxZ((r+1) mod N_ROWS)(hbusn) <= GridOut(r)(c).HBusNxDZ(hbusn);
      end generate TBufConHBusHBusN_gen;

      -- output to HBusS
      -- cell in row r drive the HBusS of the same row r
      TBufConHBusHBusS_gen : for hbuss in N_HBUSS-1 downto 0 generate
        HBusSxZ(r)(hbuss) <= GridOut(r)(c).HBusSxDZ(hbuss);
      end generate TBufConHBusHBusS_gen;

      -- output to VBusE
      -- cells in column c drive the VBusE of column the same column c
      TBufConHBusVBusE_gen : for vbuse in N_VBUSE-1 downto 0 generate
        VBusExZ(c)(vbuse) <= GridOut(r)(c).VBusExDZ(vbuse);
      end generate TBufConHBusVBusE_gen;

      -- output to memory elements: all cells in a row drive the same bus,
      -- since there is just a single shared memory block per ROW
      --   arbitration of bus is handled with configuration. If a cell is
      --   configured as alu_rom, it drives address data to this bus. Only one
      --   cell per row is allowed to be configured as memory cell
      RowRomRdAddrxZ(r) <= cellMemAddrxDO(r)(c);

      -- for RAM, add other output signals here
      
    end generate TBufConHBusCol_gen;
  end generate TBufConHBusRow_gen;



  -----------------------------------------------------------------------------
  -- CELL INPUTS
  -----------------------------------------------------------------------------


  CellInpRow_gen : for r in N_ROWS-1 downto 0 generate
    CellInpCol_gen : for c in N_COLS-1 downto 0 generate

      -- local interconnect
      GridInp(r)(c).LocalxDI(LOCAL_NW) <=
        GridOut((r-1) mod N_ROWS)((c-1) mod N_COLS).LocalxDO;  -- NW

      GridInp(r)(c).LocalxDI(LOCAL_N) <=
        GridOut((r-1) mod N_ROWS)((c+0) mod N_COLS).LocalxDO;  -- N

      GridInp(r)(c).LocalxDI(LOCAL_NE) <=
        GridOut((r-1) mod N_ROWS)((c+1) mod N_COLS).LocalxDO;  -- NE

      GridInp(r)(c).LocalxDI(LOCAL_W) <=
        GridOut((r+0) mod N_ROWS)((c-1) mod N_COLS).LocalxDO;  -- W

      GridInp(r)(c).LocalxDI(LOCAL_E) <=
        GridOut((r+0) mod N_ROWS)((c+1) mod N_COLS).LocalxDO;  -- E

      GridInp(r)(c).LocalxDI(LOCAL_SW) <=
        GridOut((r+1) mod N_ROWS)((c-1) mod N_COLS).LocalxDO;  -- SW

      GridInp(r)(c).LocalxDI(LOCAL_S) <=
        GridOut((r+1) mod N_ROWS)((c+0) mod N_COLS).LocalxDO;  -- S

      GridInp(r)(c).LocalxDI(LOCAL_SE) <=
        GridOut((r+1) mod N_ROWS)((c+1) mod N_COLS).LocalxDO;  -- SE

      -- FIXME FIXME FIXME: check feeding of singals to cells. Our testbenches
      -- do not test the south and VBusE buses yet. create test for these buses.

      -- bus interconnect


      -- input from HBusN
      CellInpHBusN_gen : for hbusn in N_HBUSN-1 downto 0 generate
        GridInp(r)(c).HBusNxDI(hbusn) <= HBusNxZ(r)(hbusn);  -- HBusN inputs
      end generate CellInpHBusN_gen;

      -- input from HBusS
      CellInpHBusS_gen : for hbuss in N_HBUSS-1 downto 0 generate
        GridInp(r)(c).HBusSxDI(hbuss) <= HBusSxZ(r)(hbuss);  -- HBusS inputs
      end generate CellInpHBusS_gen;

      -- input from VBusE
      -- cells in column c read from VBusE of column c-1 (west)
      -- VBusE inputs
      CellInpVBusE_gen : for vbuse in N_VBUSE-1 downto 0 generate
        GridInp(r)(c).VBusExDI(vbuse) <= VBusExZ((c-1) mod N_COLS)(vbuse);
      end generate CellInpVBusE_gen;

      -- cell input from MEM, drive all cell memory inputs in a row with the
      -- same data, since there is a shared memory block per row
      cellMemDataxDI(r)(c) <= RowRomRdDataxZ(r);
      
    end generate CellInpCol_gen;
  end generate CellInpRow_gen;

  -----------------------------------------------------------------------------
  -- add pulldowns to all buses (horizontal,vertical, memory);
  -----------------------------------------------------------------------------
  PullDownRows_gen : for r in N_ROWS-1 downto 0 generate
    PullDownHBusN_gen : for hbusn in N_HBUSN-1 downto 0 generate
    begin
      PullDownHBusN : PullBus
        generic map (
          WIDTH => DATAWIDTH)
        port map (
          ModexSI => '0',
          BusxZO  => HBusNxZ(r)(hbusn));
    end generate PullDownHBusN_gen;

    PullDownHBusS_gen : for hbuss in N_HBUSS-1 downto 0 generate
    begin
      PullDownHBusS : PullBus
        generic map (
          WIDTH => DATAWIDTH)
        port map (
          ModexSI => '0',
          BusxZO  => HBusSxZ(r)(hbuss));
    end generate PullDownHBusS_gen;
  end generate PullDownRows_gen;

  PullDownCols_gen : for c in N_COLS-1 downto 0 generate
    PullDownVBusE_gen : for vbuse in N_VBUSE-1 downto 0 generate
    begin
      PullDownVBusE : PullBus
        generic map (
          WIDTH => DATAWIDTH)
        port map (
          ModexSI => '0',
          BusxZO  => VBusExZ(c)(vbuse));
    end generate PullDownVBusE_gen;
  end generate PullDownCols_gen;

  PullDownRowRomIn_gen : for r in N_ROWS-1 downto 0 generate
  begin
    PullDownRowRomAddrxDI : PullBus
      generic map (
        WIDTH => DATAWIDTH)
      port map (
        ModexSI => '0',
        BusxZO  => RowRomRdAddrxZ(r));
  end generate PullDownRowRomIn_gen;

end simple;
