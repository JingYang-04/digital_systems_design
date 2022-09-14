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
    input [9:0] a,
    input [9:0] b,
    // The modes are:
    //
    // =====    =====
    // mode		y
    // =====    =====
    // 2'b00    a
    // 2'b01    b
    // 2'b10    a + b
    // 2'b11    a - b
    // =====    =====
    input [1:0] mode,
    output [9:0] y,
    // This output is 1 if y == 0; otherwise, this output is 0.
    output is_zero
);

    // SOLUTION_BEGIN
    assign y = (mode == 2'b00) ? a : (
        (mode == 2'b01) ? b : (
            (mode == 2'b10) ? a + b : a - b
            )
        );
    assign is_zero = y == 0;
    // SOLUTION_END

endmodule

// .. lp_build:: rFk7eMmc2Y
//   :builder: verilog
