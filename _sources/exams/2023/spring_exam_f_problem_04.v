// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (40 points) Complete the Verilog module below based on the provided description.. Here is one `solution <spring_exam_f_problem_04-solution>`.
//
// .. image:: spring_exam_f_problem_041.png
// .. image:: spring_exam_f_problem_042.png 
// Code
// This module froms a simple temperaure controllor. The `` interrput_tmr `` periodically initial a read single `` dout_sensor `` to sensor. Then controller will wait for response from sensor `` din_sensor ``. The controllor will check if the `` din_sensor `` is valid by comparing ``din_sensor[8]==1 ``.  The controllor only waits for `` WAIT_TIME ``. The `` interrput_tmr `` is reset once controllor starts waiting for reply. The valid data will be stored in `` buffer_data ``. By checking the `` fifo_full `` to decide if the FIFO is allowed to written. The controllor will go back to initial state once the new read signal is ready. 
// ====
module temp_sensor( 
    input clk,
    input reset,
    input [8:0] din_sensor,   // data from tempecture sensor
    output dout_sensor,         // data to tempecture sensor
    input fifo_full,
    output reg [7:0] data_to_fifo
    );

parameter PERIOD = 5;
parameter WAIT_TIME = 6;

// Timer create a interruppt to initial a read sigle to sensor;
wire match;
assign match = (interrput_tmr == PERIOD);

reg [2:0] interrput_tmr;
reg sclr_tmr;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		interrput_tmr <= 0;
	end else begin
		if (match || sclr_tmr) interrput_tmr <= 0;
		else interrput_tmr <= interrput_tmr +1;
	end
end

// Register to store the data from sensor;
reg [7:0] buffer_data;
reg ld_to_buff;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		buffer_data <= 8'h00;
	end else begin
		if (ld_to_buff) buffer_data <= din_sensor[7:0];
	end
end

// Counter
reg [2:0] counter;
reg counter_en;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		counter <= 0;
	end else begin
		if (counter_en) counter <= counter +1;
		else counter <= 0;
	end
end

// FSM for sensor write to fifo
`define STATE_WAIT_FOR_INTERRUPT           2'b00
`define STATE_WAIT_REPLY_FROM_SENSOR       2'b01
`define STATE_WAIT_WRITE_TO_FIFO           2'b10

reg [1:0] nstate,pstate;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		pstate <= 1'b0;
	end else begin
        pstate <= nstate;
	end
end

//  Write to fifo enable.
reg wr_fifo_en;

// Sensor receive this signal to write data to the module.
reg dout_sensor;

// Data to write to fifo. 
reg [7:0] data_to_fifo;

// Implement FSM of the module. 

// SOLUTION_BEGIN
always @* begin
    nstate = pstate;
    dout_sensor = 1'b0; 
    wr_fifo_en = 0;
    ld_to_buff = 0;
    sclr_tmr = 0;
    counter_en = 0;
    data_to_fifo = 0;

    case(pstate) 
        `STATE_WAIT_FOR_INTERRUPT: begin
            if (match) begin 
                dout_sensor = 1'b1;
                nstate = `STATE_WAIT_REPLY_FROM_SENSOR;
            end    
        end
        `STATE_WAIT_REPLY_FROM_SENSOR: begin
                counter_en = 1;
                if(din_sensor[8] == 1) begin
                    ld_to_buff = 1 ;
                    nstate = `STATE_WAIT_WRITE_TO_FIFO;
                end else begin
                    sclr_tmr = 1;
                    if(counter < WAIT_TIME)begin
                        nstate = `STATE_WAIT_REPLY_FROM_SENSOR;
                     end else begin
                        nstate = `STATE_WAIT_FOR_INTERRUPT;
                     end
                end
        end
        `STATE_WAIT_WRITE_TO_FIFO: begin
            if (!fifo_full) begin
                wr_fifo_en = 1;
                data_to_fifo = buffer_data;
                nstate = `STATE_WAIT_FOR_INTERRUPT; 
            end else begin
                if(!match) begin
                    nstate =  `STATE_WAIT_WRITE_TO_FIFO;
                end else begin
                    nstate = `STATE_WAIT_FOR_INTERRUPT; 
                end    
            end
        end                                
    endcase
end
// SOLUTION_END
   
endmodule

// .. lp_build:: Mr6r7c2y2Em
//   :builder: verilog