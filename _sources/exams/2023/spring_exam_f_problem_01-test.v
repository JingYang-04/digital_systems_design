// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
`timescale 1ns / 1ps

module tb_i2c_start;

// Variables used to interface with the UUT.
reg sdin, sclk, clk, reset, expected_start_detect;
wire start_detect;
// Variables used by the test bench internals.
reg pass;
integer errors, fd;
reg [8*80:1] comment;

// Instantiate the i2c_start module
i2c_start uut (
.sdin(sdin),
.sclk(sclk),
.clk(clk),
.reset(reset),
.start_detect(start_detect)
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
sdin = 1;
sclk = 1;
expected_start_detect = 0;

// Wait 100 ns for global reset to finish
#100;
reset = 0;

fd = $fopen("../../../spring_exam_f_problem_01.txt", "r");
// for post-route simulation, one directory deeper
fd = fd ? fd : $fopen("../../../../spring_exam_f_problem_01.txt", "r");
// When running as an e-book, in the current directory.
fd = fd ? fd : $fopen("spring_exam_f_problem_01.txt", "r");

// Read and discard the first line, which must be a comment;
if (fd === 0 || $fgets(comment, fd) === 0) begin
    $display("Cannot open/read vectors file 'spring_exam_f_problem_01.txt', simulation exiting.");
    $finish;
end

while (!$feof(fd)) begin
    // Assign inputs to the UUT on the falling edge for clarify.
    @(negedge clk);
    if ($fscanf(fd, "%x %x %x", sdin, sclk, expected_start_detect) !== 3) begin
        $display("Error reading test vectors.");
        $finish;
    end
    if ($fgets(comment, fd) === 0) begin
        $display("Error reading test vectors.");
        $finish;
    end

    // Check UUT output after the clock edge.
    @(posedge clk);
    pass = start_detect === expected_start_detect;
    $write("%4d ns:%0s", $time, comment);
    // The last line lacka a newline; add it back in.
    if ($feof(fd)) begin
        $write("\n");
    end         
    $display("%0s | Outputs: start_detect | Inputs: sdin sclk", pass ? "PASS" : "FAIL");
    $display("     | Actual              %x |            %x    %x", start_detect, sdin, sclk);
    $display("     | Expected            %x\n", expected_start_detect);
    if (!pass) begin                
        errors = errors + 1;
    end
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
