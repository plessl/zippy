------------------------------------------------------------------------------
-- Configuration for ADPCM application
--
-- Id      : $Id: $
-- File    : $Url: $
-- Author  : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- Created : 2004/10/27
-- Changed : $LastChangedDate: 2004-10-26 14:50:34 +0200 (Tue, 26 Oct 2004) $
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;

-------------------------------------------------------------------------------
-- Array Size requiremetns
--   N_ROWS = 7
--   N_COLS = 7
--   N_HBUSN >= 2
--   N_HBUSS >= 2
--   N_VBUSE >= 1
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------------
package CfgLib_TSTADPCM is

  function tstadpcmcfg return engineConfigRec;

end CfgLib_TSTADPCM;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_TSTADPCM is

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
  -- tstadpcm configuration
  ----------------------------------------------------------------------------
  function tstadpcmcfg return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin

-- c_0_0 op0
cfg.gridConf(0)(0).procConf.AluOpxS := ALU_OP_ROM;
-- i.0
cfg.gridConf(0)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(0).routConf.i(0).HBusNxE(1) := '1';
-- o.0
cfg.gridConf(0)(0).procConf.OutMuxS := O_NOREG;
cfg.gridConf(0)(0).routConf.o.HBusSxE(1) := '1';


-- c_0_1 op2
cfg.gridConf(0)(1).procConf.AluOpxS := ALU_OP_GT;
-- i.0
cfg.gridConf(0)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(1).routConf.i(0).LocalxE(LOCAL_E) := '1';
-- i.1
cfg.gridConf(0)(1).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(0)(1).procConf.ConstOpxD := i2cfgconst(88);
-- o.0
cfg.gridConf(0)(1).procConf.OutMuxS := O_NOREG;
cfg.gridConf(0)(1).routConf.o.HBusNxE(0) := '1';


-- c_0_2 op1
cfg.gridConf(0)(2).procConf.AluOpxS := ALU_OP_ADD;
-- i.0
cfg.gridConf(0)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(2).routConf.i(0).HBusSxE(1) := '1';
-- i.1
cfg.gridConf(0)(2).procConf.OpMuxS(1) := I_REG_CTX_THIS;
cfg.gridConf(0)(2).routConf.i(1).LocalxE(LOCAL_SE) := '1';
-- o.0
cfg.gridConf(0)(2).procConf.OutMuxS := O_NOREG;
cfg.gridConf(0)(2).routConf.o.HBusSxE(0) := '1';


-- c_0_3 op3
cfg.gridConf(0)(3).procConf.AluOpxS := ALU_OP_LT;
-- i.0
cfg.gridConf(0)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(3).routConf.i(0).LocalxE(LOCAL_W) := '1';
-- i.1
cfg.gridConf(0)(3).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(0)(3).procConf.ConstOpxD := i2cfgconst(0);
-- o.0
cfg.gridConf(0)(3).procConf.OutMuxS := O_NOREG;


-- c_0_4 op4b
cfg.gridConf(0)(4).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(0)(4).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(4).routConf.i(0).HBusSxE(0) := '1';
-- i.1
cfg.gridConf(0)(4).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(0)(4).procConf.ConstOpxD := i2cfgconst(0);
-- i.2
cfg.gridConf(0)(4).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(0)(4).routConf.i(2).LocalxE(LOCAL_W) := '1';
-- o.0
cfg.gridConf(0)(4).procConf.OutMuxS := O_NOREG;


-- c_1_1 op12
cfg.gridConf(1)(1).procConf.AluOpxS := ALU_OP_SRL;
-- i.0
cfg.gridConf(1)(1).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(1)(1).routConf.i(0).LocalxE(LOCAL_E) := '1';
-- i.1
cfg.gridConf(1)(1).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(1)(1).procConf.ConstOpxD := i2cfgconst(3);
-- o.0
cfg.gridConf(1)(1).procConf.OutMuxS := O_NOREG;


