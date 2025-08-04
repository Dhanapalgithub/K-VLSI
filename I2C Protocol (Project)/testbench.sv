`include "i2c_if.sv"
`include "i2c_transaction.sv"
`include "i2c_generator.sv"
`include "i2c_driver.sv"
`include "i2c_monitor.sv"
`include "i2c_scoreboard.sv"
`include "i2c_env.sv"
`include "i2c_test.sv"

module i2c_top_tb;
  logic clk;
  logic rst;
   i2c_test t;

  always #1 clk = ~clk;

  i2c_if vif();

  i2c_top_design dut (
    .clk(vif.clk),
    .rst(vif.rst),
    .start(vif.start),
    .rw(vif.rw),
    .addr(vif.addr),
    .master_data_in(vif.master_data_in),
    .more_data(vif.more_data),
    .slave_data_in(vif.slave_data_in),
    .master_data_out(vif.master_data_out),
    .slave_data_out(vif.slave_data_out),
    .ready(vif.ready),
    .error_flag(vif.error_flag)
  );

  assign vif.clk = clk;
  assign vif.rst = rst;

 initial begin
   $dumpfile("i2c.vcd");
    $dumpvars(0, i2c_top_tb);
  clk = 0;
 
  t = new(vif);
  t.run();
   

  #200;
   
end

endmodule