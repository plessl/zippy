------------------------------------------------------------------------------
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

------------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------------
package CfgLib_TSTPASS_VIRT is

  function tstpasscfg_p0 return engineConfigRec;
  function tstpasscfg_p1 return engineConfigRec;

end CfgLib_TSTPASS_VIRT;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_TSTPASS_VIRT is


  ----------------------------------------------------------------------------
  -- tstpass partition p0 configuration
  ----------------------------------------------------------------------------
  function tstpasscfg_p0 return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin

    -- c_0_0 op0
    cfg.gridConf(0)(0).procConf.AluOpxS               := ALU_OP_ADD;
    -- i.0
    cfg.gridConf(0)(0).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(0)(0).routConf.i(0).HBusNxE(0)       := '1';
    -- i.1
    cfg.gridConf(0)(0).procConf.OpMuxS(1)             := I_NOREG;
    cfg.gridConf(0)(0).routConf.i(1).LocalxE(LOCAL_S) := '1';
    -- o.0
    cfg.gridConf(0)(0).procConf.OutMuxS               := O_NOREG;

    -- c_0_1 opt01
    cfg.gridConf(0)(1).procConf.AluOpxS               := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(0)(1).procConf.OpMuxS(0)             := I_NOREG;
    cfg.gridConf(0)(1).routConf.i(0).LocalxE(LOCAL_W) := '1';
    -- o.0
    --cfg.gridConf(0)(1).procConf.OpMuxS(0)             := O_REG_CTX_THIS;
    -- superfluous, result is registered anyway. ??
    -- none, transfer register from ctx0 to ctx1

    -- c_1_0 opt10
    --cfg.gridConf(0)(1).procConf.AluOpxS        := alu_pass0;
    -- i.0
    -- none, transfer register from ctx1 to ctx0
    -- o.0
    cfg.gridConf(1)(0).procConf.OutMuxS        := O_REG_CTX_OTHER;
    cfg.gridConf(1)(0).procConf.OutCtxRegSelxS := i2ctx(1);

    -- input drivers
    cfg.inputDriverConf(0)(0)(0) := '1';

    -- output drivers
    --  none

    -- IO port configuration
    cfg.inportConf(0).LUT4FunctxD  := CFG_IOPORT_ON;
    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_OFF;
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_OFF;

    return cfg;
  end tstpasscfg_p0;

  ----------------------------------------------------------------------------
  -- tstpass partition p1 configuration
  ----------------------------------------------------------------------------
  function tstpasscfg_p1 return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin

    -- c_0_1 opt01
    -- i.0
    -- none transfer from ctx0 to ctx1
    -- o.0
    cfg.gridConf(0)(1).procConf.OutMuxS        := O_REG_CTX_OTHER;
    cfg.gridConf(0)(1).procConf.OutCtxRegSelxS := i2ctx(0);
    -- drive hbusn_1.0, which is connected to outport
    cfg.gridConf(0)(1).routConf.o.HBusNxE(0) := '1';

    
    -- c_1_0 opt10
    cfg.gridConf(1)(0).procConf.AluOpxS                := ALU_OP_PASS0;
    -- i.0
    cfg.gridConf(1)(0).procConf.OpMuxS(0)              := I_NOREG;
    cfg.gridConf(1)(0).routConf.i(0).LocalxE(LOCAL_NE) := '1';
    -- o.0
    -- none, transfer register from ctx1 to ctx0

    -- input drivers
    --  none

    -- output drivers
    cfg.outputDriverConf(1)(1)(0) := '1';


    -- IO port configuration
    cfg.inportConf(0).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_OFF;
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_ON;

    return cfg;
  end tstpasscfg_p1;

end CfgLib_TSTPASS_VIRT;
