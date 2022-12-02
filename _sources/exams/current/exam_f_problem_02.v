// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (25 points) Complete the Verilog module below based on the provided description. Here is the accompanying `testbench <exam_2_problem_02-test.v>`.
//
// Design a Christmas lights module with the following behavior:
//
// - On the first button press, turn all the LEDs on.
// - On the second button press, blink all the LEDs by toggling them once per clock cycle.
// - On the third button press, turn all the LEDs off.
//
// This cycle then repeats. Assume the pushbutton is synchronized to ``clk``. The LEDs should be off after reset.
//
// Hints:
//
// - Recall that the Verilog operator ``~`` is a bitwise NOT -- use this. Avoid the ``!`` operator, which is a logical NOT.
// - You may include ``$display`` statements in the code below for debugging, such as ``$display("%x", state);`` assuming you have a variable named ``state`` in your code.
//
//
// Code
// ====
module problem(
	input clk,
	input reset,
	// This is a pushbutton. It's already synchronized to the clock.
    input button,
	// The LEDs to control.
    output reg [15:0] led
);

    // SOLUTION_BEGIN
`define STATE_OFF (2'd0)
`define STATE_ON (2'd1)
`define STATE_BLINK (2'd2)

    reg button_prev;
	reg [1:0] state;

	always @(posedge clk or posedge reset) begin
		if (reset) begin
            led <= 0;
			state <= 0;
        end else begin
            button_prev <= button;
            // Update the state on a button press.
            if (button && !button_prev) begin
                state <= state == `STATE_BLINK ? `STATE_OFF : state + 1;
            end
            // Set the LEDs based on the state.
            case (state)
                `STATE_OFF: led <= 16'd0;
                `STATE_ON: led <= 16'hffff;
                `STATE_BLINK: led <= ~led;
                default: led <= 16'd0;
            endcase
        end
	end
    // SOLUTION_END

endmodule

// .. lp_build:: R2WAI3z9G2
//   :builder: verilog
