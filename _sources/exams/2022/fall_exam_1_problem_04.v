// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (20 points) Write Verilog that outputs the value that was input two clocks cycles ago. For example, an input of 1, 2, 3, 4, ... would produce outputs of (unknown), (unknown), 1, 2, 3, 4, ...
//
// Code
// ====
module problem(
    input clk,
    input [7:0] d,
    output reg [7:0] q
);

    // SOLUTION_BEGIN
    reg [7:0] d0, d1;

    always @(posedge clk) begin
        d0 <= d;
        d1 <= d0;
        q <= d1;
    end
    // SOLUTION_END

endmodule

// .. lp_build:: hS3QBEnhtL
//   :builder: verilog
