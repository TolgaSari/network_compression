`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2019 01:04:53 PM
// Design Name: 
// Module Name: top
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


module top
 #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 16,
    parameter NUM_WORDS  = 5
  )(
    input clk_i,
    input rstn_i,
    input mem_mode,
    input [1:0] oper_mode, // input bias, input image, do forward pass
    input [31:0] pkt_in,
    input valid_i,
    
    input   [1:0]                   cpu_en_i,
    input   [ADDR_WIDTH-1:0]        cpu_waddr_i,
    input   [ADDR_WIDTH-1:0]        cpu_raddr_i,
    input   [DATA_WIDTH-1:0]        cpu_wdata_i,
    input                           cpu_we_i,
    input   [DATA_WIDTH/8-1:0]      cpu_be_i,
    output  [DATA_WIDTH-1:0]        cpu_rdata_o,
    
    input [7:0] img_in,
    
    output result_ready_o,
    output fifo_ready_o
    );
    
    reg                      af_en_i;
    reg   [ADDR_WIDTH-1:0]   af_waddr_i;
    reg   [ADDR_WIDTH-1:0]   af_raddr_i;
    reg   [DATA_WIDTH-1:0]   af_wdata_i;
    reg                      af_we_i;
    reg   [DATA_WIDTH/8-1:0] af_be_i;
    wire   [DATA_WIDTH-1:0]   mul_value;
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
    
    wire [31:0] weight_pkt;
    wire [27:0] acc_pkt;
    wire        mul_valid;
    wire        mul_ready;
    wire        acc_valid;
    
    io_generic_fifo input_fifo (
   // Input Ports - Single Bit
   .clk_i           (clk_i),        
   .clr_i           (1'b0),        
   .ready_i         (mul_ready),      
   .rstn_i          (rstn_i),       
   .valid_i         (valid_i),      
   // Input Ports - Busses
   .data_i    (pkt_in[31:0]), 
   // Output Ports - Single Bit
   .ready_o         (fifo_ready_o),      
   .valid_o         (mul_valid),      
   // Output Ports - Busses
   .data_o    (weight_pkt)
   //.elements_o (elements_o)
   // InOut Ports - Single Bit
   // InOut Ports - Busses
);

	sp_ram  mem_a(  .clk(clk_i),
                    .en_i(at_en_o),
                    .waddr_i(at_waddr_o),
                    .raddr_i(at_raddr_o),
                    .wdata_i(at_wdata_o),
                    .rdata_o(at_rdata_i),
                    .we_i(at_we_o)
                   // .be_i(at_be_o)
                 );

	sp_ram  mem_b(  .clk(clk_i),
                    .en_i(bt_en_o),
                    .waddr_i(bt_waddr_o),
                    .raddr_i(bt_raddr_o),
                    .wdata_i(bt_wdata_o),
                    .rdata_o(bt_rdata_i),
                    .we_i(bt_we_o)
             //       .be_i(bt_be_o)
                );
        mul_stage mul_stage_inst (
       // Input Ports - Single Bit
       .clk_i         (clk_i),      
       .rstn_i        (rstn_i),     
       .valid_i       (mul_valid),    
       // Input Ports - Busses
       .col_i   (weight_pkt[11:0]),
       .value_i (mul_value),
       .weight_i (weight_pkt[31:24]),
       // Output Ports - Single Bit
       .ready_o       (mul_ready),    
       .valid_o       (acc_valid),    
       // Output Ports - Busses
       .data_o  (acc_pkt[27:0])
       // InOut Ports - Single Bit
       // InOut Ports - Busses
    );
	mem_switch sw1( .sw_pos_i   (oper_mode),
	
	                .cpu_en_i    (cpu_en_i),
                    .cpu_waddr_i (cpu_waddr_i),
                    .cpu_raddr_i (cpu_raddr_i),
                    .cpu_wdata_i (cpu_wdata_i),
                    .cpu_we_i    (cpu_we_i),
                    //.cpu_be_i    (cpu_be_i),
                    .cpu_rdata_o (cpu_rdata_o),
                    
                    .af_en_i    (mul_valid),
                    .af_waddr_i (),
                    .af_raddr_i (weight_pkt[23:12]),
                    .af_wdata_i (),
                    .af_we_i    (),
                    .af_be_i    (),
                    .af_rdata_o (mul_value),
                    
                    .bf_en_i    (bf_en_i),
                    .bf_waddr_i (bf_waddr_i),
                    .bf_raddr_i (bf_raddr_i),
                    .bf_wdata_i (bf_wdata_i),
                    .bf_we_i    (bf_we_i),
                    .bf_be_i    (bf_be_i),
                    .bf_rdata_o (bf_rdata_o), 
                    
                    .at_en_o    (at_en_o),
                    .at_waddr_o (at_waddr_o),
                    .at_raddr_o (at_raddr_o),
                    .at_wdata_o (at_wdata_o),
                    .at_we_o    (at_we_o),
                    .at_be_o    (at_be_o),
                    .at_rdata_i (at_rdata_i),
                    
                    .bt_en_o    (bt_en_o),
                    .bt_waddr_o (bt_waddr_o),
                    .bt_raddr_o (bt_raddr_o),
                    .bt_wdata_o (bt_wdata_o),
                    .bt_we_o    (bt_we_o),
                    .bt_be_o    (bt_be_o),
                    .bt_rdata_i (bt_rdata_i)
				);


    
endmodule
