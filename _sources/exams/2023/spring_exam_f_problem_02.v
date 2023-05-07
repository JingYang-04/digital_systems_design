// .. Copyright (C) 2022 Bryan A. Jones
//
// *********
// |docname|
// *********
// (15 points) Complete the single_port_ram Verilog module below based on the provided description. Here is one `solution <spring_exam_f_problem_02-solution>`.
//
// Code
// ====
module single_port_ram #(

// Declare two undefined variables in the module ;
  // SOLUTION_BEGIN
  parameter DATA_WIDTH = 8,          //width of data bus
  parameter ADDR_WIDTH = 8         //width of addresses buses
  // SOLUTION_END
)(

  // chip control.
  input                     en, 
  // write/read enable signal 
  input                     we,   
  input                     clk, 
  // data to be written
  input  [(DATA_WIDTH-1):0] din,  
  // address for write/read operation
  input  [(ADDR_WIDTH-1):0] addr,  
  // data to be read.
  output reg [(DATA_WIDTH-1):0]  dout      
);

 reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];


 wire wr_en;
 wire rd_en;
 // SOLUTION_BEGIN
 assign wr_en = en && we;
 assign rd_en = en && ~we;
 // SOLUTION_END

  always @(posedge clk) begin
  // Write data to RAM
      if (wr_en) begin
          ram[addr] <= din;
      end
  // Read data from RAM     
      if(rd_en) begin
        dout <= ram[addr];
      end else begin
        dout <= 'hz;
      end
  end
endmodule

// .. lp_build:: rFk7vMmc2y
//   :builder: verilog
