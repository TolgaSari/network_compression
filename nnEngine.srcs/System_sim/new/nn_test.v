
module nn_test#(
parameter ADDR_WIDTH = 12,
parameter DATA_WIDTH = 8,
parameter NUM_WORDS  = 5,
parameter LENGHT = 100,
parameter filename = "readthis.txt",
parameter CLK_PERIOD=50
)();


reg[31:0] data [LENGHT:0]; // to hold input data

reg clk_i;
reg [1:0] oper_mode;
reg rstn_i;
reg valid_i;

reg [7:0] img_in;
reg [1:0] oper_mode_in;
reg [31:0] pkt_in;

reg  [15:0] cpu_wdata_i;
reg  [11:0] cpu_waddr_i;
reg  [11:0] cpu_raddr_i;
reg         cpu_en_i;
reg  [1:0]  cpu_be_i;
reg         cpu_we_i;
wire        fifo_ready_o;

wire [15:0] cpu_rdata_o;

top top_inst (
   // Input Ports - Single Bit
   .clk_i             (clk_i),          
   .cpu_en_i          (cpu_en_i),       
   .cpu_we_i          (cpu_we_i),       
   //.mem_mode          (oper_mode),       
   .rstn_i            (rstn_i),         
   .valid_i           (valid_i),        
   // Input Ports - Busses
   .cpu_be_i     (cpu_be_i),  
   .cpu_raddr_i (cpu_raddr_i[11:0]),
   .cpu_waddr_i (cpu_waddr_i[11:0]),
   .cpu_wdata_i (cpu_wdata_i[15:0]),
   .img_in       (img_in[7:0]),    
   .oper_mode    (oper_mode[1:0]), 
   .pkt_in      (pkt_in[31:0]),   
   // Output Ports - Single Bit
   .fifo_ready_o      (fifo_ready_o),   
  // .result_ready_o    (result_ready_o), 
   // Output Ports - Busses
   .cpu_rdata_o (cpu_rdata_o[15:0])
   // InOut Ports - Single Bit
   // InOut Ports - Busses
);
    task read;
    input [ADDR_WIDTH-1:0] read_addr;
    begin
        cpu_en_i = 1;
        //cpu_be_i = 1;
        cpu_raddr_i = read_addr;
        @(posedge clk_i);
        @(negedge clk_i);
        cpu_en_i = 0;
        //cpu_be_i = 0;
        cpu_raddr_i = 0;
    end
endtask

    task write;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    begin
        cpu_en_i = 1;
        cpu_be_i = 2'h3;
        cpu_we_i = 1;
        cpu_waddr_i = write_addr;
        cpu_wdata_i = write_data;
        @(posedge clk_i);
        @(negedge clk_i);
        cpu_en_i = 0;
        cpu_be_i = 0;
        cpu_we_i = 0;
        cpu_waddr_i = 0;
        cpu_wdata_i = 0;
    end
endtask

    task push;
        input [31:0] data_in;
    begin
        valid_i = 0;
        if(~fifo_ready_o)
        begin
            @(negedge fifo_ready_o);
        end
            pkt_in = data_in;
            valid_i = 1;
        @(posedge clk_i);
            valid_i = 0;
    end
endtask

    task reset;
    begin
        //clr_i = 0;
        //ready_i = 0;
        pkt_in = 0;
        valid_i = 0;
        clk_i = 0;
        rstn_i = 1;
        @(posedge clk_i);
        rstn_i = 0;
        @(posedge clk_i);
        rstn_i = 1;

    end
endtask
    
//    task pop;
//    begin
//    ready_i = 1;
//    @(posedge clk_i);
//    ready_i = 0;
//    end
//endtask

    always
    begin
        #(CLK_PERIOD/2) clk_i = ~clk_i;
    end
    
    task write_mem;
    integer x;
    begin
        $readmemh(filename, data);
        for(x = 0; x < LENGHT; x = x + 1)
        begin
            oper_mode = 2'h2;
            write(x,data[x]);
        end
    end
    
endtask
        task layer_pass;
    integer x;
    begin
        $readmemh(filename, data);
        for(x = 0; x < LENGHT; x = x + 1)
        begin
            push(data[x]);
        end
    end
endtask

    always
    begin
        #(CLK_PERIOD/2) clk_i = ~clk_i;
    end
    
    initial begin
        reset();
        layer_pass();
        write_mem();
        $finish;
    end
    
//initial begin
//    reset();
//    push(1);
//    push(2);
//    push(3);

//end


endmodule