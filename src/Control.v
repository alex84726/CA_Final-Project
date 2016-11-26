module Control(
  Op_i,
  RegDst_o,
  ALUOp_o,
  ALUSrc_o,
  RegWrite_o
);

input  [5:0] Op_i;
output   RegDst_o;
output   [1:0] ALUOp_o;
output   ALUSrc_o, RegWrite_o;

reg rd,alus,rw;
reg [1:0] aluo;

always @(*) begin 
  case(Op_i)
    6'b000000: begin
      rd <= 1'b1;
      aluo <= 2'b11;
      alus <= 1'b0;
      rw <= 1'b1;
    end
    6'b001000: begin
      rd <= 1'b0;
      aluo <= 2'b00;
      alus <= 1'b1;
      rw <= 1'b1;
    end
    default: begin
      rd <= 1'b1;
      aluo <= 2'b01;
      alus <= 1'b0;
      rw <= 1'b0;
    end
  endcase
end

assign  RegDst_o = rd;
assign  ALUOp_o = aluo;
assign  ALUSrc_o = alus;
assign  RegWrite_o = rw;
endmodule
