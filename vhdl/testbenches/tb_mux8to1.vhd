------------------------------------------------------------------------------
-- Testbench for mux8to1.vhd
--
-- Project    : 
-- File       : tb_mux8to1.vhd
-- Author     : Rolf Enzler <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/10/15
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_Mux8to1 is
end tb_Mux8to1;


architecture arch of tb_Mux8to1 is

  constant WIDTH : integer := 8;

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
  signal SelxS : std_logic_vector(2 downto 0);
  signal In0xD : std_logic_vector(WIDTH-1 downto 0);
  signal In1xD : std_logic_vector(WIDTH-1 downto 0);
  signal In2xD : std_logic_vector(WIDTH-1 downto 0);
  signal In3xD : std_logic_vector(WIDTH-1 downto 0);
  signal In4xD : std_logic_vector(WIDTH-1 downto 0);
  signal In5xD : std_logic_vector(WIDTH-1 downto 0);
  signal In6xD : std_logic_vector(WIDTH-1 downto 0);
  signal In7xD : std_logic_vector(WIDTH-1 downto 0);
  signal OutxD : std_logic_vector(WIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut: Mux8to1
    generic map (
      WIDTH => WIDTH)
    port map (
      SelxSI => SelxS,
      In0xDI => In0xD,
      In1xDI => In1xD,
      In2xDI => In2xD,
      In3xDI => In3xD,
      In4xDI => In4xD,
      In5xDI => In5xD,
      In6xDI => In6xD,
      In7xDI => In7xD,
      OutxDO => OutxD);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    SelxS    <= O"0";
    In0xD    <= std_logic_vector(to_unsigned(0, WIDTH));
    In1xD    <= std_logic_vector(to_unsigned(1, WIDTH));
    In2xD    <= std_logic_vector(to_unsigned(2, WIDTH));
    In3xD    <= std_logic_vector(to_unsigned(3, WIDTH));
    In4xD    <= std_logic_vector(to_unsigned(4, WIDTH));
    In5xD    <= std_logic_vector(to_unsigned(5, WIDTH));
    In6xD    <= std_logic_vector(to_unsigned(6, WIDTH));
    In7xD    <= std_logic_vector(to_unsigned(7, WIDTH));

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= sel0;                   -- sel0
    SelxS    <= O"0";
    wait for CLK_PERIOD;

    tbStatus <= sel1;                   -- sel1
    SelxS    <= O"1";
    wait for CLK_PERIOD;

    tbStatus <= sel2;                   -- sel2
    SelxS    <= O"2";
    wait for CLK_PERIOD;

    tbStatus <= sel3;                   -- sel3
    SelxS    <= O"3";
    wait for CLK_PERIOD;

    tbStatus <= sel4;                   -- sel4
    SelxS    <= O"4";
    wait for CLK_PERIOD;

    tbStatus <= sel5;                   -- sel5
    SelxS    <= O"5";
    wait for CLK_PERIOD;

    tbStatus <= sel6;                   -- sel6
    SelxS    <= O"6";
    wait for CLK_PERIOD;

    tbStatus <= sel7;                   -- sel7
    SelxS    <= O"7";
    wait for CLK_PERIOD;

    tbStatus <= idle;
    SelxS    <= O"0";
    In0xD    <= std_logic_vector(to_unsigned(0, WIDTH));
    wait for 2*CLK_PERIOD;

    tbStatus <= sel1;                   -- sel1, vary input
    SelxS    <= O"1";
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    In1xD    <= std_logic_vector(to_unsigned(30, WIDTH));
    wait for CLK_PERIOD;
    In1xD    <= std_logic_vector(to_unsigned(31, WIDTH));
    wait for CLK_PERIOD;
    In1xD    <= std_logic_vector(to_unsigned(32, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    SelxS    <= O"0";
    In0xD    <= std_logic_vector(to_unsigned(0, WIDTH));
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
