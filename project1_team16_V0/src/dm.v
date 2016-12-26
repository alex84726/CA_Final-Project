/*
 * Data Memory.
 *
 * 32-bit data with a 7 bit address (128 entries).
 *
 * The read and write operations operate somewhat independently.
 *
 * Any time the read signal (rd) is high the data stored at the
 * given address (addr) will be placed on 'rdata'.
 *
 * Any time the write signal (wr) is high the data on 'wdata' will
 * be stored at the given address (addr).
 * 
 * If a simultaneous read/write is performed the data written
 * can be immediately read out.
 */

`ifndef _dm
`define _dm

module dm(
		input wire			clk,
		input wire	[31:0]	addr,
		input wire			rd,
    input wire      wr,
		input wire 	[31:0]	wdata,
		output reg	[31:0]	rdata);

	reg [31:0] mem [31:0];  // 32-bit memory with 128 entries

  always @(negedge clk) begin
		if (wr) begin
			mem[addr] <= wdata;
		end
	end
  //always @(posedge clk) begin
	//	if (rd) begin
	//		rdata = mem[addr];
	//	end
	//end
  always @(*) begin
		if (rd) begin
			rdata <= mem[addr][31:0];
		end
	end
  //assign rdata = mem[addr][31:0];
	//assign rdata = wr ? wdata : mem[addr][31:0];
	// During a write, avoid the one cycle delay by reading from 'wdata'

endmodule

`endif
