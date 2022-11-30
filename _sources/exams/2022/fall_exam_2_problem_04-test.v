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
    reg clk, reset;
    reg [7:0] d;
    // Outputs from UUT.
    wire [7:0] last_three_sum;

    integer i, lfsr;
    integer errors = 0;
    reg [7:0] d0, d1, d2;
    reg bit;

    problem uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .last_three_sum(last_three_sum)
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
        d = 0;
        reset = 1;
        #100;
        @(negedge clk);

        $display("Applying vectors...\n");

        lfsr = 1;
        i = 0;
        errors = 0;
        reset = 0;
        d0 = 0;
        d1 = 0;
        d2 = 0;
        for (i = 0; i < 2**8; i = i + 1) begin
            d2 = d1;
            d1 = d0;
            d0 = d;
            d = lfsr;
            if (last_three_sum === d0 + d1 + d2) begin
                $write("PASS: ");
            end else begin
                $write("FAIL: ");
                errors = errors + 1;
            end
            $display("time = %3d, d = %d, last_three_sum = %d, expected last_three_sum = %d", $time, d, last_three_sum, d0 + d1 + d2);
            // Update LFSR state. Taken from https://en.wikipedia.org/wiki/Linear-feedback_shift_register.
            bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1'b1;
            lfsr = (lfsr >> 1) | (bit << 15);
            @(negedge clk);
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
