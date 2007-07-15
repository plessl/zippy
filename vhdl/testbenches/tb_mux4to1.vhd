------------------------------------------------------------------------------
-- Testbench for mux4to1.vhd
--
-- Project    : 
-- File       : tb_mux4to1.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/06/25
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_Mux4to1 is

end tb_Mux4to1;


architecture arch of tb_Mux4to1 is

  constant WIDTH : integer := 8;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, sel0, sel1, sel2, sel3);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data and control/status signals
  signal SelxS : std_logic_vector(1 downto 0);
  signal In0xD : std_logic_vector(WIDTH-1 downto 0);
  signal In1xD : std_logic_vector(WIDTH-1 downto 0);
  signal In2xD : std_logic_vector(WIDTH-1 downto 0);
  signal In3xD : std_logic_vector(WIDTH-1 downto 0);
  signal OutxD : std_logic_vector(WIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut: Mux4to1
    generic map (
      WIDTH => WIDTH)
    port map (
      SelxSI => SelxS,
      In0xDI => In0xD,
      In1xDI => In1xD,
      In2xDI => In2xD,
      In3xDI => In3xD,
      OutxDO => OutxD);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    SelxS    <= "00";
    In0xD    <= std_logic_vector(to_unsigned(01, WIDTH));
    In1xD    <= std_logic_vector(to_unsigned(10, WIDTH));
    In2xD    <= std_logic_vector(to_unsigned(20, WIDTH));
    In3xD    <= std_logic_vector(to_unsigned(30, WIDTH));

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= sel0;                   -- sel0
    SelxS    <= "00";
    wait for CLK_PERIOD;

    tbStatus <= sel1;                   -- sel1
    SelxS    <= "01";
    wait for CLK_PERIOD;

    tbStatus <= sel2;                   -- sel2
    SelxS    <= "10";
    wait for CLK_PERIOD;

    tbStatus <= sel3;                   -- sel3
    SelxS    <= "11";
    wait for CLK_PERIOD;

    tbStatus <= sel0;                   -- sel0
    SelxS    <= "00";
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    In0xD    <= std_logic_vector(to_unsigned(1, WIDTH));
    wait for CLK_PERIOD;
    In0xD    <= std_logic_vector(to_unsigned(2, WIDTH));
    wait for CLK_PERIOD;
    In0xD    <= std_logic_vector(to_unsigned(3, WIDTH));
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
