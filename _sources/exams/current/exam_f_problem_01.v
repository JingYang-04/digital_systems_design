// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (20 points) Complete the Verilog module below based on the provided description. Here is the accompanying `testbench <exam_f_problem_01-test.v>`.
//
// Create a simple parity computation engine:
//
// -    The reset pin clears the parity output to 0.
// -    The load pin updates the parity to: new parity = old parity XOR loaded data.
//
// Code
// ====
module problem(
    input clk,
    // True to reset the parity to 0.
    input reset,
    // True to load data into the parity computation engine.
    input ld,
    // Data to load.
    input [7:0] d,
    // Parity computed.
    output reg [7:0] parity
);

    // SOLUTION_BEGIN
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parity <= 0;
        end else begin
            parity <= ld ? parity ^ d : parity;
        end
    end
    // SOLUTION_END

endmodule

// .. lp_build:: NptJ02EUiX
//   :builder: verilog
