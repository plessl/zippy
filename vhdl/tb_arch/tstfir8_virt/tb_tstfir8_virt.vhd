------------------------------------------------------------------------------
-- Testbench for zunit.vhd: configures an 8-tap FIR
--
-- Project     : 
-- File        : tb_zunit-fir8.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/06/28
-- Last changed: $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- testbench for the fir8 case study. Used for standalone simulation and for
-- generating the configuration header file for system co-simulation.
------------------------------------------------------------------------------

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
use work.CfgLib_FIR.all;

entity tb_tstfir8_virt is
end tb_tstfir8_virt;

architecture fir8 of tb_tstfir8_virt is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (tbstart, idle, done, rst,
                        push_data, inlevel, wr_ncycl, rd_ncycl, running,
                        outlevel, pop_data,
                        set_cntxt, wr_context0, wr_context1);
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

  -- contexts
  signal Context0 : engineConfigRec :=
    fir8mult(  ( 1,  2,  1,  2,  2,  1,  2,  1));
  signal Context1 : engineConfigRec :=
    fir8mult_b(( 1, -1,  1, -1, -1,  1, -1,  1));
  signal Context2 : engineConfigRec :=
    fir8mult(  ( 0,  1,  0,  1,  1,  0,  1,  0));
  signal Context3 : engineConfigRec :=
    fir8mult_b((-1, -2,  1,  2,  2,  1, -2, -1));
  signal Context4 : engineConfigRec :=
    fir8mult(  ( 1,  2, -2, -2, -2, -2,  2,  1));
  signal Context5 : engineConfigRec :=
    fir8mult_b(( 3,  2,  1,  0,  0,  1,  2,  3));
  signal Context6 : engineConfigRec :=
    fir8mult(  (-2, -1,  0,  1,  1,  0, -1, -2));
  signal Context7 : engineConfigRec :=
    fir8mult_b(( 1,  0, -2, -1, -1, -2,  0,  1));

  signal Context0xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context0);
  signal Context1xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context1);
  signal Context2xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context2);
  signal Context3xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context3);
  signal Context4xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context4);
  signal Context5xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context5);
  signal Context6xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context6);
  signal Context7xD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Context7);

  signal Context0Prt : cfgPartArray := partition_config(Context0xD);
  signal Context1Prt : cfgPartArray := partition_config(Context1xD);
  signal Context2Prt : cfgPartArray := partition_config(Context2xD);
  signal Context3Prt : cfgPartArray := partition_config(Context3xD);
  signal Context4Prt : cfgPartArray := partition_config(Context4xD);
  signal Context5Prt : cfgPartArray := partition_config(Context5xD);
  signal Context6Prt : cfgPartArray := partition_config(Context6xD);
  signal Context7Prt : cfgPartArray := partition_config(Context7xD);

  -- aux. stuff
  file HFILE : text open write_mode is "tstfir8_virt_cfg.h";

begin  -- fir8

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
    variable contextArr : contextPartArray;
  begin  -- process hFileGen
    contextArr(0) := Context0Prt;
    contextArr(1) := Context1Prt;
    contextArr(2) := Context2Prt;
    contextArr(3) := Context3Prt;
    contextArr(4) := Context4Prt;
    contextArr(5) := Context5Prt;
    contextArr(6) := Context6Prt;
    contextArr(7) := Context7Prt;
    gen_contexthfile2(HFILE, contextArr);
    wait;
  end process hFileGen;

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    constant NDATA      : integer := 20;       -- nr. of data elements
    constant NRUNCYCLES : integer := NDATA+1;  -- nr. of run cycles
    
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

    -- -----------------------------------------------
    -- reset (ZREG_RST:W)
    -- -----------------------------------------------
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
    -- push data into FIFO 0 (ZREG_FIFO0:W)
    -- -----------------------------------------------
    tbStatus <= push_data;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO0, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
    wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(1, IFWIDTH));
--     wait for CLK_PERIOD;

--     for i in 12 to NDATA loop
    for i in 1 to NDATA loop
      DataInxD <= std_logic_vector(to_signed(0, IFWIDTH));
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
    -- set context select register (ZREG_CONTEXTSEL:W)
    -- -----------------------------------------------
    tbStatus <= set_cntxt;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CONTEXTSEL, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(0, IFWIDTH));
    wait for CLK_PERIOD;

    -- -----------------------------------------------
    -- write cycle count register (ZREG_CYCLECNT:W)
    -- -----------------------------------------------
    tbStatus <= wr_ncycl;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_CYCLECNT, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(NRUNCYCLES, IFWIDTH));
    wait for CLK_PERIOD;

    -- -----------------------------------------------
    -- computation running
    -- -----------------------------------------------
    tbStatus <= running;
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    for i in 0 to NRUNCYCLES-1 loop
      wait for CLK_PERIOD;
    end loop;  -- i

    -- -----------------------------------------------
    -- pop data from FIFO 1 (ZREG_FIFO1:R)
    -- -----------------------------------------------
    tbStatus <= pop_data;
    WExE     <= '0';
    RExE     <= '1';
    DataInxD <= (others => '0');
    for i in 1 to NDATA loop
      AddrxD <= std_logic_vector(to_unsigned(ZREG_FIFO1, IFWIDTH));
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
    -- done; stop simulation
    -- -----------------------------------------------
    tbStatus <= done;                   -- done
    WExE     <= '0';
    RExE     <= '0';
    AddrxD   <= (others => '0');
    DataInxD <= (others => '0');
    wait for CLK_PERIOD;

    -- stop simulation
    wait until (ClkxC'event and ClkxC = '1');
    assert false
      report "ROGER; stimuli processed; sim. terminated after " &
      str(ccount) & " cycles"
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
      ccount <= ccount + 1;
    end if;
  end process cyclecounter;

end fir8;
