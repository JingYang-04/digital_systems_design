// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// ***********************************************
// |docname| - testbench for `spring_exam_f_problem_01.v`
// ***********************************************
// To use this stand-alone, also download the `test vectors <../../_static/spring_exam_f_problem_02-test.txt>`_.

`timescale 1ns / 1ps
// This test bentch is to single port ram module;
module tb_single_port_ram;

    parameter ADDR_WIDTH = 3;
    parameter DATA_WIDTH = 8;
    
    // Inputs to UUT.
    reg                     en;   // control chip
    reg                     we;   //write enable signal
    reg                     clk;   //clock signal
    reg  [(DATA_WIDTH-1):0] din;  //data to be written
    reg  [(ADDR_WIDTH-1):0] addr;  //address for write/read operation
      
    // Outputs from UUT.
    wire [(DATA_WIDTH-1):0] dout;     //read data

    reg [(DATA_WIDTH-1):0] tb_dout;
    
    integer i,fd;
    integer errors;
    integer count;
    reg [8*100:1] aline;
    reg pass;
    
    
    // Instantiate the Unit Under Test (UUT)
    single_port_ram #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) uut(
            .en(en),
            .we(we),
            .clk(clk), 
            .din (din),
            .addr(addr),
            .dout(dout)
    );
    
    // Create a 20 ns clock.
    initial begin
        clk = 0;
        forever  #10 clk = ~clk;
    end 
       
    initial begin
    // Initialize Inputs
        en = 0;
        we = 0;
        addr = 0;
        din = 0;
        errors = 0;
        count = 0;
        #100;
        @(negedge clk);
        
        i = 0;
        errors = 0;
        count = 0;
        
        fd = $fopen("../../../spring_exam_f_problem_02.txt","r");
        // for post-route simulation, one directory deeper
        fd = fd ? fd : $fopen("../../../../spring_exam_f_problem_02.txt","r");
        // When running as an e-book, in the current directory.
        fd = fd ? fd : $fopen("spring_exam_f_problem_02.txt","r");
        
        // Read and discard the first line, which must be a comment;
        if (fd === 0 || $fgets(aline, fd) === 0) begin
            $display("Cannot open/read vectors file 'spring_exam_f_problem_02.txt', simulation exiting");
            $finish;
        end
        
        while ($fgets(aline, fd)) begin              
            if ($sscanf(aline, "%x %x %x %x %x", we, en, addr, din, tb_dout) !== 5) begin
                $display("Error reading test vectors.");
                $finish;
            end
                        
            @(negedge clk);
                     
            if(we != 1 ) begin
                if(dout !== tb_dout) begin
                    $display("%d Fail! Expected dout: %h, Actual dout: %h  ## Inputs: we: %x en: %x addr: %x  ## Read\n",count,tb_dout,dout,we,en,addr);
                    errors = errors +1; 
                end else begin
                    $display("%d Pass! Expected dout: %h, Actual dout: %h  ## Inputs: we: %x en: %x addr: %x  ## Read\n",count,tb_dout,dout,we,en,addr);
                end
            end else begin
                $display("%d Inputs: we: %x en: %x addr: %x din: %x  ## Write\n",count,we,en,addr,din); 
            end                    
            count = count +1;
        end
    
        if (errors === 0) begin
            $display("PASS: All test vectors passed\nCorrect.");
            `ifdef VERIFICATION_CODE $display("%d", `VERIFICATION_CODE); `endif
        end else begin
            $display("FAIL: %d error(s) occurred.", errors);
        end
    
        $finish;    
    end

endmodule
