------------------------------------------------------------------------------
-- Library for a simple ZUnit configuration with just a single cell
--
-- Project     : 
-- File        : tstor_cfg.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/10/22
-- Last changed: $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- Changes:
-- 2004-10-22 CP created
-------------------------------------------------------------------------------
--
-- This library can be used for testing new cell functions or as a simple
--  regression test
--
-- The configuration defines a single cell at row:2, column: 3
-- Cell performs the alu_or operation, cell output is registered.
--
-- The input data to the cell is fed from FIFO0 and FIFO1
-- The input is routed using the horizontal north buses hbusn_2.0 and hbusn_2.1
-- (or HBus_BC0 and HBus_BC1 in Rolfs terminology)
--
-- The output of cell 2/3 is routed to output port OP1, using the hbusn_3.1
-- (HBus_CD1) bus.
--
-- ioport controllers are used for the FIFO access to prevent reads on empty
-- FIFOs. The architecture makes use of the normal FIFOs (i.e. without the
-- obscure first-word fall-through mode), thus an additional cycle is used for
-- FIFO access.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;

------------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------------
package CfgLib_TSTOR is

  function tstorcfg return engineConfigRec;

end CfgLib_TSTOR;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_TSTOR is

  ----------------------------------------------------------------------------
  -- tstor configuration
  --   configure alu in cell row 2, col 3
  --   connect INP0 and INP1 to inputs and OP0 to output
  ----------------------------------------------------------------------------
  function tstorcfg return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin  -- tstorcfg

    -- configure cell r2c3
    cfg.gridConf(2)(3).procConf.OpMuxS(0) := I_NOREG;
    cfg.gridConf(2)(3).procConf.OpMuxS(1) := I_NOREG;
    cfg.gridConf(2)(3).procConf.OutMuxS   := O_REG;
    cfg.gridConf(2)(3).procConf.AluOpxS   := ALU_OP_OR;  -- tstbitat0

    -- feed input 0 from hbusn_2.0
    cfg.gridConf(2)(3).routConf.i(0).HBusNxE(0) := '1';

    -- feed input 1 from hbusn_2.1
    cfg.gridConf(2)(3).routConf.i(1).HBusNxE(1) := '1';

    -- drive output to hbus_3.1 (HBus_CD1)
    cfg.gridConf(2)(3).routConf.o.HBusNxE(1) := '1';


    -- feed busses of engine from input ports
    cfg.inputDriverConf(0)(2)(0) := '1';  -- connect INP0 to hbusn_2.0
    cfg.inputDriverConf(1)(2)(1) := '1';  -- connect INP1 to hbusn_2.1

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

    -- cfg.inport1Conf.LUT4FunctxD  := X"FFFF";  -- InPort1  activated
    cfg.inportConf(1).Cmp0MuxS    := CFG_IOPORT_MUX_CYCLEDOWN;
    cfg.inportConf(1).Cmp0ModusxS := CFG_IOPORT_MODUS_LARGER;
    cfg.inportConf(1).Cmp0ConstxD := std_logic_vector(to_unsigned(2, CCNTWIDTH));
    cfg.inportConf(1).LUT4FunctxD := CFG_IOPORT_CMP0;

    return cfg;
  end tstorcfg;

end CfgLib_TSTOR;
