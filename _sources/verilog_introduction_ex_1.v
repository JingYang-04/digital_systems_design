// .. Copyright (C) 2022 Bryan A. Jones
//
// **********************************
// |docname| - Exercise using Verilog
// **********************************
// Complete the Verilog module below which simply copies the inputs to the output. To begin, first run this program -- it will fail the `test code <verilog_introduction_ex_1-test.v>`. Next, write code based on the instructions below until running it produces ``Correct.``
//
// Code
// ====
module lab1(
    // This defines outputs from the module: an array of 8 wires. (All ports are wires by default).
    output [7:0] LED,
    // This defines inputs to the module, also an array of 8 wires.
    input [7:0] SW
);


// For this exercise, write a short snippet of Verilog which copies input to output.
// SOLUTION_BEGIN
    assign LED = SW;
// SOLUTION_END

endmodule

// When you've finished coding, press the "Save and run" button.
//
// .. lp_build:: dc433yoc3E
//   :builder: verilog
