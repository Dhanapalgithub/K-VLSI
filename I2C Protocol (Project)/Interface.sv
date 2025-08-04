interface i2c_if();
  logic clk;
  logic rst;
  logic start;
  logic rw;
  logic [6:0] addr;
  logic [7:0] master_data_in;
  logic [7:0] slave_data_in;
  logic more_data;
  logic [7:0] master_data_out;
  logic [7:0] slave_data_out;
  logic ready;
  logic error_flag;
  wire sda;
  wire scl;
 
endinterface

