------------------------------------------------------------------------------
-- Testbench for the ADPCM configuration for the zippy array
--
-- Project : 
-- Author  : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- URL     : $URL: $
-- $Id: $
------------------------------------------------------------------------------
-- This testbench tests the ADPCM configuration for the zunit
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
use work.CfgLib_TSTADPCM_VIRT.all;

entity tb_tstadpcm_virt_tpsched is
end tb_tstadpcm_virt_tpsched;

architecture arch of tb_tstadpcm_virt_tpsched is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   cycle      : integer := 1;

  constant NDATA : integer := 1024;      -- nr. of data elements
  constant DELAY : integer := 2;        -- processing delay of circuit,
                                        -- due to pipeliningq


  constant CONTEXTS   : integer := 3;

  
  type tbstatusType is (tbstart, idle, done, rst, wr_context0, wr_context1,
                        wr_context2, set_cmptr, set_virtctxtno, set_virtctxsched,
                        set_cntxt, start_scheduler,
                        push_data_fifo0, push_data_fifo1, inlevel,
                        wr_ncycl, rd_ncycl, running,
                        outlevel, pop_data, finished);
  signal tbStatus : tbstatusType := idle;

  signal processSample : integer := -1;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data/control signals
  signal WExE      : std_logic;
  signal RExE      : std_logic;
  signal AddrxD    : std_logic_vector(IFWIDTH-1 downto 0);
  signal DataInxD  : std_logic_vector(IFWIDTH-1 downto 0);
  signal DataOutxD : std_logic_vector(IFWIDTH-1 downto 0);

  -- configuration signals
  signal Context0Cfg : engineConfigRec := tstadpcmcfg_p0;
  signal Context1Cfg : engineConfigRec := tstadpcmcfg_p1;
  signal Context2Cfg : engineConfigRec := tstadpcmcfg_p2;

  signal Context0xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context0Cfg);
  signal Context1xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context1Cfg);
  signal Context2xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context2Cfg);

  signal Context0Prt : cfgPartArray := partition_config(Context0xD);
  signal Context1Prt : cfgPartArray := partition_config(Context1xD);
  signal Context2Prt : cfgPartArray := partition_config(Context2xD);

  file HFILE : text open write_mode is "tstadpcm_virt_tpsched_cfg.h";

  -- set dumpResults to true if the response and the expected response
  -- shall be dumped to HFILE for post simulation verification
  -- (instead of doing the verification in the testbench)
  signal dumpResults : boolean := false;
  file RESFILE       : text open write_mode is "tstadpcm_virt_tpsched_cfg.simout";

  type fifo_array is array (0 to (3*NDATA)-1) of
    std_logic_vector(DATAWIDTH-1 downto 0);

  file TVFILE : text open read_mode is "test.adpcm.txt";  -- adpcm encoded
                                                          -- input file
  file ERFILE : text open read_mode is "test.pcm.txt";    -- decoded file in
                                                          -- PCM format

begin  -- arch

  assert (N_COLS = 4) report "configuration requires N_COLS = 4" severity failure;
  assert (N_ROWS = 4) report "configuration requires N_ROWS = 4" severity failure;
  assert (N_HBUSN >= 2) report "configuration requires N_HBUSN >=2" severity failure;
  assert (N_HBUSS >= 1) report "configuration requires N_HBUSS >=1" severity failure;
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
    variable contextArr : contextPartArray :=
      (others => (others => (others => '0')));
  begin  -- process hFileGen
    contextArr(0) := Context0Prt;
    contextArr(1) := Context1Prt;
    contextArr(2) := Context2Prt;
    -- need only 3 contexts
    gen_contexthfile2(HFILE, contextArr);
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


    -- -----------------------------------------------
    -- write configuration slices to context mem 0 (ZREG_CFGMEM0:W)
    -- -----------------------------------------------
    tbStatus <= wr_context0;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CFGMEM0, IFWIDTH));
    for i in Context0Prt'low to Context0Prt'high loop
      DataInxD <= Context0Prt(i);
      wait for CLK_PERIOD;
    end loop;  -- i

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    -- -----------------------------------------------
    -- write configuration slices to context mem 1 (ZREG_CFGMEM1:W)
    -- -----------------------------------------------
    tbStatus <= wr_context1;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CFGMEM1, IFWIDTH));
    for i in Context1Prt'low to Context1Prt'high loop
      DataInxD <= Context1Prt(i);
      wait for CLK_PERIOD;
    end loop;  -- i

    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    -- -----------------------------------------------
    -- write configuration slices to context mem 2 (ZREG_CFGMEM2:W)
    -- -----------------------------------------------
    tbStatus <= wr_context2;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CFGMEM2, IFWIDTH));
    for i in Context2Prt'low to Context2Prt'high loop
      DataInxD <= Context2Prt(i);
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

    assert false
      report "Fill FIFO: " & str(tvcount) & " words written to FIFO0"
    severity note;
    
    tbStatus <= idle;                   -- idle
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;


    ---------------------------------------------------------------------------
    -- setup temporal partitioning scheduler
    ---------------------------------------------------------------------------
    
    -- enable the temporal partitioning scheduler (ZREG_CONTEXTSCHEDSEL:W)
    tbStatus <= set_virtctxsched;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CONTEXTSCHEDSEL, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
    wait for CLK_PERIOD;
    
    -- set the number of contexts (ZREG_VIRTCONTEXTNO:W)
    tbStatus <= set_virtctxtno;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_VIRTCONTEXTNO, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(CONTEXTS, IFWIDTH));
    wait for CLK_PERIOD;

    -- write cycle count register (ZREG_CYCLECNT:W)
    --  since this application uses the temporal partitioning scheduler
    --  this number specifies the number of user-cycles
    tbStatus <= wr_ncycl;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CYCLECNT, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(NDATA+DELAY, IFWIDTH));
    wait for CLK_PERIOD;

    -- start temporal partitioning scheduler (ZREG_SCHEDSTART:W)
    tbStatus <= start_scheduler;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_SCHEDSTART, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
    wait for CLK_PERIOD;

    -- run circuit with temporal partitioning
    tbStatus <= running;
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');

    wait for (NDATA+DELAY)*CONTEXTS*CLK_PERIOD;

    -- idle cycle (not required)
    tbStatus <= idle;
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');

    wait for CLK_PERIOD;
    
    -------------------------------------------------
    -- pop DELAY words from out buffer (ZREG_FIFO1:R)
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

    if dumpResults then
      print(RESFILE, "result / expected result");
    end if;

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

      if dumpResults then

        print (RESFILE, str(to_integer(signed(response))) & " " &
               str(to_integer(signed(expectedresponse))));

      else
        
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

      end if;

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
