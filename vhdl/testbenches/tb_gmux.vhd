------------------------------------------------------------------------------
-- Testbench for gmux.vhd
--
-- Project    : 
-- File       : tb_gmux.vhd
-- Author     : Rolf Enzler <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/01/15
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_GMux is
end tb_GMux;

architecture arch of tb_GMux is

  constant NINP  : integer := 8;        -- 8:1 MUX
  constant NSEL  : integer := log2(NINP);
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
  signal SelxS : std_logic_vector(NSEL-1 downto 0);
  signal InpxD : std_logic_vector(NINP*WIDTH-1 downto 0);
  signal In0xD : std_logic_vector(WIDTH-1 downto 0);
  signal In1xD : std_logic_vector(WIDTH-1 downto 0);
  signal In2xD : std_logic_vector(WIDTH-1 downto 0);
  signal In3xD : std_logic_vector(WIDTH-1 downto 0);
  signal In4xD : std_logic_vector(WIDTH-1 downto 0);
  signal In5xD : std_logic_vector(WIDTH-1 downto 0);
  signal In6xD : std_logic_vector(WIDTH-1 downto 0);
  signal In7xD : std_logic_vector(WIDTH-1 downto 0);
  signal OutxD : std_logic_vector(WIDTH-1 downto 0);

  component GMux
    generic (
      NINP  : integer;
      WIDTH : integer);
    port (
      SelxSI : in  std_logic_vector(log2(NINP)-1 downto 0);
      InxDI  : in  std_logic_vector(NINP*WIDTH-1 downto 0);
      OutxDO : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : GMux
    generic map (
      NINP  => NINP,
      WIDTH => WIDTH)
    port map (
      SelxSI => SelxS,
      InxDI  => InpxD,
      OutxDO => OutxD);

  ----------------------------------------------------------------------------
  -- input encoding
  ----------------------------------------------------------------------------
  InpxD <= In7xD & In6xD & In5xD & In4xD & In3xD & In2xD & In1xD & In0xD;

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    SelxS    <= std_logic_vector(to_unsigned(0, NSEL));
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
    In0xD    <= std_logic_vector(to_unsigned(0, WIDTH));
    wait for 2*CLK_PERIOD;

    tbStatus <= sel1;                   -- sel1, vary input
    SelxS    <= std_logic_vector(to_unsigned(1, NSEL));
    wait for CLK_PERIOD;
    In1xD    <= std_logic_vector(to_unsigned(30, WIDTH));
    wait for CLK_PERIOD;
    In1xD    <= std_logic_vector(to_unsigned(31, WIDTH));
    wait for CLK_PERIOD;
    In1xD    <= std_logic_vector(to_unsigned(32, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    SelxS    <= std_logic_vector(to_unsigned(0, NSEL));
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
