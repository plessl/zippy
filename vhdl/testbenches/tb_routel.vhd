library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;

entity tb_RoutEl is
end tb_RoutEl;

architecture arch of tb_RoutEl is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, inmux0, inmux1, outdirect,
                        outtri0, outtri1, outtri2);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data signals
  signal Cfg         : routConfigRec;
  signal In0xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In1xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In2xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In3xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In4xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In5xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In6xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In7xD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal OutxD       : std_logic_vector(DATAWIDTH-1 downto 0);
  signal Out0xZ      : std_logic_vector(DATAWIDTH-1 downto 0);
  signal Out1xZ      : std_logic_vector(DATAWIDTH-1 downto 0);
  signal Out2xZ      : std_logic_vector(DATAWIDTH-1 downto 0);
  signal ProcElIn0xD : std_logic_vector(DATAWIDTH-1 downto 0);
  signal ProcElIn1xD : std_logic_vector(DATAWIDTH-1 downto 0);
  signal ProcElOutxD : std_logic_vector(DATAWIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : RoutEl
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC        => ClkxC,
      RstxRB       => RstxRB,
      ConfigxI     => Cfg,
      In0xDI       => In0xD,
      In1xDI       => In1xD,
      In2xDI       => In2xD,
      In3xDI       => In3xD,
      In4xDI       => In4xD,
      In5xDI       => In5xD,
      In6xDI       => In6xD,
      In7xDI       => In7xD,
      OutxDO       => OutxD,
      Out0xZO      => Out0xZ,
      Out1xZO      => Out1xZ,
      Out2xZO      => Out2xZ,
      ProcElIn0xDO => ProcElIn0xD,
      ProcElIn1xDO => ProcElIn1xD,
      ProcElOutxDI => ProcElOutxD);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    In0xD       <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(10, DATAWIDTH));
    In2xD       <= std_logic_vector(to_unsigned(20, DATAWIDTH));
    In3xD       <= std_logic_vector(to_unsigned(30, DATAWIDTH));
    In4xD       <= std_logic_vector(to_unsigned(40, DATAWIDTH));
    In5xD       <= std_logic_vector(to_unsigned(50, DATAWIDTH));
    In6xD       <= std_logic_vector(to_unsigned(60, DATAWIDTH));
    In7xD       <= std_logic_vector(to_unsigned(70, DATAWIDTH));
    ProcElOutxD <= std_logic_vector(to_unsigned(0, DATAWIDTH));

    tbStatus <= rst;
    Cfg      <= init_routConfig;

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus       <= inmux0;           -- test in mux 0
    Cfg.Route0MuxS <= "000";
    wait for CLK_PERIOD;
    Cfg.Route0MuxS <= "001";
    wait for CLK_PERIOD;
    Cfg.Route0MuxS <= "010";
    wait for CLK_PERIOD;
    Cfg.Route0MuxS <= "011";
    wait for CLK_PERIOD;
    Cfg.Route0MuxS <= "100";
    wait for CLK_PERIOD;
    Cfg.Route0MuxS <= "101";
    wait for CLK_PERIOD;
    Cfg.Route0MuxS <= "110";
    wait for CLK_PERIOD;
    Cfg.Route0MuxS <= "111";
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_routConfig;
    wait for CLK_PERIOD;

    tbStatus       <= inmux1;           -- test in mux 1
    Cfg.Route1MuxS <= "000";
    wait for CLK_PERIOD;
    Cfg.Route1MuxS <= "001";
    wait for CLK_PERIOD;
    Cfg.Route1MuxS <= "010";
    wait for CLK_PERIOD;
    Cfg.Route1MuxS <= "011";
    wait for CLK_PERIOD;
    Cfg.Route1MuxS <= "100";
    wait for CLK_PERIOD;
    Cfg.Route1MuxS <= "101";
    wait for CLK_PERIOD;
    Cfg.Route1MuxS <= "110";
    wait for CLK_PERIOD;
    Cfg.Route1MuxS <= "111";
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_routConfig;
    wait for CLK_PERIOD;

    tbStatus    <= outdirect;           -- test out
    ProcElOutxD <= std_logic_vector(to_unsigned(11, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD <= std_logic_vector(to_unsigned(22, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD <= std_logic_vector(to_unsigned(33, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD <= std_logic_vector(to_unsigned(44, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus    <= idle;
    Cfg         <= init_routConfig;
    ProcElOutxD <= (others => '0');
    wait for CLK_PERIOD;

    tbStatus     <= outtri0;            -- test out tristate 0
    Cfg.Tri0OExE <= '1';
    ProcElOutxD  <= std_logic_vector(to_unsigned(11, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD  <= std_logic_vector(to_unsigned(22, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD  <= std_logic_vector(to_unsigned(33, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus    <= idle;
    Cfg         <= init_routConfig;
    ProcElOutxD <= (others => '0');
    wait for CLK_PERIOD;

    tbStatus     <= outtri1;            -- test out tristate 1
    Cfg.Tri1OExE <= '1';
    ProcElOutxD  <= std_logic_vector(to_unsigned(11, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD  <= std_logic_vector(to_unsigned(22, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD  <= std_logic_vector(to_unsigned(33, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus    <= idle;
    Cfg         <= init_routConfig;
    ProcElOutxD <= (others => '0');
    wait for CLK_PERIOD;

    tbStatus     <= outtri2;            -- test out tristate 2
    Cfg.Tri2OExE <= '1';
    ProcElOutxD  <= std_logic_vector(to_unsigned(11, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD  <= std_logic_vector(to_unsigned(22, DATAWIDTH));
    wait for CLK_PERIOD;
    ProcElOutxD  <= std_logic_vector(to_unsigned(33, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus    <= idle;
    Cfg         <= init_routConfig;
    ProcElOutxD <= (others => '0');
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
