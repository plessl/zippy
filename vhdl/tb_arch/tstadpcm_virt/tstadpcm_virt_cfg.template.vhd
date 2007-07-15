------------------------------------------------------------------------------
-- Configuration for ADPCM application with virtualized execution on a
-- 4x4 zippy array
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


    -- ############# end   configuration of partition 2 ###################

    -- IO port configuration
    cfg.inportConf(0).LUT4FunctxD  := CFG_IOPORT_ON;
    cfg.inportConf(1).LUT4FunctxD  := CFG_IOPORT_OFF;
    cfg.outportConf(0).LUT4FunctxD := CFG_IOPORT_OFF;
    cfg.outportConf(1).LUT4FunctxD := CFG_IOPORT_ON;
    
    return cfg;
  end tstadpcmcfg_p2;


end CfgLib_TSTADPCM_VIRT;
