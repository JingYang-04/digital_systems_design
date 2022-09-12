// :orphan:
//
// .. Copyright (C) 2022 Bryan A. Jones
//
// **************************************************************
// |docname| - Test the output from `verilog_introduction_ex_1.v`
// **************************************************************
`timescale 1ns / 1ps

module tb_leds;

    reg [7:0] sw;
    wire [7:0] led;

    integer i;
    integer errors = 0;

    lab1 uut (
        .LED(led),
        .SW(sw)
    );

    initial begin
        sw = 0;

        #100;

        $display("Applying vectors...\n");

        i = 0;
        errors = 0;
        for (i = 0; i !== 256; i = i + 1) begin
            sw = i;
            #50;
            if (led !== i) begin
                $display("FAIL: sw = %d, expected led = %d, actual led = %d", sw, i, led);
                errors = errors + 1;
            end
        end

        // <p>Error check after the loop completes.</p>
        if (errors === 0) begin
            $display("PASS: All test vectors passed\nCorrect.\n%d", `VERIFICATION_CODE);
        end else begin
            $display("FAIL: %d errors occurred.", errors);
        end
    end

endmodule
