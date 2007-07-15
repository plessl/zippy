------------------------------------------------------------------------------
-- Testbench for ioportctrl.vhd
--
-- Project    : 
-- File       : tb_ioportctrl.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/01/20
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ComponentsPkg.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;

entity tb_IOPortCtrl is
end tb_IOPortCtrl;

architecture arch of tb_IOPortCtrl is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done, exp1, exp2, exp3, exp4, exp5, exp6,
                          exp7, exp8);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT I/O signals
  signal ConfigxI      : ioportConfigRec;
  signal CycleDnCntxDI : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal CycleUpCntxDI : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal PortxEO       : std_logic;
  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : IOPortCtrl
    generic map (
      CCNTWIDTH => CCNTWIDTH)
    port map (
      ClkxC         => ClkxC,
      RstxRB        => RstxRB,
      ConfigxI      => ConfigxI,
      CycleDnCntxDI => CycleDnCntxDI,
      CycleUpCntxDI => CycleUpCntxDI,
      PortxEO       => PortxEO);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    procedure init_stimuli (
      signal ConfigxI      : out ioportConfigRec;
      signal CycleDnCntxDI : out std_logic_vector(CCNTWIDTH-1 downto 0);
      signal CycleUpCntxDI : out std_logic_vector(CCNTWIDTH-1 downto 0)) is
    begin
      ConfigxI      <= init_ioportConfig;
      CycleDnCntxDI <= (others => '0');
      CycleUpCntxDI <= (others => '0');
    end init_stimuli;

  begin  -- process stimuliTb

    tbStatus <= rst;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    --------------------------------------------------------------------------
    -- Experiment 1: always "1"
    --------------------------------------------------------------------------
    tbStatus             <= exp1;
    ConfigxI.LUT4FunctxD <= X"FFFF";
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- Experiment 2: "CycleDnCnt=3 => 1"
    --------------------------------------------------------------------------
    tbStatus             <= exp2;
    ConfigxI.Cmp0MuxS    <= '1';        -- compare down counter
    ConfigxI.Cmp0ModusxS <= '1';        -- modus "="
    ConfigxI.Cmp0ConstxD <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    ConfigxI.LUT4FunctxD <= X"F0F0";
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- Experiment 3: "CycleDnCnt>3 => 1"
    --------------------------------------------------------------------------
    tbStatus             <= exp3;
    ConfigxI.Cmp0MuxS    <= '1';        -- compare down counter
    ConfigxI.Cmp0ModusxS <= '0';        -- modus ">"
    ConfigxI.Cmp0ConstxD <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    ConfigxI.LUT4FunctxD <= X"F0F0";
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- Experiment 4: "CycleDnCnt<3 => 1" (NOTE: ^= NOT>2)
    --------------------------------------------------------------------------
    tbStatus             <= exp4;
    ConfigxI.Cmp0MuxS    <= '1';        -- compare down counter
    ConfigxI.Cmp0ModusxS <= '0';        -- modus ">"
    ConfigxI.Cmp0ConstxD <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    ConfigxI.LUT4FunctxD <= X"0F0F";
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- Experiment 5: "3<CycleDnCnt<6 => 1"
    --------------------------------------------------------------------------
    tbStatus             <= exp5;
    ConfigxI.Cmp0MuxS    <= '1';        -- compare down counter
    ConfigxI.Cmp0ModusxS <= '0';        -- modus ">"
    ConfigxI.Cmp0ConstxD <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    ConfigxI.Cmp1MuxS    <= '1';        -- compare down counter
    ConfigxI.Cmp1ModusxS <= '0';        -- modus ">"
    ConfigxI.Cmp1ConstxD <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    ConfigxI.LUT4FunctxD <= X"00F0";
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleDnCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- Experiment 6: "CycleUpCnt(0)"
    --------------------------------------------------------------------------
    tbStatus             <= exp6;
    ConfigxI.LUT4FunctxD <= X"AAAA";
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- Experiment 7: "CycleUpCnt(1)"
    --------------------------------------------------------------------------
    tbStatus             <= exp7;
    ConfigxI.LUT4FunctxD <= X"CCCC";
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- Experiment 8: "3<CycleUpCnt<6 => 1"
    --------------------------------------------------------------------------
    tbStatus             <= exp8;
    ConfigxI.Cmp0MuxS    <= '0';        -- compare up counter
    ConfigxI.Cmp0ModusxS <= '0';        -- modus ">"
    ConfigxI.Cmp0ConstxD <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    ConfigxI.Cmp1MuxS    <= '0';        -- compare up counter
    ConfigxI.Cmp1ModusxS <= '0';        -- modus ">"
    ConfigxI.Cmp1ConstxD <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    ConfigxI.LUT4FunctxD <= X"00F0";
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(0, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(1, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(2, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(3, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(4, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(5, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(6, CCNTWIDTH));
    wait for CLK_PERIOD;
    CycleUpCntxDI        <= std_logic_vector(to_unsigned(7, CCNTWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
    wait for CLK_PERIOD;

    
    tbStatus <= done;
    init_stimuli(ConfigxI, CycleDnCntxDI, CycleupCntxDI);
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
