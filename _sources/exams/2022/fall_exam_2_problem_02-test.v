// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
`include "verification_code.v"
`timescale 1ns / 1ps

module tb_problem;

    // Inputs to UUT.
    reg clk, reset, button;
    // Outputs from UUT.
    wire led;

    reg done;
    integer i;
    integer errors = 0;

    problem uut (
		.clk(clk),
		.reset(reset),
		.button(button),
		.led(led)
    );

    // Create a 20 ns clock.
    initial begin
        clk = 0;
        forever begin
            #10
            clk = ~clk;
            if (clk) begin
                $display("clk rising edge.");
            end
        end
    end

    initial begin
        reset = 1;
        $display("Button = 0.");
        button = 0;
        errors = 0;
        #110;
        reset = 0;
        @(negedge clk);

        button = 1;
        $display("Button = %d.", button);
        // Wait two cycles, in case there's a weird state machine implementation.
        @(negedge clk);
        @(negedge clk);

        // Keep the button pressed for a while.
        checker(button, led, 1, errors, done);

        // Release the button.
        button = 0;
        $display("Button = %d.", button);
        @(negedge clk);
        @(negedge clk);
        checker(button, led, 1, errors, done);

        // Do another cycle to turn the LED off.
        button = 1;
        $display("Button = %d.", button);
        @(negedge clk);
        @(negedge clk);
        checker(button, led, 0, errors, done);
        button = 0;
        $display("Button = %d.", button);
        @(negedge clk);
        @(negedge clk);
        checker(button, led, 0, errors, done);

        // One more press.
        button = 1;
        $display("Button = %d.", button);
        @(negedge clk);
        @(negedge clk);
        checker(button, led, 1, errors, done);

        if (errors === 0) begin
            $display("PASS: All test vectors passed\nCorrect.\n%d", `VERIFICATION_CODE);
        end else begin
            $display("FAIL: %d errors occurred.", errors);
        end
        $finish;

    end

    task checker(
        input button,
        input led,
        input led_expected,
        inout integer errors,
        output done
    );
        integer i;

        begin
            done = 0;
            for (i = 0; i < 10; i = i + 1) begin
                if (led !== led_expected) begin
                    $display("FAIL: button = %d, led = %d, expected led = %d", button, led, led_expected);
                    errors = errors + 1;
                end
                @(negedge clk);
            end
            done = 1;
        end
    endtask

endmodule
