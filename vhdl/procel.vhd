------------------------------------------------------------------------------
-- ZIPPY processing element
--
-- Project     : 
-- File        : procel.vhd
-- Authors     : Rolf Enzler  <enzler@ife.ee.ethz.ch>
--               Christian Plessl <plessl@tik.ee.ethz.ch>
-- Company     : Swiss Federal Institute of Technology (ETH) Zurich
-- Created     : 2002/09/05
-- Last changed: $LastChangedDate: 2005-01-13 18:02:10 +0100 (Thu, 13 Jan 2005) $
------------------------------------------------------------------------------
-- Procel is the computation element within a Zippy cell. It is essentially
-- an ALU with two inputs that are optionally registered and an output. 
-- The input and output registers replicated for each context and can be 
-- optionally cleared at a context switch.
-------------------------------------------------------------------------------
-- Changes:
-- 2004-10-07 CP added documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archConfigPkg.all;
use work.ZArchPkg.all;
use work.ComponentsPkg.all;

entity ProcEl is

  generic (
    DATAWIDTH : integer);
  port (
    ClkxC         : in  std_logic;
    RstxRB        : in  std_logic;
    CExEI         : in  std_logic;      -- engine running
    ConfigxI      : in  procConfigRec;
    ClrContextxSI : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    ClrContextxEI : in  std_logic;
    ContextxSI    : in  std_logic_vector(CNTXTWIDTH-1 downto 0);
    -- data io signals
    InxDI         : in  procelInputArray;
    OutxDO        : out data_word;
    -- memory signals
    MemDataxDI    : in  data_word;
    MemAddrxDO    : out data_word;
    MemDataxDO    : out data_word;
    MemCtrlxSO    : out data_word
    );

end ProcEl;

architecture simple of ProcEl is

  -- FIXME: parameterize in number of input ports

  signal InRegxD : procelInputArray;
  signal InRegxE : std_logic_vector(N_CELLINPS-1 downto 0);
  signal OpxD    : procelInputArray;

  type contextSelInputArray is array (N_CELLINPS-1 downto 0) of
    std_logic_vector(CNTXTWIDTH-1 downto 0);
  
  signal InputRegistersetxSI  : contextSelInputArray;
  signal OutputRegistersetxSI : procOutputCtxRegSelect;

--  type OpMuxArray is
--    type OpMuxArray
-- is array (N_CELLINPS-1 downto 0) of <type>

  signal ResultxD    : data_word;
  signal ResultRegxD : data_word;
  signal OutRegxE    : std_logic;
  signal OutxD       : data_word;

  signal Op0MuxS : std_logic_vector(1 downto 0);
  signal Op1MuxS : std_logic_vector(1 downto 0);
  signal Op2MuxS : std_logic_vector(1 downto 0);

  signal OutMuxS   : procOutputMux;
  signal AluOpxS   : aluop_type;
  signal ConstOpxD : data_word;

