// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (20 points) Complete the Verilog module below based on the provided description. Here is one `solution <fall_exam_2_problem_01-solution>` and the accompanying `testbench <fall_exam_2_problem_01-test.v>`. **However**, this test bench can't be run outside the web environment, since it contains the answer.
//
// Code
// ====
// The correlator module definition is:
//
// .. codeinclude:: fall_exam_2_problem_01-test.v
//  :start-after: The correlator module.
//  :end-before: SOLUTION_BEGIN
//
// Instantiate the ``correlator`` module three times, to compute the correlation between inputs ``a``, ``b``, and ``c``.
module problem(
    input [9:0] a,
    input [9:0] b,
    input [9:0] c,
    // Instiantiate the correlator with inputs of ``a`` and ``b`` to produce this output.
    output [9:0] ab_correlation,
    // Instiantiate the correlator with inputs of ``a`` and ``c`` to produce this output.
    output [9:0] ac_correlation,
    // Instiantiate the correlator with inputs of ``b`` and ``c`` to produce this output.
    output [9:0] bc_correlation
);

    // SOLUTION_BEGIN
	correlator ab_correlator(a, b, ab_correlation);
	correlator ac_correlator(a, c, ac_correlation);
	correlator bc_correlator(b, c, bc_correlation);
    // SOLUTION_END

endmodule

// .. lp_build:: MEeAlKJ4XX
//   :builder: verilog
