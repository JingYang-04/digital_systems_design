// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// **************************************************************
// |docname| - Test the output from `micro.v`
// **************************************************************
// To use this stand-alone, also download the `test vectors <../_static/micro-test.txt>`_.

`timescale 1ns / 1ps

module tb_micro;
    // Inputs to UUT
    reg clk, reset;
    // Outputs from UUT
    wire [12:0] inst;
    wire [7:0] pc, w, a, b, d;
    wire is_zero;

    integer i;
    integer errors = 0;
    integer fd;
    reg [7:0] i_w, i_pc, i_a, i_b, i_d;
    reg [12:0] i_inst;
    reg i_is_zero;
    reg [8*100:1] aline;

    micro uut (
        .clk(clk),
        .reset(reset),
        .w(w),
        .pc(pc),
        .inst(inst),
        .is_zero(is_zero),
        .a(a),
        .b(b),
        .d(d)
    );

    // Create a 20 ns clock.
    initial begin
        clk = 0;
        forever begin
            #10
            clk = ~clk;
        end
    end

    // Main testbench code.
    initial begin
        // Wait 100 ns for global reset to finish.
        reset = 1;

        fd = $fopen("../../../../micro-test.txt", "r");
        // for post-route simulation, one directory deeper
        fd = fd ? fd : $fopen("../../../../../micro-test.txt", "r");
        // When running as an e-book, in the current directory.
        fd = fd ? fd : $fopen("micro-test.txt", "r");

        if (fd === 0) begin
          $display("Cannot open vectors file 'micro-test.txt', simulation exiting");
          $finish;
        end

        #100;
        reset = 0;

        $display("Applying vectors...\n");
        i = 0;
        errors = 0;

        while ($fgets(aline, fd)) begin
            @(negedge clk);
            if ($sscanf(aline, "%x %x %x %x %x %x %x", i_pc, i_inst, i_w, i_is_zero, i_a, i_b, i_d) !== 7) begin
                $display("Error reading test vectors.");
                $finish;
            end
            if (i_w === w && i_pc === pc && i_inst === inst && i_is_zero === is_zero && i_a === a && i_b === b && i_d === d) begin
                $write("PASS");
            end else begin
                $write("FAIL");
                errors = errors + 1;
            end
            $write(" - Actual: %x %x %x %x %x %x %x\n", pc, inst, w, is_zero, a, b, d);
            $write("     Expected: %x %x %x %x %x %x %x\n", i_pc, i_inst, i_w, i_is_zero, i_a, i_b, i_d);
        end

        // Error check after the loop completes.
        if (errors == 0) begin
            $display("PASS: All test vectors passed\nCorrect.");
            `ifdef VERIFICATION_CODE $display("%d", `VERIFICATION_CODE); `endif
        end else begin
            $display("FAIL: %d errors occurred", errors);
        end
        $finish;
    end

endmodule
