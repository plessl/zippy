------------------------------------------------------------------------------
-- Stuff for handling the ZUnit configuration(s)
--
-- Project     : 
-- File        : $Id: configPkg.vhd 218 2005-01-13 17:02:10Z plessl $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/10/08
-- Last changed: $LastChangedDate: 2005-01-13 18:02:10 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- This package provides a number of functions that convert the configuration
-- of the Zippy array from a human readable, hierarchical VHDL-record form
-- to a bitstring representation.
-- The configuration can also be transformed into a C header file. The data
-- from this header file is used to configure the zunit via the host interface.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-08 CP added documentation
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.txt_util.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.AuxPkg.all;

package ConfigPkg is

  constant PE_CFGLEN      : integer := procConfig_length;
  constant RE_CFGLEN      : integer := routConfig_length;
  constant CELL_CFGLEN    : integer := cellConfig_length;
  constant ROW_CFGLEN     : integer := rowConfig_length;
  constant GRID_CFGLEN    : integer := gridConfig_length;
  constant PORT_CFGLEN    : integer := ioportConfig_length;
  constant INPDRV_CFGLEN  : integer := inputDriverConfig_length;
  constant OUTPDRV_CFGLEN : integer := outputDriverConfig_length;
  constant INPORT_CFGLEN  : integer := inportConfig_length;
  constant OUTPORT_CFGLEN : integer := outportConfig_length;
  constant MEM_CFGLEN     : integer := memoryConfig_length;
  constant ENGN_CFGLEN    : integer := engineConfig_length;
  constant NPARTS         : integer := num_partitions(ENGN_CFGLEN, PARTWIDTH);

  constant CELLROUTINGINPUTCONFIGREC_LEN : integer :=
    N_LOCALCON + N_HBUSN + N_HBUSS + N_VBUSE;

  subtype cfgPartType is std_logic_vector(PARTWIDTH-1 downto 0);
  type    cfgPartArray is array (NPARTS-1 downto 0) of cfgPartType;

  subtype contextType is std_logic_vector(ENGN_CFGLEN-1 downto 0);
  type    contextArray is array (N_CONTEXTS-1 downto 0) of contextType;
  type    contextPartArray is array (N_CONTEXTS-1 downto 0) of cfgPartArray;

  -- initializes a procConfig record
  function init_procConfig return procConfigRec;

  -- initializes a routConfig record
  function init_routConfig return routConfigRec;

  -- initializes a cellConfig record
  function init_cellConfig return cellConfigRec;

  -- initializes a cellInputRec record
  function init_cellInput return cellInputRec;

  -- initializes a rowConfig array
  function init_rowConfig return rowConfigArray;

  -- initializes a rowInput array
  function init_rowInput return rowInputArray;

  -- initializes a gridConfig array
  function init_gridConfig return gridConfigArray;

  -- initializes an ioportConfig record
  function init_ioportConfig return ioportConfigRec;

  -- initializes an engineInportConfigArray
  function init_inportConfig return engineInportConfigArray;

  -- initializes an engineOutportConfigArray
  function init_outportConfig return engineOutportConfigArray;

  -- initializes an engineHBusNorthInputDriver array
  function init_inputDriverConfig return engineHBusNorthInputDriverArray;

  -- initializes an engineHBusNorthOutputDriver array
  function init_outputDriverConfig return engineHBusNorthOutputDriverArray;

  -- initializes an engineConfig record
  function init_engineConfig return engineConfigRec;

  -- converts a procConfig record to a vector
  function to_procConfig_vec (Cfg : procConfigRec) return std_logic_vector;

  -- converts a procConfig vector to a record
  function to_procConfig_rec (CfgxD : std_logic_vector(PE_CFGLEN-1 downto 0))
    return procConfigRec;

  -- converts a routConfig record to a vector
  function to_routConfig_vec (Cfg : routConfigRec) return std_logic_vector;

  -- converts a routConfig vector to a record
  function to_routConfig_rec (CfgxD : std_logic_vector(RE_CFGLEN-1 downto 0))
    return routConfigRec;

  -- converts a cellConfig record to a vector
  function to_cellConfig_vec (Cfg : cellConfigRec) return std_logic_vector;

  -- converts a cellConfig vector to a record
  function to_cellConfig_rec (CfgxD : std_logic_vector(CELL_CFGLEN-1 downto 0))
    return cellConfigRec;

  -- converts a rowConfig array to a vector
  function to_rowConfig_vec (Cfg : rowConfigArray) return std_logic_vector;

  -- converts a rowConfig vector to an array
  function to_rowConfig_arr (CfgxD : std_logic_vector(ROW_CFGLEN-1 downto 0))
    return rowConfigArray;

  -- converts a gridConfig array to a vector
  function to_gridConfig_vec (Cfg : gridConfigArray) return std_logic_vector;

  -- converts a gridConfig vector to an array
  function to_gridConfig_arr (CfgxD : std_logic_vector(GRID_CFGLEN-1 downto 0))
    return gridConfigArray;

  -- convert a inputDriverConfig array to a vector
  function to_inputDriverConfig_vec (Cfg : engineHBusNorthInputDriverArray)
    return std_logic_vector;

  -- convert a inputDriverConfig vector to an array
  function to_inputDriverConfig_arr (
    vec : std_logic_vector(INPDRV_CFGLEN-1 downto 0))
    return engineHBusNorthInputDriverArray;

  -- convert a outputDriverConfig array to a vector
  function to_outputDriverConfig_vec (Cfg : engineHBusNorthOutputDriverArray)
    return std_logic_vector;

  -- convert a outputDriverConfig vector to an array
  function to_outputDriverConfig_arr (
    vec : std_logic_vector(INPDRV_CFGLEN-1 downto 0))
    return engineHBusNorthOutputDriverArray;

  -- converts an ioportConfig record to a vector
  function to_ioportConfig_vec (Cfg : ioportConfigRec) return std_logic_vector;

  -- converts an ioportConfig vector to a record
  function to_ioportConfig_rec (
    CfgxD : std_logic_vector(PORT_CFGLEN-1 downto 0))
    return ioportConfigRec;

  -- convert inportConfig vector to an array of records
  function to_inportConfig_arr (
    CfgxD : std_logic_vector(INPORT_CFGLEN-1 downto 0))
    return engineInportConfigArray;

  -- convert inportConfig array of records to vector
  function to_inportConfig_vec (Cfg : engineInportConfigArray)
    return std_logic_vector;

  -- convert outportConfig vector to an array of records
  function to_outportConfig_arr (
    CfgxD : std_logic_vector(OUTPORT_CFGLEN-1 downto 0))
    return engineOutportConfigArray;

  -- convert outportConfig array of records to vector
  function to_outportConfig_vec (Cfg : engineOutportConfigArray)
    return std_logic_vector;

  -----------------------------------------------------------------------------
  -- memory configuration handling functions
  -----------------------------------------------------------------------------
  function init_memoryConfig return engineMemoryConfigArray;

  function to_memoryConfig_vec (Cfg : engineMemoryConfigArray)
    return std_logic_vector;
  
  function to_memoryConfig_arr (CfgxD : std_logic_vector(MEM_CFGLEN-1 downto 0))
    return engineMemoryConfigArray;

  -- converts an engineConfig record to a vector
  function to_engineConfig_vec (Cfg : engineConfigRec) return std_logic_vector;

  -- converts an engineConfig vector to a record
  function to_engineConfig_rec (
    CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0))
    return engineConfigRec;

  -- partitions the configuration into partitions of equal width
  function partition_config (
    signal CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0))
    return cfgPartArray;

  -- generate .h file for coupled simulation
  procedure gen_cfghfile (file hfile : text; CfgArr : in cfgPartArray);

  -- generate .h file for coupled simulation (multi-context)
  procedure gen_contexthfile2 (file hfile : text; cpArr : in contextPartArray);