-- c_1_2 op19
cfg.gridConf(1)(2).procConf.AluOpxS := ALU_OP_ROM;
-- i.0
cfg.gridConf(1)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(2).routConf.i(0).LocalxE(LOCAL_E) := '1';
-- o.0
cfg.gridConf(1)(2).procConf.OutMuxS := O_NOREG;


-- c_1_3 op4c
cfg.gridConf(1)(3).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(1)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(3).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- i.1
cfg.gridConf(1)(3).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(1)(3).routConf.i(1).LocalxE(LOCAL_E) := '1';
-- i.2
cfg.gridConf(1)(3).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(1)(3).routConf.i(2).HBusNxE(0) := '1';
-- o.0
cfg.gridConf(1)(3).procConf.OutMuxS := O_NOREG;


-- c_1_4 op4a
cfg.gridConf(1)(4).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(1)(4).procConf.OpMuxS(0) := I_CONST;
cfg.gridConf(1)(4).procConf.ConstOpxD := i2cfgconst(88);
-- i.1
cfg.gridConf(1)(4).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(1)(4).procConf.ConstOpxD := i2cfgconst(88);
-- i.2
cfg.gridConf(1)(4).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(1)(4).routConf.i(2).LocalxE(LOCAL_NW) := '1';
-- o.0
cfg.gridConf(1)(4).procConf.OutMuxS := O_NOREG;


-- c_2_0 op14
cfg.gridConf(2)(0).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(2)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(0).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- i.1
cfg.gridConf(2)(0).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(2)(0).routConf.i(1).LocalxE(LOCAL_E) := '1';
-- i.2
cfg.gridConf(2)(0).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(2)(0).routConf.i(2).LocalxE(LOCAL_S) := '1';
-- o.0
cfg.gridConf(2)(0).procConf.OutMuxS := O_NOREG;
cfg.gridConf(2)(0).routConf.o.HBusNxE(0) := '1';


-- c_2_1 op13
cfg.gridConf(2)(1).procConf.AluOpxS := ALU_OP_ADD;
-- i.0
cfg.gridConf(2)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(1).routConf.i(0).LocalxE(LOCAL_N) := '1';
-- i.1
cfg.gridConf(2)(1).procConf.OpMuxS(1) := I_REG_CTX_THIS;
cfg.gridConf(2)(1).routConf.i(1).LocalxE(LOCAL_NE) := '1';
-- o.0
cfg.gridConf(2)(1).procConf.OutMuxS := O_NOREG;


-- c_2_2 op11
cfg.gridConf(2)(2).procConf.AluOpxS := ALU_OP_SRL;
-- i.0
cfg.gridConf(2)(2).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(2)(2).routConf.i(0).LocalxE(LOCAL_N) := '1';
-- i.1
cfg.gridConf(2)(2).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(2)(2).procConf.ConstOpxD := i2cfgconst(1);
-- o.0
cfg.gridConf(2)(2).procConf.OutMuxS := O_NOREG;


-- c_2_3 op10
cfg.gridConf(2)(3).procConf.AluOpxS := ALU_OP_SRL;
-- i.0
cfg.gridConf(2)(3).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(2)(3).routConf.i(0).LocalxE(LOCAL_NW) := '1';
-- i.1
cfg.gridConf(2)(3).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(2)(3).procConf.ConstOpxD := i2cfgconst(2);
-- o.0
cfg.gridConf(2)(3).procConf.OutMuxS := O_NOREG;


-- c_3_0 op7
cfg.gridConf(3)(0).procConf.AluOpxS := ALU_OP_TSTBITAT1;
-- i.0
cfg.gridConf(3)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(0).routConf.i(0).LocalxE(LOCAL_S) := '1';
-- i.1
cfg.gridConf(3)(0).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(3)(0).procConf.ConstOpxD := i2cfgconst(4);
-- o.0
cfg.gridConf(3)(0).procConf.OutMuxS := O_NOREG;


