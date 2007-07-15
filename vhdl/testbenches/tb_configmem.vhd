library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;
use work.ComponentsPkg.all;

entity tb_ConfigMem is
end tb_ConfigMem;

architecture arch of tb_ConfigMem is

  -- constants
  constant CFGWIDTH : integer := ENGN_CFGLEN;
  constant PTRWIDTH : integer := 10;    -- 2**PTRWIDTH > CFGWIDTH
  constant SLCWIDTH : integer := 8;

  constant N_SLICES : integer := (CFGWIDTH-1)/SLCWIDTH+1;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done, write_slice, load_memptr);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data signals
  signal WExE           : std_logic;
  signal CfgSlicexD     : std_logic_vector(SLCWIDTH-1 downto 0);
  signal LoadSlicePtrxE : std_logic;
  signal SlicePtrxD     : std_logic_vector(PTRWIDTH-1 downto 0);
  signal ConfigWordxD   : std_logic_vector(CFGWIDTH-1 downto 0);
  signal ConfigWord     : engineConfigRec;

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : ConfigMem
    generic map (
      CFGWIDTH => CFGWIDTH,
      PTRWIDTH => PTRWIDTH,
      SLCWIDTH => SLCWIDTH)
    port map (
      ClkxC           => ClkxC,
      RstxRB          => RstxRB,
      WExEI           => WExE,
      CfgSlicexDI     => CfgSlicexD,
      LoadSlicePtrxEI => LoadSlicePtrxE,
      SlicePtrxDI     => SlicePtrxD,
      ConfigWordxDO   => ConfigWordxD);

  ----------------------------------------------------------------------------
  -- configuration conversion to record (for test purposes)
  ----------------------------------------------------------------------------
  ConfigWord <= to_engineConfig_rec(ConfigWordxD);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus       <= rst;
    WExE           <= '0';
    CfgSlicexD     <= (others => '0');
    LoadSlicePtrxE <= '0';
    SlicePtrxD     <= (others => '0');

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus   <= write_slice;
    WExE       <= '1';
    CfgSlicexD <= std_logic_vector(to_unsigned(254, SLCWIDTH));
    wait for CLK_PERIOD;
    WExE       <= '0';
    wait for CLK_PERIOD;

    tbStatus       <= idle;
    WExE           <= '0';
    CfgSlicexD     <= (others => '0');
    LoadSlicePtrxE <= '0';
    SlicePtrxD     <= (others => '0');
    wait for CLK_PERIOD;

    tbStatus   <= write_slice;
    WExE       <= '1';
    CfgSlicexD <= std_logic_vector(to_unsigned(254, SLCWIDTH));
    wait for CLK_PERIOD;
    WExE       <= '0';
    wait for CLK_PERIOD;

    tbStatus       <= idle;
    WExE           <= '0';
    CfgSlicexD     <= (others => '0');
    LoadSlicePtrxE <= '0';
    SlicePtrxD     <= (others => '0');
    wait for CLK_PERIOD;

    tbStatus   <= write_slice;
    WExE       <= '1';
    CfgSlicexD <= std_logic_vector(to_unsigned(254, SLCWIDTH));
    wait for CLK_PERIOD;
    for i in 4 to N_SLICES+2 loop
      wait for CLK_PERIOD;
    end loop;  -- i

    tbStatus       <= idle;
    WExE           <= '0';
    CfgSlicexD     <= (others => '0');
    LoadSlicePtrxE <= '0';
    SlicePtrxD     <= (others => '0');
    wait for CLK_PERIOD;

    tbStatus       <= load_memptr;
    LoadSlicePtrxE <= '1';
    SlicePtrxD     <= std_logic_vector(to_unsigned(3, PTRWIDTH));

    tbStatus       <= done;
    WExE           <= '0';
    CfgSlicexD     <= (others => '0');
    LoadSlicePtrxE <= '0';
    SlicePtrxD     <= (others => '0');
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
