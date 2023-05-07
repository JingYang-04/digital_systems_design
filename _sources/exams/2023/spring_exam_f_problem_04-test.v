// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
`timescale 1ns / 1ps

module tb_temp_sensor;
    // Variables used to interface with the UUT.
    reg clk, reset, fifo_full;
    reg [8:0] din_sensor;
    wire dout_sensor;
    wire [7:0] data_to_fifo;
    
    reg expected_dout_sensor;
    reg [7:0] expected_data_to_fifo;
    

    // Variables used by the test bench internals.
    integer errors, fd,count;
    reg [8*80:1] comment;

    // Instantiate the i2c_start module
    temp_sensor uut (
        .din_sensor(din_sensor),
        .clk(clk),
        .reset(reset),
        .fifo_full(fifo_full),
        .data_to_fifo(data_to_fifo),
        .dout_sensor(dout_sensor)
    );

    // Clock generation
    initial begin
        clk = 0;
        #100   //reset delay
        forever #10 clk = ~clk;
    end
    
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        errors = 0;
        fifo_full = 0;
        din_sensor = 9'b000000000;
        expected_data_to_fifo =0;
        expected_dout_sensor = 0;
        count = 0;
        
    
        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;       
        clk = 10;

        fd = $fopen("../../../spring_exam_f_problem_04.txt", "r");
        // for post-route simulation, one directory deeper
        fd = fd ? fd : $fopen("../../../../spring_exam_f_problem_04.txt", "r");
        // When running as an e-book, in the current directory.
        fd = fd ? fd : $fopen("spring_exam_f_problem_04.txt", "r");
    
        // Read and discard the first line, which must be a comment;
        if (fd === 0 || $fgets(comment, fd) === 0) begin
            $display("Cannot open/read vectors file 'spring_exam_f_problem_04.txt', simulation exiting.");
            $finish;
        end
        
        while ($fgets(comment, fd)) begin
            // Assign inputs to the UUT on the falling edge for clarify.
            @(negedge clk);
            
            if ($sscanf(comment, "%x %x %x %x",fifo_full, din_sensor, expected_data_to_fifo, expected_dout_sensor) !== 4) begin
                $display("Error reading test vectors.");
                $finish;
            end
                    
            // Check UUT output after the clock edge.           
            @(posedge clk);   
            if(expected_data_to_fifo == data_to_fifo) begin
                $display("#%4d) %4d ns: PASS! Expected data_to_fifo: %x, Actual data_to_fifo: %x  | Inputs: is_fifo_full: %x data_from_sensor: %x",count,$time,expected_data_to_fifo, data_to_fifo, fifo_full, din_sensor);
            end else begin
                $display("#%4d) %4d ns: FAIL! Expected data_to_fifo: %x, Actual data_to_fifo: %x  | Inputs: is_fifo_full: %x data_from_sensor: %x",count,$time,expected_data_to_fifo, data_to_fifo, fifo_full, din_sensor);
                errors = errors +1;                
            end
            
            
            // Check if should read from sensor
            if(expected_dout_sensor == dout_sensor) begin
                $display("#%4d) %4d ns: PASS! Expected is_read_sensor: %x, Actual is_read_sensor: %x",count,$time,expected_dout_sensor, dout_sensor);
            end else begin
                $display("#%4d) %4d ns: FAIL! Expected is_read_sensor: %x, Actual is_read_sensor: %x",count,$time,expected_dout_sensor, dout_sensor);
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