------------------------------------------------------------------------------
-- Context register file
--
-- Project     : 
-- File        : contextregfile.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003/03/06
-- Last changed: $LastChangedDate: 2005-01-13 18:02:10 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- generates the register file that holds the state of a context. Used
-- in the processing element.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-06 CP added documentation
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsPkg.all;
use work.auxPkg.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;

entity ContextRegFile is

  port (
    ClkxC         : in  std_logic;
    RstxRB        : in  std_logic;
    ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    ClrContextxEI : in  std_logic;
    ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    EnxEI         : in  std_logic;
    DinxDI        : in  data_word;
    DoutxDO       : out data_word);

end ContextRegFile;


architecture simple of ContextRegFile is

  signal Clr  : std_logic_vector(N_CONTEXTS-1 downto 0);
  signal En   : std_logic_vector(N_CONTEXTS-1 downto 0);
  signal Dout : data_vector(N_CONTEXTS-1 downto 0);

begin  -- simple

  Regs : for i in N_CONTEXTS-1 downto 0 generate
    Reg_i : Reg_Clr_En
      generic map (
        WIDTH => DATAWIDTH)
      port map (
        ClkxC   => ClkxC,
        RstxRB  => RstxRB,
        ClrxEI  => Clr(i),
        EnxEI   => En(i),
        DinxDI  => DinxDI,
        DoutxDO => Dout(i));
  end generate Regs;

  -- FIXME: this can be written more elegantly
  
  ClrDemux : process (ClrContextxSI, ClrContextxEI)
  begin
    for i in N_CONTEXTS-1 downto 0 loop
      Clr(i) <= '0';
    end loop;  -- i
    Clr(to_integer(unsigned(ClrContextxSI))) <= ClrContextxEI;
  end process ClrDemux;

  EnDemux : process (ContextxSI, EnxEI)
  begin
    for i in N_CONTEXTS-1 downto 0 loop
      En(i) <= '0';
    end loop;  -- i
    En(to_integer(unsigned(ContextxSI))) <= EnxEI;
  end process EnDemux;

  -- out mux
  DoutxDO <= Dout(to_integer(unsigned(ContextxSI)));
  
end simple;
