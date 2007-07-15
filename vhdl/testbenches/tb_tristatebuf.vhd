library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ComponentsPkg.all;

entity tb_TristateBuf is
end tb_TristateBuf;

architecture arch of tb_TristateBuf is

  constant WIDTH : integer := 8;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done, enable, disable);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data signals
  signal InxD  : std_logic_vector(WIDTH-1 downto 0);
  signal OExE  : std_logic;
  signal OutxZ : std_logic_vector(WIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : TristateBuf
    generic map (
      WIDTH => WIDTH)
    port map (
      InxDI  => InxD,
      OExEI  => OExE,
      OutxZO => OutxZ);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    InxD     <= (others => '0');
    OExE     <= '0';

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    InxD     <= std_logic_vector(to_unsigned(111, WIDTH));
    tbStatus <= enable;
    OExE     <= '1';
    wait for CLK_PERIOD;
    tbStatus <= disable;
    OExE     <= '0';
    wait for CLK_PERIOD;

    InxD     <= std_logic_vector(to_unsigned(33, WIDTH));
    tbStatus <= enable;
    OExE     <= '1';
    wait for CLK_PERIOD;
    tbStatus <= disable;
    OExE     <= '0';
    wait for CLK_PERIOD;

    tbStatus <= idle;
    InxD     <= (others => '0');
    OExE     <= '0';
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
