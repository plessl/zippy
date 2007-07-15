------------------------------------------------------------------------------
-- Testbench for contextmux.vhd
--
-- Project    : 
-- File       : tb_contextmux.vhd
-- Author     : Rolf Enzler <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/01/15
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ComponentsPkg.all;
use work.AuxPkg.all;
use work.ConfigPkg.all;

entity tb_ContextMux is
end tb_ContextMux;

architecture arch of tb_ContextMux is

  constant NINP : integer := 8;           -- 8:1 MUX
  constant NSEL : integer := log2(NINP);  -- width of select signal

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, sel0, sel1, sel2, sel3, sel4, sel5, sel6,
                        sel7);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data and control/status signals
  signal SelxS : std_logic_vector(NSEL-1 downto 0);
  signal Inp   : contextArray;
  signal OutxD : contextType;
  signal OutTailxD : std_logic_vector(15 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : ContextMux
    generic map (
      NINP => NINP)
    port map (
      SelxSI => SelxS,
      InpxI  => Inp,
      OutxDO => OutxD);

  ----------------------------------------------------------------------------
  -- aux. signals for easier waveform inspection
  ----------------------------------------------------------------------------
  OutTailxD <= OutxD(15 downto 0);
  
  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    SelxS    <= std_logic_vector(to_unsigned(0, NSEL));
    Inp(0)   <= std_logic_vector(to_unsigned(0, ENGN_CFGLEN));
    Inp(1)   <= std_logic_vector(to_unsigned(1, ENGN_CFGLEN));
    Inp(2)   <= std_logic_vector(to_unsigned(2, ENGN_CFGLEN));
    Inp(3)   <= std_logic_vector(to_unsigned(3, ENGN_CFGLEN));
    Inp(4)   <= std_logic_vector(to_unsigned(4, ENGN_CFGLEN));
    Inp(5)   <= std_logic_vector(to_unsigned(5, ENGN_CFGLEN));
    Inp(6)   <= std_logic_vector(to_unsigned(6, ENGN_CFGLEN));
    Inp(7)   <= std_logic_vector(to_unsigned(7, ENGN_CFGLEN));

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= sel0;                   -- sel0
    SelxS    <= std_logic_vector(to_unsigned(0, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= sel1;                   -- sel1
    SelxS    <= std_logic_vector(to_unsigned(1, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= sel2;                   -- sel2
    SelxS    <= std_logic_vector(to_unsigned(2, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= sel3;                   -- sel3
    SelxS    <= std_logic_vector(to_unsigned(3, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= sel4;                   -- sel4
    SelxS    <= std_logic_vector(to_unsigned(4, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= sel5;                   -- sel5
    SelxS    <= std_logic_vector(to_unsigned(5, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= sel6;                   -- sel6
    SelxS    <= std_logic_vector(to_unsigned(6, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= sel7;                   -- sel7
    SelxS    <= std_logic_vector(to_unsigned(7, NSEL));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    SelxS    <= std_logic_vector(to_unsigned(0, NSEL));
    Inp(0)   <= std_logic_vector(to_unsigned(0, ENGN_CFGLEN));
    wait for 2*CLK_PERIOD;

    tbStatus <= sel1;                   -- sel1, vary input
    SelxS    <= std_logic_vector(to_unsigned(1, NSEL));
    wait for CLK_PERIOD;
    Inp(1)   <= std_logic_vector(to_unsigned(30, ENGN_CFGLEN));
    wait for CLK_PERIOD;
    Inp(1)   <= std_logic_vector(to_unsigned(31, ENGN_CFGLEN));
    wait for CLK_PERIOD;
    Inp(1)   <= std_logic_vector(to_unsigned(32, ENGN_CFGLEN));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    SelxS    <= std_logic_vector(to_unsigned(0, NSEL));
    Inp(1)   <= std_logic_vector(to_unsigned(0, ENGN_CFGLEN));
    wait for 2*CLK_PERIOD;

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
