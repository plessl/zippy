------------------------------------------------------------------------------
-- Testbench for the tstfir4 function of the zunit
--
-- Project     : 
-- File        : tb_tstfir4.vhd
-- Author      : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/10/15
-- $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
-- $Id: tb_tstfir4.vhd 217 2005-01-13 16:52:03Z plessl $
------------------------------------------------------------------------------
-- This testbench tests the tstfir4 function of the zunit.
--
-- The primary goals of this testbench are:
--   test extension of cell to support 3 inputs (operands)
--   test ternary operators (mux is a ternary operator)
--   test the alu_mux function
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-28 CP created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
use work.AuxPkg.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;
use work.CfgLib_TSTFIR4.all;

entity tb_tstfir4 is
end tb_tstfir4;

architecture arch of tb_tstfir4 is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   cycle      : integer := 1;

  
  type tbstatusType is (tbstart, idle, done, rst, wr_cfg, set_cmptr,
                        push_data_fifo0, push_data_fifo1, inlevel,
                        wr_ncycl, rd_ncycl, running,
                        outlevel, pop_data, finished);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data/control signals
  signal WExE      : std_logic;
  signal RExE      : std_logic;
  signal AddrxD    : std_logic_vector(IFWIDTH-1 downto 0);
  signal DataInxD  : std_logic_vector(IFWIDTH-1 downto 0);
  signal DataOutxD : std_logic_vector(IFWIDTH-1 downto 0);

  -- test vector and expected response

  constant COEFS : coeff4array := (1,2,3,1);

  constant NDATA      : integer := 20;       -- nr. of data elements
  constant NRUNCYCLES : integer := NDATA+2;  -- nr. of run cycles
  
  
  type fifo_array is array (0 to NDATA-1) of natural;
    
  constant TESTV : fifo_array :=
    (1,0,0,1,2,0,0,2,3,0,0,3,1,0,0,1,0,0,0,0);
--      (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  
  constant EXPRESP : fifo_array :=
    (1,2,3,2,4,7,7,4,7,12,11,6,7,11,6,2,2,3,1,0);
--      (1,2,3,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  
  -- configuration stuff
  signal Cfg : engineConfigRec := tstfir4cfg(COEFS);
  
  signal CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Cfg);
  signal CfgPrt : cfgPartArray := partition_config(CfgxD);
  file HFILE    : text open write_mode is "tstfir4_cfg.h";

  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : ZUnit
    generic map (
      IFWIDTH   => IFWIDTH,
      DATAWIDTH => DATAWIDTH,
      CCNTWIDTH => CCNTWIDTH,
      FIFODEPTH => FIFODEPTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      WExEI   => WExE,
      RExEI   => RExE,
      AddrxDI => AddrxD,
      DataxDI => DataInxD,
      DataxDO => DataOutxD);

  ----------------------------------------------------------------------------
  -- generate .h file for coupled simulation
  ----------------------------------------------------------------------------
  hFileGen : process
  begin  -- process hFileGen
    gen_cfghfile(HFILE, CfgPrt);
    wait;
  end process hFileGen;

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    variable response         : std_logic_vector(DATAWIDTH-1 downto 0) := (others => '0');
    variable expectedresponse : std_logic_vector(DATAWIDTH-1 downto 0) := (others => '0');
    
  begin  -- process stimuliTb

    tbStatus <= tbstart;
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;

    -------------------------------------------------
    -- reset (ZREG_RST:W)
    -------------------------------------------------
    tbStatus <= rst;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_RST, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(0, IFWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    -------------------------------------------------
    -- write configuration slices (ZREG_CFGMEM0:W)
    -------------------------------------------------
    tbStatus <= wr_cfg;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CFGMEM0, IFWIDTH));
    for i in CfgPrt'low to CfgPrt'high loop
      DataInxD <= CfgPrt(i);
      wait for CLK_PERIOD;
    end loop;  -- i

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    -------------------------------------------------
    -- push data into FIFO0 (ZREG_FIFO0:W)
    -------------------------------------------------
    tbStatus <= push_data_fifo0;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO0, IFWIDTH));

    for i in 0 to NDATA-1 loop
      DataInxD              <= (others => '0');
      DataInxD(DATAWIDTH-1 downto 0) <= std_logic_vector(to_unsigned(TESTV(i), DATAWIDTH));

      -- assert false
      --  report "writing to FIFO0:" & hstr(TESTV(i))
      -- severity note;

      wait for CLK_PERIOD;
    end loop;  -- i

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    -------------------------------------------------
    -- write cycle count register (ZREG_CYCLECNT:W)
    -------------------------------------------------
    tbStatus <= wr_ncycl;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CYCLECNT, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(NRUNCYCLES, IFWIDTH));
    wait for CLK_PERIOD;

    -------------------------------------------------
    -- computation running
    -------------------------------------------------
    tbStatus <= running;
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    for i in 1 to NRUNCYCLES loop
      wait for CLK_PERIOD;
    end loop;  -- i

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;

    -------------------------------------------------
    -- pop data from out buffer (ZREG_FIFO0:R)
    -------------------------------------------------
    tbStatus <= pop_data;
    WExE     <= '0';
    RExE     <= '1';
    DataInxD <= (others => '0');
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO0, IFWIDTH));

    for i in 0 to NDATA-1 loop

      wait for CLK_PERIOD;

      expectedresponse := std_logic_vector(to_unsigned(EXPRESP(i),DATAWIDTH));
      response         := DataOutxD(DATAWIDTH-1 downto 0);

      assert response = expectedresponse
        report "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE" & LF &
        "regression test failed, response " & hstr(response) &
        " does NOT match expected response "
        & hstr(expectedresponse) & " tv: " & str(i) & LF &
        "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE"
        severity note;

      assert not(response = expectedresponse)
        report "response " & hstr(response) & " matches expected " &
        "response " & hstr(expectedresponse) & " tv: " & str(i)
        severity note;

    end loop;  -- i

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;

    -----------------------------------------------
    -- done stop simulation
    -----------------------------------------------
    tbStatus <= done;                   -- done
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;

    ---------------------------------------------------------------------------
    -- stopping the simulation is done by using the following TCL script
    -- in modelsim, since terminating the simulation with an assert failure is
    -- a crude hack:
    --
    -- when {/tbStatus == done} {
    --   echo "At Time $now Ending the simulation"
    --   quit -f
    -- } 
    ---------------------------------------------------------------------------


    -- stop simulation
    wait until (ClkxC'event and ClkxC = '1');
    assert false
      report "Testbench successfully terminated after " & str(cycle) &
      " cycles, no errors found!"
      severity failure;
    
  end process stimuliTb;

  ----------------------------------------------------------------------------
  -- clock and reset generation
  ----------------------------------------------------------------------------
  ClkxC  <= not ClkxC after CLK_PERIOD/2;
  RstxRB <= '0', '1'  after CLK_PERIOD*1.25;

  ----------------------------------------------------------------------------
  -- cycle counter
  ----------------------------------------------------------------------------
  cyclecounter : process (ClkxC)
  begin
    if (ClkxC'event and ClkxC = '1') then
      cycle <= cycle + 1;
    end if;
  end process cyclecounter;

end arch;
