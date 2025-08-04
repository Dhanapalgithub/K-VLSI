`include "I2C_master.v"
`include  "I2C_slave.v"


module i2c_top_design (
  input clk,
  input rst,
  input start,
  input rw,
  input [6:0] addr,
  input [7:0] master_data_in,
  input more_data,
  input [7:0] slave_data_in,
  
  output [7:0] master_data_out,
  output [7:0] slave_data_out,
  output ready,
  output error_flag
);

  // Bidirectional I2C lines
  wire sda;
  wire scl;

  // Instantiate I2C Master
  I2C_master master_inst (
    .addr(addr),
    .clk(clk),
    .rst(rst),
    .rw(rw),
    .data_in(master_data_in),
    .start(start),
    .more_data(more_data),
    .data_out(master_data_out),
    .ready(ready),
    .error_flag(error_flag),
    .sda(sda),
    .scl(scl)
  );

  // Instantiate I2C Slave
  slave slave_inst (
    .rst(rst),
    .slave_addr(addr),
    .data_in(slave_data_in),
    .data_out(slave_data_out),
    .sda(sda),
    .scl(scl)
  );

endmodule
