// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (25 points) Complete the Verilog module below based on the provided description. Here is one `solution <fall_exam_2_problem_02-solution>` and the accompanying `testbench <fall_exam_2_problem_02-test.v>`.
//
// Code
// ====
module problem(
	input clk,
	input reset,
	// This is a pushbutton. It's already synchronized to the clock.
    input button,
	// After the pushbutton is pressed, the LED should turn on. After the pushbutton is pressed a second time, the LED should turn off. This cycle then repeats. Note that the pushbutton may be pressed or released for many clock cycles (held down / released for a long time).
    output reg led
);

    // SOLUTION_BEGIN
    reg button_prev;

	always @(posedge clk or posedge reset) begin
		if (reset) begin
            led <= 0;
        end else begin
            button_prev <= button;
            // A button is pressed when it's now 1, but was 0 a cycle ago.
            if (button && !button_prev) begin
                // This is the signal to toggle the LED.
                led <= !led;
            end
        end
	end
    // SOLUTION_END

endmodule

// .. lp_build:: L8T6nynHms
//   :builder: verilog