-- c_3_1 op15
cfg.gridConf(3)(1).procConf.AluOpxS := ALU_OP_ADD;
-- i.0
cfg.gridConf(3)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(1).routConf.i(0).LocalxE(LOCAL_NW) := '1';
-- i.1
cfg.gridConf(3)(1).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(3)(1).routConf.i(1).LocalxE(LOCAL_NE) := '1';
-- o.0
cfg.gridConf(3)(1).procConf.OutMuxS := O_NOREG;


-- c_3_2 op17
cfg.gridConf(3)(2).procConf.AluOpxS := ALU_OP_ADD;
-- i.0
cfg.gridConf(3)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(2).routConf.i(0).LocalxE(LOCAL_S) := '1';
-- i.1
cfg.gridConf(3)(2).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(3)(2).routConf.i(1).LocalxE(LOCAL_NE) := '1';
-- o.0
cfg.gridConf(3)(2).procConf.OutMuxS := O_NOREG;


-- c_3_3 feedthrough_c_3_3
cfg.gridConf(3)(3).procConf.AluOpxS := ALU_OP_PASS0;
-- i.0
cfg.gridConf(3)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(3).routConf.i(0).HBusNxE(0) := '1';
-- o.0
cfg.gridConf(3)(3).procConf.OutMuxS := O_NOREG;


-- c_3_4 op25a
cfg.gridConf(3)(4).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(3)(4).procConf.OpMuxS(0) := I_CONST;
cfg.gridConf(3)(4).procConf.ConstOpxD := i2cfgconst(-32767);
-- i.1
cfg.gridConf(3)(4).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(3)(4).procConf.ConstOpxD := i2cfgconst(-32767);
-- i.2
cfg.gridConf(3)(4).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(3)(4).routConf.i(2).HBusSxE(0) := '1';
-- o.0
cfg.gridConf(3)(4).procConf.OutMuxS := O_NOREG;


-- c_3_5 op25b
cfg.gridConf(3)(5).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(3)(5).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(5).routConf.i(0).LocalxE(LOCAL_SE) := '1';
-- i.1
cfg.gridConf(3)(5).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(3)(5).procConf.ConstOpxD := i2cfgconst(32768);
-- i.2
cfg.gridConf(3)(5).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(3)(5).routConf.i(2).LocalxE(LOCAL_E) := '1';
-- o.0
cfg.gridConf(3)(5).procConf.OutMuxS := O_NOREG;


-- c_3_6 op23
cfg.gridConf(3)(6).procConf.AluOpxS := ALU_OP_GT;
-- i.0
cfg.gridConf(3)(6).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(6).routConf.i(0).LocalxE(LOCAL_S) := '1';
-- i.1
cfg.gridConf(3)(6).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(3)(6).procConf.ConstOpxD := i2cfgconst(32767);
-- o.0
cfg.gridConf(3)(6).procConf.OutMuxS := O_NOREG;
cfg.gridConf(3)(6).routConf.o.HBusSxE(0) := '1';


-- c_4_0 op6
cfg.gridConf(4)(0).procConf.AluOpxS := ALU_OP_AND;
-- i.0
cfg.gridConf(4)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(4)(0).routConf.i(0).HBusNxE(1) := '1';
-- i.1
cfg.gridConf(4)(0).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(4)(0).procConf.ConstOpxD := i2cfgconst(7);
-- o.0
cfg.gridConf(4)(0).procConf.OutMuxS := O_NOREG;
cfg.gridConf(4)(0).routConf.o.HBusNxE(0) := '1';


-- c_4_1 op8
cfg.gridConf(4)(1).procConf.AluOpxS := ALU_OP_TSTBITAT1;
-- i.0
cfg.gridConf(4)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(4)(1).routConf.i(0).LocalxE(LOCAL_W) := '1';
-- i.1
cfg.gridConf(4)(1).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(4)(1).procConf.ConstOpxD := i2cfgconst(2);
-- o.0
cfg.gridConf(4)(1).procConf.OutMuxS := O_NOREG;


