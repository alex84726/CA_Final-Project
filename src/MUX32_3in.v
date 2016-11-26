module MUX32_3in(
  reg_i,
  preALU_i,
  DMorALU_i,
  select_i,
  data_o
);

input   [31:0]  reg_i,preALU_i,DMorALU_i;
input   [1:0]   select_i;
output  reg [31:0]  data_o;

//assign data_o = (select_i==1'b0)?data1_i:data2_i;
always@(*) begin
  case(select_i)
    2'b00 : data_o = reg_i; 
    2'b10 : data_o = preALU_i; 
    2'b01 : data_o = DMorALU_i; 
  endcase
end
endmodule


// input = 00 -> 1
// input = 01 -> 2
// input = 10 -> 3
