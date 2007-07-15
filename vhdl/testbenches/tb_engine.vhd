------------------------------------------------------------------------------
-- Testbench for engine.vhd
--
-- Project    : 
-- File       : tb_engine.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/10/02
-- Last changed: $LastChangedDate: 2004-10-29 17:42:55 +0200 (Fri, 29 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;
use work.CfgLib_FIR.all;

entity tb_Engine is
end tb_Engine;


architecture arch of tb_Engine is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, done, pass_const, addu, fir4shft_cfg,
                        fir4shft_pulse, fir4shft_square, fir4shft_inputs,
                        fir8shft_cfg, fir8shft_pulse, fir8shft_square,
                        fir8shft_inputs, fir4mult_cfg, fir4mult_pulse,
                        fir4mult_square, fir4mult_inputs, fir8mult_cfg,
                        fir8mult_pulse, fir8mult_square, fir8mult_inputs,
                        ip0_en, ip1_en, op0_en, op1_en);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal ClrxAB       : std_logic                               := '1';
  signal CExE         : std_logic                               := '1';
  signal Cfg          : engineConfigRec;
  signal ContextxS    : std_logic_vector(CNTXTWIDTH-1 downto 0) := (others => '0');
  signal InPort0xD    : std_logic_vector(DATAWIDTH-1 downto 0);
  signal InPort1xD    : std_logic_vector(DATAWIDTH-1 downto 0);
  signal OutPort0xD   : std_logic_vector(DATAWIDTH-1 downto 0);
  signal OutPort1xD   : std_logic_vector(DATAWIDTH-1 downto 0);
  signal CycleDnCntxD : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal CycleUpCntxD : std_logic_vector(CCNTWIDTH-1 downto 0);
  signal InPort0xE    : std_logic;
  signal InPort1xE    : std_logic;
  signal OutPort0xE   : std_logic;
  signal OutPort1xE   : std_logic;

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : Engine
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC         => ClkxC,
      RstxRB        => RstxRB,
      ClrxABI       => ClrxAB,
      CExEI         => CExE,
      ConfigxI      => Cfg,
      ContextxSI    => ContextxS,
      CycleDnCntxDI => CycleDnCntxD,
      CycleUpCntxDI => CycleUpCntxD,
      InPort0xDI    => InPort0xD,
      InPort1xDI    => InPort1xD,
      OutPort0xDO   => OutPort0xD,
      OutPort1xDO   => OutPort1xD,
      InPort0xEO    => InPort0xE,
      InPort1xEO    => InPort1xE,
      OutPort0xEO   => OutPort0xE,
      OutPort1xEO   => OutPort1xE);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus  <= rst;
    Cfg       <= init_engineConfig;
    InPort0xD <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    InPort1xD <= std_logic_vector(to_unsigned(1, DATAWIDTH));

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    --------------------------------------------------------------------------
    -- TEST I/O PORT ENABLES
    --------------------------------------------------------------------------
    tbStatus                     <= ip0_en;
    Cfg.inport0Conf.LUT4FunctxD  <= X"FFFF";
    Cfg.inport1Conf.LUT4FunctxD  <= X"0000";
    Cfg.outport0Conf.LUT4FunctxD <= X"0000";
    Cfg.outport1Conf.LUT4FunctxD <= X"0000";
    wait for CLK_PERIOD;
    tbStatus                     <= ip1_en;
    Cfg.inport0Conf.LUT4FunctxD  <= X"0000";
    Cfg.inport1Conf.LUT4FunctxD  <= X"FFFF";
    Cfg.outport0Conf.LUT4FunctxD <= X"0000";
    Cfg.outport1Conf.LUT4FunctxD <= X"0000";
    wait for CLK_PERIOD;
    tbStatus                     <= op0_en;
    Cfg.inport0Conf.LUT4FunctxD  <= X"0000";
    Cfg.inport1Conf.LUT4FunctxD  <= X"0000";
    Cfg.outport0Conf.LUT4FunctxD <= X"FFFF";
    Cfg.outport1Conf.LUT4FunctxD <= X"0000";
    wait for CLK_PERIOD;
    tbStatus                     <= op1_en;
    Cfg.inport0Conf.LUT4FunctxD  <= X"0000";
    Cfg.inport1Conf.LUT4FunctxD  <= X"0000";
    Cfg.outport0Conf.LUT4FunctxD <= X"0000";
    Cfg.outport1Conf.LUT4FunctxD <= X"FFFF";
    wait for CLK_PERIOD;

    tbStatus  <= idle;
    Cfg       <= init_engineConfig;
    InPort0xD <= (others => '0');
    InPort1xD <= (others => '0');
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- EXPERIMENT 1
    --------------------------------------------------------------------------
    -- each cell passes its constant op (= cell no. +100) to its output
    -- engine outputs A0 and D1, resp.
    tbStatus <= pass_const;
    for r in 0 to N_ROWS-1 loop
      for c in 0 to N_COLS-1 loop
        Cfg.gridConf(r)(c).procConf.Op0MuxS   <= "10";
        Cfg.gridConf(r)(c).procConf.Op1MuxS   <= "00";
        Cfg.gridConf(r)(c).procConf.OutMuxS   <= '0';
        Cfg.gridConf(r)(c).procConf.AluOpxS   <= alu_pass0;
        Cfg.gridConf(r)(c).procConf.ConstOpxD <=
          std_logic_vector(to_unsigned(r*N_COLS+c+100, DATAWIDTH));
        Cfg.gridConf(r)(c).routConf.Route0MuxS <= O"0";
        Cfg.gridConf(r)(c).routConf.Route1MuxS <= O"0";
      end loop;  -- c
    end loop;  -- r
    Cfg.gridConf(1)(0).routConf.Tri0OExE <= '1';   -- B0 tristate output
    Cfg.gridConf(3)(1).routConf.Tri1OExE <= '1';   -- D1 tristate output
    Cfg.Out0MuxS                         <= O"2";  -- output B0 via HBus_BC0
    Cfg.Out1MuxS                         <= O"7";  -- output D1 via HBus_DA1
    wait for CLK_PERIOD;

    tbStatus  <= idle;
    Cfg       <= init_engineConfig;
    InPort0xD <= (others => '0');
    InPort1xD <= (others => '0');
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- EXPERIMENT 2
    --------------------------------------------------------------------------
    -- addition: C2 = B2 + B1 -> output 0
    tbStatus                               <= addu;
    -- config B2
    Cfg.gridConf(1)(2).procConf.Op0MuxS    <= "00";
    Cfg.gridConf(1)(2).procConf.AluOpxS    <= alu_pass0;
    Cfg.gridConf(1)(2).routConf.Route0MuxS <= "001";  -- HBus_AB1 (inport 1)
    Cfg.gridConf(1)(2).routConf.Tri0OExE   <= '0';
    Cfg.gridConf(1)(2).routConf.Tri1OExE   <= '0';
    Cfg.gridConf(1)(2).routConf.Tri2OExE   <= '0';
    -- config B1
    Cfg.gridConf(1)(1).procConf.Op0MuxS    <= "00";
    Cfg.gridConf(1)(1).procConf.AluOpxS    <= alu_pass0;
    Cfg.gridConf(1)(1).routConf.Route0MuxS <= "000";  -- HBus_AB0 (inport 0)
    Cfg.gridConf(1)(1).routConf.Tri0OExE   <= '0';
    Cfg.gridConf(1)(1).routConf.Tri1OExE   <= '1';    -- HBus_BC1 (outport 1)
    Cfg.gridConf(1)(1).routConf.Tri2OExE   <= '0';
    -- config C2
    Cfg.gridConf(2)(2).procConf.Op0MuxS    <= "00";   -- input
    Cfg.gridConf(2)(2).procConf.Op0MuxS    <= "00";   -- input
    Cfg.gridConf(2)(2).procConf.AluOpxS    <= alu_addu;
    Cfg.gridConf(2)(2).routConf.Route0MuxS <= "110";  -- north neighbour
    Cfg.gridConf(2)(2).routConf.Route1MuxS <= "101";  -- NE neighbour
    Cfg.gridConf(2)(2).routConf.Tri0OExE   <= '1';    -- HBus_CD0 (outport 0)
    Cfg.gridConf(2)(2).routConf.Tri1OExE   <= '0';
    Cfg.gridConf(2)(2).routConf.Tri2OExE   <= '0';
    -- engine input
    Cfg.Inp0OExE(2)                        <= '1';    -- HBus_AB0
    Cfg.Inp1OExE(3)                        <= '1';    -- HBus_AB1
    -- engine output
    Cfg.Out0MuxS                           <= O"4";   -- output C2 via HBus_CD0
    Cfg.Out1MuxS                           <= O"3";   -- output B1 via HBus_BC1

    -- inputs
    InPort0xD <= std_logic_vector(to_unsigned(22, DATAWIDTH));
    InPort1xD <= std_logic_vector(to_unsigned(33, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(3, DATAWIDTH));
    InPort1xD <= std_logic_vector(to_unsigned(14, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(15, DATAWIDTH));
    InPort1xD <= std_logic_vector(to_unsigned(22, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus  <= idle;
    Cfg       <= init_engineConfig;
    InPort0xD <= (others => '0');
    InPort1xD <= (others => '0');
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- EXPERIMENT 3
    --------------------------------------------------------------------------
    -- 4-tap FIR filter
    tbStatus  <= fir4shft_cfg;
    Cfg       <= fir4shift;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD;

    -- EXPERIMENT 3A ---------------------------------------------------------
    -- 4-tap FIR filter: pulse response
    tbStatus  <= fir4shft_pulse;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*6;

    -- EXPERIMENT 3B ---------------------------------------------------------
    -- 4-tap FIR filter: square response
    tbStatus  <= fir4shft_square;
    -- inputs
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*6;

    -- EXPERIMENT 3C ---------------------------------------------------------
    -- 4-tap FIR filter: inputs
    tbStatus  <= fir4shft_inputs;
    -- inputs
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(36, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(44, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(32, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(48, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*6;

    tbStatus  <= idle;
    Cfg       <= init_engineConfig;
    InPort0xD <= (others => '0');
    InPort1xD <= (others => '0');
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- EXPERIMENT 4
    --------------------------------------------------------------------------
    -- 8-tap FIR filter
    tbStatus  <= fir8shft_cfg;
    Cfg       <= fir8shift;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD;

    -- EXPERIMENT 4A ---------------------------------------------------------
    -- 8-tap FIR filter: pulse response
    tbStatus  <= fir8shft_pulse;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*9;

    -- EXPERIMENT 4B ---------------------------------------------------------
    -- 8-tap FIR filter: square response
    tbStatus  <= fir8shft_square;
    -- inputs
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*10;

    -- EXPERIMENT 4C ---------------------------------------------------------
    -- 8-tap FIR filter: inputs
    tbStatus  <= fir8shft_inputs;
    -- inputs
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(72, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(88, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(64, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(96, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(88, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(72, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(72, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(88, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(64, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(96, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(88, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(72, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(80, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*9;

    tbStatus  <= idle;
    Cfg       <= init_engineConfig;
    InPort0xD <= (others => '0');
    InPort1xD <= (others => '0');
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- EXPERIMENT 5
    --------------------------------------------------------------------------
    -- 4-tap FIR filter (with arbitrary coefficients)
    tbStatus  <= fir4mult_cfg;
    Cfg       <= fir4mult((2, -2, -1, 1));
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD;

    -- EXPERIMENT 5A ---------------------------------------------------------
    -- 4-tap FIR filter: pulse response
    tbStatus  <= fir4mult_pulse;
    InPort0xD <= std_logic_vector(to_signed(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*6;

    -- EXPERIMENT 5B ---------------------------------------------------------
    -- 4-tap FIR filter: square response
    tbStatus  <= fir4mult_square;
    -- inputs
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*6;

    tbStatus  <= idle;
    Cfg       <= init_engineConfig;
    InPort0xD <= (others => '0');
    InPort1xD <= (others => '0');
    wait for CLK_PERIOD;

    --------------------------------------------------------------------------
    -- EXPERIMENT 6
    --------------------------------------------------------------------------
    -- 8-tap FIR filter (with arbitrary coefficients)
    tbStatus  <= fir8mult_cfg;
    Cfg       <= fir8mult((-1, 1, 4, 8, 8, 4, 1, -1));
    -- Cfg       <= fir8mult((-18979, 12237, 76169, 131070, 131070, 76169, 12237, -18979));
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD;

    -- EXPERIMENT 6A ---------------------------------------------------------
    -- 8-tap FIR filter: pulse response
    tbStatus  <= fir8mult_pulse;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*10;

    -- EXPERIMENT 6B ---------------------------------------------------------
    -- 8-tap FIR filter: square response
    tbStatus  <= fir8mult_square;
    -- inputs
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*10;

    -- EXPERIMENT 6C ---------------------------------------------------------
    -- 8-tap FIR filter: inputs
    tbStatus  <= fir8mult_inputs;
    -- inputs
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(2, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(4, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(3, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(2, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(5, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(2, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(1, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(4, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(4, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(3, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(5, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(2, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= std_logic_vector(to_signed(3, DATAWIDTH));
    wait for CLK_PERIOD;
    InPort0xD <= (others => '0');
    wait for CLK_PERIOD*10;

    tbStatus  <= done;
    Cfg       <= init_engineConfig;
    InPort0xD <= (others => '0');
    InPort1xD <= (others => '0');
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
