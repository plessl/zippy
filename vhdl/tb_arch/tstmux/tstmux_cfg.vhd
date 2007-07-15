------------------------------------------------------------------------------
-- Configuration for mux testbench
--
-- Project     : 
-- File        : $URL: $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/10/27
-- Last changed: $LastChangedDate: 2004-10-26 14:50:34 +0200 (Tue, 26 Oct 2004) $
------------------------------------------------------------------------------
-- ZUnit configuration for MUX testbench. This testbench is used for testing
-- the multiplexer function alu_mux. The ALU MUX instruction needs special
-- testing, since it is the first ternary operation on the Zippy array.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-37 CP created
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
package CfgLib_TSTMUX is

  function tstmuxcfg return engineConfigRec;

end CfgLib_TSTMUX;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_TSTMUX is

  ----------------------------------------------------------------------------
  -- tstmux configuration
  --   configure alu in cell row 2, col 3
  --   connect INP0 and INP1 to inputs and OP0 to output
  ----------------------------------------------------------------------------
  function tstmuxcfg return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin

    -- configure cell_2_3
    cfg.gridConf(2)(3).procConf.OpMuxS(0) := I_NOREG;
    cfg.gridConf(2)(3).procConf.OpMuxS(1) := I_NOREG;
    cfg.gridConf(2)(3).procConf.OpMuxS(2) := I_NOREG;
    cfg.gridConf(2)(3).procConf.OutMuxS   := O_REG;
    cfg.gridConf(2)(3).procConf.AluOpxS   := ALU_OP_MUX;

    -- feed input 0 from hbusn_2.0
    cfg.gridConf(2)(3).routConf.i(0).HBusNxE(1) := '1';

    -- feed input 1 from hbusn_2.1
    cfg.gridConf(2)(3).routConf.i(1).HBusNxE(0) := '1';

    -- feed input 2 also from hbusn_2.0
    cfg.gridConf(2)(3).routConf.i(2).HBusNxE(1) := '1';

    -- drive output to hbusn_3.1 (HBus_CD1)
    cfg.gridConf(2)(3).routConf.o.HBusNxE(1) := '1';


    -- feed busses of engine from input ports
    cfg.inputDriverConf(0)(2)(1) := '1';  -- connect INP0 to hbusn_2.1
    cfg.inputDriverConf(1)(2)(0) := '1';  -- connect INP1 to hbusn_2.0

    -- engine outputs
    cfg.outputDriverConf(0)(3)(1) := '1';  -- connect OP0 to hbusn_3.1


    -- i/o port controller

    -- activate write to output FIFO0 after 2 cycles
    cfg.outportConf(0).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEUP;
    cfg.outportConf(0).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
    cfg.outportConf(0).Cmp0ConstxD := std_logic_vector(to_unsigned(1, CCNTWIDTH));
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_CMP0;

    -- deactivate read from input FIFO0 2 cycles before end
    cfg.inportConf(0).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEDOWN;
    cfg.inportConf(0).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
    cfg.inportConf(0).Cmp0ConstxD := std_logic_vector(to_unsigned(2, CCNTWIDTH));
    cfg.inportConf(0).LUT4FunctxD := CFG_IOPORT_CMP0;

    cfg.inportConf(1).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEDOWN;
    cfg.inportConf(1).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
    cfg.inportConf(1).Cmp0ConstxD := std_logic_vector(to_unsigned(2, CCNTWIDTH));
    cfg.inportConf(1).LUT4FunctxD := CFG_IOPORT_CMP0;

    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_OFF;

    return cfg;
  end tstmuxcfg;


end CfgLib_TSTMUX;
