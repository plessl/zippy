------------------------------------------------------------------------------
-- Library of ZUnit FIR filter configurations
--
-- Project     : 
-- File        : cfglib_fir.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/10/21
-- Last changed: $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- library of FIR filter configurations for the 4x4 zippy array, as used in 
-- a couple of case studies (ERSA,FPL,Micpro,Rolfs PhD thesis)
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-08 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;

------------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------------
package CfgLib_FIR is

  type coeffArray is array (natural range <>) of integer;

  function fir8mult (coeff   : coeffArray) return engineConfigRec;
  function fir8mult_b (coeff : coeffArray) return engineConfigRec;

end CfgLib_FIR;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_FIR is




  -----------------------------------------------------------------------------
  -- FIXME
  -----------------------------------------------------------------------------
  --
  -- This configuration library needs to be validated with a testbench again,
  -- since quite a lot of things have changed in the zippy architecture.
  --
  -- The 4tap FIR filters have been removed and moved to their own testbench
  -- tstfir4. The fir8shif configuration has also been removed.
  --
  -- The coordinate system of the engine has been changed from Rolfs scheme
  --
  -- |A3|A2|A1|A0|
  -- |B3|B2|B1|B0|
  -- |C3|C2|C1|C0|
  -- |D3|D2|D1|D0|
  --
  -- to a more commonly used scheme
  --
  -- |00|01|02|03|
  -- |10|11|12|13|
  -- |20|21|22|23|
  -- |30|31|32|33|
  --
  --
  -- This implies, that the configurations need to be mirrored on a vertical
  -- axis, which was done, but has not been verified so far.


  ----------------------------------------------------------------------------
  -- 8-tap FIR filter
  ----------------------------------------------------------------------------
  -- Changed:
  --   old order of coefficients: (k7,k6,k5,k4,k3,k2,k1,k0)
  --   new order of coefficients: (k0,k1,k2,k3,k4,k5,k6,k7)
  --
  function fir8mult (coeff : coeffArray) return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin  -- fir8mult

    -- row 0 multiplies:
    for i in 0 to 3 loop
      cfg.gridConf(0)(i).procConf.OpMuxS(0) := I_NOREG;
      cfg.gridConf(0)(i).procConf.OpMuxS(1) := I_CONST;
      cfg.gridConf(0)(i).procConf.OutMuxS   := O_NOREG;
      cfg.gridConf(0)(i).procConf.AluOpxS   := ALU_OP_MULTLO;
      -- last 4 coefficients of impulse response
      cfg.gridConf(0)(i).procConf.ConstOpxD :=
        std_logic_vector(to_signed(coeff(7-i), DATAWIDTH));
      cfg.gridConf(0)(i).routConf.i(0).HBusNxE(0) := '1';  -- hbusn_0.0 (inport 0)
    end loop;

    ---------------------------------------------------------------------------
    -- row 1 adds:
    ---------------------------------------------------------------------------
    -- c_1_1
    cfg.gridConf(1)(1).procConf.OpMuxS(0)              := I_REG;
    cfg.gridConf(1)(1).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(1).procConf.OutMuxS                := O_REG;
    cfg.gridConf(1)(1).procConf.AluOpxS                := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(1).routConf.i(0).LocalxE(LOCAL_NW) := '1';  -- NW neighb.
    cfg.gridConf(1)(1).routConf.i(1).LocalxE(LOCAL_N)  := '1';  -- N  neighb.
    -- c_1_2
    cfg.gridConf(1)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(2).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(2).procConf.OutMuxS                := O_REG;
    cfg.gridConf(1)(2).procConf.AluOpxS                := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(2).routConf.i(0).LocalxE(LOCAL_W)  := '1';  -- W neighb.
    cfg.gridConf(1)(2).routConf.i(1).LocalxE(LOCAL_N)  := '1';  -- N neighb.
    -- c_1_3
    cfg.gridConf(1)(3).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(3).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(3).procConf.OutMuxS                := O_REG;
    cfg.gridConf(1)(3).procConf.AluOpxS                := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(3).routConf.i(0).LocalxE(LOCAL_W)  := '1';  -- W neighb.
    cfg.gridConf(1)(3).routConf.i(1).LocalxE(LOCAL_N)  := '1';  -- N neighb.
    cfg.gridConf(1)(3).routConf.o.HBusNxE(0)           := '1';  -- hbusn_2.0

    -------------------------------------------------------------------------------
    -- row 2 adds:
    -------------------------------------------------------------------------------

    -- c_2_0
    cfg.gridConf(2)(0).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(0).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(0).procConf.OutMuxS               := O_REG;
    cfg.gridConf(2)(0).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(0).routConf.i(0).HBusNxE(0)       := '1';  -- hbusn_2.0
    cfg.gridConf(2)(0).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.
    -- c_2_1
    cfg.gridConf(2)(1).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(1).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(1).procConf.OutMuxS               := O_REG;
    cfg.gridConf(2)(1).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(1).routConf.i(0).LocalxE(LOCAL_W) := '1';  -- W neighb.
    cfg.gridConf(2)(1).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.
    -- c_2_2
    cfg.gridConf(2)(2).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(2).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(2).procConf.OutMuxS               := O_REG;
    cfg.gridConf(2)(2).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(2).routConf.i(0).LocalxE(LOCAL_W) := '1';  -- W neighb.
    cfg.gridConf(2)(2).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.
    -- c_2_3
    cfg.gridConf(2)(3).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(3).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(3).procConf.OutMuxS               := O_NOREG;
    cfg.gridConf(2)(3).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(3).routConf.i(0).LocalxE(LOCAL_W) := '1';  -- W neighb.
    cfg.gridConf(2)(3).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.
    cfg.gridConf(2)(3).routConf.o.HBusNxE(1)          := '1';  -- hbusn_3.1 (oport 1)
    -- row 3 multiplies:
    for i in 0 to 3 loop
      cfg.gridConf(3)(i).procConf.OpMuxS(0) := I_NOREG;
      cfg.gridConf(3)(i).procConf.OpMuxS(1) := I_CONST;
      cfg.gridConf(3)(i).procConf.OutMuxS   := O_NOREG;
      cfg.gridConf(3)(i).procConf.AluOpxS   := ALU_OP_MULTLO;
      -- first 4 coefficients of impulse response
      cfg.gridConf(3)(i).procConf.ConstOpxD :=
        std_logic_vector(to_signed(coeff(3-i), DATAWIDTH));
      cfg.gridConf(3)(i).routConf.i(0).HBusNxE(0) := '1';  -- hbusn_0.0 (inport 0)
    end loop;

    ---------------------------------------------------------------------------
    -- engine inputs and outputs
    ---------------------------------------------------------------------------

    -- engine input
    cfg.inputDriverConf(0)(0)(0) := '1';  -- hbusn_0.0
    cfg.inputDriverConf(0)(3)(0) := '1';  -- hbusn_3.0

    -- engine outputs
    cfg.outputDriverConf(1)(3)(1) := '1';  -- output hbusn_3.1 to OUTP1

    -- IP0 controller (activated)
    cfg.inportConf(0).LUT4FunctxD := X"FFFF";

    -- IP1 controller (deactivated)
    cfg.inportConf(1).LUT4FunctxD := X"0000";

    -- OP0 controller (deactivated)
    cfg.outportConf(0).LUT4FunctxD := X"0000";

    -- OP1 controller (activated)
    cfg.outportConf(1).LUT4FunctxD := X"FFFF";

    return cfg;
  end fir8mult;

  ----------------------------------------------------------------------------
  -- 8-tap FIR filter (2nd version)
  ----------------------------------------------------------------------------
  -- input on inport 1; output on outport 0
  function fir8mult_b (coeff : coeffArray) return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin  -- fir8mult_b

    ---------------------------------------------------------------------------
    -- row 0 multiplies:
    ---------------------------------------------------------------------------
    
    for i in 0 to 3 loop
      cfg.gridConf(0)(i).procConf.OpMuxS(0) := I_NOREG;
      cfg.gridConf(0)(i).procConf.OpMuxS(1) := I_CONST;
      cfg.gridConf(0)(i).procConf.OutMuxS   := O_NOREG;
      cfg.gridConf(0)(i).procConf.AluOpxS   := ALU_OP_MULTLO;
      cfg.gridConf(0)(i).procConf.ConstOpxD :=
        std_logic_vector(to_signed(coeff(7-i), DATAWIDTH));
      cfg.gridConf(0)(i).routConf.i(0).HBusNxE(0) := '1';  -- hbusn_0.0 (inport 1)
    end loop;  -- i

    ---------------------------------------------------------------------------
    -- row 1 adds:
    ---------------------------------------------------------------------------

    -- c_1_1
    cfg.gridConf(1)(1).procConf.OpMuxS(0)              := I_REG;
    cfg.gridConf(1)(1).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(1).procConf.OutMuxS                := O_REG;
    cfg.gridConf(1)(1).procConf.AluOpxS                := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(1).routConf.i(0).LocalxE(LOCAL_NW) := '1';  -- NW neighb.
    cfg.gridConf(1)(1).routConf.i(1).LocalxE(LOCAL_N)  := '1';  -- N neighb.
    -- c_1_2
    cfg.gridConf(1)(2).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(2).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(2).procConf.OutMuxS                := O_REG;
    cfg.gridConf(1)(2).procConf.AluOpxS                := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(2).routConf.i(0).LocalxE(LOCAL_W)  := '1';  -- W neighb.
    cfg.gridConf(1)(2).routConf.i(1).LocalxE(LOCAL_N)  := '1';  -- N neighb.
    -- c_1_3
    cfg.gridConf(1)(3).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(3).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(3).procConf.OutMuxS                := O_REG;
    cfg.gridConf(1)(3).procConf.AluOpxS                := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(3).routConf.i(0).LocalxE(LOCAL_W)  := '1';  -- W neighb.
    cfg.gridConf(1)(3).routConf.i(1).LocalxE(LOCAL_N)  := '1';  -- N neighb.
    cfg.gridConf(1)(3).routConf.o.HBusNxE(0)           := '1';  -- hbusn_2.0

    ---------------------------------------------------------------------------
    -- row 2 adds:
    ---------------------------------------------------------------------------

    -- c_2_0
    cfg.gridConf(2)(0).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(0).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(0).procConf.OutMuxS               := O_REG;
    cfg.gridConf(2)(0).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(0).routConf.i(0).HBusNxE(0)       := '1';  -- hbusn_3.0
    cfg.gridConf(2)(0).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.
    -- c_2_1
    cfg.gridConf(2)(1).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(1).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(1).procConf.OutMuxS               := O_REG;
    cfg.gridConf(2)(1).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(1).routConf.i(0).LocalxE(LOCAL_W) := '1';  -- W neighb.
    cfg.gridConf(2)(1).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.
    -- c_2_2
    cfg.gridConf(2)(2).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(2).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(2).procConf.OutMuxS               := O_REG;
    cfg.gridConf(2)(2).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(2).routConf.i(0).LocalxE(LOCAL_W) := '1';  -- W neighb.
    cfg.gridConf(2)(2).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.
    -- c_2_3
    cfg.gridConf(2)(3).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(2)(3).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(2)(3).procConf.OutMuxS               := O_NOREG;
    cfg.gridConf(2)(3).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(2)(3).routConf.i(0).LocalxE(LOCAL_W) := '1';  -- W neighb.
    cfg.gridConf(2)(3).routConf.i(1).LocalxE(LOCAL_S) := '1';  -- S neighb.    
    cfg.gridConf(2)(3).routConf.o.HBusNxE(1)          := '1';  -- hbusn_3.1 (oport 0)

    ---------------------------------------------------------------------------
    -- row 3 multiplies:
    ---------------------------------------------------------------------------

    for i in 0 to 3 loop
      cfg.gridConf(3)(i).procConf.OpMuxS(0) := I_NOREG;
      cfg.gridConf(3)(i).procConf.OpMuxS(1) := I_CONST;
      cfg.gridConf(3)(i).procConf.OutMuxS   := O_NOREG;
      cfg.gridConf(3)(i).procConf.AluOpxS   := ALU_OP_MULTLO;
      cfg.gridConf(3)(i).procConf.ConstOpxD :=
        std_logic_vector(to_signed(coeff(i), DATAWIDTH));
      cfg.gridConf(3)(i).routConf.o.HBusNxE(0) := '1';  -- hbusn_0.0 (inport 1)      
    end loop;

    ---------------------------------------------------------------------------
    -- engine inputs and outputs
    ---------------------------------------------------------------------------

    -- engine input
    cfg.inputDriverConf(1)(0)(0) := '1';  -- hbusn_0.0
    cfg.inputDriverConf(1)(3)(0) := '1';  -- hbusn_3.0

    -- engine outputs
    cfg.outputDriverConf(0)(3)(1) := '1';  -- hbusn_3.1

    -- IP0 controller (deactivated)
    cfg.inportConf(0).LUT4FunctxD := X"0000";

    -- IP1 controller (activated)
    cfg.inportConf(1).LUT4FunctxD := X"FFFF";

    -- OP0 controller (activated)
    cfg.outportConf(0).LUT4FunctxD := X"FFFF";

    -- OP1 controller (deactivated)
    cfg.outportConf(1).LUT4FunctxD := X"0000";


    return cfg;
  end fir8mult_b;

end CfgLib_FIR;
