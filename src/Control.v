module Control (
    Op_i,
    Branch_o,
    Jump_o,
    Bus_o
);

input	  wire  [5:0] Op_i;
output  wire  [7:0] Bus_o;
        reg         RegDst_o; 
        reg         ALUSrc_o;
        reg         MemtoReg_o;
        reg         RegWrite_o;
        reg         MemWrite_o;
        reg         MemRead_o;
output  reg         Branch_o;
output  reg         Jump_o;
        reg         ExtOp_o;
        reg   [1:0] ALUOp_o;

parameter X = 0;

always@(*) begin
  if(Op_i==6'b000000) begin   // R-type
    RegDst_o = 1;
    ALUSrc_o = 0;
    MemtoReg_o = 0;
    RegWrite_o = 1;
    MemWrite_o = 0;
    MemRead_o = 0;
    Branch_o = 0;
    Jump_o = 0;
    ExtOp_o = X;
    ALUOp_o = 2'b11; 
  end
  else if(Op_i==6'b001101) begin   // ori
    RegDst_o = 0;
    ALUSrc_o = 1;
    MemtoReg_o = 0;
    RegWrite_o = 1;
    MemWrite_o = 0;
    Branch_o = 0;
    MemRead_o = 0;
    Jump_o = 0;
    ExtOp_o = 0;
    ALUOp_o = 2'b10; 
  end
  else if(Op_i==6'b100111) begin   // lw
    RegDst_o = 0;
    ALUSrc_o = 1;
    MemtoReg_o = 1;
    RegWrite_o = 1;
    MemWrite_o = 0;
    MemRead_o = 1;
    Branch_o = 0;
    Jump_o = 0;
    ExtOp_o = 1;
    ALUOp_o = 2'b00; 
  end
  else if(Op_i==6'b101011) begin   // sw
    RegDst_o = X;
    ALUSrc_o = 1;
    MemtoReg_o = X;
    RegWrite_o = 0;
    MemWrite_o = 1;
    MemRead_o = 0;
    Branch_o = 0;
    Jump_o = 0;
    ExtOp_o = 1;
    ALUOp_o = 2'b00; 
  end
  else if(Op_i==6'b000100) begin   // beq
    RegDst_o = X;
    ALUSrc_o = 0;
    MemtoReg_o = X;
    RegWrite_o = 0;
    MemWrite_o = 0;
    MemRead_o = 0;
    Branch_o = 1;
    Jump_o = 0;
    ExtOp_o = X;
    ALUOp_o = 2'b01; 
  end
  else if(Op_i==6'b000010) begin   // jump
    RegDst_o = X;
    ALUSrc_o = X;
    MemtoReg_o = X;
    RegWrite_o = 0;
    MemWrite_o = 0;
    MemRead_o = 0;
    Branch_o = 0;
    Jump_o = 1;
    ExtOp_o = X;
    ALUOp_o = 2'bXX; 
  end
end

assign Bus_o[7:0] = {ALUSrc_o, ALUOp_o[1:0], RegDst_o, MemRead_o, MemWrite_o, MemtoReg_o, RegWrite_o} 
endmodule

