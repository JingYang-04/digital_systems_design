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
    reg clk, reset;
    // Outputs from UUT.
    wire [3:0] q;

    reg [3:0] expected_q [15:0];
    integer i;
    integer errors = 0;

    problem uut (
        .clk(clk),
        .reset(reset),
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
        reset = 1;
        #110;

        $display("Applying vectors...\n");

        i = 0;
        errors = 0;
        reset = 0;
        expected_q[0] =  4'b0001;
        expected_q[1] =  4'b0010;
        expected_q[2] =  4'b0100;
        expected_q[3] =  4'b1000;
        expected_q[4] =  4'b0011;
        expected_q[5] =  4'b0110;
        expected_q[6] =  4'b1100;
        expected_q[7] =  4'b1011;
        expected_q[8] =  4'b0101;
        expected_q[9] =  4'b1010;
        expected_q[10] = 4'b0111;
        expected_q[11] = 4'b1110;
        expected_q[12] = 4'b1111;
        expected_q[13] = 4'b1101;
        expected_q[14] = 4'b1001;
        expected_q[15] = 4'b0001;

        for (i = 0; i < 2**4; i = i + 1) begin
            if (q !== expected_q[i]) begin
                $display("FAIL: time = %3d, i = %2d, reset = %b, q = %b, expected_q = %b", $time, i, reset, q, expected_q[i]);
                errors = errors + 1;
            end
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
