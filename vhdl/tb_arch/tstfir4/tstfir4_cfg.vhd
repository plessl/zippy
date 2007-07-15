------------------------------------------------------------------------------
-- Configuration for fir testbench
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/tb_arch/tstfir4/tstfir4_cfg.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/10/27
-- $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
-- $Id: tstfir4_cfg.vhd 217 2005-01-13 16:52:03Z plessl $
------------------------------------------------------------------------------
-- ZUnit configuration for MUX testbench. This testbench is used for testing
-- the multiplexer function alu_mux. The ALU MUX instruction needs special
-- testing, since it is the first ternary operation on the Zippy array.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-28 CP created
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
package CfgLib_TSTFIR4 is

  type coeff4Array is array (0 to 3) of integer;

  function tstfir4cfg(coeff : coeff4Array) return engineConfigRec;

end CfgLib_TSTFIR4;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_TSTFIR4 is


  ----------------------------------------------------------------------------
  -- 4-tap FIR filter
  ----------------------------------------------------------------------------

  function tstfir4cfg (coeff : coeff4Array) return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin  -- tstfir4cfg

    ---------------------------------------------------------------------------
    -- row 0 multiplies:
    ---------------------------------------------------------------------------
    
    for i in 0 to 3 loop
      cfg.gridConf(0)(i).procConf.OpMuxS(0) := I_NOREG;
      cfg.gridConf(0)(i).procConf.OpMuxS(1) := I_CONST;
      cfg.gridConf(0)(i).procConf.OutMuxS   := O_NOREG;
      cfg.gridConf(0)(i).procConf.AluOpxS   := ALU_OP_MULTLO;
      cfg.gridConf(0)(i).procConf.ConstOpxD := i2cfgconst(coeff(coeff'length-1 - i));
      cfg.gridConf(0)(i).routConf.i(0).HBusNxE(0) := '1';  -- hbusn_0.0
    end loop;  -- i

    ---------------------------------------------------------------------------
    -- row 1 adds:
    ---------------------------------------------------------------------------

    -- cell_1_1
    cfg.gridConf(1)(1).procConf.OpMuxS(0)              := I_REG_CTX_THIS;
    cfg.gridConf(1)(1).procConf.OpMuxS(1)              := I_NOREG;
    cfg.gridConf(1)(1).procConf.OutMuxS                := O_REG;
    cfg.gridConf(1)(1).procConf.AluOpxS                := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(1).routConf.i(0).LocalxE(LOCAL_NW) := '1';         -- NW neighb.
    cfg.gridConf(1)(1).routConf.i(1).LocalxE(LOCAL_N)  := '1';         -- N neighb.

    -- cell_1_2
    cfg.gridConf(1)(2).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(1)(2).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(1)(2).procConf.OutMuxS               := O_REG;
    cfg.gridConf(1)(2).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(2).routConf.i(0).LocalxE(LOCAL_W) := '1';         -- W neighb.
    cfg.gridConf(1)(2).routConf.i(1).LocalxE(LOCAL_N) := '1';         -- N neighb.

    -- cell_1_3
    cfg.gridConf(1)(3).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(1)(3).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(1)(3).procConf.OutMuxS               := O_REG;
    cfg.gridConf(1)(3).procConf.AluOpxS               := ALU_OP_ADD;  -- add
    cfg.gridConf(1)(3).routConf.i(0).LocalxE(LOCAL_W) := '1';         -- W neighb.
    cfg.gridConf(1)(3).routConf.i(1).LocalxE(LOCAL_N) := '1';         -- N neighb.
    cfg.gridConf(1)(3).routConf.o.HBusNxE(0)          := '1';         -- hbusn_2.0 (oport 0)

    -- engine input
    cfg.inputDriverConf(0)(0)(0) := '1';  -- hbusn_0.0

    -- engine outputs
    cfg.outputDriverConf(0)(2)(0) := '1';  -- output on OUTP0 via hbusn_2.0

    -- Input from FIFO0 (INP0), deactivate read from input FIFO0 5 cycles
    -- before end
    cfg.inportConf(0).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEDOWN;
    cfg.inportConf(0).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
    cfg.inportConf(0).Cmp0ConstxD := std_logic_vector(to_unsigned(2, CCNTWIDTH));
    cfg.inportConf(0).LUT4FunctxD := CFG_IOPORT_CMP0;

    -- Output to FIFO0 (OP0), activate write to output FIFO0 after 1 cycles
    cfg.outportConf(0).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEUP;
    cfg.outportConf(0).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
    cfg.outportConf(0).Cmp0ConstxD := std_logic_vector(to_unsigned(1, CCNTWIDTH));
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_CMP0;

    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;  -- InPort1 deactivated
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_OFF;  -- OutPort1 deactivated

    return cfg;
  end tstfir4cfg;


end CfgLib_TSTFIR4;
