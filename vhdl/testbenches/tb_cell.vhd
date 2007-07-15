library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;

entity tb_Cell is
end tb_Cell;

architecture arch of tb_Cell is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, add, shift);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal ClrxAB    : std_logic                               := '1';
  signal CExE      : std_logic                               := '1';
  signal Cfg       : cellConfigRec;
  signal ContextxS : std_logic_vector(CNTXTWIDTH-1 downto 0) := (others => '0');
  signal In0xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In1xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In2xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In3xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In4xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In5xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In6xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In7xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal OutxD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal Out0xZ    : std_logic_vector(DATAWIDTH-1 downto 0);
  signal Out1xZ    : std_logic_vector(DATAWIDTH-1 downto 0);
  signal Out2xZ    : std_logic_vector(DATAWIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : Cell
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC      => ClkxC,
      RstxRB     => RstxRB,
      ClrxABI    => ClrxAB,
      CExEI      => CExE,
      ConfigxI   => Cfg,
      ContextxSI => ContextxS,
      In0xDI     => In0xD,
      In1xDI     => In1xD,
      In2xDI     => In2xD,
      In3xDI     => In3xD,
      In4xDI     => In4xD,
      In5xDI     => In5xD,
      In6xDI     => In6xD,
      In7xDI     => In7xD,
      OutxDO     => OutxD,
      Out0xZO    => Out0xZ,
      Out1xZO    => Out1xZ,
      Out2xZO    => Out2xZ);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb
    
    In0xD <= std_logic_vector(to_unsigned(01, DATAWIDTH));
    In1xD <= std_logic_vector(to_unsigned(10, DATAWIDTH));
    In2xD <= std_logic_vector(to_unsigned(20, DATAWIDTH));
    In3xD <= std_logic_vector(to_unsigned(30, DATAWIDTH));
    In4xD <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    In5xD <= std_logic_vector(to_unsigned(50, DATAWIDTH));
    In6xD <= std_logic_vector(to_unsigned(60, DATAWIDTH));
    In7xD <= std_logic_vector(to_unsigned(70, DATAWIDTH));

    tbStatus <= rst;
    Cfg      <= init_cellConfig;

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus                <= add;
    Cfg.routConf.Route0MuxS <= "011";
    Cfg.routConf.Route1MuxS <= "110";
    Cfg.routConf.Tri0OExE   <= '1';
    Cfg.routConf.Tri1OExE   <= '1';
    Cfg.routConf.Tri2OExE   <= '1';
    Cfg.procConf.Op0MuxS    <= "00";
    Cfg.procConf.Op1MuxS    <= "00";
    Cfg.procConf.OutMuxS    <= '0';
    Cfg.procConf.AluOpxS    <= alu_addu;
    Cfg.procConf.ConstOpxD  <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_cellConfig;
    wait for CLK_PERIOD;

    tbStatus                <= shift;
    Cfg.routConf.Route0MuxS <= "010";
    Cfg.routConf.Route1MuxS <= "000";
    Cfg.routConf.Tri0OExE   <= '1';
    Cfg.routConf.Tri1OExE   <= '0';
    Cfg.routConf.Tri2OExE   <= '1';
    Cfg.procConf.Op0MuxS    <= "00";
    Cfg.procConf.Op1MuxS    <= "10";
    Cfg.procConf.OutMuxS    <= '0';
    Cfg.procConf.AluOpxS    <= alu_sll;
    Cfg.procConf.ConstOpxD  <= std_logic_vector(to_unsigned(2, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_cellConfig;
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
