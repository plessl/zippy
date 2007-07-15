------------------------------------------------------------------------------
-- Testbench for reg_aclr_en.vhd
--
-- Project    : 
-- File       : tb_reg_aclr_en.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2003/03/05
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;

entity tb_Reg_aclr_en is
end tb_Reg_aclr_en;


architecture arch of tb_Reg_aclr_en is

  constant WIDTH : integer := 8;

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type   tbstatusType is (rst, idle, done, en, dis, clr, clr_en);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal ClrxAB : std_logic;
  signal EnxE   : std_logic;
  signal DinxD  : std_logic_vector(WIDTH-1 downto 0);
  signal DoutxD : std_logic_vector(WIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : Reg_AClr_En
    generic map (
      WIDTH => WIDTH)
    port map (
      ClkxC   => ClkxC,
      RstxRB  => RstxRB,
      ClrxABI => ClrxAB,
      EnxEI   => EnxE,
      DinxDI  => DinxD,
      DoutxDO => DoutxD);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    ClrxAB   <= '1';
    EnxE     <= '0';
    DinxD    <= std_logic_vector(to_unsigned(0, WIDTH));

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus <= en;
    ClrxAB   <= '1';
    EnxE     <= '1';
    DinxD    <= std_logic_vector(to_unsigned(1, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= dis;
    ClrxAB   <= '1';
    EnxE     <= '0';
    DinxD    <= std_logic_vector(to_unsigned(2, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= en;
    ClrxAB   <= '1';
    EnxE     <= '1';
    DinxD    <= std_logic_vector(to_unsigned(3, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= dis;
    ClrxAB   <= '1';
    EnxE     <= '0';
    DinxD    <= std_logic_vector(to_unsigned(4, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= clr;
    ClrxAB   <= '0';
    EnxE     <= '0';
    DinxD    <= (others => '0');
    wait for CLK_PERIOD;

    tbStatus <= en;
    ClrxAB   <= '1';
    EnxE     <= '1';
    DinxD    <= std_logic_vector(to_unsigned(5, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= dis;
    ClrxAB   <= '1';
    EnxE     <= '0';
    DinxD    <= std_logic_vector(to_unsigned(6, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= clr_en;
    ClrxAB   <= '0';
    EnxE     <= '1';
    DinxD    <= std_logic_vector(to_unsigned(7, WIDTH));
    wait for CLK_PERIOD;

    tbStatus <= done;
    ClrxAB   <= '1';
    EnxE     <= '0';
    DinxD    <= (others => '0');
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
