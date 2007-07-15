------------------------------------------------------------------------------
-- Testbench for fifo2.vhd
--
-- Project    : 
-- File       : tb_fifo2.vhd
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

entity tb_Fifo2 is

end tb_Fifo2;

architecture arch of tb_Fifo2 is

  constant WIDTH : integer := 8;        -- Data width
  constant DEPTH : integer := 4;        -- FIFO depth

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, wr, wr1, wr2, wr3, wr4, wr5, wr6, wr7, wr0,
                        rd, rd1, rd2, rd3, rd4, rd5, rd6, rd7, rd0, r_w, done);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- FIFO data and control/status signals
  signal FifoModexSI      : std_logic;
  signal FifoWExEI        : std_logic;
  signal FifoRExEI        : std_logic;
  signal FifoDinxDI       : std_logic_vector(WIDTH-1 downto 0);
  signal FifoDoutxDO      : std_logic_vector(WIDTH-1 downto 0);
  signal FifoEmptyxSO     : std_logic;
  signal FifoFullxSO      : std_logic;
  signal FifoFillLevelxDO : std_logic_vector(log2(DEPTH) downto 0);
  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : Fifo2
    generic map (
      WIDTH => WIDTH,
      DEPTH => DEPTH)
    port map (
      ClkxC        => ClkxC,
      RstxRB       => RstxRB,
      ModexSI      => FifoModexSI,
      WExEI        => FifoWExEI,
      RExEI        => FifoRExEI,
      DinxDI       => FifoDinxDI,
      DoutxDO      => FifoDoutxDO,
      EmptyxSO     => FifoEmptyxSO,
      FullxSO      => FifoFullxSO,
      FillLevelxDO => FifoFillLevelxDO);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    FifoModexSI <= '1';

    tbStatus   <= rst;
    FifoWExEI  <= '0';
    FifoRExEI  <= '0';
    FifoDinxDI <= (others => '0');

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus   <= wr1;                  -- write #1
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(10, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= wr2;                  -- write #2
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(20, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= wr3;                  -- write #3
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(30, WIDTH));
    wait for CLK_PERIOD;

    tbStatus  <= rd1;                   -- read #1
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= wr4;                  -- write #4
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(40, WIDTH));
    wait for CLK_PERIOD;

    tbStatus  <= rd2;                   -- read #2
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= wr5;                  -- write #5
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(50, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= wr6;                  -- write #6
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(60, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= wr0;                  -- write #0 (fifo is full...)
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(61, WIDTH));
    wait for CLK_PERIOD;

    tbStatus  <= rd3;                   -- read #3
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus  <= rd4;                   -- read #4
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= wr7;                  -- write #7
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(70, WIDTH));
    wait for CLK_PERIOD;

    tbStatus  <= rd5;                   -- read #5
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus  <= rd6;                   -- read #6
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus  <= rd7;                   -- read #7
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus  <= rd0;                   -- read #0 (fifo is empty...)
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= idle;                 -- idle
    FifoWExEI  <= '0';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(0, WIDTH));
    wait for 3*CLK_PERIOD;

    -------------------------------------------------------------------------
    -- now test what happens if read and write are both set at the same time
    -------------------------------------------------------------------------

    tbStatus   <= wr;                   -- write
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(11, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= wr;                   -- write
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(22, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= idle;                 -- idle
    FifoWExEI  <= '0';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(0, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= r_w;                  -- read AND write
    FifoWExEI  <= '1';
    FifoRExEI  <= '1';
    FifoDinxDI <= std_logic_vector(to_unsigned(33, WIDTH));
    wait for CLK_PERIOD;
    FifoDinxDI <= std_logic_vector(to_unsigned(44, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= wr;                   -- write
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(55, WIDTH));
    wait for CLK_PERIOD;

    tbStatus   <= wr;                   -- write
    FifoWExEI  <= '1';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(66, WIDTH));
    wait for CLK_PERIOD;

    -- now FIFO is full ----------------------------------------------------

    tbStatus   <= r_w;                                       -- read AND write
    FifoWExEI  <= '1';
    FifoRExEI  <= '1';
    FifoDinxDI <= std_logic_vector(to_unsigned(67, WIDTH));  -- => no write
    wait for CLK_PERIOD;
    FifoDinxDI <= std_logic_vector(to_unsigned(77, WIDTH));  -- => write
    wait for CLK_PERIOD;

    tbStatus   <= idle;                 -- idle
    FifoWExEI  <= '0';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(0, WIDTH));
    wait for CLK_PERIOD;

    tbStatus  <= rd;                    -- read
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus  <= rd;                    -- read
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus  <= rd;                    -- read
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    -- now FIFO is empty ---------------------------------------------------

    tbStatus   <= r_w;                  -- read AND write
    FifoWExEI  <= '1';
    FifoRExEI  <= '1';
    FifoDinxDI <= std_logic_vector(to_unsigned(88, WIDTH));
    wait for CLK_PERIOD;
    FifoDinxDI <= std_logic_vector(to_unsigned(99, WIDTH));
    wait for CLK_PERIOD;

    tbStatus  <= rd;                    -- read
    FifoWExEI <= '0';
    FifoRExEI <= '1';
    wait for CLK_PERIOD;

    tbStatus   <= done;                 -- done
    FifoWExEI  <= '0';
    FifoRExEI  <= '0';
    FifoDinxDI <= std_logic_vector(to_unsigned(0, WIDTH));
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
