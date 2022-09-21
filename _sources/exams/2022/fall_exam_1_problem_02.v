// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (15 points) Complete the Verilog module below based on the provided description.
//
// Code
// ====
module problem(
    input [5:0] a,
    input [5:0] b,
    // This output is 1 if a < b using a signed comparison; otherwise, it is 0.
    output lt,
    // This output is 1 if a < b using an unsigned comparison; otherwise, it is 0.
    output ltu,
    // This output is 1 if a == b; otherwise, it is 0.
    output eq
);

    // SOLUTION_BEGIN
    assign ltu = a < b;
    wire signed [5:0] a_signed, b_signed;
    assign a_signed = a;
    assign b_signed = b;
    assign lt = a_signed < b_signed;
    assign eq = a == b;
    // SOLUTION_END

endmodule

// .. lp_build:: M1npPRLYLg
//   :builder: verilog
