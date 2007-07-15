------------------------------------------------------------------------------
-- Testbench for decoder.vhd
--
-- Project    : 
-- File       : tb_decoder.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/06/26
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

----------------------------------------------------------------------------
-- see ZArchPkg:
--
-- ZUnit Register Mapping and Functions:
--   0   Reset              W
--   1   FIFO0              R/W
--   2   FIFO0 Level        R
--   3   FIFO1              R/W
--   4   FIFO1 Level        R
--   5   Run Cycle Counter  R/W
--   6   CfgMemory0         W
--   7   CfgMemory0 Pointer W
--   8   CfgMemory1         W
--   9   CfgMemory1 Pointer W
--  10   CfgMemory2         W
--  11   CfgMemory2 Pointer W
--  12   CfgMemory3         W
--  13   CfgMemory3 Pointer W
--  14   CfgMemory4         W
--  15   CfgMemory4 Pointer W
--  16   CfgMemory5         W
--  17   CfgMemory5 Pointer W
--  18   CfgMemory6         W
--  19   CfgMemory6 Pointer W
--  20   CfgMemory7         W
--  21   CfgMemory7 Pointer W
--  22   Context Sel. Reg.  W
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ComponentsPkg.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;

entity tb_Decoder is

end tb_Decoder;

architecture arch of tb_Decoder is

  constant REGWDT : integer := 8;     -- Register Width

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (init, idle, done, w_rst, w_fifo0, r_fifo0,
                          r_fifo0lev, w_fifo1, r_fifo1, r_fifo1lev,
                          w_ccnt, r_ccnt,
                          w_cfgmem0, w_cfgmem0ptr, w_cfgmem1, w_cfgmem1ptr,
                          w_cfgmem2, w_cfgmem2ptr, w_cfgmem3, w_cfgmem3ptr,
                          w_cfgmem4, w_cfgmem4ptr, w_cfgmem5, w_cfgmem5ptr,
                          w_cfgmem6, w_cfgmem6ptr, w_cfgmem7, w_cfgmem7ptr,
                          w_cntxt);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data and control/status signals
  signal WrReqxE     : std_logic;
  signal RdReqxE     : std_logic;
  signal RegNrxD     : std_logic_vector(REGWDT-1 downto 0);
  signal SystRstxRB  : std_logic;
  signal CCloadxE    : std_logic;
  signal Fifo0WExE   : std_logic;
  signal Fifo0RExE   : std_logic;
  signal Fifo1WExE   : std_logic;
  signal Fifo1RExE   : std_logic;
  signal CMWExE      : std_logic_vector(N_CONTEXTS-1 downto 0);
  signal CMLoadPtrxE : std_logic_vector(N_CONTEXTS-1 downto 0);
  signal CSRxE       : std_logic;
  signal DoutMuxS    : std_logic_vector(2 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut: Decoder
    generic map (
      REGWIDTH => REGWDT)
    port map (
      RstxRB       => RstxRB,
      WrReqxEI     => WrReqxE,
      RdReqxEI     => RdReqxE,
      RegNrxDI     => RegNrxD,
      SystRstxRBO  => SystRstxRB,
      CCloadxEO    => CCloadxE,
      Fifo0WExEO   => Fifo0WExE,
      Fifo0RExEO   => Fifo0RExE,
      Fifo1WExEO   => Fifo1WExE,
      Fifo1RExEO   => Fifo1RExE,
      CMWExEO      => CMWExE,
      CMLoadPtrxEO => CMLoadPtrxE,
      CSRxEO       => CSRxE,
      DoutMuxSO    => DoutMuxS);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= init;
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD*0.25;

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*1.25;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- reset (ZREG_RST:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_rst;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_RST, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- push data into FIFO0 (ZREG_FIFO0:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_fifo0;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_FIFO0, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- pop data from FIFO0 (ZREG_FIFO0:R)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= r_fifo0;
    WrReqxE  <= '0';
    RdReqxE  <= '1';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_FIFO0, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- read FIFO0 fill level (ZREG_FIFO0LEV:R)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= r_fifo0lev;
    WrReqxE  <= '0';
    RdReqxE  <= '1';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_FIFO0LEV, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- push data into FIFO1 (ZREG_FIFO1:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_fifo1;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_FIFO1, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;


    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- pop data from FIFO1 (ZREG_FIFO1:R)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= r_fifo1;
    WrReqxE  <= '0';
    RdReqxE  <= '1';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_FIFO1, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- read FIFO1 fill level (ZREG_FIFO1LEV:R)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= r_fifo1lev;
    WrReqxE  <= '0';
    RdReqxE  <= '1';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_FIFO1LEV, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write cycle count register (ZREG_CYCLECNT:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_ccnt;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CYCLECNT, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- read cycle count register (ZREG_CYCLECNT:R)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= r_ccnt;
    WrReqxE  <= '0';
    RdReqxE  <= '1';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CYCLECNT, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 0 (ZREG_CFGMEM0:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem0;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM0, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 0 pointer (ZREG_CFGMEM0PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem0ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM0PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 1 (ZREG_CFGMEM1:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem1;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM1, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 1 pointer (ZREG_CFGMEM1PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem1ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM1PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 2 (ZREG_CFGMEM2:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem2;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM2, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 2 pointer (ZREG_CFGMEM2PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem2ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM2PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 3 (ZREG_CFGMEM3:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem3;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM3, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 3 pointer (ZREG_CFGMEM3PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem3ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM3PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 4 (ZREG_CFGMEM4:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem4;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM4, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 4 pointer (ZREG_CFGMEM4PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem4ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM4PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 5 (ZREG_CFGMEM5:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem5;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM5, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 5 pointer (ZREG_CFGMEM5PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem5ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM5PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 6 (ZREG_CFGMEM6:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem6;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM6, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 6 pointer (ZREG_CFGMEM6PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem6ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM6PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write config. memory 7 (ZREG_CFGMEM7:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem7;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM7, REGWDT));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- set config. memory 7 pointer (ZREG_CFGMEM7PTR:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cfgmem7ptr;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CFGMEM7PTR, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

    -- - - - - - - - - - - - - - - - - - - - - - - -
    -- write context sel. register (ZREG_CONTEXTSEL:W)
    -- - - - - - - - - - - - - - - - - - - - - - - -
    tbStatus <= w_cntxt;
    WrReqxE  <= '1';
    RdReqxE  <= '0';
    RegNrxD  <= std_logic_vector(to_unsigned(ZREG_CONTEXTSEL, REGWDT));
    wait for CLK_PERIOD;
    
    tbStatus <= done;                   -- done
    WrReqxE  <= '0';
    RdReqxE  <= '0';
    RegNrxD  <= (others => '0');
    wait for CLK_PERIOD;

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

end arch;
