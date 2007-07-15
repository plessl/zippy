------------------------------------------------------------------------------
-- FIFO controller
--
-- Project     : 
-- File        : $URL: svn+ssh://plessl@yosemite.ethz.ch/home/plessl/SVN/simzippy/trunk/vhdl/fifoctrl.vhd $
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2003/01/17
-- $Id: fifoctrl.vhd 241 2005-04-07 08:50:55Z plessl $
------------------------------------------------------------------------------
-- FIFO controller: The controller arbitrates the access to the FIFO
-- between the engine. The engine is given priority over the FIFO access.
--
-- Whenever the engine is running (RunningxSI = 1) the engine can issue a FIFO
-- read or write request EngInPortxEI/EngOutPortxEI).
-- FIXME: Signal names are confusing, rename
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

entity FifoCtrl is
  
  port (
    RunningxSI    : in  std_logic;
    EngInPortxEI  : in  std_logic;
    EngOutPortxEI : in  std_logic;
    DecFifoWExEI  : in  std_logic;
    DecFifoRExEI  : in  std_logic;
    FifoMuxSO     : out std_logic;
    FifoWExEO     : out std_logic;
    FifoRExEO     : out std_logic);

end FifoCtrl;


architecture simple of FifoCtrl is

  signal EngWriteReqxS : std_logic;
  signal EngReadReqxS  : std_logic;
  signal IFWriteReqxS  : std_logic;
  signal IFReadReqxS   : std_logic;
  
begin  -- simple

  EngWriteReqxS <= RunningxSI and EngOutPortxEI;
  EngReadReqxS  <= RunningxSI and EngInPortxEI;

  IFWriteReqxS <= DecFifoWExEI;
  IFReadReqxS  <= DecFifoRExEI;

  FifoMux : process (EngWriteReqxS)
  begin
    -- always interface write unless engine write request;
    -- engine write is priorized over interface write
    if (EngWriteReqxS = '1') then
      FifoMuxSO <= '1';
    else
      FifoMuxSO <= '0';
    end if;
  end process FifoMux;

  FifoWE : process (EngWriteReqxS, IFWriteReqxS)
  begin
    if (EngWriteReqxS = '1') or (IFWriteReqxS = '1') then
      FifoWExEO <= '1';
    else
      FifoWExEO <= '0';
    end if;
  end process FifoWE;

  FifoRE : process (EngReadReqxS, IFReadReqxS)
  begin
    if (EngReadReqxS = '1') or (IFReadReqxS = '1') then
      FifoRExEO <= '1';
    else
      FifoRExEO <= '0';
    end if;
  end process FifoRE;

  -- assertions
  WarnConcWrite : process (EngWriteReqxS, IFWriteReqxS)
  begin
    assert (EngWriteReqxS = '1') nand (IFWriteReqxS = '1')
      report "FifoCtrl: concurrent interface and engine write requests"
      severity warning;
  end process WarnConcWrite;

  WarnConcRead : process (EngReadReqxS, IFReadReqxS)
  begin
    assert (EngReadReqxS = '1') nand (IFReadReqxS = '1')
      report "FifoCtrl: concurrent interface and engine read requests"
      severity warning;
  end process WarnConcRead;
  
end simple;