-- c_4_2 op16
cfg.gridConf(4)(2).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(4)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(4)(2).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- i.1
cfg.gridConf(4)(2).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(4)(2).routConf.i(1).LocalxE(LOCAL_NW) := '1';
-- i.2
cfg.gridConf(4)(2).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(4)(2).routConf.i(2).LocalxE(LOCAL_W) := '1';
-- o.0
cfg.gridConf(4)(2).procConf.OutMuxS := O_NOREG;


-- c_4_3 op18
cfg.gridConf(4)(3).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(4)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(4)(3).routConf.i(0).LocalxE(LOCAL_W) := '1';
-- i.1
cfg.gridConf(4)(3).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(4)(3).routConf.i(1).LocalxE(LOCAL_NW) := '1';
-- i.2
cfg.gridConf(4)(3).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(4)(3).routConf.i(2).LocalxE(LOCAL_SW) := '1';
-- o.0
cfg.gridConf(4)(3).procConf.OutMuxS := O_NOREG;
cfg.gridConf(4)(3).routConf.o.HBusSxE(1) := '1';


-- c_4_4 op25c
cfg.gridConf(4)(4).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(4)(4).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(4)(4).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- i.1
cfg.gridConf(4)(4).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(4)(4).routConf.i(1).LocalxE(LOCAL_N) := '1';
-- i.2
cfg.gridConf(4)(4).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(4)(4).routConf.i(2).LocalxE(LOCAL_SE) := '1';
-- o.0
cfg.gridConf(4)(4).procConf.OutMuxS := O_NOREG;


-- c_4_5 op20
cfg.gridConf(4)(5).procConf.AluOpxS := ALU_OP_ADD;
-- i.0
cfg.gridConf(4)(5).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(4)(5).routConf.i(0).HBusSxE(1) := '1';
-- i.1
cfg.gridConf(4)(5).procConf.OpMuxS(1) := I_REG_CTX_THIS;
cfg.gridConf(4)(5).routConf.i(1).LocalxE(LOCAL_W) := '1';
-- o.0
cfg.gridConf(4)(5).procConf.OutMuxS := O_NOREG;


-- c_4_6 op22
cfg.gridConf(4)(6).procConf.AluOpxS := ALU_OP_MUX;
-- i.0
cfg.gridConf(4)(6).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(4)(6).routConf.i(0).LocalxE(LOCAL_W) := '1';
-- i.1
cfg.gridConf(4)(6).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(4)(6).routConf.i(1).VBusExE(0) := '1';
-- i.2
cfg.gridConf(4)(6).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(4)(6).routConf.i(2).LocalxE(LOCAL_S) := '1';
-- o.0
cfg.gridConf(4)(6).procConf.OutMuxS := O_NOREG;


-- c_5_2 op9
cfg.gridConf(5)(2).procConf.AluOpxS := ALU_OP_TSTBITAT1;
-- i.0
cfg.gridConf(5)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(5)(2).routConf.i(0).HBusNxE(0) := '1';
-- i.1
cfg.gridConf(5)(2).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(5)(2).procConf.ConstOpxD := i2cfgconst(1);
-- o.0
cfg.gridConf(5)(2).procConf.OutMuxS := O_NOREG;


-- c_5_3 obuf
cfg.gridConf(5)(3).procConf.AluOpxS := ALU_OP_PASS0;
-- i.0
cfg.gridConf(5)(3).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(5)(3).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- o.0
cfg.gridConf(5)(3).procConf.OutMuxS := O_NOREG;
cfg.gridConf(5)(3).routConf.o.HBusNxE(1) := '1';


