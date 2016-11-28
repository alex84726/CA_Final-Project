module Forwarding_unit(
    clk_i,
    MEM_Rd_i,
    WB_Rd_i,
    MEM_W_i, 
    WB_W_i,
    RS_i, 
    RT_i,
    RS_Src_o,
    RT_Src_o 
);

// Ports
input               clk_i;
input   [4:0]       MEM_Rd_i;
input   [4:0]       WB_Rd_i;
input               MEM_W_i;
input               WB_W_i;
input   [4:0]       RS_i;
input   [4:0]       RT_i;
output  reg [1:0]       RS_Src_o; 
output  reg [1:0]       RT_Src_o;

//RS_Src_o
always @(posedge clk_i) begin
    // EX hazard
    if((MEM_W_i == 1'b1)&&(MEM_Rd_i != 5'b0)&&(MEM_Rd_i == RS_i)) begin
      RS_Src_o = 2'b10;
    end
    // MEM hazard
    else if((WB_W_i == 1'b1)&&(WB_Rd_i != 5'b0)&&(MEM_Rd_i != RS_i)&&(WB_Rd_i == RS_i)) begin
      RS_Src_o = 2'b01;
    end
    else begin
      RS_Src_o = 2'b00;
    end
end

//RT_Src_o
always @(posedge clk_i) begin
    // EX hazard
    if((MEM_W_i == 1'b1)&&(MEM_Rd_i != 5'b0)&&(MEM_Rd_i == RT_i)) begin
      RT_Src_o = 2'b10;
    end
    else if((WB_W_i == 1'b1)&&(WB_Rd_i != 5'b0)&&(MEM_Rd_i != RT_i)&&(WB_Rd_i == RT_i)) begin
      RT_Src_o = 2'b01;
    end
    else begin
      RT_Src_o = 2'b00;
    end
end
   
endmodule 
