// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (25 points) Complete the Verilog module below based on the provided description. Here is one `solution <fall_exam_2_problem_03-solution>` and the accompanying `testbench <fall_exam_2_problem_03-test.v>`.
//
// Code
// ====
// This module forms a part of an ultrasonic ranging system. The system asserts ``reset``, sends a burst of ultrasonic sound, then deasserts ``reset``. A timer then counts the time until the echo of the sound returns. At the first rising edge of ``echo``, this module should save the value of ``timer`` into ``echo_time``, in order to measure the time between producing sound and receiving it. It must not change ``echo_time`` if ``echo`` later toggles, due to receiving other echos of sound. If no echo is received, then ``echo_time`` must be 0.
module problem(
    input clk,
    input reset,
    // This timer starts counting as soon as ``reset`` is deasserted / a burst of ultrasonic sound is sent.
	input [12:0] timer,
    // A rising edge on this pin indicates that an echo of sound was received.
	input echo,
    // This must contain 0 until the first rising edge of ``echo``; after that, it must contain the value of ``timer`` sampled at that first rising edge.
    output reg [12:0] echo_time
);

    // SOLUTION_BEGIN
	always @(posedge clk or posedge reset) begin
		if (reset) begin
            echo_time <= 0;
        end else begin
            if (echo_time == 0 && echo) begin
                echo_time <= timer;
            end
        end
	end
    // SOLUTION_END

endmodule

// .. lp_build:: bqDJgR6oTq
//   :builder: verilog
