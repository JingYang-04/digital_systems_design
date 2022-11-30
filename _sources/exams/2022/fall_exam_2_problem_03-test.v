// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
`timescale 1ns / 1ps

module tb_problem;

    // Inputs to UUT.
    reg clk, reset, echo;
    reg [12:0] timer;
    // Outputs from UUT.
    wire [12:0] echo_time;

    integer i, j;
    integer errors = 0;
    reg [12:0] expected_echo_time;

    problem uut (
        .clk(clk),
        .reset(reset),
        .timer(timer),
        .echo,
        .echo_time(echo_time)
    );

    // Create a 20 ns clock.
    initial begin
        clk = 0;
        forever begin
            #10
            clk = ~clk;
        end
    end

    initial begin
        errors = 0;
        reset = 1;
        timer = 0;
        echo = 0;
        expected_echo_time = 0;
        #100;
        @(negedge clk);

        $display("Applying vectors...\n");

        reset = 0;
        @(negedge clk);
        // The echo_time should be 0 until an echo pulse is received.
        for (i = 0; i < 2**13; i = i + 1) begin
            if (echo_time !== expected_echo_time) begin
                $display("FAIL: time = %3d, reset = %b, echo = %b, timer = %d, echo_time = %d, expected echo_time = %d", $time, reset, echo, timer, echo_time, expected_echo_time);
                errors = errors + 1;
            end
            @(negedge clk);
            timer = i;
        end

        // Check that the echo_time is recorded on the first edge of an echo.
        for (j = 2; j < 2**13; j = j + 100) begin
            // Reset for the next test.
            reset = 1;
            timer = 0;
            echo = 0;
            expected_echo_time = j - 1;
            @(negedge clk);
            reset = 0;

            for (i = 0; i < 2**13; i = i + 1) begin
                // Toggle echo after the preset "distance" in j.
                if (i >= j) begin
                    echo = ~echo;
                end
                if (((i <= j) && (echo_time !== 0)) || (i > j) && (echo_time !== expected_echo_time)) begin
                    $display("FAIL: time = %3d, reset = %b, echo = %b, timer = %d, echo_time = %d, expected echo_time = %d", $time, reset, echo, timer, echo_time, expected_echo_time);
                    errors = errors + 1;
                end
                @(negedge clk);
                timer = i;

                // Fail early, instead of spewing errors forever.
                if (errors > 20) begin
                    $finish;
                end
            end
        end

        if (errors === 0) begin
            $display("PASS: All test vectors passed\nCorrect.");
            `ifdef VERIFICATION_CODE $display("%d", `VERIFICATION_CODE); `endif
        end else begin
            $display("FAIL: %0d errors occurred.", errors);
        end

        $finish;
    end

endmodule
