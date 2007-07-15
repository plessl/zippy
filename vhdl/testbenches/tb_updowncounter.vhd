------------------------------------------------------------------------------
-- Testbench for updowncounter.vhd
--
-- Project    : 
-- File       : updowncounter.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/01/21
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_UpDownCounter is
end tb_UpDownCounter;

architecture arch of tb_UpDownCounter is

  constant WIDTH : integer := 4;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done, load, cnt_up, cnt_down);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT I/O signals
  signal LoadxEI : std_logic;
  signal CExEI   : std_logic;
  signal ModexSI : std_logic;
  signal CinxDI  : std_logic_vector(WIDTH-1 downto 0);
  signal CoutxDO : std_logic_vector(WIDTH-1 downto 0);
  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : UpDownCounter
    generic map (
      WIDTH => WIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      LoadxEI => LoadxEI,
      CExEI   => CExEI,
      ModexSI => ModexSI,
      CinxDI  => CinxDI,
      CoutxDO => CoutxDO);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    procedure init_stimuli (
      signal LoadxEI : out std_logic;
      signal CExEI   : out std_logic;
      signal ModexSI : out std_logic;
      signal CinxDI  : out std_logic_vector(WIDTH-1 downto 0)) is
    begin
      LoadxEI <= '0';
      CExEI   <= '0';
      ModexSI <= '0';
      CinxDI  <= (others => '0');
    end init_stimuli;

  begin  -- process stimuliTb

    tbStatus <= rst;
    init_stimuli(LoadxEI, CExEI, ModexSI, CinxDI);

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= load;                   -- load start value
    LoadxEI  <= '1';
    CinxDI   <= std_logic_vector(to_unsigned(7, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(LoadxEI, CExEI, ModexSI, CinxDI);
    wait for CLK_PERIOD;

    tbStatus <= cnt_up;                 -- count up
    CExEI    <= '1';
    ModexSI  <= '0';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= load;                   -- load new start value
    LoadxEI  <= '1';
    CinxDI   <= std_logic_vector(to_unsigned(5, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(LoadxEI, CExEI, ModexSI, CinxDI);
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= cnt_up;                 -- count up
    CExEI    <= '1';
    ModexSI  <= '0';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= load;                   -- load new start value
    LoadxEI  <= '1';
    CinxDI   <= std_logic_vector(to_unsigned(13, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(LoadxEI, CExEI, ModexSI, CinxDI);
    wait for CLK_PERIOD;

    tbStatus <= cnt_up;                 -- count up
    CExEI    <= '1';
    ModexSI  <= '0';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(LoadxEI, CExEI, ModexSI, CinxDI);
    wait for CLK_PERIOD;

    tbStatus <= load;                   -- load new start value
    LoadxEI  <= '1';
    CinxDI   <= std_logic_vector(to_unsigned(4, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    init_stimuli(LoadxEI, CExEI, ModexSI, CinxDI);
    wait for CLK_PERIOD;

    tbStatus <= cnt_down;               -- count down
    CExEI    <= '1';
    ModexSI  <= '1';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= done;                   -- done
    init_stimuli(LoadxEI, CExEI, ModexSI, CinxDI);
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
