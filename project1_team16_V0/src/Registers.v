module Registers
(
    clk_i,
    RSaddr_i,
    RTaddr_i,
    RDaddr_i, 
    RDdata_i,
    RegWrite_i, 
    RSdata_o, 
    RTdata_o 
);

// Ports
input               clk_i;
input   [4:0]       RSaddr_i;
input   [4:0]       RTaddr_i;
input   [4:0]       RDaddr_i;
input   [31:0]      RDdata_i;
input               RegWrite_i;
output reg [31:0]      RSdata_o; 
output reg [31:0]      RTdata_o;

// Register File
reg     [31:0]      register        [0:31];

// Read Data      
always@(*) begin
  RSdata_o = register[RSaddr_i];
  RTdata_o = register[RTaddr_i];
end

// Write Data   
always@(negedge clk_i) begin
    if(RegWrite_i)
        register[RDaddr_i] <= RDdata_i;
end
   
endmodule 
