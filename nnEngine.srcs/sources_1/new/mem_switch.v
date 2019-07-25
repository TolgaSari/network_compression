`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2019 12:01:29 AM
// Design Name: 
// Module Name: mem_switch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_switch
#(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 8,
    parameter NUM_WORDS  = 5
  )(
    // Port to CPU
    input                           cpu_en_i,
    input   [ADDR_WIDTH-1:0]        cpu_waddr_i,
    input   [ADDR_WIDTH-1:0]        cpu_raddr_i,
    input   [DATA_WIDTH-1:0]        cpu_wdata_i,
    input                           cpu_we_i,
    input   [DATA_WIDTH/8-1:0]      cpu_be_i,
    output reg  [DATA_WIDTH-1:0]    cpu_rdata_o,
    // Port A to Stage
    input                      af_en_i,
    input   [ADDR_WIDTH-1:0]   af_waddr_i,
    input   [ADDR_WIDTH-1:0]   af_raddr_i,
    input   [DATA_WIDTH-1:0]   af_wdata_i,
    input                      af_we_i,
    input   [DATA_WIDTH/8-1:0] af_be_i,
    output reg  [DATA_WIDTH-1:0]   af_rdata_o,
    // Port B to Stage
    input                      bf_en_i,
    input   [ADDR_WIDTH-1:0]   bf_waddr_i,
    input   [ADDR_WIDTH-1:0]   bf_raddr_i,
    input   [DATA_WIDTH-1:0]   bf_wdata_i,
    input                      bf_we_i,
    input   [DATA_WIDTH/8-1:0] bf_be_i,
    output reg [DATA_WIDTH-1:0]   bf_rdata_o,
    
    // Port A to SPRAM
    output reg                     at_en_o,
    output reg  [ADDR_WIDTH-1:0]   at_waddr_o,
    output reg  [ADDR_WIDTH-1:0]   at_raddr_o,
    output reg  [DATA_WIDTH-1:0]   at_wdata_o,
    output reg                     at_we_o,
    output reg  [DATA_WIDTH/8-1:0] at_be_o,
    input  [DATA_WIDTH-1:0]   at_rdata_i,
    // Port B to SP-RAM
    output reg                      bt_en_o,
    output reg  [ADDR_WIDTH-1:0]   bt_waddr_o,
    output reg  [ADDR_WIDTH-1:0]   bt_raddr_o,
    output reg  [DATA_WIDTH-1:0]   bt_wdata_o,
    output reg                     bt_we_o,
    output reg  [DATA_WIDTH/8-1:0] bt_be_o,
    input    [DATA_WIDTH-1:0]   bt_rdata_i,
    
    input                      sw_pos_i
  );
  
  always@(*)
  begin
	  case(sw_pos_i)
	  2'b00: // Mem1 => weights, mem2 => layer_out 
	  begin
		at_en_o    <= af_en_i;
		at_waddr_o <= af_waddr_i;
		at_raddr_o <= af_raddr_i;
		at_wdata_o <= af_wdata_i;
		at_we_o    <= af_we_i;
		at_be_o    <= af_be_i;
		af_rdata_o <= at_rdata_i;
		
		bt_en_o    <= bf_en_i;
		bt_waddr_o <= bf_waddr_i;
		bt_raddr_o <= bf_raddr_i;
		bt_wdata_o <= bf_wdata_i;
		bt_we_o    <= bf_we_i;
		bt_be_o    <= bf_be_i;
		bf_rdata_o <= bt_rdata_i;
	  end
	  2'b01: // Mem2 => weights, mem1 => layer_out 
	  begin
		bt_en_o    <= af_en_i;
		bt_waddr_o <= af_waddr_i;
		bt_raddr_o <= af_raddr_i;
		bt_wdata_o <= af_wdata_i;
		bt_we_o    <= af_we_i;
		bt_be_o    <= af_be_i;
		bf_rdata_o <= at_rdata_i;
		
		at_en_o    <= bf_en_i;
		at_waddr_o <= bf_waddr_i;
		at_raddr_o <= bf_raddr_i;
		at_wdata_o <= bf_wdata_i;
		at_we_o    <= bf_we_i;
		at_be_o    <= bf_be_i;
		af_rdata_o <= bt_rdata_i;
	  end
	  2'b10:// CPU drives mem1
	  begin
	    bt_en_o    <= 1'bZ;
		bt_waddr_o <= 12'bZ;
		bt_raddr_o <= 12'bZ;
		bt_wdata_o <= 16'bZ;
		bt_we_o    <= 1'bZ;
		bt_be_o    <= 1'bZ;
		bf_rdata_o <= 16'bZ;
		
		at_en_o    <= cpu_en_i;
		at_waddr_o <= cpu_waddr_i;
		at_raddr_o <= cpu_raddr_i;
		at_wdata_o <= cpu_wdata_i;
		at_we_o    <= cpu_we_i;
		at_be_o    <= cpu_be_i;
		af_rdata_o <= cpu_rdata_o;
	  end
	  2'b11:// CPU drives mem2
	  begin
	  	at_en_o    <= 1'bZ;
		at_waddr_o <= 12'bZ;
		at_raddr_o <= 12'bZ;
		at_wdata_o <= 16'bZ;
		at_we_o    <= 1'bZ;
		at_be_o    <= 1'bZ;
		af_rdata_o <= 16'bZ;
		
		bt_en_o    <= cpu_en_i;
		bt_waddr_o <= cpu_waddr_i;
		bt_raddr_o <= cpu_raddr_i;
		bt_wdata_o <= cpu_wdata_i;
		bt_we_o    <= cpu_we_i;
		bt_be_o    <= cpu_be_i;
		bf_rdata_o <= cpu_rdata_o;
	  end
	  endcase
  end
endmodule