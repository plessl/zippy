library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_UpCounter is
end tb_UpCounter;

architecture arch of tb_UpCounter is

  constant WIDTH : integer := 8;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done, load, count);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- data/control signals
  signal LoadxE : std_logic;
  signal CExE   : std_logic;
  signal CinxD  : std_logic_vector(WIDTH-1 downto 0);
  signal CoutxD : std_logic_vector(WIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut: UpCounter
    generic map (
      WIDTH => WIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      LoadxEI => LoadxE,
      CExEI   => CExE,
      CinxDI  => CinxD,
      CoutxDO => CoutxD);
  
  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    LoadxE   <= '0';
    CExE     <= '0';
    CinxD    <= (others => '0');

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= load;                   -- load start value
    LoadxE   <= '1';
    CinxD    <= std_logic_vector(to_unsigned(2, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    LoadxE   <= '0';
    CExE     <= '0';
    CinxD    <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= count;                  -- count
    CExE     <= '1';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    LoadxE   <= '0';
    CExE     <= '0';
    CinxD    <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= load;                   -- load start value
    LoadxE   <= '1';
    CExE     <= '0';
    CinxD    <= std_logic_vector(to_unsigned(5, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;                   -- idle
    LoadxE   <= '0';
    CExE     <= '0';
    CinxD    <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= count;                  -- count
    CExE     <= '1';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= done;                   -- done
    LoadxE   <= '0';
    CExE     <= '0';
    CinxD    <= (others => '0');
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
