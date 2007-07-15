-- c_0_0 opt232
cfg.gridConf(0)(0).procConf.AluOpxS := alu_pass0;
-- i.0
cfg.gridConf(0)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(0).routConf.i(0).LocalxE(LOCAL_SW) := '1';


-- c_0_1 op13
cfg.gridConf(0)(1).procConf.AluOpxS := alu_add;
-- i.0
cfg.gridConf(0)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(1).routConf.i(0).HBusNxE(0) := '1';
-- i.1
cfg.gridConf(0)(1).procConf.OpMuxS(1) := I_REG_CTX_THIS;
cfg.gridConf(0)(1).routConf.i(1).LocalxE(LOCAL_N) := '1';
-- o.0
cfg.gridConf(0)(1).procConf.OutMuxS := O_NOREG;


-- c_0_2 op14
cfg.gridConf(0)(2).procConf.AluOpxS := alu_mux;
-- i.0
cfg.gridConf(0)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(2).routConf.i(0).LocalxE(LOCAL_NE) := '1';
-- i.1
cfg.gridConf(0)(2).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(0)(2).routConf.i(1).LocalxE(LOCAL_W) := '1';
-- i.2
cfg.gridConf(0)(2).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(0)(2).routConf.i(2).LocalxE(LOCAL_N) := '1';
-- o.0
cfg.gridConf(0)(2).procConf.OutMuxS := O_NOREG;
cfg.gridConf(0)(2).routConf.o.VBusExE(1) := '1';


-- c_0_3 op6
cfg.gridConf(0)(3).procConf.AluOpxS := alu_and;
-- i.0
cfg.gridConf(0)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(0)(3).routConf.i(0).HBusNxE(1) := '1';
-- i.1
cfg.gridConf(0)(3).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(0)(3).procConf.ConstOpxD := i2cfgconst(7);
-- o.0
cfg.gridConf(0)(3).procConf.OutMuxS := O_NOREG;
cfg.gridConf(0)(3).routConf.o.HBusNxE(0) := '1';


-- c_1_0 opt230
cfg.gridConf(1)(0).procConf.AluOpxS := alu_pass0;
-- i.0
cfg.gridConf(1)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(0).routConf.i(0).LocalxE(LOCAL_SE) := '1';


-- c_1_1 op8
cfg.gridConf(1)(1).procConf.AluOpxS := alu_tstbitat1;
-- i.0
cfg.gridConf(1)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(1).routConf.i(0).HBusNxE(0) := '1';
-- i.1
cfg.gridConf(1)(1).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(1)(1).procConf.ConstOpxD := i2cfgconst(2);
-- o.0
cfg.gridConf(1)(1).procConf.OutMuxS := O_NOREG;
cfg.gridConf(1)(1).routConf.o.HBusNxE(0) := '1';


-- c_1_2 op15
cfg.gridConf(1)(2).procConf.AluOpxS := alu_add;
-- i.0
cfg.gridConf(1)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(2).routConf.i(0).LocalxE(LOCAL_N) := '1';
-- i.1
cfg.gridConf(1)(2).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(1)(2).routConf.i(1).LocalxE(LOCAL_S) := '1';
-- o.0
cfg.gridConf(1)(2).procConf.OutMuxS := O_NOREG;


-- c_1_3 op9
cfg.gridConf(1)(3).procConf.AluOpxS := alu_tstbitat1;
-- i.0
cfg.gridConf(1)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(1)(3).routConf.i(0).LocalxE(LOCAL_N) := '1';
-- i.1
cfg.gridConf(1)(3).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(1)(3).procConf.ConstOpxD := i2cfgconst(1);
-- o.0
cfg.gridConf(1)(3).procConf.OutMuxS := O_NOREG;


-- c_2_0 opt231
cfg.gridConf(2)(0).procConf.AluOpxS := alu_pass0;
-- i.0
cfg.gridConf(2)(0).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(0).routConf.i(0).LocalxE(LOCAL_W) := '1';


