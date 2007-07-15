------------------------------------------------------------------------------
-- Testbench for cycledncntr.vhd
--
-- Project    : 
-- File       : tb_cycledncntr.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/06/26
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_CycleDnCntr is

end tb_CycleDnCntr;


architecture arch of tb_CycleDnCntr is

  constant CNTWIDTH : integer := 8;     -- Counter width

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, load, countdown, done);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT I/O signals
  signal LoadxE : std_logic;
  signal CinxD  : std_logic_vector(CNTWIDTH-1 downto 0);
  signal OnxS   : std_logic;
  signal CoutxD : std_logic_vector(CNTWIDTH-1 downto 0);
  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : CycleDnCntr
    generic map (
      CNTWIDTH => CNTWIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      LoadxEI => LoadxE,
      CinxDI  => CinxD,
      OnxSO   => OnxS,
      CoutxDO => CoutxD);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    LoadxE   <= '0';
    CinxD    <= std_logic_vector(to_unsigned(0, CNTWIDTH));

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= load;                   -- load start value
    LoadxE   <= '1';
    CinxD    <= std_logic_vector(to_unsigned(9, CNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= countdown;              -- countdown
    LoadxE   <= '0';
    CinxD    <= std_logic_vector(to_unsigned(0, CNTWIDTH));
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= load;                   -- load start value
    LoadxE   <= '1';                    -- (should *not* be loaded)
    CinxD    <= std_logic_vector(to_unsigned(9, CNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= countdown;              -- countdown
    LoadxE   <= '0';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= load;                   -- load start value
    LoadxE   <= '1';
    CinxD    <= std_logic_vector(to_unsigned(4, CNTWIDTH));
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    LoadxE   <= '0';
    tbStatus <= countdown;              -- countdown

    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= done;                   -- done
    LoadxE   <= '0';
    CinxD    <= std_logic_vector(to_unsigned(0, CNTWIDTH));
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
