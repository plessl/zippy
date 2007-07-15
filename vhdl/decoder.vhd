------------------------------------------------------------------------------
-- ZUnit Decoder
--
-- Project     : 
-- File        : decoder.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/06/26
-- Last changed: $LastChangedDate: 2005-04-07 11:17:51 +0200 (Thu, 07 Apr 2005) $
------------------------------------------------------------------------------
--  address decoder that decodes the read/write commands on the host
--  interface and generates the appropriate control signals
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-06 CP added documentation
-------------------------------------------------------------------------------


----------------------------------------------------------------------------
-- see ZArchPkg for ZUnit Register Mapping and Functions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;

entity Decoder is

  generic (
    REGWIDTH : integer);
  port (
    RstxRB          : in  std_logic;
    WrReqxEI        : in  std_logic;
    RdReqxEI        : in  std_logic;
    RegNrxDI        : in  std_logic_vector(REGWIDTH-1 downto 0);
    SystRstxRBO     : out std_logic;    -- system reset
    CCloadxEO       : out std_logic;    -- cycle counter load
    VirtContextNoxEO : out std_logic;   -- load number of contexts for
                                        -- virtualization (temporal partitioning)
    ContextSchedulerSelectxEO : out std_logic;
    Fifo0WExEO      : out std_logic;    -- FIFO0 WE
    Fifo0RExEO      : out std_logic;    -- FIFO0 RE
    Fifo1WExEO      : out std_logic;    -- FIFO1 WE
    Fifo1RExEO      : out std_logic;    -- FIFO1 RE
    CMWExEO         : out std_logic_vector(N_CONTEXTS-1 downto 0);  -- CfgMem WE
    CMLoadPtrxEO    : out std_logic_vector(N_CONTEXTS-1 downto 0);  -- CfgMemPtr
    CSRxEO          : out std_logic;    -- context sel. load
    EngClrCntxtxEO  : out std_logic;    -- engine clear context
    SSWExEO         : out std_logic;    -- schedule store WE
    SSIAddrxDO      : out std_logic_vector(SIW_ADRWIDTH-1 downto 0);  -- address
    ScheduleStartxE : out std_logic;    -- schedule start
    DoutMuxSO       : out std_logic_vector(2 downto 0));            -- Dout mux

end Decoder;


architecture simple of Decoder is

  signal SoftRstxRB : std_logic;
  
begin  -- simple

  -- system reset
  SystRstxRBO <= RstxRB and SoftRstxRB;

  Decode : process (WrReqxEI, RdReqxEI, RegNrxDI)
  begin  -- process Decode
    -- default signal assignments
    SoftRstxRB      <= '1';
    CCloadxEO       <= '0';
    Fifo0WExEO      <= '0';
    Fifo0RExEO      <= '0';
    Fifo1WExEO      <= '0';
    Fifo1RExEO      <= '0';
    CMWExEO         <= (others => '0');
    CMLoadPtrxEO    <= (others => '0');
    CSRxEO          <= '0';
    EngClrCntxtxEO  <= '0';
    SSWExEO         <= '0';
    SSIAddrxDO      <= (others => '0');
    ScheduleStartxE <= '0';
    DoutMuxSO      <= (others => '0');
    VirtContextNoxEO <= '0';
    ContextSchedulerSelectxEO <= '0';
    
    if WrReqxEI = '1' then              -- WRITE REQUESTS
      case to_integer(unsigned(RegNrxDI)) is
        when ZREG_RST =>
          SoftRstxRB <= '0';
        when ZREG_FIFO0 =>
          Fifo0WExEO <= '1';
        when ZREG_FIFO1 =>
          Fifo1WExEO <= '1';
        when ZREG_CYCLECNT =>
          CCloadxEO <= '1';
        when ZREG_VIRTCONTEXTNO =>
          VirtContextNoxEO <= '1';
        when ZREG_CONTEXTSCHEDSEL =>
          ContextSchedulerSelectxEO <= '1';
        when ZREG_CFGMEM0 =>
          CMWExEO(0) <= '1';
        when ZREG_CFGMEM0PTR =>
          CMLoadPtrxEO(0) <= '1';
        when ZREG_CFGMEM1 =>
          CMWExEO(1) <= '1';
        when ZREG_CFGMEM1PTR =>
          CMLoadPtrxEO(1) <= '1';
        when ZREG_CFGMEM2 =>
          CMWExEO(2) <= '1';
        when ZREG_CFGMEM2PTR =>
          CMLoadPtrxEO(2) <= '1';
        when ZREG_CFGMEM3 =>
          CMWExEO(3) <= '1';
        when ZREG_CFGMEM3PTR =>
          CMLoadPtrxEO(3) <= '1';
        when ZREG_CFGMEM4 =>
          CMWExEO(4) <= '1';
        when ZREG_CFGMEM4PTR =>
          CMLoadPtrxEO(4) <= '1';
        when ZREG_CFGMEM5 =>
          CMWExEO(5) <= '1';
        when ZREG_CFGMEM5PTR =>
          CMLoadPtrxEO(5) <= '1';
        when ZREG_CFGMEM6 =>
          CMWExEO(6) <= '1';
        when ZREG_CFGMEM6PTR =>
          CMLoadPtrxEO(6) <= '1';
        when ZREG_CFGMEM7 =>
          CMWExEO(7) <= '1';
        when ZREG_CFGMEM7PTR =>
          CMLoadPtrxEO(7) <= '1';
        when ZREG_CONTEXTSEL =>
          CSRxEO <= '1';
        when ZREG_CONTEXTSELCLR =>
          CSRxEO         <= '1';
          EngClrCntxtxEO <= '1';
        when ZREG_SCHEDSTART =>
          ScheduleStartxE <= '1';
        when ZREG_SCHEDIWORD00 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "000";
        when ZREG_SCHEDIWORD01 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "001";
        when ZREG_SCHEDIWORD02 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "010";
        when ZREG_SCHEDIWORD03 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "011";
        when ZREG_SCHEDIWORD04 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "100";
        when ZREG_SCHEDIWORD05 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "101";
        when ZREG_SCHEDIWORD06 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "110";
        when ZREG_SCHEDIWORD07 =>
          SSWExEO <= '1';
          SSIAddrxDO(2 downto 0) <= "111";
        when others => assert false report "Corrupt ZREG access" severity error;
      end case;
      
    elsif RdReqxEI = '1' then           -- READ REQUESTS
      case to_integer(unsigned(RegNrxDI)) is
        when ZREG_FIFO0 =>
          Fifo0RExEO <= '1';
          DoutMuxSO  <= O"0";
        when ZREG_FIFO0LEV =>
          DoutMuxSO <= O"1";
        when ZREG_FIFO1 =>
          Fifo1RExEO <= '1';
          DoutMuxSO  <= O"2";
        when ZREG_FIFO1LEV =>
          DoutMuxSO <= O"3";
        when ZREG_VIRTCONTEXTNO =>
          DoutMuxSO <= O"4";
        when ZREG_SCHEDSTATUS =>
          DoutMuxSO <= O"6";
        when ZREG_CYCLECNT =>
          DoutMuxSO <= O"7";
        when others => assert false report "Corrupt ZREG access" severity error;
      end case;
    end if;
  end process Decode;

end simple;
