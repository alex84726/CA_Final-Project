module ALU_Control (
  funct_i,
  ALUOp_i,
  ALUCtrl_o
);

input   wire  [5:0] funct_i;
input   wire  [1:0] ALUOp_i;
output  reg   [2:0] ALUCtrl_o;

always @(*) begin
  if(ALUOp_i==2'b00) begin      // Add for load/store
    ALUCtrl_o = 3'b010;   
  end
  else if(ALUOp_i==2'b01) begin  // Sub for beq
    ALUCtrl_o = 3'b110;
  end
  else if(ALUOp_i==2'b10) begin  // Andi
    ALUCtrl_o = 3'b010;
  end
  else if(ALUOp_i==2'b11) begin  // R-type -> need to refer to func field
    if(funct_i[3:0]==4'b0000) begin
      ALUCtrl_o = 3'b010;
    end
    if(funct_i[3:0]==4'b0010) begin
      ALUCtrl_o = 3'b110;
    end
    if(funct_i[3:0]==4'b0100) begin
      ALUCtrl_o = 3'b000;
    end
    if(funct_i[3:0]==4'b0101) begin
      ALUCtrl_o = 3'b001;
    end
    if(funct_i[3:0]==4'b1010) begin
      ALUCtrl_o = 3'b111;
    end
  end
end
endmodule

