------------------------------------------------------------------------------
-- Testbench for conifgPkg.vhd
--
-- Project    : 
-- File       : tb_configPkg.vhd
-- Author     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
-- Company    : Swiss Federal Institute of Technology (ETH) Zurich
-- Created    : 2002/10/08
-- Last changed: $LastChangedDate: 2004-10-05 17:10:36 +0200 (Tue, 05 Oct 2004) $
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ConfigPkg.all;

entity tb_configPkg is
end tb_configPkg;

architecture abstract of tb_configPkg is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (idle, conv_procCfg, conv_routCfg, conv_cellCfg,
                        conv_rowCfg, conv_gridCfg, conv_ioportCfg,
                        conv_engineCfg, part_cfg);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC : std_logic := '1';

  -- configuration signals
  signal ProcCfg    : procConfigRec;
  signal ProcCfgxD  : std_logic_vector(PE_CFGLEN-1 downto 0);
  signal ProcCfgBck : procConfigRec;

  signal RoutCfg    : routConfigRec;
  signal RoutCfgxD  : std_logic_vector(RE_CFGLEN-1 downto 0);
  signal RoutCfgBck : routConfigRec;

  signal CellCfg    : cellConfigRec;
  signal CellCfgxD  : std_logic_vector(CELL_CFGLEN-1 downto 0);
  signal CellCfgBck : cellConfigRec;

  signal RowCfg    : rowConfigArray;
  signal RowCfgxD  : std_logic_vector(ROW_CFGLEN-1 downto 0);
  signal RowCfgBck : rowConfigArray;

  signal GridCfg    : gridConfigArray;
  signal GridCfgxD  : std_logic_vector(GRID_CFGLEN-1 downto 0);
  signal GridCfgBck : gridConfigArray;

  signal IOPortCfg    : ioportConfigRec;
  signal IOPortCfgxD  : std_logic_vector(PORT_CFGLEN-1 downto 0);
  signal IOPortCfgBck : ioportConfigRec;

  signal EngnCfg    : engineConfigRec;
  signal EngnCfgxD  : std_logic_vector(ENGN_CFGLEN-1 downto 0);
  signal EngnCfgBck : engineConfigRec;
  signal EngnCfgArr : cfgPartArray;

