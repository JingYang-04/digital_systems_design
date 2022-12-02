// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// ***********************************************
// |docname| - testbench for `exam_f_problem_01.v`
// ***********************************************
// To use this stand-alone, also download the `test vectors <../../_static/exam_f_problem_01-test.txt>`_.
`timescale 1ns / 1ps

module tb_problem;

    // Inputs to UUT.
    reg clk, reset, ld;
    reg [7:0] d;
    // Outputs from UUT.
    wire [7:0] parity;

    reg [7:0] i_parity;
    integer i;
    integer errors;
    reg pass;
    reg [8*100:1] aline;
    integer fd;

    problem uut (
        .clk(clk),
        .reset(reset),
        .ld(ld),
        .d(d),
        .parity(parity)
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
        ld = 0;
        d = 0;
        #100;
        reset = 0;

        i = 0;
        errors = 0;

        fd = $fopen("../../../../exam_f_problem_01-test.txt", "r");
        // for post-route simulation, one directory deeper
        fd = fd ? fd : $fopen("../../../../../exam_f_problem_01-test.txt", "r");
        // When running as an e-book, in the current directory.
        fd = fd ? fd : $fopen("exam_f_problem_01-test.txt", "r");

        if (fd === 0) begin
          $display("Cannot open vectors file 'exam_f_problem_01-test.txt', simulation exiting");
          $finish;
        end

        while ($fgets(aline, fd)) begin
            @(negedge clk);
            if ($sscanf(aline, "%x %x %x", i_parity, ld, d) !== 3) begin
                $display("Error reading test vectors.");
                $finish;
            end
            if (i_parity === parity) begin
                pass = 1;
            end else begin
                pass = 0;
                errors = errors + 1;
            end
            $write({
                "%04s | Outputs: parity | Inputs: ld d\n",
                "     | Actual   %x     |         %x  %x\n",
                "     | Expected %x     |\n",
                "\n"},
                pass ? "PASS" : "FAIL",
                parity, ld, d,
                i_parity
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
