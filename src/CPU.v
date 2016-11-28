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

wire  [31:0]  inst_addr, inst;
wire  [31:0]  next_pc, Write_Data;
wire  [4:0] Write_Reg;
wire  [31:0]  Read_data1, Read_data2; 
wire  [31:0]  Sign_extend_o, ALU_i2;
wire  RegDst,ALUSrc,RegWrite,Zero;
wire  [1:0]   ALUOp;
wire  [2:0]   ALUCtrl;
//logic [3:0]    i;
Control Control(
    .Op_i       (inst[31:26]),
    .RegDst_o   (RegDst),
    .ALUOp_o    (ALUOp),
    .ALUSrc_o   (ALUSrc),
    .RegWrite_o (RegWrite)
);

Adder Add_PC(
    .data1_in   (inst_addr),
    .data2_in   (32'd4),
    .data_o     (next_pc)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .flushPC_i  (),
    .start_i    (start_i),
    .pc_i       (next_pc),
    .pc_o       (inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr), 
    .instr_o    (inst)
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

MUX32 MUX_JumpPC(
    .data1_i    (),
    .data2_i    (),
    .select_i   (),
    .data_o     ()
);

MUX32 MUX_BranchPC(
    .data1_i    (),
    .data2_i    (),
    .select_i   (),
    .data_o     ()
);

Sign_Extend Sign_Extend(
    .data_i     (inst[15:0]),
    .data_o     (Sign_extend_o)
);


ALU ALU(
    .data1_i    (Read_data1),
    .data2_i    (ALU_i2),
    .ALUCtrl_i  (ALUCtrl),
    .data_o     (Write_Data),
    .Zero_o     (Zero)
);

ALU_Control ALU_Control(
    .funct_i    (inst[5:0]),
    .ALUOp_i    (ALUOp),
    .ALUCtrl_o  (ALUCtrl)
);

regr MEM_WB(
); 

MUX32_3in MUX32_3in(
    .reg_i      (),
    .preALU_i   (),
    .DMorALU_i  (),
    .select_i   (),
    .data_o     ()
);

dm dm(
		.clk        (),
		.addr       (),
		.rd         (),
    .wr         (),
		.wdata      (),
		.rdata      ()
);

Shift32 Shift_32(
  data_i        (),
  data_o        ()
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

HazDetect_unit HazDetect_unit(
    .clk_i      (),
    .MemRead_i  (),
    .Prev_RT_i  (),
    .RSRT_i     (),
    .PCWrite_o  (),
    .IFIDWrite_o  (),
    .IDEXWrite_o  ()
);

endmodule

