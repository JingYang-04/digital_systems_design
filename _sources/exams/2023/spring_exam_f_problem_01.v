// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (14 points) Complete the Verilog module below based on the provided description. Here is one `solution <spring_exam_f_problem_01-solution>`.
//
// .. image:: spring_exam_f_problem_01.png
// Code
// This module is to detect the start condition of an I2C communication based on the timing specifications of the protocol. As a slave device, it needs to detect a start condition from master device to start a communiction. `` start_detect `` is one, transmission start.
// ====
module i2c_start(input sdin, input sclk, input clk, input reset, output start_detect);    

// SOLUTION_BEGIN
  reg past_state;
  always @(posedge clk) begin
      past_state <= (sdin ==1 && sclk == 1);
  end

  assign start_detect = past_state && (sdin ==0 && sclk == 1); 
// SOLUTION_END

endmodule

// .. lp_build:: rFk7mMr6c2y
//   :builder: verilog