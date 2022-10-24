// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
`timescale 1ns / 1ps

// The correlator module.
module correlator(
	input [9:0] a,
	input [9:0] b,
	output [9:0] correlation
);
    // SOLUTION_BEGIN
    // Use a solution to hide this code from students, so they can't implement it manually.
    assign correlation = {a[9], a[7], a[5], a[3], a[1], a[0], a[2], a[4], a[6], a[8]} ^ {b[5:3], b[9:5], b[2:0]};
    // SOLUTION_END
endmodule


module tb_problem;

    // Inputs to UUT.
    reg [9:0] a, b, c;
    // Outputs from UUT.
    wire [9:0] ab_correlation, ac_correlation, bc_correlation;

    integer i;
    integer errors = 0;

    problem uut (
        .a(a),
        .b(b),
        .c(c),
        .ab_correlation(ab_correlation),
        .ac_correlation(ac_correlation),
        .bc_correlation(bc_correlation)
    );

    wire [9:0] ab_correlator_expected, ac_correlator_expected, bc_correlator_expected;
	// SOLUTION_BEGIN
    correlator ab_corr(a, b, ab_correlator_expected);
    correlator ac_corr(a, c, ac_correlator_expected);
    correlator bc_corr(b, c, bc_correlator_expected);
	// SOLUTION_END

    initial begin
        a = 0;
        b = 0;
        c = 0;
        #100;

        $display("Applying vectors...\n");

        i = 0;
        errors = 0;
        for (i = 0; i !== 1023; i = i + 1) begin
            a = i;
            b = ~a;
            c = (a << 4) + (a >> 4);

            // Test all modes.
            if ((ab_correlation !== ab_correlator_expected) || (ac_correlation !== ac_correlator_expected) || (bc_correlation !== bc_correlator_expected)) begin
                $display("FAIL: a = %X, b = %X, c = %X\n  actual:   ab_correlation = %X, ac_correlation = %X, bc_correlation = %X\n  expected: ab_correlation = %X, ac_correlation = %X, bc_correlation = %X\n",
                    a, b, c, ab_correlation, ac_correlation, bc_correlation, ab_correlator_expected, ac_correlator_expected, bc_correlator_expected);
                errors = errors + 1;
            end

            #10;
        end

        if (errors === 0) begin
            $display("PASS: All test vectors passed\nCorrect.\n%d", `VERIFICATION_CODE);
        end else begin
            $display("FAIL: %d errors occurred.", errors);
        end

        $finish;
    end

endmodule
