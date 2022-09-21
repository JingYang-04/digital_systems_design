// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (20 points) Write Verilog that implements the following schematic. The Verilog operator for an exclusive OR is ``^``. As shown in the schematic, the reset should force the ``q`` output to be 4'b0001.
//
// .. image:: fall_exam_1_problem_03.png
//
// Code
// ====
module problem(
    input reset,
    input clk,
    output reg [3:0] q
);

    // SOLUTION_BEGIN
    wire [3:0] d;

    always @(posedge clk or reset) begin
        if (reset == 1) begin
            q <= 4'b0001;
        end else begin
            q <= d;
        end
    end

    assign d[0] = q[3];
    assign d[1] = q[0] ^ q[3];
    assign d[2] = q[1];
    assign d[3] = q[2];
    // SOLUTION_END

endmodule

// .. lp_build:: WaS1FC6vAO
//   :builder: verilog
