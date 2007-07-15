------------------------------------------------------------------------------
-- Testbench for contextregfile.vhd
--
-- Project    : 
-- File       : tb_contextregfile.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/03/06
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_ContextRegFile is
end tb_ContextRegFile;


architecture arch of tb_ContextRegFile is

  constant NCONTEXTS : integer := 8;
  constant WIDTH     : integer := 16;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done, reg1, clr3, wrall, rdall, clrall);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal ClrContextxSI : std_logic_vector(log2(NCONTEXTS)-1 downto 0);
  signal ClrContextxEI : std_logic;
  signal ContextxSI    : std_logic_vector(log2(NCONTEXTS)-1 downto 0);
  signal EnxEI         : std_logic;
  signal DinxDI        : std_logic_vector(WIDTH-1 downto 0);
  signal DoutxDO       : std_logic_vector(WIDTH-1 downto 0);
  
begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : ContextRegFile
    generic map (
      NCONTEXTS => NCONTEXTS,
      WIDTH     => WIDTH)
    port map (
      ClkxC         => ClkxC,
      RstxRB        => RstxRB,
      ClrContextxSI => ClrContextxSI,
      ClrContextxEI => ClrContextxEI,
      ContextxSI    => ContextxSI,
      EnxEI         => EnxEI,
      DinxDI        => DinxDI,
      DoutxDO       => DoutxDO);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    procedure init_stimuli (
      signal ClrContextxSI : out std_logic_vector(log2(NCONTEXTS)-1 downto 0);
      signal ClrContextxEI : out std_logic;
      signal ContextxSI    : out std_logic_vector(log2(NCONTEXTS)-1 downto 0);
      signal EnxEI         : out std_logic;
      signal DinxDI        : out std_logic_vector(WIDTH-1 downto 0)) is
    begin
      ClrContextxSI <= (others => '0');
      ClrContextxEI <= '0';
      ContextxSI    <= (others => '0');
      EnxEI         <= '0';
      DinxDI        <= (others => '0');
    end init_stimuli;

  begin  -- process stimuliTb

    tbStatus <= rst;
    init_stimuli(ClrContextxSI, ClrContextxEI, ContextxSI, EnxEI, DinxDI);

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    -- enable and disable register 1
    tbStatus   <= reg1;
    ContextxSI <= std_logic_vector(to_unsigned(1, log2(NCONTEXTS)));
    EnxEI      <= '1';
    DinxDI     <= std_logic_vector(to_unsigned(11, WIDTH));
    wait for CLK_PERIOD;
    EnxEI      <= '0';
    DinxDI     <= std_logic_vector(to_unsigned(12, WIDTH));
    wait for CLK_PERIOD;
    EnxEI      <= '1';
    DinxDI     <= std_logic_vector(to_unsigned(13, WIDTH));
    wait for CLK_PERIOD;
    EnxEI      <= '0';
    DinxDI     <= std_logic_vector(to_unsigned(14, WIDTH));
    wait for CLK_PERIOD;
    EnxEI      <= '1';
    DinxDI     <= std_logic_vector(to_unsigned(15, WIDTH));
    wait for CLK_PERIOD;

    EnxEI  <= '1';
    DinxDI <= std_logic_vector(to_unsigned(0, WIDTH));
    wait for CLK_PERIOD;


    tbStatus <= idle;
    init_stimuli(ClrContextxSI, ClrContextxEI, ContextxSI, EnxEI, DinxDI);
    wait for CLK_PERIOD;

    -- write all
    tbStatus <= wrall;
    for c in 0 to NCONTEXTS-1 loop
      ContextxSI <= std_logic_vector(to_unsigned(c, log2(NCONTEXTS)));
      EnxEI      <= '1';
      DinxDI     <= std_logic_vector(to_unsigned(c+10, WIDTH));
      wait for CLK_PERIOD;
    end loop;  -- c

    tbStatus <= idle;
    init_stimuli(ClrContextxSI, ClrContextxEI, ContextxSI, EnxEI, DinxDI);
    wait for CLK_PERIOD;

    -- read all
    tbStatus <= rdall;
    for c in 0 to NCONTEXTS-1 loop
      ContextxSI <= std_logic_vector(to_unsigned(c, log2(NCONTEXTS)));
      wait for CLK_PERIOD;
    end loop;  -- c

    tbStatus <= idle;
    init_stimuli(ClrContextxSI, ClrContextxEI, ContextxSI, EnxEI, DinxDI);
    wait for CLK_PERIOD;

    -- clear register 3
    tbstatus      <= clr3;
    ContextxSI    <= std_logic_vector(to_unsigned(3, log2(NCONTEXTS)));
    ClrContextxSI <= std_logic_vector(to_unsigned(3, log2(NCONTEXTS)));
    ClrContextxEI <= '1';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ClrContextxSI, ClrContextxEI, ContextxSI, EnxEI, DinxDI);
    wait for CLK_PERIOD;

    -- clear all
    tbstatus <= clrall;
    for c in 0 to NCONTEXTS-1 loop
      ClrContextxSI <= std_logic_vector(to_unsigned(c, log2(NCONTEXTS)));
      ClrContextxEI <= '1';
      wait for CLK_PERIOD;
    end loop;  -- c

    -- read all
    tbStatus <= rdall;
    for c in 0 to NCONTEXTS-1 loop
      ContextxSI <= std_logic_vector(to_unsigned(c, log2(NCONTEXTS)));
      wait for CLK_PERIOD;
    end loop;  -- c

    tbStatus <= idle;
    init_stimuli(ClrContextxSI, ClrContextxEI, ContextxSI, EnxEI, DinxDI);
    wait for CLK_PERIOD;

    tbStatus <= done;
    init_stimuli(ClrContextxSI, ClrContextxEI, ContextxSI, EnxEI, DinxDI);
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
