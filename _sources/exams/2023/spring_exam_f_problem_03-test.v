// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
//`timescale 1ns / 1ps

module tb_fifo;

    // Variables used to interface with the UUT
    // Inputs to UUT
    reg rden;
    reg wren;
    reg clk;
    reg reset;
    reg [7:0] din; 
    
    // Outputs from UUT 
    wire [7:0] dout;
    wire full;
    wire empty;
    wire read_valid;
      
    // Expected Outputs from module. 
    reg [7:0] expected_dout;
    reg expected_full;
    reg expected_empty;
    reg expected_read_valid;
    
    // Variables used by the test bench internals.
    integer i,fd,f;
    integer errors;
    integer count;
    integer pass_rd1,pass_rd2,pass_rd, pass_full, pass_empty, pass_read_valid, pass;
    reg [8*100:1] comment;
    
    // Instantiate the fifo module Unit Under Test (UUT)
    fifo uut(
        .rden(rden),
        .wren(wren),
        .clk(clk),
        .reset(reset),
        .sclr(sclr),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .read_valid(read_valid)
    );
    
    // Create a 20 ns clock.
    initial begin
        clk = 0;  
        #100   //reset delay
        forever #10
            clk = ~clk;
    end
    
    initial begin
        // Initialize Inputs
        rden = 0;
        wren = 0;
        din = 0;
        expected_dout = 0;
        expected_full = 0;
        expected_empty = 0;
        expected_read_valid = 0;
        
        clk = 0;
        reset = 1;
        errors = 0;
        count = 0;
        
        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;

        
        fd = $fopen("../../../spring_exam_f_problem_03.txt","r");
        // for post-route simulation, one directory deeper
        fd = fd ? fd : $fopen("../../../../spring_exam_f_problem_03.txt","r");
        // When running as an e-book, in the current directory.
        fd = fd ? fd : $fopen("spring_exam_f_problem_03.txt","r");
        
        // Read and discard the first line, which must be a comment;
        if (fd === 0 || $fgets(comment, fd) === 0) begin
            $display("Cannot open/read vectors file 'spring_exam_f_problem_03.txt', simulation exiting");
            $finish;
        end

        while (!$feof(fd)) begin
            // Assign inputs to the UUT on the falling edge for clarify. 
            @(negedge clk); 
            if ($fgets(comment, fd) === 0) begin
                $display("Error reading test vectors.");
                $finish;
            end                            
            if ($sscanf(comment, "%x %x %x %x %x %x %x", wren, rden, din, expected_dout, expected_full, expected_empty, expected_read_valid) !== 7) begin
                $display("Error reading test vectors.");
                $finish;
            end
            
            // Check all UUT outputs after the clock edge
            @(posedge clk); 
            
            // Check read
            if(rden == 1) begin
                if(rden == wren) begin
                    if(full == 1) begin 
                        if (expected_dout == dout) begin
                            $display("#%4d) %4d ns: PASS! Expected dout: %h, Actual dout: %h  | Inputs: wren: %x rden: %x",count,$time,expected_dout,dout,wren,rden);                                              
                        end else begin
                            $display("#%4d) %4d ns: FAIL! Expected dout: %h, Actual dout: %h  | Inputs: wren: %x rden: %x",count,$time,expected_dout,dout,wren,rden);  
                            errors = errors +1;
                        end
                    end
                end else begin
                    if (expected_dout == dout) begin
                        $display("#%4d) %4d ns: PASS! Expected dout: %h, Actual dout: %h  | Inputs: wren: %x rden: %x",count,$time,expected_dout,dout,wren,rden);                   
                    end else begin
                        $display("#%4d) %4d ns: FAIL! Expected dout: %h, Actual dout: %h  | Inputs: wren: %x rden: %x",count,$time,expected_dout,dout,wren,rden);  
                        errors = errors +1;
                    end
                end
            end
            
            
            // Check Full logic   
            if(expected_full == full) begin
                $display("#%4d) %4d ns: PASS! Expected full: %h, Actual full: %h",count,$time,expected_full, full);
            end else begin
                $display("#%4d) %4d ns: FAIL! Expected full: %h, Actual full: %h",count,$time,expected_full, full);
                errors = errors +1;                
            end
            // Check Empty logic               
            if(expected_empty == empty) begin
                $display("#%4d) %4d ns: PASS! Expected empty: %h, Actual empty: %h",count,$time,expected_empty, empty);
            end else begin
                $display("#%4d) %4d ns: FAIL! Expected empty: %h, Actual empty: %h",count,$time,expected_empty, empty);
                errors = errors +1;                
            end
            
            // Check if read is valid logic 
            if(expected_read_valid == read_valid) begin
                $display("#%4d) %4d ns: PASS! Expected read_valid: %h, Actual read_valid: %h",count,$time,expected_read_valid, read_valid);
            end else begin
                $display("#%4d) %4d ns: FAIL! Expected read_valid: %h, Actual read_valid: %h",count,$time,expected_read_valid, read_valid);
                errors = errors +1;                
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