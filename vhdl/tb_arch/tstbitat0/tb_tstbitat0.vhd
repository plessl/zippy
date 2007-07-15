------------------------------------------------------------------------------
-- Testbench for the tstbitat0 function of the zunit
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/tb_arch/tstbitat0/tb_tstbitat0.vhd $
-- Author      : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/10/26
-- Last changed: $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
-- $Id: tb_tstbitat0.vhd 217 2005-01-13 16:52:03Z plessl $
------------------------------------------------------------------------------
-- This testbench tests the tstbitat0 function of the zunit.
--
-- The primary goal of this testbench is to provide an example of a testbench
-- that can be used for standalone simulation and co-simulation to verify the
-- correct function of the zunit.
--
-- There a 2 main purposes of the testbench:
--  a) specific testing of newly added components and features
--  b) regression testing of the whole architecture
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-05 CP created (based on the tb_zarch testbench by Rolf Enzler)
-- 2004-10-26 CP extended for automated verification of testvectors
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
use work.CfgLib_TSTBITAT0.all;

entity tb_tstbitat0 is
end tb_tstbitat0;

architecture arch of tb_tstbitat0 is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   cycle      : integer := 1;

  constant NDATA      : integer := 6;        -- nr. of data elements
  constant NRUNCYCLES : integer := NDATA+2;  -- nr. of run cycles
  

  
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

  -- configuration stuff
  signal Cfg : engineConfigRec :=
    tstbitat0cfg;
  signal CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Cfg);
  signal CfgPrt : cfgPartArray := partition_config(CfgxD);
  file HFILE    : text open write_mode is "tstbitat0_cfg.h";

  type fifo_array is array (0 to (3*NDATA)-1) of
    std_logic_vector(15 downto 0);


  --------------------------------------------------------------------
  -- test vectors
  -- out = tst_bitsat0(a,b)
  -- array contains: contents for fifo0, contents for fifo1, expected
  -- result
  --------------------------------------------------------------------
  constant TESTV : fifo_array :=
    (b"0000_0000_0000_0000",            -- a    0000
     b"0000_1111_0000_1111",            -- b    0F0F
     b"1111_1111_1111_1111",            -- out  FFFF

     b"0000_0000_0000_0000",            -- a    0000
     b"0000_0000_0000_0000",            -- b    0000
     b"1111_1111_1111_1111",            -- out  FFFF

     b"0111_1101_1010_0101",            -- a    7DA5
     b"1000_0010_0000_1000",            -- b    8208
     b"1111_1111_1111_1111",            -- out  FFFF

     b"1101_0101_1101_1000",            -- a    D5D8
     b"1011_0000_0010_0000",            -- b    B020
     b"0000_0000_0000_0000",            -- out  0000

     b"1001_0111_1110_0001",            -- a    97E1
     b"0010_1100_0000_0000",            -- b    2C00
     b"0000_0000_0000_0000",            -- out  0000

     b"1001_0111_1110_0001",            -- a    97E1
     b"0010_1000_0000_0010",            -- b    2802
     b"1111_1111_1111_1111"             -- out  FFFF
     );


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

    variable expectedresponse : std_logic_vector(15 downto 0) := (others => '0');
    variable response         : std_logic_vector(15 downto 0) := (others => '0');



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
      DataInxD(15 downto 0) <= TESTV(i*3);

      -- assert false
      --  report "writing to FIFO0:" & hstr(TESTV(i*3))
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
    -- push data into FIFO1 (ZREG_FIFO1:W)
    -------------------------------------------------
    tbStatus <= push_data_fifo1;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO1, IFWIDTH));

    for i in 0 to NDATA-1 loop
      DataInxD              <= (others => '0');
      DataInxD(15 downto 0) <= TESTV(i*3+1);

      -- assert false
      --  report "writing to FIFO1:" & hstr(TESTV(i*3+1))
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

    -- -----------------------------------------------
    -- pop data from out buffer (ZREG_FIFO0:R)
    -- -----------------------------------------------
    tbStatus <= pop_data;
    WExE     <= '0';
    RExE     <= '1';
    DataInxD <= (others => '0');
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO0, IFWIDTH));

    for i in 0 to NDATA-1 loop

      wait for CLK_PERIOD;

      expectedresponse := TESTV(3*i+2);
      response         := DataOutxD(15 downto 0);

      assert response = expectedresponse
        report "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE" & LF &
        "regression test failed, response " & hstr(response) &
        " does NOT match expected response "
        & hstr(expectedresponse) & " tv: " & str(i) & LF &
        "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE"
        severity failure;

      assert not(response = expectedresponse)
        report "response " & hstr(response) & " matches expected " &
        "response " & hstr(expectedresponse)
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
