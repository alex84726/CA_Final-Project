module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

// ****************** Stage 1 components ***************
wire  pc_flush;
wire  [31:0]  next_pc, pc_4;
wire  [31:0]  inst_addr, inst;

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .flushPC_i  (pc_flush),
    .start_i    (start_i),
    .pc_i       (next_pc),
    .pc_o       (inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr), 
    .instr_o    (inst)
);

wire  [31:0]  sh_addr, branch_addr, sh_32;
wire  [27:0]  sh_28_o;
wire  ctrl_branch, equal, mux_branch, jump, beq_flush, lw_flush, flush_IFID;
assign mux_branch = equal&ctrl_branch;
assign beq_flush = jump|mux_branch;
assign flush_IFID = beq_flush|lw_flush;

MUX32 MUX_BranchPC(
    .data1_i    (pc_4),
    .data2_i    (sh_addr),
    .select_i   (mux_branch),
    .data_o     (branch_addr)
);

MUX32 MUX_JumpPC(
    .data1_i    (branch_addr),
    .data2_i    (sh_32),
    .select_i   (jump),
    .data_o     (next_pc)
);

Adder Add_PC(
    .data1_in   (inst_addr),
    .data2_in   (32'd4),
    .data_o     (pc_4)
);

regr #(.N( )) IFID(
    .clk        (clk_i),
	  .clear      (flush_IFID),
	  .hold       (),
    .in         (),
	  .out        ()
);

// ******************Stage 2 components *****************
Sign_Extend Sign_Extend(
    .data_i     (inst[15:0]),
    .data_o     (Sign_extend_o)
);

shiftLeft_26_28 sh_26_28(
    .data_i     (inst[25:0]),
    .data_o     (sh_28_o)
);

assign sh_32[27:0] = sh_28_o;
assign sh_32[31:28] = branch_addr[31:28];

Shift32 Shift_32(
  data_i        (),
  data_o        ()
);

HazDetect_unit HazDetect_unit(
    .clk_i      (),
    .MemRead_i  (),
    .Prev_RT_i  (),
    .RSRT_i     (),
    .PCWrite_o  (),
    .IFIDWrite_o  (),
    .IDEXWrite_o  ()
);

Control Control(
    .Op_i       (inst[31:26]),
    .RegDst_o   (RegDst),
    .ALUOp_o    (ALUOp),
    .ALUSrc_o   (ALUSrc),
    .RegWrite_o (RegWrite)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]),
    .RTaddr_i   (inst[20:16]),
    .RDaddr_i   (Write_Reg), 
    .RDdata_i   (Write_Data),
    .RegWrite_i (RegWrite), 
    .RSdata_o   (Read_data1), 
    .RTdata_o   (Read_data2) 
);

// ******************Stage 3 components *****************
MUX32_3in MUX32_3in_rs(
    .reg_i      (),
    .preALU_i   (),
    .DMorALU_i  (),
    .select_i   (),
    .data_o     ()
);

MUX32_3in MUX32_3in_rt(
    .reg_i      (),
    .preALU_i   (),
    .DMorALU_i  (),
    .select_i   (),
    .data_o     ()
);

ALU ALU(
    .data1_i    (Read_data1),
    .data2_i    (ALU_i2),
    .ALUCtrl_i  (ALUCtrl),
    .data_o     (Write_Data),
    .Zero_o     (Zero)
);

Forwarding_unit Forwarding_unit(
    .clk_i      (),
    .MEM_Rd_i   (),
    .WB_Rd_i    (),
    .MEM_W_i    (), 
    .WB_W_i     (),
    .RS_i       (), 
    .RT_i       (),
    .RS_Src_o   ()
);

ALU_Control ALU_Control(
    .funct_i    (inst[5:0]),
    .ALUOp_i    (ALUOp),
    .ALUCtrl_o  (ALUCtrl)
);

MUX5 MUX_RegDst(
    .data1_i    (inst[20:16]),
    .data2_i    (inst[15:11]),
    .select_i   (RegDst),
    .data_o     (Write_Reg)
);

MUX32 MUX_ALUSrc(
    .data1_i    (Read_data2),
    .data2_i    (Sign_extend_o),
    .select_i   (ALUSrc),
    .data_o     (ALU_i2)
);

// ******************Stage 4 components *****************
dm dm(
		.clk        (),
		.addr       (),
		.rd         (),
    .wr         (),
		.wdata      (),
		.rdata      ()
);


endmodule

