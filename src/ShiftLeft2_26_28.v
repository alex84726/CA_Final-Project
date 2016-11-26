module shiftLeft_26_28(
  data_i,
  data_o
);

input   wire  [25:0]  data_i;
output  reg   [27:0]  data_o;

always @(*) begin
  data_o[27:0] = { data_i[25:0], {2'b00} };
end

endmodule



