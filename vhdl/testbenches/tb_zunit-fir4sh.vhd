------------------------------------------------------------------------------
-- Testbench for zunit.vhd
--   configures a 4-tap FIR (coefficients are shifts)
--
-- Project    : 
-- File       : tb_zunit-fir4sh.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/06/28
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;
use work.CfgLib_FIR.all;

architecture fir4sh of tb_ZUnit is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (tbstart, idle, done, rst, wr_cfg, set_cmptr,
                        push_data, inlevel, wr_ncycl, rd_ncycl, running,
                        outlevel, pop_data);
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
  signal Cfg : engineConfigRec := fir4shift;

  signal CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Cfg);
  
  signal CfgPrt : cfgPartArray := partition_config(CfgxD);
  file HFILE    : text open write_mode is "fir4sh.h";
  
begin  -- fir4sh

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

    constant NDATA      : integer := 12;  -- nr. of data elements
    constant NRUNCYCLES : integer := 12;  -- nr. of run cycles
    
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
    -- write configuration slices (ZREG_CFGMEM0:W)
    -- -----------------------------------------------
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

    -- -----------------------------------------------
    -- push data into in buffer (ZREG_FIFO0:W)
    -- -----------------------------------------------
    tbStatus <= push_data;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO0, IFWIDTH));
    DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
    wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
--     wait for CLK_PERIOD;
--     DataInxD <= std_logic_vector(to_signed(80, IFWIDTH));
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
    -- pop data from out buffer (ZREG_FIFO1:R)
    -- -----------------------------------------------
    tbStatus <= pop_data;
    WExE     <= '0';
    RExE     <= '1';
    DataInxD <= (others => '0');
    for i in 0 to NDATA loop
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
      report "stimuli processed; sim. terminated after " & int2str(ccount) &
      " cycles"
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

end fir4sh;
