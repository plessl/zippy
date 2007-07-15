------------------------------------------------------------------------------
-- Configuration for ADPCM application with virtualized execution on a
-- 4x4 zippy array
--
-- File    : $URL: $
-- Author  : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- Created : 2004/10/27
-- $Id: $
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;

------------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------------
package CfgLib_TSTADPCM_VIRT is

  function tstadpcmcfg_p0 return engineConfigRec;
  function tstadpcmcfg_p1 return engineConfigRec;
  function tstadpcmcfg_p2 return engineConfigRec;

end CfgLib_TSTADPCM_VIRT;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_TSTADPCM_VIRT is

  ---------------------------------------------------------------------------
  -- ROM DATA
  ---------------------------------------------------------------------------

  type indextable_arr is array (0 to 15) of integer;
  constant INDEXTABLE : indextable_arr := (
    -1, -1, -1, -1, 2, 4, 6, 8,
    -1, -1, -1, -1, 2, 4, 6, 8
    );

  type stepsizetable_arr is array (0 to 88) of integer;
  constant STEPSIZETABLE : stepsizetable_arr := (
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
    19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
    130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
    337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
    876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
    2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
    5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
    15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
    );

  ----------------------------------------------------------------------------
  -- tstadpcm partition p0 configuration
  ----------------------------------------------------------------------------
  function tstadpcmcfg_p0 return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin

    -- ############# begin configuration of partition 0 ###################
    -- c_0_1 op4a
    cfg.gridConf(0)(1).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(0)(1).procConf.OpMuxS(0)              := I_CONST;
    cfg.gridConf(0)(1).procConf.ConstOpxD              := i2cfgconst(88);
    -- i.1
    cfg.gridConf(0)(1).procConf.OpMuxS(1)              := I_CONST;
    cfg.gridConf(0)(1).procConf.ConstOpxD              := i2cfgconst(88);
    -- i.2
    cfg.gridConf(0)(1).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(0)(1).routConf.i(2).LocalxE(LOCAL_NE) := '1';
    -- o.0
    cfg.gridConf(0)(1).procConf.OutMuxS                := O_NOREG;


    -- c_1_0 op4b
    cfg.gridConf(1)(0).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(1)(0).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(0).routConf.i(0).LocalxE(LOCAL_S)  := '1';
    -- i.1
    cfg.gridConf(1)(0).procConf.OpMuxS(1)              := I_CONST;
    cfg.gridConf(1)(0).procConf.ConstOpxD              := i2cfgconst(0);
    -- i.2
    cfg.gridConf(1)(0).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(1)(0).routConf.i(2).LocalxE(LOCAL_SW) := '1';
    -- o.0
    cfg.gridConf(1)(0).procConf.OutMuxS                := O_NOREG;


    -- c_1_1 op4c
    cfg.gridConf(1)(1).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(1)(1).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(1).routConf.i(0).LocalxE(LOCAL_W)  := '1';
    -- i.1
    cfg.gridConf(1)(1).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(1).routConf.i(1).LocalxE(LOCAL_N)  := '1';
    -- i.2
    cfg.gridConf(1)(1).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(1)(1).routConf.i(2).LocalxE(LOCAL_SE) := '1';
    -- o.0
    cfg.gridConf(1)(1).procConf.OutMuxS                := O_NOREG;


    -- c_2_0 op1
    cfg.gridConf(2)(0).procConf.AluOpxS                := ALU_OP_ADD;
    -- i.0
    cfg.gridConf(2)(0).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(2)(0).routConf.i(0).LocalxE(LOCAL_S)  := '1';
    -- i.1
    cfg.gridConf(2)(0).procConf.OpMuxS(1)              := I_REG_CTX_THIS;
    cfg.gridConf(2)(0).routConf.i(1).LocalxE(LOCAL_NE) := '1';
    -- o.0
    cfg.gridConf(2)(0).procConf.OutMuxS                := O_NOREG;
    cfg.gridConf(2)(0).routConf.o.HBusSxE(1)           := '1';


    -- c_2_1 op19
    cfg.gridConf(2)(1).procConf.AluOpxS               := ALU_OP_ROM;
    -- i.0
    cfg.gridConf(2)(1).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(1).routConf.i(0).LocalxE(LOCAL_N) := '1';
    -- o.0
    cfg.gridConf(2)(1).procConf.OutMuxS               := O_NOREG;


    -- c_2_2 op2
    cfg.gridConf(2)(2).procConf.AluOpxS         := ALU_OP_GT;
    -- i.0
    cfg.gridConf(2)(2).procConf.OpMuxS(0)       := I_NOREG;
    cfg.gridConf(2)(2).routConf.i(0).HBusSxE(1) := '1';
    -- i.1
    cfg.gridConf(2)(2).procConf.OpMuxS(1)       := I_CONST;
    cfg.gridConf(2)(2).procConf.ConstOpxD       := i2cfgconst(88);
    -- o.0
    cfg.gridConf(2)(2).procConf.OutMuxS         := O_NOREG;


    -- c_2_3 op3
    cfg.gridConf(2)(3).procConf.AluOpxS               := ALU_OP_LT;
    -- i.0
    cfg.gridConf(2)(3).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(3).routConf.i(0).LocalxE(LOCAL_E) := '1';
    -- i.1
    cfg.gridConf(2)(3).procConf.OpMuxS(1)             := I_CONST;
    cfg.gridConf(2)(3).procConf.ConstOpxD             := i2cfgconst(0);
    -- o.0
    cfg.gridConf(2)(3).procConf.OutMuxS               := O_NOREG;


    -- c_3_0 op0
    cfg.gridConf(3)(0).procConf.AluOpxS         := ALU_OP_ROM;
    -- i.0
    cfg.gridConf(3)(0).procConf.OpMuxS(0)       := I_NOREG;
    cfg.gridConf(3)(0).routConf.i(0).HBusNxE(1) := '1';
    -- o.0
    cfg.gridConf(3)(0).procConf.OutMuxS         := O_NOREG;


    -- c_3_1 opt120
    cfg.gridConf(3)(1).procConf.AluOpxS               := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(3)(1).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(3)(1).routConf.i(0).LocalxE(LOCAL_N) := '1';


    -- c_3_2 feedthrough_c_3_2
    cfg.gridConf(3)(2).procConf.AluOpxS                := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(3)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(3)(2).routConf.i(0).LocalxE(LOCAL_NE) := '1';
    -- o.0
    cfg.gridConf(3)(2).procConf.OutMuxS                := O_NOREG;


    -- input drivers
    cfg.inputDriverConf(0)(3)(1) := '1';

    -- output drivers

    -- ############# end   configuration of partition 0 ###################

    -- initialize ROM

    -- ROM index table (op0) is mapped to cell c_3_0
    for i in INDEXTABLE'range loop
      cfg.memoryConf(3)(i) :=
        std_logic_vector(to_signed(INDEXTABLE(i), DATAWIDTH));
    end loop;  -- i


    -- ROM stepsize table (op19) is mapped to cell c_2_1
    for i in STEPSIZETABLE'range loop
      cfg.memoryConf(2)(i) :=
        std_logic_vector(to_signed(STEPSIZETABLE(i), DATAWIDTH));
    end loop;  -- i


    -- IO port configuration
    cfg.inportConf(0).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_OFF;
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_OFF;


    return cfg;
  end tstadpcmcfg_p0;

  ----------------------------------------------------------------------------
  -- tstadpcm partition p1 configuration
  ----------------------------------------------------------------------------
  function tstadpcmcfg_p1 return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin

    -- ############# begin configuration of partition 1 ###################
    -- c_0_0 opt232
    cfg.gridConf(0)(0).procConf.AluOpxS                := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(0)(0).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(0)(0).routConf.i(0).LocalxE(LOCAL_SW) := '1';


    -- c_0_1 op13
    cfg.gridConf(0)(1).procConf.AluOpxS               := ALU_OP_ADD;
    -- i.0
    cfg.gridConf(0)(1).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(0)(1).routConf.i(0).HBusNxE(0)       := '1';
    -- i.1
    cfg.gridConf(0)(1).procConf.OpMuxS(1)             := I_REG_CTX_THIS;
    cfg.gridConf(0)(1).routConf.i(1).LocalxE(LOCAL_N) := '1';
    -- o.0
    cfg.gridConf(0)(1).procConf.OutMuxS               := O_NOREG;


    -- c_0_2 op14
    cfg.gridConf(0)(2).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(0)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(0)(2).routConf.i(0).LocalxE(LOCAL_NE) := '1';
    -- i.1
    cfg.gridConf(0)(2).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(0)(2).routConf.i(1).LocalxE(LOCAL_W)  := '1';
    -- i.2
    cfg.gridConf(0)(2).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(0)(2).routConf.i(2).LocalxE(LOCAL_N)  := '1';
    -- o.0
    cfg.gridConf(0)(2).procConf.OutMuxS                := O_NOREG;
    cfg.gridConf(0)(2).routConf.o.VBusExE(1)           := '1';


    -- c_0_3 op6
    cfg.gridConf(0)(3).procConf.AluOpxS         := ALU_OP_AND;
    -- i.0
    cfg.gridConf(0)(3).procConf.OpMuxS(0)       := I_NOREG;
    cfg.gridConf(0)(3).routConf.i(0).HBusNxE(1) := '1';
    -- i.1
    cfg.gridConf(0)(3).procConf.OpMuxS(1)       := I_CONST;
    cfg.gridConf(0)(3).procConf.ConstOpxD       := i2cfgconst(7);
    -- o.0
    cfg.gridConf(0)(3).procConf.OutMuxS         := O_NOREG;
    cfg.gridConf(0)(3).routConf.o.HBusNxE(0)    := '1';


    -- c_1_0 opt230
    cfg.gridConf(1)(0).procConf.AluOpxS                := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(1)(0).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(0).routConf.i(0).LocalxE(LOCAL_SE) := '1';


    -- c_1_1 op8
    cfg.gridConf(1)(1).procConf.AluOpxS         := ALU_OP_TSTBITAT1;
    -- i.0
    cfg.gridConf(1)(1).procConf.OpMuxS(0)       := I_NOREG;
    cfg.gridConf(1)(1).routConf.i(0).HBusNxE(0) := '1';
    -- i.1
    cfg.gridConf(1)(1).procConf.OpMuxS(1)       := I_CONST;
    cfg.gridConf(1)(1).procConf.ConstOpxD       := i2cfgconst(2);
    -- o.0
    cfg.gridConf(1)(1).procConf.OutMuxS         := O_NOREG;
    cfg.gridConf(1)(1).routConf.o.HBusNxE(0)    := '1';


    -- c_1_2 op15
    cfg.gridConf(1)(2).procConf.AluOpxS               := ALU_OP_ADD;
    -- i.0
    cfg.gridConf(1)(2).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(1)(2).routConf.i(0).LocalxE(LOCAL_N) := '1';
    -- i.1
    cfg.gridConf(1)(2).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(1)(2).routConf.i(1).LocalxE(LOCAL_S) := '1';
    -- o.0
    cfg.gridConf(1)(2).procConf.OutMuxS               := O_NOREG;


    -- c_1_3 op9
    cfg.gridConf(1)(3).procConf.AluOpxS               := ALU_OP_TSTBITAT1;
    -- i.0
    cfg.gridConf(1)(3).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(1)(3).routConf.i(0).LocalxE(LOCAL_N) := '1';
    -- i.1
    cfg.gridConf(1)(3).procConf.OpMuxS(1)             := I_CONST;
    cfg.gridConf(1)(3).procConf.ConstOpxD             := i2cfgconst(1);
    -- o.0
    cfg.gridConf(1)(3).procConf.OutMuxS               := O_NOREG;


    -- c_2_0 opt231
    cfg.gridConf(2)(0).procConf.AluOpxS               := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(2)(0).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(0).routConf.i(0).LocalxE(LOCAL_W) := '1';


    -- c_2_1 op17
    cfg.gridConf(2)(1).procConf.AluOpxS                := ALU_OP_ADD;
    -- i.0
    cfg.gridConf(2)(1).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(2)(1).routConf.i(0).HBusSxE(0)        := '1';
    -- i.1
    cfg.gridConf(2)(1).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(2)(1).routConf.i(1).LocalxE(LOCAL_SW) := '1';
    -- o.0
    cfg.gridConf(2)(1).procConf.OutMuxS                := O_NOREG;


    -- c_2_2 op11
    cfg.gridConf(2)(2).procConf.AluOpxS                := ALU_OP_SRL;
    -- i.0
    cfg.gridConf(2)(2).procConf.OpMuxS(0)              := I_REG_CTX_THIS;
    cfg.gridConf(2)(2).routConf.i(0).LocalxE(LOCAL_SW) := '1';
    -- i.1
    cfg.gridConf(2)(2).procConf.OpMuxS(1)              := I_CONST;
    cfg.gridConf(2)(2).procConf.ConstOpxD              := i2cfgconst(1);
    -- o.0
    cfg.gridConf(2)(2).procConf.OutMuxS                := O_NOREG;


    -- c_2_3 op16
    cfg.gridConf(2)(3).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(2)(3).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(2)(3).routConf.i(0).VBusExE(1)        := '1';
    -- i.1
    cfg.gridConf(2)(3).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(2)(3).routConf.i(1).LocalxE(LOCAL_NW) := '1';
    -- i.2
    cfg.gridConf(2)(3).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(2)(3).routConf.i(2).HBusNxE(0)        := '1';
    -- o.0
    cfg.gridConf(2)(3).procConf.OutMuxS                := O_NOREG;
    cfg.gridConf(2)(3).routConf.o.HBusSxE(0)           := '1';


    -- c_3_0 op10
    cfg.gridConf(3)(0).procConf.AluOpxS               := ALU_OP_SRL;
    -- i.0
    cfg.gridConf(3)(0).procConf.OpMuxS(0)             := I_REG_CTX_THIS;
    cfg.gridConf(3)(0).routConf.i(0).LocalxE(LOCAL_E) := '1';
    -- i.1
    cfg.gridConf(3)(0).procConf.OpMuxS(1)             := I_CONST;
    cfg.gridConf(3)(0).procConf.ConstOpxD             := i2cfgconst(2);
    -- o.0
    cfg.gridConf(3)(0).procConf.OutMuxS               := O_NOREG;


    -- c_3_1 opt120
    cfg.gridConf(3)(1).procConf.AluOpxS        := ALU_OP_PASS0;
    -- o.0
    cfg.gridConf(3)(1).procConf.OutMuxS        := O_REG_CTX_OTHER;
    cfg.gridConf(3)(1).procConf.OutCtxRegSelxS := i2ctx(0);
    cfg.gridConf(3)(1).routConf.o.HBusSxE(1)   := '1';


    -- c_3_2 op7
    cfg.gridConf(3)(2).procConf.AluOpxS                := ALU_OP_TSTBITAT1;
    -- i.0
    cfg.gridConf(3)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(3)(2).routConf.i(0).LocalxE(LOCAL_SE) := '1';
    -- i.1
    cfg.gridConf(3)(2).procConf.OpMuxS(1)              := I_CONST;
    cfg.gridConf(3)(2).procConf.ConstOpxD              := i2cfgconst(4);
    -- o.0
    cfg.gridConf(3)(2).procConf.OutMuxS                := O_NOREG;


    -- c_3_3 op12
    cfg.gridConf(3)(3).procConf.AluOpxS         := ALU_OP_SRL;
    -- i.0
    cfg.gridConf(3)(3).procConf.OpMuxS(0)       := I_REG_CTX_THIS;
    cfg.gridConf(3)(3).routConf.i(0).HBusSxE(1) := '1';
    -- i.1
    cfg.gridConf(3)(3).procConf.OpMuxS(1)       := I_CONST;
    cfg.gridConf(3)(3).procConf.ConstOpxD       := i2cfgconst(3);
    -- o.0
    cfg.gridConf(3)(3).procConf.OutMuxS         := O_NOREG;
    cfg.gridConf(3)(3).routConf.o.HBusNxE(0)    := '1';


    -- input drivers
    cfg.inputDriverConf(0)(0)(1) := '1';

    -- output drivers


    -- ############# end   configuration of partition 1 ###################



    -- IO port configuration
    cfg.inportConf(0).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_OFF;
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_OFF;


    return cfg;
  end tstadpcmcfg_p1;

  ----------------------------------------------------------------------------
  -- tstadpcm partition p2 configuration
  ----------------------------------------------------------------------------
  function tstadpcmcfg_p2 return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin

    -- ############# begin configuration of partition 2 ###################

    -- c_0_0 opt232
    cfg.gridConf(0)(0).procConf.AluOpxS        := ALU_OP_PASS0;
    -- o.0
    cfg.gridConf(0)(0).procConf.OutMuxS        := O_REG_CTX_OTHER;
    cfg.gridConf(0)(0).procConf.OutCtxRegSelxS := i2ctx(1);


    -- c_0_1 op22
    cfg.gridConf(0)(1).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(0)(1).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(0)(1).routConf.i(0).LocalxE(LOCAL_NE) := '1';
    -- i.1
    cfg.gridConf(0)(1).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(0)(1).routConf.i(1).HBusNxE(0)        := '1';
    -- i.2
    cfg.gridConf(0)(1).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(0)(1).routConf.i(2).LocalxE(LOCAL_NW) := '1';
    -- o.0
    cfg.gridConf(0)(1).procConf.OutMuxS                := O_NOREG;
    cfg.gridConf(0)(1).routConf.o.HBusNxE(0)           := '1';


    -- c_0_2 op25b
    cfg.gridConf(0)(2).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(0)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(0)(2).routConf.i(0).LocalxE(LOCAL_W)  := '1';
    -- i.1
    cfg.gridConf(0)(2).procConf.OpMuxS(1)              := I_CONST;
    cfg.gridConf(0)(2).procConf.ConstOpxD              := i2cfgconst(32768);
    -- i.2
    cfg.gridConf(0)(2).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(0)(2).routConf.i(2).LocalxE(LOCAL_SE) := '1';
    -- o.0
    cfg.gridConf(0)(2).procConf.OutMuxS                := O_NOREG;


    -- c_0_3 obuf
    cfg.gridConf(0)(3).procConf.AluOpxS                := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(0)(3).procConf.OpMuxS(0)              := I_REG_CTX_THIS;
    cfg.gridConf(0)(3).routConf.i(0).LocalxE(LOCAL_SW) := '1';
    -- o.0
    cfg.gridConf(0)(3).procConf.OutMuxS                := O_NOREG;
    cfg.gridConf(0)(3).routConf.o.HBusNxE(1)           := '1';


    -- c_1_0 opt230
    cfg.gridConf(1)(0).procConf.AluOpxS        := ALU_OP_PASS0;
    -- o.0
    cfg.gridConf(1)(0).procConf.OutMuxS        := O_REG_CTX_OTHER;
    cfg.gridConf(1)(0).procConf.OutCtxRegSelxS := i2ctx(1);
    cfg.gridConf(1)(0).routConf.o.VBusExE(1)   := '1';


    -- c_1_1 op24
    cfg.gridConf(1)(1).procConf.AluOpxS               := ALU_OP_LT;
    -- i.0
    cfg.gridConf(1)(1).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(1)(1).routConf.i(0).LocalxE(LOCAL_N) := '1';
    -- i.1
    cfg.gridConf(1)(1).procConf.OpMuxS(1)             := I_CONST;
    cfg.gridConf(1)(1).procConf.ConstOpxD             := i2cfgconst(-32768);
    -- o.0
    cfg.gridConf(1)(1).procConf.OutMuxS               := O_NOREG;


    -- c_1_2 op25c
    cfg.gridConf(1)(2).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(1)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(2).routConf.i(0).LocalxE(LOCAL_N)  := '1';
    -- i.1
    cfg.gridConf(1)(2).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(2).routConf.i(1).LocalxE(LOCAL_SE) := '1';
    -- i.2
    cfg.gridConf(1)(2).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(1)(2).routConf.i(2).LocalxE(LOCAL_W)  := '1';
    -- o.0
    cfg.gridConf(1)(2).procConf.OutMuxS                := O_NOREG;


    -- c_1_3 op23
    cfg.gridConf(1)(3).procConf.AluOpxS         := ALU_OP_GT;
    -- i.0
    cfg.gridConf(1)(3).procConf.OpMuxS(0)       := I_NOREG;
    cfg.gridConf(1)(3).routConf.i(0).HBusNxE(0) := '1';
    -- i.1
    cfg.gridConf(1)(3).procConf.OpMuxS(1)       := I_CONST;
    cfg.gridConf(1)(3).procConf.ConstOpxD       := i2cfgconst(32767);
    -- o.0
    cfg.gridConf(1)(3).procConf.OutMuxS         := O_NOREG;


    -- c_2_0 opt231
    cfg.gridConf(2)(0).procConf.AluOpxS        := ALU_OP_PASS0;
    -- o.0
    cfg.gridConf(2)(0).procConf.OutMuxS        := O_REG_CTX_OTHER;
    cfg.gridConf(2)(0).procConf.OutCtxRegSelxS := i2ctx(1);


    -- c_2_1 op20
    cfg.gridConf(2)(1).procConf.AluOpxS                := ALU_OP_ADD;
    -- i.0
    cfg.gridConf(2)(1).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(2)(1).routConf.i(0).LocalxE(LOCAL_S)  := '1';
    -- i.1
    cfg.gridConf(2)(1).procConf.OpMuxS(1)              := I_REG_CTX_THIS;
    cfg.gridConf(2)(1).routConf.i(1).LocalxE(LOCAL_NE) := '1';
    -- o.0
    cfg.gridConf(2)(1).procConf.OutMuxS                := O_NOREG;


    -- c_2_2 op21
    cfg.gridConf(2)(2).procConf.AluOpxS                := ALU_OP_SUB;
    -- i.0
    cfg.gridConf(2)(2).procConf.OpMuxS(0)              := I_REG_CTX_THIS;
    cfg.gridConf(2)(2).routConf.i(0).LocalxE(LOCAL_N)  := '1';
    -- i.1
    cfg.gridConf(2)(2).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(2)(2).routConf.i(1).LocalxE(LOCAL_SW) := '1';
    -- o.0
    cfg.gridConf(2)(2).procConf.OutMuxS                := O_NOREG;


    -- c_2_3 op25a
    cfg.gridConf(2)(3).procConf.AluOpxS               := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(2)(3).procConf.OpMuxS(0)             := I_CONST;
    cfg.gridConf(2)(3).procConf.ConstOpxD             := i2cfgconst(-32767);
    -- i.1
    cfg.gridConf(2)(3).procConf.OpMuxS(1)             := I_CONST;
    cfg.gridConf(2)(3).procConf.ConstOpxD             := i2cfgconst(-32767);
    -- i.2
    cfg.gridConf(2)(3).procConf.OpMuxS(2)             := I_NOREG;
    cfg.gridConf(2)(3).routConf.i(2).LocalxE(LOCAL_N) := '1';
    -- o.0
    cfg.gridConf(2)(3).procConf.OutMuxS               := O_NOREG;


    -- c_3_0 op5
    cfg.gridConf(3)(0).procConf.AluOpxS         := ALU_OP_TSTBITAT1;
    -- i.0
    cfg.gridConf(3)(0).procConf.OpMuxS(0)       := I_NOREG;
    cfg.gridConf(3)(0).routConf.i(0).HBusNxE(1) := '1';
    -- i.1
    cfg.gridConf(3)(0).procConf.OpMuxS(1)       := I_CONST;
    cfg.gridConf(3)(0).procConf.ConstOpxD       := i2cfgconst(8);
    -- o.0
    cfg.gridConf(3)(0).procConf.OutMuxS         := O_NOREG;


    -- c_3_1 op18
    cfg.gridConf(3)(1).procConf.AluOpxS                := ALU_OP_MUX;
    -- i.0
    cfg.gridConf(3)(1).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(3)(1).routConf.i(0).LocalxE(LOCAL_NW) := '1';
    -- i.1
    cfg.gridConf(3)(1).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(3)(1).routConf.i(1).VBusExE(1)        := '1';
    -- i.2
    cfg.gridConf(3)(1).procConf.OpMuxS(2)              := I_NOREG;
    cfg.gridConf(3)(1).routConf.i(2).LocalxE(LOCAL_SW) := '1';
    -- o.0
    cfg.gridConf(3)(1).procConf.OutMuxS                := O_NOREG;


    -- c_3_2 feedthrough_c_3_2
    cfg.gridConf(3)(2).procConf.AluOpxS                := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(3)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(3)(2).routConf.i(0).LocalxE(LOCAL_NW) := '1';
    -- o.0
    cfg.gridConf(3)(2).procConf.OutMuxS                := O_NOREG;


    -- c_3_3 feedthrough_c_3_3
    cfg.gridConf(3)(3).procConf.AluOpxS                := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(3)(3).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(3)(3).routConf.i(0).LocalxE(LOCAL_NW) := '1';
    -- o.0
    cfg.gridConf(3)(3).procConf.OutMuxS                := O_NOREG;
    cfg.gridConf(3)(3).routConf.o.HBusNxE(0)           := '1';


    -- input drivers
    cfg.inputDriverConf(0)(3)(1) := '1';

    -- output drivers
    cfg.outputDriverConf(1)(1)(1) := '1';

    -- ############# end   configuration of partition 2 ###################

    -- IO port configuration
    cfg.inportConf(0).LUT4FunctxD  := CFG_IOPORT_ON;
    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_OFF;
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_ON;

    return cfg;
  end tstadpcmcfg_p2;


end CfgLib_TSTADPCM_VIRT;
