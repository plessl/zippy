------------------------------------------------------------------------------
-- Testbench for the alu_rom function of the zunit
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/tb_arch/tstrom/tb_tstrom.vhd $
-- Author      : Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2004/11/16
-- Last changed: $LastChangedDate: 2005-01-13 17:52:03 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- This testbench tests the alu_rom function of the zunit.
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
use work.CfgLib_TSTROM.all;

entity tb_tstrom is
end tb_tstrom;

architecture arch of tb_tstrom is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   cycle      : integer := 1;

  constant NDATA      : integer := 20;        -- nr. of data elements
  constant NRUNCYCLES : integer := NDATA+2;  -- nr. of run cycles
  

  
  type tbstatusType is (tbstart, idle, done, rst, wr_cfg, set_cmptr,
                        push_data_fifo0, push_data_fifo1, inlevel,
                        wr_ncycl, rd_ncycl, running,
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
  signal Cfg : engineConfigRec := tstromcfg;
  signal CfgxD : std_logic_vector(ENGN_CFGLEN-1 downto 0) :=
    to_engineConfig_vec(Cfg);
  signal CfgPrt : cfgPartArray := partition_config(CfgxD);
  file HFILE    : text open write_mode is "tstrom_cfg.h";

  type fifo_array is array (0 to NDATA-1) of integer;
  type nat_array is array (0 to NDATA-1) of integer;

  -----------------------------------------------------------------------------
  -- test vectors
  -- out = a or b
  -- array contains: contents for fifo0, contents for fifo1, expected result
  -----------------------------------------------------------------------------
  constant TESTV : nat_array :=
    (
      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
    );
  
  constant EXPRES : fifo_array :=
    ( 
        1,  -2,   3,  -5,   7,
      -11,  13, -17,  19, -23,
       29, -31,  37, -41,  43,
      -47,  53, -59,  61,  -67
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
    
    variable response         : integer;
    variable expectedresponse : integer;

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
    -- push data into FIFO0 (ZREG_FIFO0:W)
    -- -----------------------------------------------
    tbStatus <= push_data_fifo0;
    WExE     <= '1';
    RExE     <= '0';
    AddrxD   <= std_logic_vector(to_unsigned(ZREG_FIFO0, IFWIDTH));

    for i in 0 to NDATA-1 loop
      DataInxD              <= (others => '0');
      DataInxD(DATAWIDTH-1 downto 0) <=
        std_logic_vector(to_unsigned(TESTV(i),DATAWIDTH));

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

      expectedresponse := EXPRES(i);
      response         := to_integer(signed(DataOutxD(DATAWIDTH-1 downto 0)));

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
      report "stimuli processed; sim. terminated after " & str(cycle) &
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
      cycle <= cycle + 1;
    end if;
  end process cyclecounter;

end arch;
