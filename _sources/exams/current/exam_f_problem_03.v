// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (30 points) Complete the Verilog module below based on the provided description. Here is the accompanying `testbench <exam_f_problem_03-test.v>`.
//
// When a motor spins, a device on it called an `encoder <https://en.wikipedia.org/wiki/Rotary_encoder>`_ generates pulses to track the rotation of the motor. Design a module that counts each edge of these pulses to track how far the motor has rotated. Include an interface to an embedded microcontroller (see lab 7) which allows the microcontroller to read and write the number of pulses counted.
//
// Register addressing and reset behavior:
//
// ===============  =======  ==============
// Register  		Address  Value at reset
// ===============  =======  ==============
// Counter   		0b00     0
// Status/control	0b01     1
// ===============  =======  ==============
//
// Status/Control register definition:
//
// - Bit 0: Enable bit, counter counts up when ``1``, frozen when ``0``.
//
// Code
// ====
module problem(
	// Clock input.
    input clk,
	// High-true reset.
    input reset,
	// Read enable for the ``dout`` bus.
	input rden,
	// Data input bus
	input [31:0] din,
	// Data output bus; this reflects the contents addressed by the ``addr`` input when ``rden`` is high, else ``dout`` must be 0.
	output reg [31:0] dout,
	// Address bus for internal registers.
	input [2:0] addr,
	// Write line for a register. The register selected by ``addr`` is written on the rising clock edge when ``wren`` is high.
	input wren,
    // Pulses from the motor's encoder. A rising edge or a falling edge on this input should increment the counter (address 0b00) if the counter is enabled (bit 0 of address 0b01).
    input encoder_pulse
);

    // SOLUTION_BEGIN
    reg [31:0] counter;
    reg en;
    reg prev_encoder_pulse;
	always @(posedge clk or posedge reset) begin
		if (reset) begin
            counter <= 0;
            en <= 1;
        end else begin
            prev_encoder_pulse <= encoder_pulse;

            // Update the counter's value.
            if (addr == 0 && wren) begin
                counter <= din;
            end else if (en && prev_encoder_pulse != encoder_pulse) begin
                counter <= counter + 1;
            end

            // Update the enable bit.
            if (addr == 1 && wren) begin
                en <= din[0];
            end
        end
	end

    // Determine ``dout``.
    always @* begin
        if (addr == 0 && rden) begin
            dout = counter;
        end else if (addr == 1 && rden) begin
            dout = {31'b0, en};
        end else begin
            dout = 0;
        end
    end
    // SOLUTION_END

endmodule

// .. lp_build:: qWjQsYABho
//   :builder: verilog
