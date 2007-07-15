------------------------------------------------------------------------------
-- Library for a simple ZUnit configuration with just a single cell
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/tb_arch/tstrom/tstrom_cfg.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/11/16
-- Last changed: $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- Changes:
-- 2004-11-16 CP created
-------------------------------------------------------------------------------
-- The configuration defines a single cell at row:2, column: 3
-- Cell performs the alu_rom operation, cell output is registered.
--
-- The input data to the cell is fed from FIFO0 and routed via the
-- horizontal north buses hbusn_2.0
--
-- The output of cell 2/3 is routed to output port OP1, using the hbusn_3.1
-- (HBus_CD1) bus.
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
package CfgLib_TSTROM is

  function tstromcfg return engineConfigRec;

end CfgLib_TSTROM;


------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------
package body CfgLib_TSTROM is

  ----------------------------------------------------------------------------
  -- tstor configuration
  --   configure alu in cell row 2, col 3
  --   connect INP0 to inputs and OP0 to output
  ----------------------------------------------------------------------------
  function tstromcfg return engineConfigRec is
    variable cfg : engineConfigRec := init_engineConfig;
  begin  -- tstorcfg

    -- feed busses of engine from input ports
    cfg.inputDriverConf(0)(2)(0) := '1';  -- connect INP0 to hbusn_2.0

    -- configure cell r2c3
    cfg.gridConf(2)(3).procConf.OpMuxS(0) := I_NOREG;
    cfg.gridConf(2)(3).procConf.OutMuxS   := O_REG;
    cfg.gridConf(2)(3).procConf.AluOpxS   := ALU_OP_ROM;

    -- feed input 0 from hbusn_2.0
    cfg.gridConf(2)(3).routConf.i(0).HBusNxE(0) := '1';

    -- drive output to hbus_3.1 (HBus_CD1)
    cfg.gridConf(2)(3).routConf.o.HBusNxE(1) := '1';

    -- engine outputs
    cfg.outputDriverConf(0)(3)(1) := '1';  -- connect OP0 to hbusn_3.1


    -- memory (ROM) configuration
    cfg.memoryConf(2)(0)  := std_logic_vector(to_signed(  1,DATAWIDTH));
    cfg.memoryConf(2)(1)  := std_logic_vector(to_signed( -2,DATAWIDTH));
    cfg.memoryConf(2)(2)  := std_logic_vector(to_signed(  3,DATAWIDTH));
    cfg.memoryConf(2)(3)  := std_logic_vector(to_signed( -5,DATAWIDTH));
    cfg.memoryConf(2)(4)  := std_logic_vector(to_signed(  7,DATAWIDTH));
    cfg.memoryConf(2)(5)  := std_logic_vector(to_signed(-11,DATAWIDTH));
    cfg.memoryConf(2)(6)  := std_logic_vector(to_signed( 13,DATAWIDTH));
    cfg.memoryConf(2)(7)  := std_logic_vector(to_signed(-17,DATAWIDTH));
    cfg.memoryConf(2)(8)  := std_logic_vector(to_signed( 19,DATAWIDTH));
    cfg.memoryConf(2)(9)  := std_logic_vector(to_signed(-23,DATAWIDTH));
    cfg.memoryConf(2)(10) := std_logic_vector(to_signed( 29,DATAWIDTH));
    cfg.memoryConf(2)(11) := std_logic_vector(to_signed(-31,DATAWIDTH));
    cfg.memoryConf(2)(12) := std_logic_vector(to_signed( 37,DATAWIDTH));
    cfg.memoryConf(2)(13) := std_logic_vector(to_signed(-41,DATAWIDTH));
    cfg.memoryConf(2)(14) := std_logic_vector(to_signed( 43,DATAWIDTH));
    cfg.memoryConf(2)(15) := std_logic_vector(to_signed(-47,DATAWIDTH));
    cfg.memoryConf(2)(16) := std_logic_vector(to_signed( 53,DATAWIDTH));
    cfg.memoryConf(2)(17) := std_logic_vector(to_signed(-59,DATAWIDTH));
    cfg.memoryConf(2)(18) := std_logic_vector(to_signed( 61,DATAWIDTH));
    cfg.memoryConf(2)(19) := std_logic_vector(to_signed(-67,DATAWIDTH));
             
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

    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;  -- InPort1  deactivated
    
    return cfg;
  end tstromcfg;

end CfgLib_TSTROM;
