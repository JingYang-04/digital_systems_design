// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (30 points) Complete the Verilog module below based on the provided description. Here is one `solution <spring_exam_f_problem_03-solution>`.
//
// Code
// ====
module fifo(
	input	rden,
	input	wren,
	input   clk,
	input	reset,
	input   sclr,
	input   [7:0] din,
	output	[7:0] dout,
	output empty,
	output full,
	output read_valid
    );
    
    // read and write counter    
    parameter AWIDTH = 3;   
    reg [AWIDTH-1:0] wraddr,rdaddr;
    wire [AWIDTH-1:0] next_wraddr;
    wire [AWIDTH-1:0] next_rdaddr;
    
    // write and full logic  
    assign next_wraddr = wraddr + 1;
    assign full = (next_wraddr == rdaddr);

    // write counter
    reg wren_int;
    always @(posedge clk or posedge reset) begin
    if (reset) wraddr <= 0;
        else begin
            if (wren_int) wraddr <= next_wraddr;		
        end   
    end
    
    // read and empty logic 
    assign next_rdaddr = rdaddr + 1;
    assign empty = (rdaddr == wraddr);
    
    // read counter
    reg rden_int; 
    always @(posedge clk or posedge reset) begin
    if (reset) rdaddr <= 0;
        else begin
            if (rden_int) rdaddr <= next_rdaddr;	
        end   
    end
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------
    // Instatiate a single_port_mem netId with 8(WIDTH)*8(DEPTH), assign correspondings input and outputs.

    // SOLUTION_BEGIN
    reg wr_or_rd;
    reg [7:0] addr_to_ram;

    wire en_chip;
    assign en_chip =  wren && (full == 0) || rden && (empty == 0);
    
    single_port_ram #(.DATA_WIDTH(8),.ADDR_WIDTH(3)) u1 (.en(en_chip), .we(wr_or_rd), .clk(clk), .addr( addr_to_ram), .din(din), .dout(dout));
    // SOLUTION_END

    // Implement read and write logic on single_port_ram. 1. If read and write operations occur at the same time, the write operation has higher priority. 2. If data can be read from fifo, the read_valid is 1.

    // SOLUTION_BEGIN
    // read and write logic    
    reg read_valid;    
    always @* begin
        wren_int = 0;
        rden_int = 0;
        wr_or_rd = 1;
        read_valid = 0;
        addr_to_ram = 0;
        
        if(wren ==1 &&  rden == 1) begin
            if(full == 0) begin
                wren_int = 1;
                rden_int = 0;
                addr_to_ram = wraddr;
            end else begin
                if(empty == 0) begin
                    wr_or_rd = 0;
                    rden_int = 1;
                    read_valid = 1;
                    addr_to_ram = rdaddr; 
                end
            end          
        end else begin
            if (wren && (full == 0))begin
                wren_int = 1;
                addr_to_ram = wraddr;
            end
            
            if ( rden && (empty == 0)) begin
                wr_or_rd = 0;
                rden_int = 1;
                read_valid = 1;
                addr_to_ram = rdaddr;
            end  
        
        end
    end
    // SOLUTION_END

endmodule


// .. lp_build:: Mr6c2yr7FeEm
//   :builder: verilog