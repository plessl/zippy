------------------------------------------------------------------------------
-- Testbench for the ADPCM configuration for the zippy array
--
-- Project : 
-- File    : $Id: $
-- Author  : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- Created : 2004/10/15
-- Changed : $LastChangedDate: 2004-10-26 14:50:34 +0200 (Tue, 26 Oct 2004) $
------------------------------------------------------------------------------
-- This testbnech tests the ADPCM configuration for the zunit
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
use work.CfgLib_TSTADPCM.all;

entity tb_tstadpcm is
end tb_tstadpcm;

architecture arch of tb_tstadpcm is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   cycle      : integer := 1;
  constant DELAY      : integer := 2;   -- processing delay of circuit,
                                        -- due to pipelining
  signal NDATA      : integer := 0;     -- nr. of data elements
  signal NRUNCYCLES : integer := 0;      -- nr. of run cycles
  

  
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
  signal Cfg   : engineConfigRec                          := tstadpcmcfg;
  signal CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Cfg);
  signal CfgPrt : cfgPartArray := partition_config(CfgxD);
  file HFILE    : text open write_mode is "tstadpcm_cfg.h";

  file TVFILE : text open read_mode is "test.adpcm.txt";  -- adpcm encoded
                                                          -- input file
  file ERFILE : text open read_mode is "test.pcm.txt";    -- decoded file in
                                                          -- PCM format
  --------------------------------------------------------------------
  -- test vectors
  --   out = c(0) ? a : b
  --
  -- The testbench feeds input a also to the mux input, i.e. the output of the
  -- multiplexer is alway determined by the LSB of input A
  --------------------------------------------------------------------

begin  -- arch

  assert (N_ROWS = 7) report "configuration needs N_ROWS=7" severity failure;
  assert (N_COLS = 7) report "configuration needs N_COLS=7" severity failure;
  assert (N_HBUSN >= 2) report "configuration needs N_HBUSN>=2" severity failure;
  assert (N_HBUSS >= 2) report "configuration needs N_HBUSS>=2" severity failure;
  assert (N_VBUSE >= 1) report "configuration needs N_VBUSE>=1" severity failure;

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

    variable l : line;

    variable tv       : std_logic_vector(3 downto 0);
    variable tvstring : string(tv'range);

    variable expr       : std_logic_vector(15 downto 0);
    variable exprstring : string(expr'range);

    variable tvcount : integer := 0;
    

    
  begin  -- process stimuliTb

--    while not endfile(TVFILE) loop
--
--      readline(TVFILE, l);
--      read(l, tvstring);
--      tv := to_std_logic_vector(tvstring);  -- from txt_util
--
--      readline(ERFILE, l);
--      read(l, exprstring);
--      expr := to_std_logic_vector(exprstring);
--
--      assert false
--        report "tv=" & str(tv) & " expr= " & str(expr)
--        severity note;
--    end loop;



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

    while not endfile(TVFILE) loop
      
      readline(TVFILE, l);
      read(l, tvstring);
      tv := to_std_logic_vector(tvstring);  -- defined in txt_util

      DataInxD             <= (others => '0');
      DataInxD(3 downto 0) <= tv;

      tvcount := tvcount + 1;

      wait for CLK_PERIOD;
      
    end loop;

    -- determine length of data from input file
    NDATA <= tvcount;
    NRUNCYCLES <= tvcount + DELAY;
    
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


    -------------------------------------------------
    -- pop 2 words from out buffer (ZREG_FIFO1:R)
    --   delay of circuit due to registers (pipelining)
    -------------------------------------------------
    tbStatus <= pop_data;
    WExE     <= '0';
    RExE     <= '1';
    DataInxD <= (others => '0');
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO1, IFWIDTH));
    wait for DELAY*CLK_PERIOD;

    -------------------------------------------------
    -- pop data from out buffer (ZREG_FIFO1:R)
    -------------------------------------------------
    tbStatus <= pop_data;
    WExE     <= '0';
    RExE     <= '1';
    DataInxD <= (others => '0');
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO1, IFWIDTH));

    for i in 0 to NDATA-1 loop

      wait for CLK_PERIOD;

      if not endfile(ERFILE) then
        readline(ERFILE, l);
        read(l, exprstring);
        expr := to_std_logic_vector(exprstring);
      else
        expr := (others => '0');
      end if;

      expectedresponse := std_logic_vector(resize(signed(expr), DATAWIDTH));
      response         := DataOutxD(DATAWIDTH-1 downto 0);

      assert response = expectedresponse
        report "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE" & LF &
        "regression test failed, response " & hstr(response) &
        " does NOT match expected response "
        & hstr(expectedresponse) & " tv: " & str(i) & LF &
        "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE"
        severity failure;

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
