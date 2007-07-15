-- c_0_1 op4a
cfg.gridConf(0)(1).procConf.AluOpxS := alu_mux;
-- i.0
cfg.gridConf(0)(1).procConf.OpMuxS(0) := I_CONST;
cfg.gridConf(0)(1).procConf.ConstOpxD := i2cfgconst(88);
-- i.1
cfg.gridConf(0)(1).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(0)(1).procConf.ConstOpxD := i2cfgconst(88);
-- i.2
cfg.gridConf(0)(1).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(0)(1).routConf.i(2).LocalxE(LOCAL_NE) := '1';
-- o.0
cfg.gridConf(0)(1).procConf.OutMuxS := O_NOREG;


-- c_1_0 op4b
cfg.gridConf(1)(0).procConf.AluOpxS := alu_mux;
-- i.0
cfg.gridConf(1)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(0).routConf.i(0).LocalxE(LOCAL_S) := '1';
-- i.1
cfg.gridConf(1)(0).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(1)(0).procConf.ConstOpxD := i2cfgconst(0);
-- i.2
cfg.gridConf(1)(0).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(1)(0).routConf.i(2).LocalxE(LOCAL_SW) := '1';
-- o.0
cfg.gridConf(1)(0).procConf.OutMuxS := O_NOREG;


-- c_1_1 op4c
cfg.gridConf(1)(1).procConf.AluOpxS := alu_mux;
-- i.0
cfg.gridConf(1)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(1).routConf.i(0).LocalxE(LOCAL_W) := '1';
-- i.1
cfg.gridConf(1)(1).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(1)(1).routConf.i(1).LocalxE(LOCAL_N) := '1';
-- i.2
cfg.gridConf(1)(1).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(1)(1).routConf.i(2).LocalxE(LOCAL_SE) := '1';
-- o.0
cfg.gridConf(1)(1).procConf.OutMuxS := O_NOREG;


-- c_2_0 op1
cfg.gridConf(2)(0).procConf.AluOpxS := alu_add;
-- i.0
cfg.gridConf(2)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(0).routConf.i(0).LocalxE(LOCAL_S) := '1';
-- i.1
cfg.gridConf(2)(0).procConf.OpMuxS(1) := I_REG_CTX_THIS;
cfg.gridConf(2)(0).routConf.i(1).LocalxE(LOCAL_NE) := '1';
-- o.0
cfg.gridConf(2)(0).procConf.OutMuxS := O_NOREG;
cfg.gridConf(2)(0).routConf.o.HBusSxE(1) := '1';


-- c_2_1 op19
cfg.gridConf(2)(1).procConf.AluOpxS := alu_rom;
-- i.0
cfg.gridConf(2)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(1).routConf.i(0).LocalxE(LOCAL_N) := '1';
-- o.0
cfg.gridConf(2)(1).procConf.OutMuxS := O_NOREG;


-- c_2_2 op2
cfg.gridConf(2)(2).procConf.AluOpxS := alu_gt;
-- i.0
cfg.gridConf(2)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(2).routConf.i(0).HBusSxE(1) := '1';
-- i.1
cfg.gridConf(2)(2).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(2)(2).procConf.ConstOpxD := i2cfgconst(88);
-- o.0
cfg.gridConf(2)(2).procConf.OutMuxS := O_NOREG;


-- c_2_3 op3
cfg.gridConf(2)(3).procConf.AluOpxS := alu_lt;
-- i.0
cfg.gridConf(2)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(3).routConf.i(0).LocalxE(LOCAL_E) := '1';
-- i.1
cfg.gridConf(2)(3).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(2)(3).procConf.ConstOpxD := i2cfgconst(0);
-- o.0
cfg.gridConf(2)(3).procConf.OutMuxS := O_NOREG;


-- c_3_0 op0
cfg.gridConf(3)(0).procConf.AluOpxS := alu_rom;
-- i.0
cfg.gridConf(3)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(0).routConf.i(0).HBusNxE(1) := '1';
-- o.0
cfg.gridConf(3)(0).procConf.OutMuxS := O_NOREG;


-- c_3_1 opt120
cfg.gridConf(3)(1).procConf.AluOpxS := alu_pass0;
-- i.0
cfg.gridConf(3)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(1).routConf.i(0).LocalxE(LOCAL_N) := '1';


-- c_3_2 feedthrough_c_3_2
cfg.gridConf(3)(2).procConf.AluOpxS := alu_pass0;
-- i.0
cfg.gridConf(3)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(2).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- o.0
cfg.gridConf(3)(2).procConf.OutMuxS := O_NOREG;


-- input drivers
cfg.inputDriverConf(0)(3)(1) := '1';

-- output drivers
