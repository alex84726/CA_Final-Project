module HazDetect_unit(
    clk_i,
    MemRead_i,
    Prev_RT_i,
    RSRT_i,
    PCWrite_o,
    IFIDWrite_o,
    IDEXWrite_o
);

// Ports
input               clk_i;
input               MemRead_i;
input   [4:0]       Prev_RT_i;
input   [9:0]       RSRT_i;
output  reg         PCWrite_o;
output  reg         IFIDWrite_o; 
output  reg         IDEXWrite_o;

wire [4:0]  Cur_RS;
wire [4:0]  Cur_RT;

assign Cur_RS = RSRT_i[9:5];
assign Cur_RT = RSRT_i[4:0];

always @(posedge clk_i) begin
    // EX hazard
    if((MemRead_i)&&((Prev_RT_i == Cur_RS)||(Prev_RT_i == Cur_RT))) begin
      //stall 1 cycle
      PCWrite_o = 1'b1;
      IFIDWrite_o = 1'b1;
      IDEXWrite_o = 1'b1;
    end
    else begin
      PCWrite_o = 1'b0;
      IFIDWrite_o = 1'b0;
      IDEXWrite_o = 1'b0;
    end 
end
   
endmodule 
