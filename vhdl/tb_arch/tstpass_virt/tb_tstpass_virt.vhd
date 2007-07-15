------------------------------------------------------------------------------
-- Testbench for the tstpass_virt configuration
--
-- Project : 
-- File    : $Id: $
-- Author  : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company : Swiss Federal Institute of Technology (ETH) Zurich
-- Changed : $LastChangedDate: 2004-10-26 14:50:34 +0200 (Tue, 26 Oct 2004) $
------------------------------------------------------------------------------
-- This testbench tests the tstpass_virt configuration
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
use work.CfgLib_TSTPASS_VIRT.all;

entity tb_tstpass_virt is
end tb_tstpass_virt;

architecture arch of tb_tstpass_virt is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   cycle      : integer := 1;

  constant NDATA      : integer := 16;          -- nr. of data elements
  constant DELAY      : integer := 1;   -- processing delay of circuit,
                                        -- due to pipeliningq


  constant CONTEXTS   : integer := 2;
  constant NRUNCYCLES : integer := NDATA+DELAY;  -- nr. of run cycles
  

  
  type tbstatusType is (tbstart, idle, done, rst, wr_context0, wr_context1,
                        wr_context2, set_cmptr, set_cntxt,
                        push_data_fifo0, wr_ncycl, rd_ncycl, running,
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

  -- configuration signals
  signal Context0Cfg : engineConfigRec := tstpasscfg_p0;
  signal Context1Cfg : engineConfigRec := tstpasscfg_p1;
  
  signal Context0xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context0Cfg);
  signal Context1xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context1Cfg);

  signal Context0Prt : cfgPartArray := partition_config(Context0xD);
  signal Context1Prt : cfgPartArray := partition_config(Context1xD);

  file HFILE    : text open write_mode is "tstpass_virt_cfg.h";

  type tv_array is array (0 to NDATA-1) of integer;

  constant TESTV : tv_array :=
    (  1,  2,  3,  5,
       7, 11, 13, 17,
      19, 23, 29, 31,
      37, 41, 43, 47);

  constant EXPRES : tv_array :=
    (    1,   3,   6,  11,
        18,  29,  42,  59,
        78, 101, 130, 161,
       198, 239, 282, 329);

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
    variable contextArr : contextPartArray :=
      (others => (others => (others => '0')));
  begin  -- process hFileGen
    contextArr(0) := Context0Prt;
    contextArr(1) := Context1Prt;
    -- need only 2 contexts
    gen_contexthfile2(HFILE, contextArr);
    wait;
  end process hFileGen;

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    variable response         : integer;
    variable expectedresponse : integer;
    variable l : line;
    
  begin  -- process stimuliTb

    tbStatus <= tbstart;
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
--    wait for CLK_PERIOD*0.25;
    wait for CLK_PERIOD*0.1;

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


    -------------------------------------------------
    -- push data into FIFO0 (ZREG_FIFO0:W)
    -------------------------------------------------
    tbStatus <= push_data_fifo0;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO0, IFWIDTH));

    for i in 0 to NDATA-1 loop
      DataInxD              <= (others => '0');
      DataInxD(DATAWIDTH-1 downto 0) <=
        std_logic_vector(to_unsigned(TESTV(i),DATAWIDTH));

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

      for runcycle in 0 to NDATA+DELAY-1 loop

        for context in 0 to CONTEXTS-1 loop
        
        -- set context select register (ZREG_CONTEXTSEL:W)
        tbStatus <= set_cntxt;
        WExE     <= '1';
        RExE     <= '0';
        AddrxD   <= std_logic_vector(to_unsigned(ZREG_CONTEXTSEL, IFWIDTH));
        DataInxD <= std_logic_vector(to_signed(context, IFWIDTH));
        wait for CLK_PERIOD;  
        
        -- write cycle count register (ZREG_CYCLECNT:W)
        tbStatus <= wr_ncycl;
        WExE     <= '1';
        RExE     <= '0';
        AddrxD   <= std_logic_vector(to_unsigned(ZREG_CYCLECNT, IFWIDTH));
        DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
        wait for CLK_PERIOD;


        -- run computation of current context
        tbStatus <= running;
        WExE     <= '0';
        RExE     <= '0';
        AddrxD   <= (others => '0');
        DataInxD <= (others => '0');
        wait for CLK_PERIOD;

        end loop;  -- context      

      end loop;  -- runcycle
      

    -------------------------------------------------
    -- pop 1 words from out buffer (ZREG_FIFO1:R)
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

      response         := to_integer(signed(DataOutxD(DATAWIDTH-1 downto 0)));
      expectedresponse := EXPRES(i);

      assert response = expectedresponse
        report "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE" & LF &
        "regression test failed, response " & str(response) &
        " does NOT match expected response "
        & str(expectedresponse) & " tv: " & str(i) & LF &
        "FAILURE--FAILURE--FAILURE--FAILURE--FAILURE--FAILURE"
        severity failure;

      assert not(response = expectedresponse)
        report "response " & str(response) & " matches expected " &
        "response " & str(expectedresponse) & " tv: " & str(i)
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
