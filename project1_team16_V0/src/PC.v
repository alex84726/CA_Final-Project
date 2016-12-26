module PC
(
    clk_i,
//    rst_i,
    flushPC_i,
    start_i,
    pc_i,
    pc_o
);

// Ports
input               clk_i;
//input               rst_i;
input               start_i;
input               flushPC_i;
input   [31:0]      pc_i;
output  [31:0]      pc_o;

// Wires & Registers
reg     [31:0]      pc_o;
always@(posedge clk_i ) begin
    
    //if begin
    if(start_i) begin
      if (flushPC_i)
        pc_o <= pc_o;
      else
        pc_o <= pc_i;
    end
    else begin
      pc_o <= pc_o;
    end
    //end
end

endmodule
