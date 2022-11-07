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
    reg [5:0] a, b;
    // Outputs from UUT.
    wire lt, ltu, eq;

    reg signed [5:0] a_signed, b_signed;
    reg lt_expected, ltu_expected, eq_expected;
    integer i;
    integer errors = 0;

    problem uut (
        .a(a),
        .b(b),
        .lt(lt),
        .ltu(ltu),
        .eq(eq)
    );

    initial begin
        a = 0;
        b = 0;

        #100;

        $display("Applying vectors...\n");

        i = 0;
        errors = 0;
        for (i = 0; i < 2**12; i = i + 1) begin
            a = i[5:0];
            b = i[11:6];
            #10
            a_signed = a;
            b_signed = b;
            ltu_expected = a < b;
            lt_expected = a_signed < b_signed;
            eq_expected = a === b;
            if (ltu !== ltu_expected || lt !== lt_expected || eq !== eq_expected) begin
                $write("FAIL: a = %d, b = %d\n", a, b);
                $write("  expected: lt = %d, ltu = %d, eq = %d\n", lt_expected, ltu_expected, eq_expected);
                $write("  actual:   lt = %d, ltu = %d, eq = %d\n", lt, ltu, eq);
                errors = errors + 1;
            end
        end

        if (errors === 0) begin
            $display("PASS: All test vectors passed\nCorrect.\n%d", `VERIFICATION_CODE);
        end else begin
            $display("FAIL: %d errors occurred.", errors);
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
