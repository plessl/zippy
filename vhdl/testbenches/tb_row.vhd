library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;

entity tb_Row is
end tb_Row;

architecture arch of tb_Row is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, cell0_sll, cell1_sll, cell2_sll,
                        cell3_sll);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal ClrxAB    : std_logic                               := '1';
  signal CExE      : std_logic                               := '1';
  signal Cfg       : rowConfigArray;
  signal ContextxS : std_logic_vector(CNTXTWIDTH-1 downto 0) := (others => '0');
  signal Input     : rowInputArray;
  signal Output    : rowOutputArray;

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : Row
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC      => ClkxC,
      RstxRB     => RstxRB,
      ClrxABI    => ClrxAB,
      CExEI      => CExE,
      ConfigxI   => Cfg,
      ContextxSI => ContextxS,
      InpxI      => Input,
      OutxO      => Output);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    Cfg      <= init_rowConfig;
    Input    <= init_rowInput;

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    -- cell0: shift (SSL) by constant operator (=3)
    tbStatus                  <= cell0_sll;
    Cfg(0).procConf.AluOpxS   <= alu_sll;
    Cfg(0).procConf.Op1MuxS   <= "10";
    Cfg(0).procConf.ConstOpxD <= std_logic_vector(to_unsigned(3, DATAWIDTH));
    Cfg(0).routConf.Tri0OExE  <= '1';
    Cfg(0).routConf.Tri1OExE  <= '1';
    Cfg(0).routConf.Tri2OExE  <= '1';
    Input(0).In0xD            <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_rowConfig;
    Input    <= init_rowInput;
    wait for CLK_PERIOD;

    -- cell1:  shift (SSL) by constant operator (=4)
    tbStatus                  <= cell1_sll;
    Cfg(1).procConf.AluOpxS   <= alu_sll;
    Cfg(1).procConf.Op1MuxS   <= "10";
    Cfg(1).procConf.ConstOpxD <= std_logic_vector(to_unsigned(4, DATAWIDTH));
    Cfg(1).routConf.Tri0OExE  <= '1';
    Cfg(1).routConf.Tri1OExE  <= '1';
    Cfg(1).routConf.Tri2OExE  <= '1';
    Input(1).In0xD            <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_rowConfig;
    Input    <= init_rowInput;
    wait for CLK_PERIOD;

    -- cell2: shift (SSL) by constant operator (=5)
    tbStatus                  <= cell2_sll;
    Cfg(2).procConf.AluOpxS   <= alu_sll;
    Cfg(2).procConf.Op1MuxS   <= "10";
    Cfg(2).procConf.ConstOpxD <= std_logic_vector(to_unsigned(5, DATAWIDTH));
    Cfg(2).routConf.Tri0OExE  <= '1';
    Cfg(2).routConf.Tri1OExE  <= '1';
    Cfg(2).routConf.Tri2OExE  <= '1';
    Input(2).In0xD            <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_rowConfig;
    Input    <= init_rowInput;
    wait for CLK_PERIOD;

    -- cell3: shift (SSL) by constant operator (=6)
    tbStatus                  <= cell3_sll;
    Cfg(3).procConf.AluOpxS   <= alu_sll;
    Cfg(3).procConf.Op1MuxS   <= "10";
    Cfg(3).procConf.ConstOpxD <= std_logic_vector(to_unsigned(6, DATAWIDTH));
    Cfg(3).routConf.Tri0OExE  <= '1';
    Cfg(3).routConf.Tri1OExE  <= '1';
    Cfg(3).routConf.Tri2OExE  <= '1';
    Input(3).In0xD            <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_rowConfig;
    Input    <= init_rowInput;
    wait for CLK_PERIOD*2;

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
