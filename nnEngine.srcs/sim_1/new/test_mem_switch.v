`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2019 01:50:21 AM
// Design Name: 
// Module Name: test_mem_switch
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


module test_mem_switch
  #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 8,
    parameter NUM_WORDS  = 5
  )();
    // Port A from Stage
    reg                      af_en_i;
    reg   [ADDR_WIDTH-1:0]   af_waddr_i;
    reg   [ADDR_WIDTH-1:0]   af_raddr_i;
    reg   [DATA_WIDTH-1:0]   af_wdata_i;
    reg                      af_we_i;
    reg   [DATA_WIDTH/8-1:0] af_be_i;
    wire   [DATA_WIDTH-1:0]   af_rdata_o;
    // Port B from Stage
    reg                      bf_en_i;
    reg   [ADDR_WIDTH-1:0]   bf_waddr_i;
    reg   [ADDR_WIDTH-1:0]   bf_raddr_i;
    reg   [DATA_WIDTH-1:0]   bf_wdata_i;
    reg                      bf_we_i;
    reg   [DATA_WIDTH/8-1:0] bf_be_i;
    wire  [DATA_WIDTH-1:0]   bf_rdata_o;
    
    // Port A to SPRAM
    wire                      at_en_o;
    wire   [ADDR_WIDTH-1:0]   at_waddr_o;
    wire   [ADDR_WIDTH-1:0]   at_raddr_o;
    wire   [DATA_WIDTH-1:0]   at_wdata_o;
    wire                      at_we_o;
    wire   [DATA_WIDTH/8-1:0] at_be_o;
	
    wire    [DATA_WIDTH-1:0]   at_rdata_i;
    // Port B to SP-RAM
    wire                      bt_en_o;
    wire   [ADDR_WIDTH-1:0]   bt_waddr_o;
    wire   [ADDR_WIDTH-1:0]   bt_raddr_o;
    wire   [DATA_WIDTH-1:0]   bt_wdata_o;
    wire                      bt_we_o;
    wire   [DATA_WIDTH/8-1:0] bt_be_o;
	
    wire    [DATA_WIDTH-1:0]   bt_rdata_i;
    
    reg                       sw_pos_i;
	reg 					   clk;
	
	sp_ram  mem_a(.clk(clk),
                .en_i(at_en_o),
                .waddr_i(at_waddr_o),
                .raddr_i(at_raddr_o),
                .wdata_i(at_wdata_o),
                .rdata_o(at_rdata_i),
                .we_i(at_we_o),
                .be_i(at_be_o)
                );

	sp_ram  mem_b(.clk(clk),
                .en_i(bt_en_o),
                .waddr_i(bt_waddr_o),
                .raddr_i(bt_raddr_o),
                .wdata_i(bt_wdata_o),
                .rdata_o(bt_rdata_i),
                .we_i(bt_we_o),
                .be_i(bt_be_o)
                );
				
	mem_switch sw1( .sw_pos_i(sw_pos_i),
				.af_en_i(af_en_i),
				.af_waddr_i(af_waddr_i),
				.af_raddr_i(af_raddr_i),
				.af_wdata_i(af_wdata_i),
				.af_we_i(af_we_i),
				.af_be_i(af_be_i),
				.af_rdata_o(af_rdata_o),
				.bf_en_i(bf_en_i),
				.bf_waddr_i(bf_waddr_i),
				.bf_raddr_i(bf_raddr_i),
				.bf_wdata_i(bf_wdata_i),
				.bf_we_i(bf_we_i),
				.bf_be_i(bf_be_i),
				.bf_rdata_o(bf_rdata_o), 
				.at_en_o(at_en_o),
				.at_waddr_o(at_waddr_o),
				.at_raddr_o(at_raddr_o),
				.at_wdata_o(at_wdata_o),
				.at_we_o(at_we_o),
				.at_be_o(at_be_o),
				.at_rdata_i(at_rdata_i),
				.bt_en_o(bt_en_o),
				.bt_waddr_o(bt_waddr_o),
				.bt_raddr_o(bt_raddr_o),
				.bt_wdata_o(bt_wdata_o),
				.bt_we_o(bt_we_o),
				.bt_be_o(bt_be_o),
				.bt_rdata_i(bt_rdata_i)
				);
	
	task a_read;
    input [ADDR_WIDTH-1:0] read_addr;
    begin
        af_en_i = 1;
        af_be_i = 1;
        af_raddr_i = read_addr;
        @(posedge clk);
        @(negedge clk);
        af_en_i = 0;
        af_be_i = 0;
        af_raddr_i = 0;
    end
endtask

    task a_write;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    begin
        af_en_i = 1;
        af_be_i = 1;
        af_we_i = 1;
        af_waddr_i = write_addr;
        af_wdata_i = write_data;
        @(posedge clk);
        @(negedge clk);
        af_en_i = 0;
        af_be_i = 0;
        af_we_i = 0;
        af_waddr_i = 0;
        af_wdata_i = 0;
    end
endtask

    task a_read_write;
    input [ADDR_WIDTH-1:0] read_addr;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    begin
        af_en_i = 1;
        af_be_i = 1;
        af_we_i = 1;
        af_waddr_i = write_addr;
        af_wdata_i = write_data;
        af_raddr_i = read_addr;
        @(posedge clk);
        @(negedge clk);
        af_en_i = 0;
        af_we_i = 0;
        af_be_i = 0;
        af_waddr_i = 0;
        af_wdata_i = 0;
        af_raddr_i = 0;
    end
endtask

	task b_read;
    input [ADDR_WIDTH-1:0] read_addr;
    begin
        bf_en_i = 1;
        bf_be_i = 1;
        bf_raddr_i = read_addr;
        @(posedge clk);
        @(negedge clk);
        bf_en_i = 0;
        bf_be_i = 0;
        bf_raddr_i = 0;
    end
endtask

    task b_write;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    begin
        bf_en_i = 1;
        bf_be_i = 1;
        bf_we_i = 1;
        bf_waddr_i = write_addr;
        bf_wdata_i = write_data;
        @(posedge clk);
        @(negedge clk);
        bf_en_i = 0;
        bf_be_i = 0;
        bf_we_i = 0;
        bf_waddr_i = 0;
        bf_wdata_i = 0;
    end
endtask

    task b_read_write;
    input [ADDR_WIDTH-1:0] read_addr;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    begin
        bf_en_i = 1;
        bf_be_i = 1;
        bf_we_i = 1;
        bf_waddr_i = write_addr;
        bf_wdata_i = write_data;
        bf_raddr_i = read_addr;
        @(posedge clk);
        @(negedge clk);
        bf_en_i = 0;
        bf_we_i = 0;
        bf_be_i = 0;
        bf_waddr_i = 0;
        bf_wdata_i = 0;
        bf_raddr_i = 0;
    end
endtask
	
	always begin #50 clk = ~clk; end
	
	initial 
	begin
		sw_pos_i = 0;
		clk = 0;
		a_write(12'h0, 8'h44);
		b_write(12'h1, 8'h69);
		sw_pos_i = 1;
		b_read_write(12'h0, 12'h2, 8'h9);
		a_read_write(12'h1, 12'h3, 8'h5);
		sw_pos_i = 0;
		a_read(12'h3);
		b_read(12'h2);
	end
	
endmodule
