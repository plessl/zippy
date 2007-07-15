library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AuxPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;
use work.ConfigPkg.all;

entity tb_ProcEl is
end tb_ProcEl;

architecture arch of tb_ProcEl is

  -- simulation stuff
  constant CLK_PERIOD : time    := 100 ns;
  signal   ccount     : integer := 1;

  type tbstatusType is (rst, idle, alu, alu_mult, outreg, op0inreg, op0const,
                        op0feedback, op1inreg, op1const, op1feedback);
  signal tbStatus : tbstatusType := idle;

  -- general control signals
  signal ClkxC  : std_logic := '1';
  signal RstxRB : std_logic;

  -- DUT signals
  signal ClrxAB    : std_logic                               := '1';
  signal CExE      : std_logic                               := '1';
  signal Cfg       : procConfigRec;
  signal ContextxS : std_logic_vector(CNTXTWIDTH-1 downto 0) := (others => '0');
  signal In0xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal In1xD     : std_logic_vector(DATAWIDTH-1 downto 0);
  signal OutxD     : std_logic_vector(DATAWIDTH-1 downto 0);

  -- aux. signal for multiplication (full width)
  signal MultUxD : unsigned(2*DATAWIDTH-1 downto 0);
  signal MultSxD : signed(2*DATAWIDTH-1 downto 0);

begin  -- arch

  ----------------------------------------------------------------------------
  -- device under test
  ----------------------------------------------------------------------------
  dut : ProcEl
    generic map (
      DATAWIDTH => DATAWIDTH)
    port map (
      ClkxC      => ClkxC,
      RstxRB     => RstxRB,
      ClrxABI    => ClrxAB,
      CExEI      => CExE,
      ConfigxI   => Cfg,
      ContextxSI => ContextxS,
      In0xDI     => In0xD,
      In1xDI     => In1xD,
      OutxDO     => OutxD);

  -- aux. multiplications
  MultUxD <= unsigned(In0xD) * unsigned(In1xD);
  MultSxD <= signed(In0xD) * signed(In1xD);

  ----------------------------------------------------------------------------
  -- stimuli
  ----------------------------------------------------------------------------
  stimuliTb : process
  begin  -- process stimuliTb

    tbStatus <= rst;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));

    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '0');
    wait until (ClkxC'event and ClkxC = '1' and RstxRB = '1');
    tbStatus <= idle;
    wait for CLK_PERIOD*0.25;

    tbStatus    <= alu;                 -- test ALU functionality
    In0xD       <= std_logic_vector(to_unsigned(7, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    Cfg.AluOpxS <= alu_pass0;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_pass1;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_neg0;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_neg1;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_add;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_sub;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_addu;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_subu;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multlo;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multuhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multulo;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_and;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_nand;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_or;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_nor;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_xor;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_xnor;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_not0;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_not1;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_sll;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_srl;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_rol;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_ror;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus    <= alu_mult;            -- test multiplication modes
    In0xD       <= std_logic_vector(to_signed(-7, DATAWIDTH));
    In1xD       <= std_logic_vector(to_signed(1, DATAWIDTH));
    Cfg.AluOpxS <= alu_multhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multlo;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multuhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multulo;
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_signed(-7, DATAWIDTH));
    In1xD       <= std_logic_vector(to_signed(2, DATAWIDTH));
    Cfg.AluOpxS <= alu_multhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multlo;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multuhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multulo;
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_signed(-7, DATAWIDTH));
    In1xD       <= std_logic_vector(to_signed(-1, DATAWIDTH));
    Cfg.AluOpxS <= alu_multhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multlo;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multuhi;
    wait for CLK_PERIOD;
    Cfg.AluOpxS <= alu_multulo;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus    <= outreg;              -- test output mux
    Cfg.OutMuxS <= '1';
    Cfg.AluOpxS <= alu_add;
    In0xD       <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(5, DATAWIDTH));
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_unsigned(2, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(3, DATAWIDTH));
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_unsigned(4, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(4, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus    <= op0inreg;            -- test operand 0 mux
    Cfg.Op0MuxS <= "01";                -- registered input
    Cfg.AluOpxS <= alu_add;
    In0xD       <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(5, DATAWIDTH));
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_unsigned(2, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(3, DATAWIDTH));
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_unsigned(4, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(4, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus      <= op0const;          -- test operand 0 mux
    Cfg.Op0MuxS   <= "10";              -- constant operand
    Cfg.AluOpxS   <= alu_pass0;
    Cfg.ConstOpxD <= std_logic_vector(to_unsigned(13, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus    <= op0feedback;         -- test operand 0 mux
    Cfg.Op0MuxS <= "11";                -- feed back registered result
    Cfg.AluOpxS <= alu_add;
    In1xD       <= std_logic_vector(to_unsigned(10, DATAWIDTH));
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus    <= op1inreg;            -- test operand 1 mux
    Cfg.Op1MuxS <= "01";                -- registered input
    Cfg.AluOpxS <= alu_add;
    In0xD       <= std_logic_vector(to_unsigned(1, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(5, DATAWIDTH));
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_unsigned(2, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(3, DATAWIDTH));
    wait for CLK_PERIOD;
    In0xD       <= std_logic_vector(to_unsigned(4, DATAWIDTH));
    In1xD       <= std_logic_vector(to_unsigned(4, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus      <= op1const;          -- test operand 1 mux
    Cfg.Op1MuxS   <= "10";              -- constant operand
    Cfg.AluOpxS   <= alu_pass1;
    Cfg.ConstOpxD <= std_logic_vector(to_unsigned(13, DATAWIDTH));
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    wait for CLK_PERIOD*2;

    tbStatus    <= op1feedback;         -- test operand 1 mux
    Cfg.Op1MuxS <= "11";                -- feed back registered result
    Cfg.AluOpxS <= alu_add;
    In0xD       <= std_logic_vector(to_unsigned(10, DATAWIDTH));
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;

    tbStatus <= idle;
    Cfg      <= init_procConfig;
    In0xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
    In1xD    <= std_logic_vector(to_unsigned(0, DATAWIDTH));
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
