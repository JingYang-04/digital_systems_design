// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (30 points) Write Verilog that computes the following sums. Here is one `solution <fall_exam_2_problem_04-solution>` and the accompanying `testbench <fall_exam_2_problem_04-test.v>`.
//
// Code
// ====
// Create a module that outputs the sum of the last three numbers each clock cycle. Pipeline the design so that it uses three registers (sum1, sum2, and sum3) and three two-input adders. The schedule is:
//
// =====    ======  ======================  ===============     ===============     ===============
// Cycle    Number  Output                  sum1                sum2                sum3
// =====    ======  ======================  ===============     ===============     ===============
// 1        A       Anything                sum1 = A
// 2        B       Anything                sum1 = sum1 + B     sum2 = B
// 3        C       Anything                sum1 = sum1 + C     sum2 = sum2 + C     sum3 = C
// 4        D       A + B + C (in sum1)     sum1 = D            sum2 = sum2 + D     sum3 = sum3 + D
// 5        E       B + C + D (in sum2)     sum1 = sum1 + E     sum2 = E            sum3 = sum3 + E
// 6        F       C + D + E (in sum3)     sum1 = sum1 + F     sum2 = sum2 + F     sum3 = F
// 7        G       D + E + F (in sum1)     sum1 = G            sum2 = sum2 + G     sum3 = sum3 + G
// =====    ======  ======================  ===============     ===============     ===============
//
// This table then continues for an unlimited number of clock cycles. Only the first seven entries are shown for brevity.
module problem(
    input clk,
    input reset,
    // The number to sum for this clock cycle.
    input [7:0] d,
    // The sum of the last three numbers.
    output reg [7:0] last_three_sum
);

    // SOLUTION_BEGIN
    reg [7:0] sum1, sum2, sum3;
    reg [1:0] state = 0;

    // Register updates of sums and state.
    always @(posedge clk) begin
        sum1 <= state == 2'b00 ? d : sum1 + d;
        sum2 <= state == 2'b01 ? d : sum2 + d;
        sum3 <= state == 2'b10 ? d : sum3 + d;
        state <= state == 2'b10 ? 2'b00 : state + 1;
    end

    // Mux one of the sums to the last_three_sum based on the state.
    always @* begin
        case (state)
            2'b00: last_three_sum = sum1;
            2'b01: last_three_sum = sum2;
            default: last_three_sum = sum3;
        endcase
    end
    // SOLUTION_END

endmodule

// .. lp_build:: a7mZ3QRQwpR
//   :builder: verilog
