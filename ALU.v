module ALU(
  data1_i,
  data2_i,
  ALUCtrl_i,
  data_o,
  Zero_o
);

input   [31:0]  data1_i,data2_i;
input   [2:0]   ALUCtrl_i;
output  [31:0]  data_o;
output  Zero_o;

/*
wire [31:0] sub_ab;
wire oflow_sub;
wire slt;

assign sub_ab = a-b;
assign oflow_sub = ((a[31]== b[31]) && (sub_ab[31] != a[31]))? 1:0;
assign slt = oflow_sub ? ~(a[31]):a[31];
*/
reg [31:0] out;

always @(*) begin
  case (ALUCtrl_i)
    3'b000: 
      out <= data1_i&data2_i;
    3'b001:
      out <= data1_i|data2_i;
    3'b010:
      out <= data1_i+data2_i;
    3'b110:
      out <= data1_i-data2_i;
   /* 3'b111:
      out <= {{31{1'b0},slt}; */
    3'b101:
      out <= data1_i*data2_i;
    default: out <= data1_i;
  endcase
end

assign data_o = out;
assign Zero_o = (0 == out);
endmodule
