------------------------------------------------------------------------------
-- Auxiliary routines
--
-- Project     : 
-- File        : auxPkg.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003-10-16
-- Last changed: $LastChangedDate: 2004-10-26 14:50:34 +0200 (Tue, 26 Oct 2004) $
------------------------------------------------------------------------------
-- This packages provides a number of auxiliary routines, in particular for
-- printing and converting characters and numbers.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-06 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.txt_util.all;

package AuxPkg is

  -- computes base-2 logarithm of an integer
  function log2b (int : integer) return integer;
  function log2 (int : integer) return integer;

end AuxPkg;


package body auxPkg is

  ---------------------------------------------------------------------------
  -- computes base-2 logarithm of an integer (inverse function of **)
  -- rounds up, i.e. log2(8)=3, log2(9)=log2(16)=4
  -- this function is not intended to synthesize directly into hardware,
  -- rather it is used to generate constants for synthesized hardware.
  -- (adapted from Ray Andraka's posting in comp.arch.fpga; has a different
  -- behaviour!)
  ---------------------------------------------------------------------------
  function log2b (int : integer) return integer is
    variable temp : integer := int-1;
    variable log  : integer := 0;
  begin  -- log2b
    assert int /= 0
      report "ERROR: function missuse: log2(zero)"
      severity failure;
    while temp /= 0 loop
      temp := temp/2;
      log  := log+1;
    end loop;
    return log;
  end log2b;

  -- simple version (synthesizable); doesn't cover full range!
  function log2 (int : integer) return integer is
    variable log : integer := 0;
  begin  -- log2
    assert int /= 0
      report "ERROR: function missuse: log2(zero)"
      severity failure;
    case int is
      when 1       => log := 1;                    -- reasonable. ..?
      when 2       => log := 1;
      when 3       => log := 2;
      when 4       => log := 2;
      when 5       => log := 3;
      when 6       => log := 3;
      when 7       => log := 3;
      when 8       => log := 3;
      when 9       => log := 4;
      when 10      => log := 4;
      when 11      => log := 4;
      when 12      => log := 4;
      when 13      => log := 4;
      when 14      => log := 4;
      when 15      => log := 4;
      when 16      => log := 4;
      when 17      => log := 5;
      when 18      => log := 5;
      when 19      => log := 5;
      when 20      => log := 5;
      when 21      => log := 5;
      when 22      => log := 5;
      when 23      => log := 5;
      when 24      => log := 5;
      when 25      => log := 5;
      when 26      => log := 5;
      when 27      => log := 5;
      when 28      => log := 5;
      when 29      => log := 5;
      when 30      => log := 5;
      when 31      => log := 5;
      when 32      => log := 5;
      when 64      => log := 6;
      when 128     => log := 7;
      when 256     => log := 8;
      when 512     => log := 9;
      when 1024    => log := 10;
      when 2048    => log := 11;
      when 4096    => log := 12;
      when 8192    => log := 13;
      when 16384   => log := 14;
      when 32768   => log := 15;
      when 65536   => log := 16;
      when 131072  => log := 17;
      when 262144  => log := 18;
      when 524288  => log := 19;
      when 1048576 => log := 20;
      when others  => assert false
                        report "ERROR: log2() of value `" & str(int) &
                        "' not defined; adapt function"
                        severity error;
    end case;
    return log;
  end log2;

end auxPkg;
