module i2c_top_tb;

  reg clk = 0;
  reg rst;
  reg start;
  reg rw;
  reg more_data;
  reg [6:0] addr;
  reg [7:0] master_data_in;
  reg [7:0] slave_data_in;

  wire [7:0] master_data_out;
  wire [7:0] slave_data_out;
  wire ready;
  wire error_flag;

  // Instantiate the top design
  i2c_top_design dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .rw(rw),
    .addr(addr),
    .master_data_in(master_data_in),
    .more_data(more_data),
    .slave_data_in(slave_data_in),
    .master_data_out(master_data_out),
    .slave_data_out(slave_data_out),
    .ready(ready),
    .error_flag(error_flag)
  );

  // Clock generation
  always #1 clk = ~clk;  // 100MHz clock

  initial begin
    $dumpfile("i2c.vcd");
    $dumpvars(0, i2c_top_tb);

    rst = 1;
    
    addr = 7'b1000010;
    #13 rst = 0; 
    #1 start = 1;rw = 0; 
    master_data_in = 8'b01010101;
    #6 start = 0;
    more_data = 0;
    
    
    
    
//     addr = 7'b1000010;
//     #13 rst = 0; 
//     #1 start = 1;rw = 1; 
//     slave_data_in = 8'b01110101;
    
    
	#250;
    
    
   
     // Check if master received correct data from slave
    $display("Master read data: %d", master_data_out);

    if (master_data_in == slave_data_out)
    //if (slave_data_in == master_data_out)
      $display("TEST PASSED: Master received correct data from slave.");
    else
      $display("TEST FAILED: Master data_out mismatch.");
//     if (
    $finish;
  end
  
//   always @ (
endmodule
