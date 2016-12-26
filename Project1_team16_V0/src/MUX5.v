module MUX5(
  data1_i,
  data2_i,
  select_i,
  data_o
);

output  [4:0] data_o;
input   [4:0] data1_i, data2_i;
input   select_i;

assign data_o = (select_i==1'b0)?data1_i:data2_i;

endmodule
