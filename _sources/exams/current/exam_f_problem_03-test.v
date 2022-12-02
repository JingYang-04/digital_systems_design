// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// ***********************************************
// |docname| - testbench for `exam_f_problem_03.v`
// ***********************************************
// To use this stand-alone, also download the `test vectors <../../_static/exam_f_problem_03-test.txt>`_.
`timescale 1ns / 1ps

module tb_problem;

    // Inputs to UUT.
    reg clk, reset, rden, wren, encoder_pulse;
    reg [31:0] din;
    reg [2:0] addr;
    // Outputs from UUT.
    wire [31:0] dout;

    reg [31:0] i_dout;
    integer i;
    integer errors;
    reg pass;
    reg [8*100:1] aline, notes;
    integer fd;

    problem uut (
		.clk(clk),
		.reset(reset),
        .rden(rden),
        .din(din),
        .dout(dout),
        .addr(addr),
        .wren(wren),
        .encoder_pulse(encoder_pulse)
    );

    // Create a 20 ns clock.
    initial begin
        clk = 0;
        forever begin
            #10
            clk = ~clk;
        end
    end

    initial begin
        reset = 1;
        rden = 0;
        din = 0;
        addr = 0;
        wren = 0;
        encoder_pulse = 0;
        errors = 0;
        #100;
        reset = 0;

        i = 0;
        errors = 0;

        fd = $fopen("../../../../exam_f_problem_03-test.txt", "r");
        // for post-route simulation, one directory deeper
        fd = fd ? fd : $fopen("../../../../../exam_f_problem_03-test.txt", "r");
        // When running as an e-book, in the current directory.
        fd = fd ? fd : $fopen("exam_f_problem_03-test.txt", "r");

        // Read and discard the first line, which must be a comment.
        if (fd === 0 || $fgets(aline, fd) === 0) begin
          $display("Cannot open/read vectors file 'exam_f_problem_03-test.txt', simulation exiting");
          $finish;
        end


        while ($fgets(aline, fd)) begin
            @(negedge clk);
            if ($sscanf(aline, "%x %x %x %x %x %x", i_dout, rden, din, addr, wren, encoder_pulse) !== 6) begin
                $display("Error reading test vectors.");
                $finish;
            end
            // Horrible Verilog indexing: Notes begin in column 48, end in column 85, snip off 3 characters (period, \r, \n) from the end. The last character read (**NOT** the first character read) is at aline[9:1], meaning indexing is reversed.
            notes = aline[8*(85-48+3):25];
            if (i_dout === dout) begin
                pass = 1;
            end else begin
                pass = 0;
                errors = errors + 1;
            end
            $write({
                "%0s\n",
                "%04s | Outputs:     dout  | Inputs: rden      din addr wren encoder_pulse\n",
                "     | Actual   %x  |            %x %x    %x    %x             %x\n",
                "     | Expected %x  |\n",
                "\n"},
                notes,
                pass ? "PASS" : "FAIL",
                dout, rden, din, addr, wren, encoder_pulse,
                i_dout
            );
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