begin  -- abstract

  ----------------------------------------------------------------------------
  -- conversions
  ----------------------------------------------------------------------------
  flat_procConfig : process (ProcCfg)
  begin  -- process flat_procConfig
    ProcCfgxD <= to_procConfig_vec(ProcCfg);
  end process flat_procConfig;

  struct_procConfig : process (ProcCfgxD)
  begin  -- process struct_procConfig
    ProcCfgBck <= to_procConfig_rec(ProcCfgxD);
  end process struct_procConfig;

  flat_routConfig : process (RoutCfg)
  begin  -- process flat_routConfig
    RoutCfgxD <= to_routConfig_vec(RoutCfg);
  end process flat_routConfig;

  struct_routConfig : process (RoutCfgxD)
  begin  -- process struct_routConfig
    RoutCfgBck <= to_routConfig_rec(RoutCfgxD);
  end process struct_routConfig;

  flat_cellConfig : process (CellCfg)
  begin  -- process flat_cellConfig
    CellCfgxD <= to_cellConfig_vec(CellCfg);
  end process flat_cellConfig;

  struct_cellConfig : process (CellCfgxD)
  begin  -- process struct_cellConfig
    CellCfgBck <= to_cellConfig_rec(CellCfgxD);
  end process struct_cellConfig;

  flat_rowConfig : process (RowCfg)
  begin  -- process flat_rowConfig
    RowCfgxD <= to_rowConfig_vec(RowCfg);
  end process flat_rowConfig;

  struct_rowConfig : process (RowCfgxD)
  begin  -- process struct_rowConfig
    RowCfgBck <= to_rowConfig_arr(RowCfgxD);
  end process struct_rowConfig;

  flat_gridConfig : process (GridCfg)
  begin  -- process flat_gridConfig
    GridCfgxD <= to_gridConfig_vec(GridCfg);
  end process flat_gridConfig;

  struct_gridConfig : process (GridCfgxD)
  begin  -- process struct_gridConfig
    GridCfgBck <= to_gridConfig_arr(GridCfgxD);
  end process struct_gridConfig;

  flat_ioportConfig : process (IOPortCfg)
  begin  -- process flat_ioportConfig
    IOPortCfgxD <= to_ioportConfig_vec(IOPortCfg);
  end process flat_ioportConfig;

  struct_ioportConfig : process (IOPortCfgxD)
  begin  -- process struct_ioportConfig
    IOPortCfgBck <= to_ioportConfig_rec(IOPortCfgxD);
  end process struct_ioportConfig;

  flat_engineConfig : process (EngnCfg)
  begin  -- process flat_engineConfig
    EngnCfgxD <= to_engineConfig_vec(EngnCfg);
  end process flat_engineConfig;

  struct_engineConfig : process (EngnCfgxD)
  begin  -- process struct_engineConfig
    EngnCfgBck <= to_engineConfig_rec(EngnCfgxD);
  end process struct_engineConfig;

  part_engineConfig : process (EngnCfgxD)
  begin  -- process part_engineConfig
    EngnCfgArr <= partition_config(EngnCfgxD);
  end process part_engineConfig;

  ----------------------------------------------------------------------------
  -- checks (assertion statements)
  ----------------------------------------------------------------------------
  check_procConfig : process (ClkxC, ProcCfg, ProcCfgBck)
  begin  -- process check_procConfig
    if ClkxC'event and ClkxC = '1' then
      assert (ProcCfg = ProcCfgBck)
        report "SIMOUT: ProcCfg's differ (cycle " & int2str(ccount) & ")"
        severity failure;
    end if;
  end process check_procConfig;

  check_routConfig : process (ClkxC, RoutCfg, RoutCfgBck)
  begin  -- process check_routConfig
    if ClkxC'event and ClkxC = '1' then
      assert (RoutCfg = RoutCfgBck)
        report "SIMOUT: RoutCfg's differ (cycle " & int2str(ccount) & ")"
        severity failure;
    end if;
  end process check_routConfig;

  check_cellConfig : process (ClkxC, CellCfg, CellCfgBck)
  begin  -- process check_cellConfig
    if ClkxC'event and ClkxC = '1' then
      assert (CellCfg = CellCfgBck)
        report "SIMOUT: CellCfg's differ (cycle " & int2str(ccount) & ")"
        severity failure;
    end if;
  end process check_cellConfig;

  check_rowConfig : process (ClkxC, RowCfg, RowCfgBck)
  begin  -- process check_rowConfig
    if ClkxC'event and ClkxC = '1' then
      assert (RowCfg = RowCfgBck)
        report "SIMOUT: RowCfg's differ (cycle " & int2str(ccount) & ")"
        severity failure;
    end if;
  end process check_rowConfig;

  check_gridConfig : process (ClkxC, GridCfg, GridCfgBck)
  begin  -- process check_gridConfig
    if ClkxC'event and ClkxC = '1' then
      assert (GridCfg = GridCfgBck)
        report "SIMOUT: GridCfg's differ (cycle " & int2str(ccount) & ")"
        severity failure;
    end if;
  end process check_gridConfig;

  check_ioportConfig : process (ClkxC, IOPortCfg, IOPortCfgBck)
  begin  -- process check_ioportConfig
    if ClkxC'event and ClkxC = '1' then
      assert (IOPortCfg = IOPortCfgBck)
        report "SIMOUT: IOPortCfg's differ (cycle " & int2str(ccount) & ")"
        severity failure;
    end if;
  end process check_ioportConfig;

  check_engnConfig : process (ClkxC, EngnCfg, EngnCfgBck)
  begin  -- process check_engnConfig
    if ClkxC'event and ClkxC = '1' then
      assert (EngnCfg = EngnCfgBck)
        report "SIMOUT: EngnCfg's differ (cycle " & int2str(ccount) & ")"
        severity failure;
    end if;
  end process check_engnConfig;

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process

    procedure init_stimuli (
      signal ProcCfg   : out procConfigRec;
      signal RoutCfg   : out routConfigRec;
      signal CellCfg   : out cellConfigRec;
      signal RowCfg    : out rowConfigArray;
      signal GridCfg   : out gridConfigArray;
      signal IOPortCfg : out ioportConfigRec;
      signal EngnCfg   : out engineConfigRec ) is
    begin
      ProcCfg   <= init_procConfig;
      RoutCfg   <= init_routConfig;
      CellCfg   <= init_cellConfig;
      RowCfg    <= init_rowConfig;
      GridCfg   <= init_gridConfig;
      IOPortCfg <= init_ioportConfig;
      EngnCfg   <= init_engineConfig;
    end init_stimuli;

  begin  -- process stimuliTb

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD;

    tbStatus          <= conv_procCfg;
    ProcCfg.Op0MuxS   <= "10";
    ProcCfg.Op1MuxS   <= "01";
    ProcCfg.OutMuxS   <= '1';
    ProcCfg.AluOpxS   <= alu_add;
    ProcCfg.ConstOpxD <= std_logic_vector(to_unsigned(15, DATAWIDTH));
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    ProcCfg.Op0MuxS   <= "11";
    ProcCfg.Op1MuxS   <= "10";
    ProcCfg.OutMuxS   <= '0';
    ProcCfg.AluOpxS   <= alu_nand;
    ProcCfg.ConstOpxD <= std_logic_vector(to_unsigned(255, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD;

    tbStatus           <= conv_routCfg;
    RoutCfg.Route0MuxS <= "110";
    RoutCfg.Route1MuxS <= "001";
    RoutCfg.Tri0OExE   <= '1';
    RoutCfg.Tri1OExE   <= '0';
    RoutCfg.Tri2OExE   <= '1';
    wait for CLK_PERIOD;
    RoutCfg.Route0MuxS <= "001";
    RoutCfg.Tri0OExE   <= '0';
    RoutCfg.Tri1OExE   <= '1';
    RoutCfg.Tri2OExE   <= '0';
    RoutCfg.Route1MuxS <= "100";
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD;

    tbStatus                   <= conv_cellCfg;
    CellCfg.procConf.Op0MuxS   <= "10";
    CellCfg.procConf.Op1MuxS   <= "01";
    CellCfg.procConf.OutMuxS   <= '1';
    CellCfg.procConf.AluOpxS   <= alu_add;
    CellCfg.procConf.ConstOpxD <=
      std_logic_vector(to_unsigned(15, DATAWIDTH));
    CellCfg.routConf.Route0MuxS <= "110";
    CellCfg.routConf.Route1MuxS <= "001";
    CellCfg.routConf.Tri0OExE   <= '1';
    CellCfg.routConf.Tri1OExE   <= '0';
    CellCfg.routConf.Tri2OExE   <= '1';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD;

    tbStatus <= conv_rowCfg;
    for i in RowCfg'range loop
      RowCfg(i).procConf.Op0MuxS   <= "10";
      RowCfg(i).procConf.Op1MuxS   <= "01";
      RowCfg(i).procConf.OutMuxS   <= '1';
      RowCfg(i).procConf.AluOpxS   <= alu_add;
      RowCfg(i).procConf.ConstOpxD <=
        std_logic_vector(to_unsigned(15, DATAWIDTH));
      RowCfg(i).routConf.Route0MuxS <= "110";
      RowCfg(i).routConf.Route1MuxS <= "001";
      RowCfg(i).routConf.Tri0OExE   <= '1';
      RowCfg(i).routConf.Tri1OExE   <= '0';
      RowCfg(i).routConf.Tri2OExE   <= '1';
    end loop;  -- i
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD;

    tbStatus <= conv_gridCfg;
    for i in GridCfg'range loop
      for j in GridCfg(i)'range loop
        GridCfg(i)(j).procConf.Op0MuxS   <= "10";
        GridCfg(i)(j).procConf.Op1MuxS   <= "01";
        GridCfg(i)(j).procConf.OutMuxS   <= '1';
        GridCfg(i)(j).procConf.AluOpxS   <= alu_add;
        GridCfg(i)(j).procConf.ConstOpxD <=
          std_logic_vector(to_unsigned(15, DATAWIDTH));
        GridCfg(i)(j).routConf.Route0MuxS <= "110";
        GridCfg(i)(j).routConf.Route1MuxS <= "001";        
        GridCfg(i)(j).routConf.Tri0OExE   <= '1';
        GridCfg(i)(j).routConf.Tri1OExE   <= '0';
        GridCfg(i)(j).routConf.Tri2OExE   <= '1';
      end loop;  -- j
    end loop;  -- i
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD;

    tbStatus              <= conv_ioportCfg;
    ioportCfg.Cmp0MuxS    <= '1';
    ioportCfg.Cmp1MuxS    <= '1';
    ioportCfg.Cmp0ModusxS <= '1';
    ioportCfg.Cmp1ModusxS <= '1';
    ioportCfg.Cmp0ConstxD <= std_logic_vector(to_unsigned(111, CCNTWIDTH));
    ioportCfg.Cmp1ConstxD <= std_logic_vector(to_unsigned(222, CCNTWIDTH));
    ioportCfg.LUT4FunctxD <= X"ABCD";
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD;

    tbStatus <= conv_engineCfg;
    for i in EngnCfg.gridConf'range loop
      for j in EngnCfg.gridConf(i)'range loop
        EngnCfg.gridConf(i)(j).procConf.Op0MuxS   <= "10";
        EngnCfg.gridConf(i)(j).procConf.Op1MuxS   <= "01";
        EngnCfg.gridConf(i)(j).procConf.OutMuxS   <= '1';
        EngnCfg.gridConf(i)(j).procConf.AluOpxS   <= alu_add;
        EngnCfg.gridConf(i)(j).procConf.ConstOpxD <=
          std_logic_vector(to_unsigned(15, DATAWIDTH));
        EngnCfg.gridConf(i)(j).routConf.Route0MuxS <= "110";
        EngnCfg.gridConf(i)(j).routConf.Route1MuxS <= "001";
        EngnCfg.gridConf(i)(j).routConf.Tri0OExE   <= '1';
        EngnCfg.gridConf(i)(j).routConf.Tri1OExE   <= '0';
        EngnCfg.gridConf(i)(j).routConf.Tri2OExE   <= '1';
      end loop;  -- j
    end loop;  -- i
    EngnCfg.Inp0OExE                <= "11111111";
    EngnCfg.Inp1OExE                <= "00000000";
    EngnCfg.Out0MuxS                <= "110";
    EngnCfg.Out1MuxS                <= "011";
    -- inport0
    EngnCfg.inport0Conf.Cmp0MuxS    <= '1';
    EngnCfg.inport0Conf.Cmp1MuxS    <= '1';
    EngnCfg.inport0Conf.Cmp0ModusxS <= '1';
    EngnCfg.inport0Conf.Cmp1ModusxS <= '1';
    EngnCfg.inport0Conf.Cmp0ConstxD <=
      std_logic_vector(to_unsigned(111, CCNTWIDTH));
    EngnCfg.inport0Conf.Cmp1ConstxD <=
      std_logic_vector(to_unsigned(222, CCNTWIDTH));
    EngnCfg.inport0Conf.LUT4FunctxD  <= X"ABCD";
    -- outport1
    EngnCfg.outport1Conf.Cmp0MuxS    <= '1';
    EngnCfg.outport1Conf.Cmp1MuxS    <= '1';
    EngnCfg.outport1Conf.Cmp0ModusxS <= '1';
    EngnCfg.outport1Conf.Cmp1ModusxS <= '1';
    EngnCfg.outport1Conf.Cmp0ConstxD <=
      std_logic_vector(to_unsigned(3, CCNTWIDTH));
    EngnCfg.outport1Conf.Cmp1ConstxD <=
      std_logic_vector(to_unsigned(4, CCNTWIDTH));
    EngnCfg.outport1Conf.LUT4FunctxD <= X"A2D2";
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    init_stimuli(ProcCfg, RoutCfg, CellCfg, RowCfg, GridCfg, IOPortCfg,
                 EngnCfg);
    wait for CLK_PERIOD*2;

    -- stop simulation
    wait until (ClkxC'event and ClkxC = '1');
    assert false
      report "stimuli processed; sim. terminated after " & int2str(ccount) &
      " cycles"
      severity failure;
    
  end process stimuliTb;

  ----------------------------------------------------------------------------
  -- clock generation
  ----------------------------------------------------------------------------
  ClkxC <= not ClkxC after CLK_PERIOD/2;

  ----------------------------------------------------------------------------
  -- cycle counter
  ----------------------------------------------------------------------------
  cyclecounter : process (ClkxC)
  begin
    if (ClkxC'event and ClkxC = '1') then
      ccount <= ccount + 1;
    end if;
  end process cyclecounter;

end abstract;
