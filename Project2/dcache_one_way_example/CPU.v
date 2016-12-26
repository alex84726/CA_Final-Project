module CPU
(
	clk_i,
	rst_i,
	start_i,
   
	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o
);

//input
input clk_i;
input rst_i;
input start_i;

//
// to Data Memory interface		
//
input	[256-1:0]	mem_data_i; 
input				mem_ack_i; 	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o; 

//
// add your project1 here!
//

wire  [31:0]  next_pc, pc_4;
wire  [31:0]  inst_addr, inst;
wire  pc_stall_haz;
wire  MemStall;

PC PC
(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.start_i(start_i),
	.stall_i(pc_stall_haz),
	.pcEnable_i(MemStall),
	.pc_i(next_pc),
	.pc_o(inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr), 
    .instr_o    (inst)
);

wire  [31:0]  sh_addr, branch_addr, sh_32;
wire  [27:0]  sh_28_o;
wire  ctrl_branch, equal, beq_flush, lw_stall, jump;
wire mux_branch, jump_reg;
assign mux_branch = equal&ctrl_branch;
assign jump_reg = jump;
assign beq_flush = jump|mux_branch;


MUX32 MUX_BranchPC(
    .data1_i    (pc_4),
    .data2_i    (sh_addr),
    .select_i   (mux_branch),
    .data_o     (branch_addr)
);

MUX32 MUX_JumpPC(
    .data1_i    (branch_addr),
    .data2_i    (sh_32),
    .select_i   (jump_reg),
    .data_o     (next_pc)
);

Adder Add_PC(
    .data1_in   (inst_addr),
    .data2_in   (32'd4),
    .data_o     (pc_4)
);

wire [31:0] inst_ID;
wire [31:0] pc_4_ID;

regr #(.N(64)) IFID(
    .clk        (clk_i),
	  .clear      (beq_flush),
	  .hold       (lw_stall|MemStall),
    .in         ({pc_4,inst}),
	  .out        ({pc_4_ID,inst_ID})
);

// ******************Stage 2 components *****************
wire [5:0]  opcode;
wire [4:0]  rs;
wire [4:0]  rt;
wire [9:0]  rsrt;
wire [4:0]  rd;
wire [15:0] imm;
wire [4:0]  shamt;
wire [31:0] sign_ext_id, sign_ext_id_sh2;  // sign extended immediate
//
assign opcode   = inst_ID[31:26];
assign rsrt     = inst_ID[25:16];
assign rs       = inst_ID[25:21];
assign rt       = inst_ID[20:16];
assign rd       = inst_ID[15:11];
assign imm      = inst_ID[15:0];
assign shamt    = inst_ID[10:6];

Sign_Extend Sign_Extend(
    .data_i     (imm),
    .data_o     (sign_ext_id)
);

shiftLeft_26_28 sh_26_28(
    .data_i     (inst_ID[25:0]),
    .data_o     (sh_28_o)
);

assign sh_32[27:0] = sh_28_o;
assign sh_32[31:28] = branch_addr[31:28];

Shift_32 Shift_32(
  .data_i        (sign_ext_id),
  .data_o        (sign_ext_id_sh2)
);

Adder Add_imm(
  .data1_in       (sign_ext_id_sh2),
  .data2_in       (pc_4_ID),
  .data_o        (sh_addr)
);

wire IDEX_flush;
wire [4:0]  rt_ex;
HazDetect_unit HazDetect_unit(
    .clk_i      (clk_i),
    .MemRead_i  (M_ex[1]),
    .Prev_RT_i  (rt_ex),
    .RSRT_i     (rsrt),
    .PCWrite_o  (pc_stall_haz),
    .IFIDWrite_o  (lw_stall),
    .IDEXWrite_o  (IDEX_flush)
);

wire          Reg_Write;
wire  [7:0]   control_id;

Control Control(
    .Op_i       (opcode),
    .Branch_o   (ctrl_branch),
    .Jump_o     (jump),
    .Bus_o      (control_id)
);

wire  [3:0]   EX_id;
wire  [1:0]   M_id;
wire  [1:0]   WB_id;

MUX8 MUX8(
  .data1_i       (control_id),
  .data2_i       (8'd0),
  .select_i       (IDEX_flush),
  .data_o         ({EX_id,M_id,WB_id})
);

wire  [31:0]  Write_Data;
wire  [31:0]  read_data1_id;
wire  [31:0]  read_data2_id;
wire [4:0]  Write_Register;
Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (rs),
    .RTaddr_i   (rt),
    .RDaddr_i   (Write_Register), 
    .RDdata_i   (Write_Data),
    .RegWrite_i (Reg_Write), 
    .RSdata_o   (read_data1_id), 
    .RTdata_o   (read_data2_id) 
);
assign equal = (read_data1_id == read_data2_id)? 1 : 0;