begin  -- simple

  -- configuration decoding
  OutMuxS   <= ConfigxI.OutMuxS;
  AluOpxS   <= ConfigxI.AluOpxS;
  ConstOpxD <= ConfigxI.ConstOpxD;


  -----------------------------------------------------------------------------
  -- input register files (one per context)
  -----------------------------------------------------------------------------

  inputSelect_gen : for inp in N_CELLINPS-1 downto 0 generate

    ctxRegfile : ContextRegFile
      port map (
        ClkxC         => ClkxC,
        RstxRB        => RstxRB,
        ClrContextxSI => ClrContextxSI,
        ClrContextxEI => ClrContextxEI,
        ContextxSI    => InputRegistersetxSI(inp),
        EnxEI         => InRegxE(inp),
        DinxDI        => InxDI(inp),
        DoutxDO       => InRegxD(inp));

    InputRegistersetxSI(inp) <= ConfigxI.OpCtxRegSelxS(inp) when
                                (ConfigxI.OpMuxS(inp) = I_REG_CTX_OTHER)
                                else
                                ContextxSI;

    -- Register is always written if a context is active. If the context register
    -- of context 'i' is read by a differnt context c!='i' the register is not
    -- written.
    --
    -- This might be extended with the possibility of writing any register
    InRegxE(inp) <= '0' when (ConfigxI.OpMuxS(inp) = I_REG_CTX_OTHER) else
                    CExEI;

    OpxD(inp) <= InxDI(inp) when (ConfigxI.OpMuxS(inp) = I_NOREG) else
                 InRegxD(inp) when ((ConfigxI.OpMuxS(inp) = I_REG_CTX_THIS) or
                                    (ConfigxI.OpMuxS(inp) = I_REG_CTX_OTHER)) else
                 ConstOpxD when (ConfigxI.OpMuxS(inp) = I_CONST) else
                 ResultRegxD when (ConfigxI.OpMuxS(inp) = I_REG_FEEDBACK) else
                 (others => '0');
    
  end generate inputSelect_gen;

  -----------------------------------------------------------------------------
  -- output register file (one per context)
  -----------------------------------------------------------------------------

  outReg : ContextRegFile
    port map (
      ClkxC         => ClkxC,
      RstxRB        => RstxRB,
      ClrContextxSI => ClrContextxSI,
      ClrContextxEI => ClrContextxEI,
      ContextxSI    => OutputRegistersetxSI,
      EnxEI         => OutRegxE,
      DinxDI        => ResultxD,
      DoutxDO       => ResultRegxD);

  OutputRegistersetxSI <= ConfigxI.OutCtxRegSelxS when
                          (ConfigxI.OutMuxS = O_REG_CTX_OTHER)
                          else ContextxSI;

  -- See input register
  OutRegxE <= '0' when (ConfigxI.OutMuxS = O_REG_CTX_OTHER)
              else CExEI;

  -- output multiplexer
  with OutMuxS select
    OutxD <=
    ResultxD    when O_NOREG,           -- not registered
    ResultRegxD when others;            -- registered

  -- procel output
  OutxDO <= OutxD;

  -- drive ROM read address to MemAddrxDO if the cell is configured as ROM cell
  -- (alu_rom), else tristate
  MemAddrxDO <= OpxD(0) when (AluOpxS = ALU_OP_ROM) else (others => 'Z');

  -- unsued memory outputs
  MemDataxDO <= (others => 'Z');
  MemCtrlxSO <= (others => 'Z');

  -- ALU
  aluComb : process (AluOpxS, MemDataxDI, OpxD)
    variable res   : data_word;
    variable long  : std_logic_vector(2*DATAWIDTH-1 downto 0);
    variable op0_s : signed(DATAWIDTH-1 downto 0);
    variable op1_s : signed(DATAWIDTH-1 downto 0);
    variable op2_s : signed(DATAWIDTH-1 downto 0);
    variable op0_u : unsigned(DATAWIDTH-1 downto 0);
    variable op1_u : unsigned(DATAWIDTH-1 downto 0);
    variable op2_u : unsigned(DATAWIDTH-1 downto 0);
    
  begin  -- process aluComb
    op0_s := signed(OpxD(0));
    op1_s := signed(OpxD(1));
    op0_u := unsigned(OpxD(0));
    op1_u := unsigned(OpxD(1));

    case AluOpxS is
      when ALU_OP_PASS0 =>
        res := OpxD(0);
      when ALU_OP_PASS1 =>
        res := OpxD(1);
      when ALU_OP_NEG0 =>
        res := std_logic_vector(- op0_s);
      when ALU_OP_NEG1 =>
        res := std_logic_vector(- op1_s);
      when ALU_OP_ADD =>
        res := std_logic_vector(op0_s + op1_s);
      when ALU_OP_SUB =>
        res := std_logic_vector(op0_s - op1_s);
      when ALU_OP_ADDU =>
        res := std_logic_vector(op0_u + op1_u);
      when ALU_OP_SUBU =>
        res := std_logic_vector(op0_u - op1_u);
      when ALU_OP_MULTHI =>
        long := std_logic_vector(op0_s * op1_s);
        res  := long(2*DATAWIDTH-1 downto DATAWIDTH);
      when ALU_OP_MULTLO =>
        long := std_logic_vector(op0_s * op1_s);
        res  := long(DATAWIDTH-1 downto 0);
      when ALU_OP_MULTUHI =>
        long := std_logic_vector(op0_u * op1_u);
        res  := long(2*DATAWIDTH-1 downto DATAWIDTH);
      when ALU_OP_MULTULO =>
        long := std_logic_vector(op0_u * op1_u);
        res  := long(DATAWIDTH-1 downto 0);
      when ALU_OP_AND =>
        res := OpxD(0) and OpxD(1);
      when ALU_OP_NAND =>
        res := OpxD(0) nand OpxD(1);
      when ALU_OP_OR =>
        res := OpxD(0) or OpxD(1);
      when ALU_OP_NOR =>
        res := OpxD(0) nor OpxD(1);
      when ALU_OP_XOR =>
        res := OpxD(0) xor OpxD(1);
      when ALU_OP_XNOR =>
        res := OpxD(0) xnor OpxD(1);
      when ALU_OP_NOT0 =>
        res := not OpxD(0);
      when ALU_OP_NOT1 =>
        res := not OpxD(1);
      when ALU_OP_SLL =>
        res := std_logic_vector(op0_u sll to_integer(op1_u));
      when ALU_OP_SRL =>
        res := std_logic_vector(op0_u srl to_integer(op1_u));
      when ALU_OP_ROL =>
        res := std_logic_vector(op0_u rol to_integer(op1_u));
      when ALU_OP_ROR =>
        res := std_logic_vector(op0_u ror to_integer(op1_u));
      when ALU_OP_TSTBITAT0 =>
        if ((not(OpxD(0)) and OpxD(1)) = OpxD(1)) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when ALU_OP_TSTBITAT1 =>
        if ((OpxD(0) and OpxD(1)) = OpxD(1)) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when ALU_OP_MUX =>
        if (OpxD(2)(0) = '0') then
          res := OpxD(0);
        else
          res := OpxD(1);
        end if;
      when ALU_OP_ROM =>
        res := MemDataxDI;
      when ALU_OP_EQ =>
        if (OpxD(0) = OpxD(1)) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when ALU_OP_NEQ =>
        if (OpxD(0) /= OpxD(1)) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when ALU_OP_LT =>
        if (op0_s < op1_s) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when ALU_OP_GT =>
        if (op0_s > op1_s) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when ALU_OP_LTE =>
        if (op0_s <= op1_s) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when ALU_OP_GTE =>
        if (op0_s >= op1_s) then
          res := (others => '1');
        else
          res := (others => '0');
        end if;
      when others => null;
    end case;
    ResultxD <= res;
  end process aluComb;

end simple;
