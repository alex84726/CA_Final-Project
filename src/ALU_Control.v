module ALU_Control(
  funct_i,
  ALUOp_i,
  ALUCtrl_o
);

input   [5:0] funct_i;
input   [1:0] ALUOp_i;
output  [2:0] ALUCtrl_o;

reg [2:0] temp;
reg [2:0] out ;
always @(*) begin
  case(funct_i[3:0])
    4'b0000: temp <= 3'b010; /* add */
    4'b0010: temp <= 3'b110; /* sub */
    4'b0100: temp <= 3'b000; /* and */
    4'b0101: temp <= 3'b001; /* or */
    /* 4'b1010: temp <= 3'b111 slt */
    4'b1000: temp <= 3'b101; /* mul */
    default: temp <= 3'b011; /* ? */
  endcase
end

always@(*) begin
  case(ALUOp_i)
    2'b00: out <= 3'b010; /* add */
    /* 2'b01: out <= 3'b110  sub */
    /* 2'b10: out <= 3'b001 /* or */
    2'b11: out <= temp;   /* R type */
    default: out <= 3'b011; /* ? */
  endcase
end

assign ALUCtrl_o = out;
endmodule