wire [1:0]  WB_ex, M_ex, ALUOp;
wire ALUSrc, RegDst;
wire [31:0] read_data1_ex, read_data2_ex, Sign_extend_o;
wire [4:0]  rs_ex,rd_ex;
// Noted: clear and hold signal
regr #(.N(119)) IDEX(
    .clk        (clk_i),
	  .clear      (lw_stall),
	  .hold       (MemStall),
    .in         ({WB_id,M_id,EX_id,read_data1_id,read_data2_id,sign_ext_id,rs,rt,rd}),
	  .out        ({WB_ex,M_ex,ALUSrc,ALUOp,RegDst,read_data1_ex,read_data2_ex,Sign_extend_o,rs_ex,rt_ex,rd_ex})
);

// ******************Stage 3 components *****************
wire [31:0] ALU_mem, muxRS_data_o, muxRT_data_o, ALU_i2;
wire [1:0]  RS_Src_Ctr, RT_Src_Ctr;

MUX32_3in MUX32_3in_rs(
    .reg_i      (read_data1_ex),
    .preALU_i   (ALU_mem),
    .DMorALU_i  (Write_Data),
    .select_i   (RS_Src_Ctr),
    .data_o     (muxRS_data_o)
);

MUX32_3in MUX32_3in_rt(
    .reg_i      (read_data2_ex),
    .preALU_i   (ALU_mem),
    .DMorALU_i  (Write_Data),
    .select_i   (RT_Src_Ctr),
    .data_o     (muxRT_data_o)
);

MUX32 MUX_ALUSrc(
    .data1_i    (muxRT_data_o),
    .data2_i    (Sign_extend_o),
    .select_i   (ALUSrc),
    .data_o     (ALU_i2)
);

wire [2:0]  ALUCtrl;
ALU_Control ALU_Control(
    .funct_i    (Sign_extend_o[5:0]),
    .ALUOp_i    (ALUOp),
    .ALUCtrl_o  (ALUCtrl)
);

//redundant signal Zero
wire Zero;
wire [31:0] ALU_ex;
ALU ALU(
    .data1_i    (muxRS_data_o),
    .data2_i    (ALU_i2),
    .ALUCtrl_i  (ALUCtrl),
    .data_o     (ALU_ex),
    .Zero_o     (Zero)
);

wire [4:0] Write_Register_ex;
MUX5 MUX_RegDst(
    .data1_i    (rt_ex),
    .data2_i    (rd_ex),
    .select_i   (RegDst),
    .data_o     (Write_Register_ex)
);

wire [1:0] WB_mem;
wire MemRead, MemWrite;
wire [31:0] dm_Write_Data;
wire [4:0] Write_Register_mem;
regr #(.N(73)) EXMEM(
    .clk        (clk_i),
	  .clear      (1'b0),
	  .hold       (MemStall),
    .in         ({WB_ex,M_ex,ALU_ex,muxRT_data_o,Write_Register_ex}),
	  .out        ({WB_mem,MemRead,MemWrite,ALU_mem,dm_Write_Data,Write_Register_mem})
);

// ******************Stage 4 components *****************
wire [31:0] dm_o;
//data cache
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i), 
	.rst_i(rst_i),
	
	// to Data Memory interface		
	.mem_data_i(mem_data_i), 
	.mem_ack_i(mem_ack_i), 	
	.mem_data_o(mem_data_o), 
	.mem_addr_o(mem_addr_o), 	
	.mem_enable_o(mem_enable_o), 
	.mem_write_o(mem_write_o), 
	
	// to CPU interface	
	.p1_data_i(dm_Write_Data), 
	.p1_addr_i(ALU_mem), 	
	.p1_MemRead_i(MemRead), 
	.p1_MemWrite_i(MemWrite), 
	.p1_data_o(dm_o), 
	.p1_stall_o(MemStall)
);

wire MemtoReg;
wire [31:0] dm_data, ALU_data;
regr #(.N(71)) MEMWB(
    .clk        (clk_i),
	  .clear      (1'b0),
	  .hold       (MemStall),
    .in         ({WB_mem,dm_o,ALU_mem,Write_Register_mem}),
	  .out        ({MemtoReg,Reg_Write,dm_data,ALU_data,Write_Register})
);

// ******************Stage 5 WriteBack *****************

MUX32 MUX_MemtoReg(
    .data1_i    (ALU_data),
    .data2_i    (dm_data),
    .select_i   (MemtoReg),
    .data_o     (Write_Data)
);

Forwarding_unit Forwarding_unit(
    .clk_i      (clk_i),
    .MEM_Rd_i   (Write_Register_mem),
    .WB_Rd_i    (Write_Register),
    .MEM_W_i    (WB_mem[0]), 
    .WB_W_i     (Reg_Write),
    .RS_i       (rs_ex), 
    .RT_i       (rt_ex),
    .RS_Src_o   (RS_Src_Ctr),
    .RT_Src_o   (RT_Src_Ctr)
);


endmodule
