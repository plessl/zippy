library ieee;
use ieee.std_logic_1164.all;
use work.AuxPkg.all;
use work.ComponentsPkg.all;

entity tb_Pull is
end tb_Pull;

architecture arch of tb_Pull is

  constant WIDTH : integer := 8;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, pull_up, pull_down, partbus);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data/control signals
  signal ModexS : std_logic;
  signal BusxZ  : std_logic_vector(WIDTH-1 downto 0) := (others => 'Z');

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : PullBus
    generic map (
      WIDTH => WIDTH)
    port map (
      ModexSI => ModexS,
      BusxZO  => BusxZ);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    ModexS <= '0';
    BusxZ <= (others => 'Z');

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= pull_up;
    ModexS <= '1';
    wait for CLK_PERIOD;

    tbStatus <= pull_down;
    ModexS <= '0';
    wait for CLK_PERIOD;

    tbStatus <= partbus;
    BusxZ <= (5 downto 4 => '1', 2 downto 1 => '0', others => 'Z');
    wait for CLK_PERIOD;

    tbStatus <= idle;
    ModexS <= '0';
    BusxZ <= (others => 'Z');
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
