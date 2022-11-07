// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
`include "verification_code.v"
`timescale 1ns / 1ps

module tb_problem;

    // Inputs to UUT.
    reg clk;
    reg [7:0] d;
    // Outputs from UUT.
    wire [7:0] q;

    integer i;
    integer errors = 0;
    reg [15:0] lfsr;
    reg bit;
    reg [7:0] d0, d1, d2;

    problem uut (
        .clk(clk),
        .d(d),
        .q(q)
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
        #110;

        $display("Applying vectors...\n");

        i = 0;
        errors = 0;
        d1 = 0;
        d2 = 0;
        // Any non-zero starting state.
        lfsr = 1;
        for (i = 0; i < 2**8; i = i + 1) begin
            if (q === d2 || i < 2) begin
                $write("PASS: ");
            end else begin
                $write("FAIL: ");
                errors = errors + 1;
            end
            $display("time = %3d, i = %2d, d = %d, q = %d, expected_q = %d", $time, i, d, q, d2);
            d2 = d1;
            d1 = d;
            d = lfsr;
            // Update LFSR state. Taken from https://en.wikipedia.org/wiki/Linear-feedback_shift_register.
            bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1'b1;
            lfsr = (lfsr >> 1) | (bit << 15);

            #20;
        end

        if (errors === 0) begin
            $display("PASS: All test vectors passed.\nCorrect.\n%0d", `VERIFICATION_CODE);
        end else begin
            $display("FAIL: %0d errors occurred.", errors);
        end

        $finish;
    end

    function integer checker(
        input [9:0] a,
        input [9:0] b,
        input [1:0] mode,
        input [9:0] y,
        input is_zero,
        input [9:0] expected_y,
        input integer errors
    );
        begin
            if (y !== expected_y) begin
                $display("FAIL: a = %d, b = %d, mode = %d, y = %d, expected y = %d", a, b, mode, y, expected_y);
                checker = errors + 1;
            end else begin
                checker = errors;
            end
        end
    endfunction

endmodule
