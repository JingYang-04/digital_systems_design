// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
`timescale 1ns / 1ps

module tb_problem;

    // Inputs to UUT.
    reg [9:0] a, b;
    reg [1:0] mode;
    // Outputs from UUT.
    wire [9:0] y;
    wire is_zero;

    integer i;
    integer errors = 0;

    problem uut (
        .a(a),
        .b(b),
        .mode(mode),
        .y(y),
        .is_zero(is_zero)
    );

    initial begin
        a = 0;
        b = 0;
        mode = 0;

        #100;

        $display("Applying vectors...\n");

        i = 0;
        errors = 0;
        for (i = 0; i !== 1023; i = i + 1) begin
            a = i;
            b = 1023 - i;

            // Test all modes.
            mode = 0;
            #50;
            errors = checker(a, b, mode, y, is_zero, a, errors);
            mode = 1;
            #50;
            errors = checker(a, b, mode, y, is_zero, b, errors);
            mode = 2;
            #50;
            errors = checker(a, b, mode, y, is_zero, a + b, errors);
            mode = 3;
            #50;
            errors = checker(a, b, mode, y, is_zero, a - b, errors);
        end

        if (errors === 0) begin
            $display("PASS: All test vectors passed\nCorrect.\n%d", `VERIFICATION_CODE);
        end else begin
            $display("FAIL: %d errors occurred.", errors);
        end

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
