------------------------------------------------------------------------------
-- Configurable parameters for the ZIPPY architecture
--
-- Project     : 
-- Authors     : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- $Id: $
-- $URL: $
------------------------------------------------------------------------------
-- This file declares the user configurable architecture parameters for the
-- zippy architecture.
-- These parameters can/shall be modified by the user for defining a Zippy
-- architecture variant that is suited for the application at hand.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.auxPkg.all;

package archConfigPkg is

  ----------------------------------------------------------------------------
  -- User configurable architecture parameter
  ----------------------------------------------------------------------------

  constant DATAWIDTH : integer := 24;       -- data path width
  constant FIFODEPTH : integer := 4096;  -- FIFO depth

  constant N_CONTEXTS : integer := 8;        -- no. of contexts
  constant CNTXTWIDTH : integer := log2(N_CONTEXTS);

  constant N_COLS     : integer := 4;   -- no. of columns (cells per row)
  constant N_ROWS     : integer := 4;   -- no. of rows
  constant N_HBUSN    : integer := 2;   -- no. of horizontal north buses
  constant N_HBUSS    : integer := 2;   -- no. of horizontal south buses
  constant N_VBUSE    : integer := 2;   -- no. of vertical east buses

  constant N_MEMADDRWIDTH : integer := 7;
  constant N_MEMDEPTH     : integer := 2**N_MEMADDRWIDTH;

end archConfigPkg;


package body archConfigPkg is

end archConfigPkg;