-- c_5_4 op21
cfg.gridConf(5)(4).procConf.AluOpxS := ALU_OP_SUB;
-- i.0
cfg.gridConf(5)(4).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(5)(4).routConf.i(0).LocalxE(LOCAL_N) := '1';
-- i.1
cfg.gridConf(5)(4).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(5)(4).routConf.i(1).LocalxE(LOCAL_NW) := '1';
-- o.0
cfg.gridConf(5)(4).procConf.OutMuxS := O_NOREG;


-- c_5_5 op24
cfg.gridConf(5)(5).procConf.AluOpxS := ALU_OP_LT;
-- i.0
cfg.gridConf(5)(5).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(5)(5).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- i.1
cfg.gridConf(5)(5).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(5)(5).procConf.ConstOpxD := i2cfgconst(-32768);
-- o.0
cfg.gridConf(5)(5).procConf.OutMuxS := O_NOREG;


-- c_5_6 op5
cfg.gridConf(5)(6).procConf.AluOpxS := ALU_OP_TSTBITAT1;
-- i.0
cfg.gridConf(5)(6).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(5)(6).routConf.i(0).HBusNxE(1) := '1';
-- i.1
cfg.gridConf(5)(6).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(5)(6).procConf.ConstOpxD := i2cfgconst(8);
-- o.0
cfg.gridConf(5)(6).procConf.OutMuxS := O_NOREG;


-- c_6_5 feedthrough_c_6_5
cfg.gridConf(6)(5).procConf.AluOpxS := ALU_OP_PASS0;
-- i.0
cfg.gridConf(6)(5).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(6)(5).routConf.i(0).LocalxE(LOCAL_NW) := '1';
-- o.0
cfg.gridConf(6)(5).procConf.OutMuxS := O_NOREG;
cfg.gridConf(6)(5).routConf.o.VBusExE(0) := '1';


-- input drivers
cfg.inputDriverConf(0)(0)(1) := '1';
cfg.inputDriverConf(0)(4)(1) := '1';
cfg.inputDriverConf(0)(5)(1) := '1';

-- output drivers
cfg.outputDriverConf(1)(6)(1) := '1';

    for i in INDEXTABLE'range loop
      cfg.memoryConf(0)(i) :=
        std_logic_vector(to_signed(INDEXTABLE(i), DATAWIDTH));
    end loop;  -- i

    for i in STEPSIZETABLE'range loop
      cfg.memoryConf(1)(i) :=
        std_logic_vector(to_signed(STEPSIZETABLE(i), DATAWIDTH));
    end loop;  -- i


    ---------------------------------------------------------------------------
    -- FIXME Naming of inport and outport is consistent but a little
    -- confusing. Inport is the inport of the array, i.e. die outport
    -- of the FIFO.
    ---------------------------------------------------------------------------

    -- i/o port controller
    cfg.inportConf(0).LUT4FunctxD  := CFG_IOPORT_ON;
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_ON;

--    -- activate write to output FIFO0 after 2 cycles
--    cfg.outportConf(0).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEUP;
--    cfg.outportConf(0).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
--    cfg.outportConf(0).Cmp0ConstxD := std_logic_vector(to_unsigned(1, CCNTWIDTH));
--    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_CMP0;
--
--    -- deactivate read from input FIFO0 2 cycles before end
--    cfg.inportConf(0).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEDOWN;
--    cfg.inportConf(0).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
--    cfg.inportConf(0).Cmp0ConstxD := std_logic_vector(to_unsigned(2, CCNTWIDTH));
--    cfg.inportConf(0).LUT4FunctxD := CFG_IOPORT_CMP0;
--
--    cfg.inportConf(1).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEDOWN;
--    cfg.inportConf(1).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
--    cfg.inportConf(1).Cmp0ConstxD := std_logic_vector(to_unsigned(2, CCNTWIDTH));
--    cfg.inportConf(1).LUT4FunctxD := CFG_IOPORT_CMP0;
--
--    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_OFF;

    return cfg;
  end tstadpcmcfg;


end CfgLib_TSTADPCM;
