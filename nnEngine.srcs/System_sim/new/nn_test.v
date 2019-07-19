
module nn_test#(
parameter LENGHT = 100,
parameter filename = "readthis.txt",
parameter CLK_PERIOD=50
)();


reg[31:0] data [LENGHT:0]; // to hold input data

reg clk_i;
reg mem_mode;
reg rstn_i;
reg valid_i;

reg [7:0] img_in;
reg [1:0] oper_mode_in;
reg [31:0] pkt_in;


top uut (
   // Input Ports - Single Bit
   .clk_i          (clk_i),       
   .mem_mode       (mem_mode),    
   .rstn_i         (rstn_i),      
   .valid_i        (valid_i),     
   // Input Ports - Busses
   .img_in    (img_in[7:0]), 
   .oper_mode (oper_mode_in[1:0]),
   .pkt_in   (pkt_in[31:0]),
   // Output Ports - Single Bit
   .fifo_ready_o  (fifo_ready_o)
   // Output Ports - Busses
   // InOut Ports - Single Bit
   // InOut Ports - Busses
);

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
        $finish;
    end
    
//initial begin
//    reset();
//    push(1);
//    push(2);
//    push(3);

//end


endmodule