end ConfigPkg;


------------------------------------------------------------------------------
-- BODY
------------------------------------------------------------------------------

package body ConfigPkg is

  -- initializes a procConfig record
  function init_procConfig return procConfigRec is
    variable Cfg : procConfigRec;
  begin
    Cfg.OpMuxS         := (others => I_NOREG);
    Cfg.OpCtxRegSelxS  := (others => (others => '0'));
    Cfg.OutMuxS        := O_NOREG;
    Cfg.OutCtxRegSelxS := (others => '0');
    Cfg.AluOpxS        := ALU_OP_PASS0;
    Cfg.ConstOpxD      := (others => '0');
    return Cfg;
  end init_procConfig;

  -- initializes a routConfig record
  function init_routConfig return routConfigRec is
    variable Cfg : routConfigRec;
  begin
    for inp in Cfg.i'range loop
      Cfg.i(inp).LocalxE := (others => '0');
      Cfg.i(inp).HBusNxE := (others => '0');
      Cfg.i(inp).HBusSxE := (others => '0');
      Cfg.i(inp).VBusExE := (others => '0');
    end loop;  --  inp
    Cfg.o.HBusNxE := (others => '0');
    Cfg.o.HBusSxE := (others => '0');
    Cfg.o.VBusExE := (others => '0');
    return Cfg;
  end init_routConfig;

  -- initializes a cellConfig record
  function init_cellConfig return CellConfigRec is
    variable Cfg : CellConfigRec;
  begin
    Cfg.procConf := init_procConfig;
    Cfg.routConf := init_routConfig;
    return Cfg;
  end init_cellConfig;

  -- initializes a cellInputRec record
  function init_cellInput return cellInputRec is
    variable Inp : cellInputRec;
  begin
    Inp.LocalxDI := (others => (others => '0'));
    Inp.HBusNxDI := (others => (others => '0'));
    Inp.HBusSxDI := (others => (others => '0'));
    Inp.VBusExDI := (others => (others => '0'));
    return Inp;
  end init_cellInput;

  -- initializes a rowConfig array
  function init_rowConfig return rowConfigArray is
    variable Cfg : rowConfigArray;
  begin
    for i in Cfg'range loop
      Cfg(i) := init_cellConfig;
    end loop;  -- i
    return Cfg;
  end init_rowConfig;

  -- initializes a rowInput array
  function init_rowInput return rowInputArray is
    variable Inp : rowInputArray;
  begin
    for i in Inp'range loop
      Inp(i) := init_cellInput;
    end loop;  -- i
    return Inp;
  end init_rowInput;

  -- initializes a gridConfig array
  function init_gridConfig return gridConfigArray is
    variable Cfg : gridConfigArray;
  begin
    for i in Cfg'range loop
      Cfg(i) := init_rowConfig;
    end loop;  -- i
    return Cfg;
  end init_gridConfig;

  -- initializes an ioportConfig record
  function init_ioportConfig return ioportConfigRec is
    variable Cfg : ioportConfigRec;
  begin
    Cfg.Cmp0MuxS    := '0';
    Cfg.Cmp0ModusxS := '0';
    Cfg.Cmp0ConstxD := (others => '0');
    Cfg.Cmp1MuxS    := '0';
    Cfg.Cmp1ModusxS := '0';
    Cfg.Cmp1ConstxD := (others => '0');
    Cfg.LUT4FunctxD := (others => '0');
    return Cfg;
  end init_ioportConfig;

  -- initializes an engineInportConfigArray
  function init_inportConfig return engineInportConfigArray is
    variable Cfg : engineInportConfigArray;
  begin
    for inp in Cfg'range loop
      Cfg(inp) := init_ioportConfig;
    end loop;  -- inp
    return Cfg;
  end init_inportConfig;

  -- initializes an engineOutportConfigArray
  function init_outportConfig return engineOutportConfigArray is
    variable Cfg : engineOutportConfigArray;
  begin
    for outp in Cfg'range loop
      Cfg(outp) := init_ioportConfig;
    end loop;  -- outp
    return Cfg;
  end init_outportConfig;


  -----------------------------------------------------------------------------
  -- functions for memory configuration handling
  -----------------------------------------------------------------------------

  -- initializes a memoryConfigArray
  function init_memoryConfig return engineMemoryConfigArray is
    variable arr : engineMemoryConfigArray;
  begin
    arr := (others => (others => (others => '0')));
    return arr;
  end init_memoryConfig;

  function to_memoryConfig_vec (Cfg : engineMemoryConfigArray)
    return std_logic_vector is
    variable vec            : std_logic_vector(MEM_CFGLEN-1 downto 0);
    variable fromInd, toInd : integer;
    constant SINGLEROMLEN   : integer := N_MEMDEPTH*DATAWIDTH;
  begin
    for rom in Cfg'range loop
      for i in Cfg(0)'range loop
        fromInd                   := rom*SINGLEROMLEN + (i+1)*DATAWIDTH-1;
        toInd                     := rom*SINGLEROMLEN + i*DATAWIDTH;
        vec(fromInd downto toInd) := Cfg(rom)(i);
      end loop;
    end loop;
    return vec;
  end to_memoryConfig_vec;

  function to_memoryConfig_arr (CfgxD : std_logic_vector(MEM_CFGLEN-1 downto 0))
    return engineMemoryConfigArray is
    variable Cfg            : engineMemoryConfigArray;
    variable fromInd, toInd : integer;
    constant SINGLEROMLEN   : integer := N_MEMDEPTH*DATAWIDTH;
  begin
    for rom in Cfg'range loop
      for i in Cfg(0)'range loop
        fromInd     := rom*SINGLEROMLEN + (i+1)*DATAWIDTH-1;
        toInd       := rom*SINGLEROMLEN + i*DATAWIDTH;
        Cfg(rom)(i) := CfgxD(fromInd downto toInd);
      end loop;
    end loop;
    return Cfg;
  end to_memoryConfig_arr;

  -------------------------------------------------------------------------------
  -- input and output driver configuration functions
  -------------------------------------------------------------------------------

  function init_inputDriverConfig return engineHBusNorthInputDriverArray is
    variable Cfg : engineHBusNorthInputDriverArray;
  begin
    Cfg := (others => (others => (others => '0')));
    return Cfg;
  end init_inputDriverConfig;

  function init_outputDriverConfig return engineHBusNorthOutputDriverArray is
    variable Cfg : engineHBusNorthOutputDriverArray;
  begin
    Cfg := (others => (others => (others => '0')));
    return Cfg;
  end init_outputDriverConfig;

  function to_inputDriverConfig_vec (Cfg : engineHBusNorthInputDriverArray)
    return std_logic_vector is
    variable vec : std_logic_vector(INPDRV_CFGLEN-1 downto 0);
  begin
    for inp in Cfg'range loop
      for row in Cfg(0)'range loop
        for p in Cfg(0)(0)'range loop
          vec( (inp*Cfg(0)'length + row)*Cfg(0)(0)'length + p) := Cfg(inp)(row)(p);
        end loop;  -- p
      end loop;  -- row
    end loop;  -- inp
    return vec;
  end to_inputDriverConfig_vec;


  function to_outputDriverConfig_vec (Cfg : engineHBusNorthOutputDriverArray)
    return std_logic_vector is
    variable vec : std_logic_vector(OUTPDRV_CFGLEN-1 downto 0);
  begin
    for outp in Cfg'range loop
      for row in Cfg(0)'range loop
        for p in Cfg(0)(0)'range loop
          vec( (outp*Cfg(0)'length + row)*Cfg(0)(0)'length + p) := Cfg(outp)(row)(p);
        end loop;  -- p
      end loop;  -- row
    end loop;  -- outp
    return vec;
  end to_outputDriverConfig_vec;


  function to_inputDriverConfig_arr (
    vec : std_logic_vector(INPDRV_CFGLEN-1 downto 0))
    return engineHBusNorthInputDriverArray is
    variable Cfg : engineHBusNorthInputDriverArray;
  begin
    for inp in Cfg'range loop
      for row in Cfg(0)'range loop
        for p in Cfg(0)(0)'range loop
          Cfg(inp)(row)(p) := vec( (inp*Cfg(0)'length + row)*Cfg(0)(0)'length + p);
        end loop;  -- p
      end loop;  -- row
    end loop;  -- inp
    return Cfg;
  end to_inputDriverConfig_arr;


  function to_outputDriverConfig_arr (
    vec : std_logic_vector(INPDRV_CFGLEN-1 downto 0))
    return engineHBusNorthOutputDriverArray is
    variable Cfg : engineHBusNorthOutputDriverArray;
  begin
    for outp in Cfg'range loop
      for row in Cfg(0)'range loop
        for p in Cfg(0)(0)'range loop
          Cfg(outp)(row)(p) := vec( (outp*Cfg(0)'length + row)*Cfg(0)(0)'length + p);
        end loop;  -- p
      end loop;  -- row
    end loop;  -- outp
    return Cfg;
  end to_outputDriverConfig_arr;


  -- initializes an engineConfig record
  function init_engineConfig return engineConfigRec is
    variable Cfg : engineConfigRec;
  begin
    Cfg.gridConf         := init_gridConfig;
    Cfg.inputDriverConf  := init_inputDriverConfig;
    Cfg.outputDriverConf := init_outputDriverConfig;
    Cfg.inportConf       := init_inportConfig;
    Cfg.outportConf      := init_outportConfig;
    Cfg.memoryConf       := init_memoryConfig;
    return Cfg;
  end init_engineConfig;

--  type procConfigRec is
--    record                                            
--      OpMuxS         : procInputMuxArray;             -- PE_CFGLEN-1 downto bnd0
--      OpCtxRegSelxS  : procInputCtxRegSelectArray;    -- bnd0-1      downto bnd1
--      OutMuxS        : procOutputMux;                 -- bnd1-1      downto bnd2
--      OutCtxRegSelxS : procOutputCtxRegSelect;        -- bnd2-1      downto bnd3
--      AluOpxS        : aluOpType;                     -- bnd3-1      downto bnd4
--      ConstOpxD      : data_word;                     -- bnd4-1      downto 0
--    end record;

  -- converts a procConfig record to a vector
  function to_procConfig_vec (Cfg : procConfigRec) return std_logic_vector is
    variable vec       : std_logic_vector(PE_CFGLEN-1 downto 0);

    constant bnd0 : natural := PE_CFGLEN - Cfg.OpMuxS'length*Cfg.OpMuxS(0)'length;
    constant bnd1 : natural := bnd0 - Cfg.OpCtxRegSelxS'length*Cfg.OpCtxRegSelxS(0)'length;
    constant bnd2 : natural := bnd1 - Cfg.OutMuxS'length;
    constant bnd3 : natural := bnd2 - Cfg.OutCtxRegSelxS'length;
    constant bnd4 : natural := bnd3 - ALUOPWIDTH;

  begin

    for inp in Cfg.OpMuxS'range loop
      vec((inp+1)*Cfg.OpMuxS(0)'length-1+bnd0 downto
          inp*Cfg.OpMuxS(0)'length+bnd0) := Cfg.OpMuxS(inp);
    end loop;

    for inp in Cfg.OpMuxS'range loop
      vec((inp+1)*Cfg.OpCtxRegSelxS(0)'length-1+bnd1
          downto inp*Cfg.OpCtxRegSelxS(0)'length+bnd1) := Cfg.OpCtxRegSelxS(inp);
    end loop;  -- inp
    
    vec(bnd1-1 downto bnd2) := Cfg.OutMuxS;
    vec(bnd2-1 downto bnd3) := Cfg.OutCtxRegSelxS;
    vec(bnd3-1 downto bnd4) := std_logic_vector(to_unsigned(Cfg.AluOpxS, ALUOPWIDTH));
    vec(bnd4-1 downto 0)    := Cfg.ConstOpxD;
    return vec;
  end to_procConfig_vec;

  -- converts a procConfig vector to a record
  function to_procConfig_rec (CfgxD : std_logic_vector(PE_CFGLEN-1 downto 0))
    return procConfigRec
  is
    variable rec       : procConfigRec;
    constant bnd0 : natural := PE_CFGLEN - rec.OpMuxS'length*rec.OpMuxS(0)'length;
    constant bnd1 : natural := bnd0 - rec.OpCtxRegSelxS'length*rec.OpCtxRegSelxS(0)'length;
    constant bnd2 : natural := bnd1 - rec.OutMuxS'length;
    constant bnd3 : natural := bnd2 - rec.OutCtxRegSelxS'length;
    constant bnd4 : natural := bnd3 - ALUOPWIDTH;
    
  begin

    for inp in rec.OpMuxS'range loop
      rec.OpMuxS(inp) := CfgxD((inp+1)*rec.OpMuxS(0)'length-1+bnd0 downto
          inp*rec.OpMuxS(0)'length+bnd0);
    end loop;  -- inp

    for inp in rec.OpCtxRegSelxS'range loop
      rec.OpCtxRegSelxS(inp) := CfgxD((inp+1)*rec.OpCtxRegSelxS(0)'length-1+bnd1
          downto inp*rec.OpCtxRegSelxS(0)'length+bnd1);
    end loop;  -- inp
    
    rec.OutMuxS        := CfgxD(bnd1-1 downto bnd2);
    rec.OutCtxRegSelxS := CfgxD(bnd2-1 downto bnd3);
    rec.AluOpxS        := to_integer(unsigned(CfgxD(bnd3-1 downto bnd4)));
    rec.ConstOpxD      := CfgxD(bnd4-1 downto 0);
    return rec;
  end to_procConfig_rec;

  -- converts a routConfig record to a vector
  function to_routConfig_vec (Cfg : routConfigRec) return std_logic_vector is

    constant OUTPLEN : integer := Cfg.o.HBusNxE'length +
                                  Cfg.o.HBusSxE'length +
                                  Cfg.o.VBusExE'length;

    constant INPLEN : integer := Cfg.i'length*(Cfg.i(0).LocalxE'length +
                                               Cfg.i(0).HBusNxE'length +
                                               Cfg.i(0).HBusSxE'length +
                                               Cfg.i(0).VBusExE'length);

    variable vec_inp  : std_logic_vector(INPLEN-1 downto 0);
    variable vec_outp : std_logic_vector(OUTPLEN-1 downto 0);
    variable vec      : std_logic_vector(RE_CFGLEN-1 downto 0);

    variable start, bnd0, bnd1, bnd2, bnd3, bnd4, bnd5, bnd6 : integer;
  begin

    -- convert configuration for inputs to vector
    for inp in Cfg.i'range loop
      start := (inp+1)*CELLROUTINGINPUTCONFIGREC_LEN;
      bnd0  := start - N_LOCALCON;
      bnd1  := bnd0 - N_HBUSN;
      bnd2  := bnd1 - N_HBUSS;
      bnd3  := bnd2 - N_VBUSE;

      vec_inp(start-1 downto bnd0) := Cfg.i(inp).LocalxE;
      vec_inp(bnd0-1 downto bnd1)  := Cfg.i(inp).HBusNxE;
      vec_inp(bnd1-1 downto bnd2)  := Cfg.i(inp).HBusSxE;
      vec_inp(bnd2-1 downto bnd3)  := Cfg.i(inp).VBusExE;
    end loop;  -- inp

    -- convert configuration for output to vector
    bnd4 := OUTPLEN - N_HBUSN;
    bnd5 := bnd4 - N_HBUSS;
    bnd6 := bnd5 - N_VBUSE;

    vec_outp(OUTPLEN-1 downto bnd4) := Cfg.o.HBusNxE;
    vec_outp(bnd4-1 downto bnd5)    := Cfg.o.HBusSxE;
    vec_outp(bnd5-1 downto bnd6)    := Cfg.o.VBusExE;

    vec := vec_inp & vec_outp;
    return vec;
    
  end to_routConfig_vec;

  -- converts a routConfig vector to a record
  function to_routConfig_rec (CfgxD : std_logic_vector(RE_CFGLEN-1 downto 0))
    return routConfigRec
  is
    variable CfgRec : routConfigRec;

    constant OUTPLEN : integer := CfgRec.o.HBusNxE'length +
                                  CfgRec.o.HBusSxE'length +
                                  CfgRec.o.VBusExE'length;

    constant INPLEN : integer := CfgRec.i'length*(CfgRec.i(0).LocalxE'length +
                                                  CfgRec.i(0).HBusNxE'length +
                                                  CfgRec.i(0).HBusSxE'length +
                                                  CfgRec.i(0).VBusExE'length);


    variable CfgInpxD  : std_logic_vector(INPLEN-1 downto 0);
    variable CfgOutpxD : std_logic_vector(OUTPLEN-1 downto 0);

    variable start, bnd0, bnd1, bnd2, bnd3, bnd4, bnd5, bnd6 : integer;

  begin

    CfgInpxD  := CfgxD(RE_CFGLEN-1 downto RE_CFGLEN-INPLEN);
    CfgOutpxD := CfgxD(OUTPLEN-1 downto 0);

    -- convert configuration for inputs to record entries
    for inp in CfgRec.i'range loop
      start := (inp+1)*CELLROUTINGINPUTCONFIGREC_LEN;
      bnd0  := start - N_LOCALCON;
      bnd1  := bnd0 - N_HBUSN;
      bnd2  := bnd1 - N_HBUSS;
      bnd3  := bnd2 - N_VBUSE;

      CfgRec.i(inp).LocalxE := CfgInpxD(start-1 downto bnd0);
      CfgRec.i(inp).HBusNxE := CfgInpxD(bnd0-1 downto bnd1);
      CfgRec.i(inp).HBusSxE := CfgInpxD(bnd1-1 downto bnd2);
      CfgRec.i(inp).VBusExE := CfgInpxD(bnd2-1 downto bnd3);
    end loop;  -- inp

    -- convert configuration for outputs to record entry
    bnd4             := OUTPLEN-N_HBUSN;
    bnd5             := bnd4-N_HBUSS;
    bnd6             := bnd5-N_VBUSE;
    CfgRec.o.HBusNxE := CfgOutpxD(OUTPLEN-1 downto bnd4);
    CfgRec.o.HBusSxE := CfgOutpxD(bnd4-1 downto bnd5);
    CfgRec.o.VBusExE := CfgOutpxD(bnd5-1 downto bnd6);

    return CfgRec;
  end to_routConfig_rec;

  -- converts a cellConfig record to a vector
  function to_cellConfig_vec (Cfg : cellConfigRec) return std_logic_vector is
    variable vec : std_logic_vector(CELL_CFGLEN-1 downto 0);
  begin
    vec := to_procConfig_vec(Cfg.procConf) & to_routConfig_vec(Cfg.routConf);
    return vec;
  end to_cellConfig_vec;

  -- converts a cellConfig vector to a record
  function to_cellConfig_rec (CfgxD : std_logic_vector(CELL_CFGLEN-1 downto 0))
    return cellConfigRec
  is
    variable rec : cellConfigRec;
  begin
    rec.procConf := to_procConfig_rec(CfgxD(CELL_CFGLEN-1 downto RE_CFGLEN));
    rec.routConf := to_routConfig_rec(CfgxD(RE_CFGLEN-1 downto 0));
    return rec;
  end to_cellConfig_rec;

  -- converts a rowConfig array to a vector
  function to_rowConfig_vec (Cfg : rowConfigArray) return std_logic_vector is
    variable vec : std_logic_vector(ROW_CFGLEN-1 downto 0);
  begin
    for i in Cfg'range loop
      vec(CELL_CFGLEN*(i+1)-1 downto CELL_CFGLEN*i) :=
        to_cellConfig_vec(Cfg(i));
    end loop;  -- i
    return vec;
  end to_rowConfig_vec;

  -- converts a rowConfig vector to an array
  function to_rowConfig_arr (CfgxD : std_logic_vector(ROW_CFGLEN-1 downto 0))
    return rowConfigArray
  is
    variable arr : rowConfigArray;
  begin
    for i in arr'range loop
      arr(i) :=
        to_cellConfig_rec(CfgxD(CELL_CFGLEN*(i+1)-1 downto CELL_CFGLEN*i));
    end loop;  -- i
    return arr;
  end to_rowConfig_arr;

  -- converts a gridConfig array to a vector
  function to_gridConfig_vec (Cfg : gridConfigArray) return std_logic_vector is
    variable vec : std_logic_vector(GRID_CFGLEN-1 downto 0);
  begin
    for i in Cfg'range loop
      vec(ROW_CFGLEN*(i+1)-1 downto ROW_CFGLEN*i) := to_rowConfig_vec(Cfg(i));
    end loop;  -- i
    return vec;
  end to_gridConfig_vec;

  -- converts a gridConfig vector to an array
  function to_gridConfig_arr (CfgxD : std_logic_vector(GRID_CFGLEN-1 downto 0))
    return gridConfigArray
  is
    variable arr : gridConfigArray;
  begin
    for i in arr'range loop
      arr(i) :=
        to_rowConfig_arr(CfgxD(ROW_CFGLEN*(i+1)-1 downto ROW_CFGLEN*i));
    end loop;  -- i
    return arr;
  end to_gridConfig_arr;

  -- converts an ioportConfig record to a vector
  function to_ioportConfig_vec (Cfg : ioportConfigRec) return std_logic_vector
  is
    variable vec : std_logic_vector(PORT_CFGLEN-1 downto 0);
  begin
    vec := Cfg.LUT4FunctxD & Cfg.Cmp0MuxS & Cfg.Cmp1MuxS & Cfg.Cmp0ModusxS &
           Cfg.Cmp1ModusxS & Cfg.Cmp0ConstxD & Cfg.Cmp1ConstxD;
    return vec;
  end to_ioportConfig_vec;

  -- converts an ioportConfig vector to a record
  function to_ioportConfig_rec (
    CfgxD : std_logic_vector(PORT_CFGLEN-1 downto 0))
    return ioportConfigRec
  is
    variable rec  : ioportConfigRec;
    variable clen : integer := rec.Cmp0ConstxD'length;  -- constant length
  begin
    rec.LUT4FunctxD := CfgxD(PORT_CFGLEN-1 downto PORT_CFGLEN-16);
    rec.Cmp0MuxS    := CfgxD(PORT_CFGLEN-17);
    rec.Cmp1MuxS    := CfgxD(PORT_CFGLEN-18);
    rec.Cmp0ModusxS := CfgxD(PORT_CFGLEN-19);
    rec.Cmp1ModusxS := CfgxD(PORT_CFGLEN-20);
    rec.Cmp0ConstxD := CfgxD(2*clen-1 downto clen);
    rec.Cmp1ConstxD := CfgxD(clen-1 downto 0);
    return rec;
  end to_ioportConfig_rec;

  function to_inportConfig_vec (Cfg : engineInportConfigArray)
    return std_logic_vector
  is
    variable vec : std_logic_vector(INPORT_CFGLEN-1 downto 0);
  begin
    for inp in Cfg'range loop
      vec((inp+1)*PORT_CFGLEN-1 downto inp*PORT_CFGLEN) :=
        to_ioportConfig_vec(Cfg(inp));
    end loop;  -- inp
    return vec;
  end to_inportConfig_vec;

  function to_outportConfig_vec (Cfg : engineOutportConfigArray)
    return std_logic_vector
  is
    variable vec : std_logic_vector(OUTPORT_CFGLEN-1 downto 0);
  begin
    for outp in Cfg'range loop
      vec((outp+1)*PORT_CFGLEN-1 downto outp*PORT_CFGLEN) :=
        to_ioportConfig_vec(Cfg(outp));
    end loop;  -- outp
    return vec;
  end to_outportConfig_vec;

--FIXME
--Check code for splitting up vector into chunks of equal size

  function to_outportConfig_arr (
    CfgxD : std_logic_vector(OUTPORT_CFGLEN-1 downto 0))
    return engineOutportConfigArray
  is
    variable arr : engineOutportConfigArray;
  begin
    for outp in arr'range loop
      arr(outp) := to_ioportConfig_rec(CfgxD((outp+1)*PORT_CFGLEN-1 downto
                                             outp*PORT_CFGLEN));
    end loop;  -- outp
    return arr;
  end to_outportConfig_arr;
  
  function to_inportConfig_arr (
    CfgxD : std_logic_vector(INPORT_CFGLEN-1 downto 0))
    return engineInportConfigArray
  is
    variable arr : engineInportConfigArray;
  begin
    for inp in arr'range loop
      arr(inp) := to_ioportConfig_rec(CfgxD((inp+1)*PORT_CFGLEN-1 downto
                                            inp*PORT_CFGLEN));
    end loop;  -- inp
    return arr;
  end to_inportConfig_arr;


  -- converts an engineConfig record to a vector
  function to_engineConfig_vec (Cfg : engineConfigRec) return std_logic_vector
  is
    variable vec : std_logic_vector(ENGN_CFGLEN-1 downto 0);
  begin
    vec := to_gridConfig_vec(Cfg.gridConf) &
           to_inputDriverConfig_vec(Cfg.inputDriverConf) &
           to_outputDriverConfig_vec(Cfg.outputDriverConf) &
           to_inportConfig_vec(Cfg.inportConf) &
           to_outportConfig_vec(Cfg.outportConf) &
           to_memoryConfig_vec(Cfg.memoryConf);
    return vec;
  end to_engineConfig_vec;

  -- converts an engineConfig vector to a record
  function to_engineConfig_rec (
    CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0))
    return engineConfigRec
  is
    variable rec  : engineConfigRec;
    -- note: order is from last engineConfigRec entry to first
    variable bnd0 : integer := MEM_CFGLEN;
    variable bnd1 : integer := bnd0 + OUTPORT_CFGLEN;
    variable bnd2 : integer := bnd1 + INPORT_CFGLEN;
    variable bnd3 : integer := bnd2 + OUTPDRV_CFGLEN;
    variable bnd4 : integer := bnd3 + INPDRV_CFGLEN;
  begin
    rec.gridConf         := to_gridConfig_arr(CfgxD(ENGN_CFGLEN-1 downto bnd4));
    rec.inputDriverConf  := to_inputDriverConfig_arr(CfgxD(bnd4-1 downto bnd3));
    rec.outputDriverConf := to_outputDriverConfig_arr(CfgxD(bnd3-1 downto bnd2));
    rec.inportConf       := to_inportConfig_arr(CfgxD(bnd2-1 downto bnd1));
    rec.outportConf      := to_outportConfig_arr(CfgxD(bnd1-1 downto bnd0));
    rec.memoryConf       := to_memoryConfig_arr(CfgxD(bnd0-1 downto 0));
    return rec;
  end to_engineConfig_rec;

  -- partitions the configuration into partitions of equal widths
  function partition_config (
    signal CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0))
    return cfgPartArray
  is
    variable parts : cfgPartArray;
    variable hi    : natural;
    variable lo    : natural;

    function std_resize (arg : std_logic_vector; new_size : natural)
      return std_logic_vector
    is
      variable result : std_logic_vector(new_size downto 0) := (others => '0');
    begin
      return std_logic_vector(resize(unsigned(arg), new_size));
    end std_resize;
    
  begin  -- partition_config
    for i in parts'low to parts'high-1 loop
      lo       := PARTWIDTH * i;
      hi       := lo + PARTWIDTH - 1;
      parts(i) := CfgxD(hi downto lo);
    end loop;  -- i
    -- special treatment for the highest, probably shorter partition
    lo                := parts'high * PARTWIDTH;
    hi                := CfgxD'high;
    parts(parts'high) := std_resize(CfgxD(hi downto lo), PARTWIDTH);
    return parts;
  end partition_config;

  -- generate .h file for coupled simulation
  procedure gen_cfghfile (file hfile : text; CfgArr : in cfgPartArray)
  is
    variable buf : line;
  begin  -- gen_cfghfile
    -- comment
    write(buf, string'("/* ZUnit configuration partitions "));     
    write(buf, string'("(automatically generated) */"));
    writeline(hfile, buf);
    write(buf, string'(""));
    writeline(hfile, buf);
    -- PARTWIDTH define
    write(buf, string'("#define PARTWIDTH "));     
    write(buf, PARTWIDTH);
    write(buf, string'(" /* partition width (bits) */"));
    writeline(hfile, buf);
    write(buf, string'(""));
    writeline(hfile, buf);
    -- NCFGPARTS define
    write(buf, string'("#define NCFGPARTS "));     
    write(buf, CfgArr'length);
    write(buf, string'(" /* no. of partitions */"));
    writeline(hfile, buf);
    write(buf, string'(""));
    writeline(hfile, buf);
    -- config. array
    write(buf, string'("unsigned int config[NCFGPARTS] = {"));
    writeline(hfile, buf);
    for i in CfgArr'low to CfgArr'high loop
      write(buf, string'(" 0X"));
      hwrite(buf, std_logic_vector(CfgArr(i)));
      if i < CfgArr'high then
        write(buf, string'(","));
      else
        write(buf, string'(" "));     
      end if;
      write(buf, string'(" /* "));     
      write(buf, CfgArr(i));
      write(buf, string'("b, "));     
      write(buf, to_integer(unsigned(CfgArr(i))), right, 11);
      write(buf, string'("d */"));
      writeline(hfile, buf);
    end loop;  -- i
    write(buf, string'(" };"));
    writeline(hfile, buf);
  end gen_cfghfile;

  procedure gen_contexthfile2 (file hfile : text; cpArr : in contextPartArray)
  is
    variable buf : line;
    variable cp  : cfgPartArray;
  begin  -- gen_contexthfile2
    -- comment
    write(buf, string'("/* ZUnit multi-context configuration partitions "));     
    write(buf, string'("(automatically generated) */"));
    writeline(hfile, buf);
    write(buf, string'(""));
    writeline(hfile, buf);
    -- NCONTEXTS define
    write(buf, string'("#define NCONTEXTS "));     
    write(buf, N_CONTEXTS);
    write(buf, string'(" /* no. of contexts */"));
    writeline(hfile, buf);
    write(buf, string'(""));
    writeline(hfile, buf);
    -- PARTWIDTH define
    write(buf, string'("#define PARTWIDTH "));     
    write(buf, PARTWIDTH);
    write(buf, string'(" /* partition width (bits) */"));
    writeline(hfile, buf);
    write(buf, string'(""));
    writeline(hfile, buf);
    -- NCFGPARTS define
    write(buf, string'("#define NCFGPARTS "));     
    write(buf, cp'length);
    write(buf, string'(" /* no. of partitions */"));
    writeline(hfile, buf);
    write(buf, string'(""));
    writeline(hfile, buf);
    -- contexts
    write(buf, string'("unsigned int contextdata"));
    write(buf, string'("[NCONTEXTS][NCFGPARTS] = {"));
    writeline(hfile, buf);
    for c in 0 to N_CONTEXTS-1 loop
      cp := cpArr(c);
      write(buf, string'(" /* context "));     
      write(buf, c);
      write(buf, string'(" */"));
      writeline(hfile, buf);
      write(buf, string'(" {"));
      writeline(hfile, buf);
      for i in cp'low to cp'high loop
        write(buf, string'(" 0X"));
        hwrite(buf, std_logic_vector(cp(i)));
        if i < cp'high then
          write(buf, string'(","));
        else
          write(buf, string'(" "));     
        end if;
        write(buf, string'(" /* "));     
        write(buf, cp(i));
        write(buf, string'("b, "));     
        write(buf, to_integer(unsigned(cp(i))), right, 11);
        write(buf, string'("d */"));
        writeline(hfile, buf);
      end loop;  -- i
      write(buf, string'(" }"));
      if c < N_CONTEXTS-1 then
        write(buf, string'(","));
      end if;
      writeline(hfile, buf);
    end loop;  -- c
    write(buf, string'("};"));
    writeline(hfile, buf);
  end gen_contexthfile2;

end ConfigPkg;