-- c_2_1 op17
cfg.gridConf(2)(1).procConf.AluOpxS := alu_add;
-- i.0
cfg.gridConf(2)(1).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(1).routConf.i(0).HBusSxE(0) := '1';
-- i.1
cfg.gridConf(2)(1).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(2)(1).routConf.i(1).LocalxE(LOCAL_SW) := '1';
-- o.0
cfg.gridConf(2)(1).procConf.OutMuxS := O_NOREG;


-- c_2_2 op11
cfg.gridConf(2)(2).procConf.AluOpxS := alu_srl;
-- i.0
cfg.gridConf(2)(2).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(2)(2).routConf.i(0).LocalxE(LOCAL_SW) := '1';
-- i.1
cfg.gridConf(2)(2).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(2)(2).procConf.ConstOpxD := i2cfgconst(1);
-- o.0
cfg.gridConf(2)(2).procConf.OutMuxS := O_NOREG;


-- c_2_3 op16
cfg.gridConf(2)(3).procConf.AluOpxS := alu_mux;
-- i.0
cfg.gridConf(2)(3).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(2)(3).routConf.i(0).VBusExE(1) := '1';
-- i.1
cfg.gridConf(2)(3).procConf.OpMuxS(1) := I_NOREG;
cfg.gridConf(2)(3).routConf.i(1).LocalxE(LOCAL_NW) := '1';
-- i.2
cfg.gridConf(2)(3).procConf.OpMuxS(2) := I_NOREG;
cfg.gridConf(2)(3).routConf.i(2).HBusNxE(0) := '1';
-- o.0
cfg.gridConf(2)(3).procConf.OutMuxS := O_NOREG;
cfg.gridConf(2)(3).routConf.o.HBusSxE(0) := '1';


-- c_3_0 op10
cfg.gridConf(3)(0).procConf.AluOpxS := alu_srl;
-- i.0
cfg.gridConf(3)(0).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(3)(0).routConf.i(0).LocalxE(LOCAL_E) := '1';
-- i.1
cfg.gridConf(3)(0).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(3)(0).procConf.ConstOpxD := i2cfgconst(2);
-- o.0
cfg.gridConf(3)(0).procConf.OutMuxS := O_NOREG;


-- c_3_1 opt120
cfg.gridConf(3)(1).procConf.AluOpxS := alu_pass0;
-- o.0
cfg.gridConf(3)(1).procConf.OutMuxS := O_REG_CTX_OTHER;
cfg.gridConf(3)(1).procConf.OutCtxRegSelxS := i2ctx(0);
cfg.gridConf(3)(1).routConf.o.HBusSxE(1) := '1';


-- c_3_2 op7
cfg.gridConf(3)(2).procConf.AluOpxS := alu_tstbitat1;
-- i.0
cfg.gridConf(3)(2).procConf.OpMuxS(0) := I_NOREG;
cfg.gridConf(3)(2).routConf.i(0).LocalxE(LOCAL_SE) := '1';
-- i.1
cfg.gridConf(3)(2).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(3)(2).procConf.ConstOpxD := i2cfgconst(4);
-- o.0
cfg.gridConf(3)(2).procConf.OutMuxS := O_NOREG;


-- c_3_3 op12
cfg.gridConf(3)(3).procConf.AluOpxS := alu_srl;
-- i.0
cfg.gridConf(3)(3).procConf.OpMuxS(0) := I_REG_CTX_THIS;
cfg.gridConf(3)(3).routConf.i(0).HBusSxE(1) := '1';
-- i.1
cfg.gridConf(3)(3).procConf.OpMuxS(1) := I_CONST;
cfg.gridConf(3)(3).procConf.ConstOpxD := i2cfgconst(3);
-- o.0
cfg.gridConf(3)(3).procConf.OutMuxS := O_NOREG;
cfg.gridConf(3)(3).routConf.o.HBusNxE(0) := '1';


-- input drivers
cfg.inputDriverConf(0)(0)(1) := '1';

-- output drivers
