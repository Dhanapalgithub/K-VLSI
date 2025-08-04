class i2c_transaction;
  rand bit [6:0] addr;
  rand bit [7:0] master_data_in;
  rand bit [7:0] slave_data_in;
  rand bit rw;
  rand bit start;
  bit rst;
  bit more_data;
  bit [7:0] master_data_out;
  bit [7:0] slave_data_out;
  bit error_flag;
  constraint addr_c {
    
    addr inside {[8'h08 : 8'h77]};  // Typical valid I2C address range
    !(addr inside {7'h00, 7'h7F});  // Reserved addresses
  }
   constraint data_c {
    // Master and slave data should be within valid range
    master_data_in inside {[0:255]};
    slave_data_in inside {[0:255]};
  }
   constraint rw_c {
    
     rw dist {0 := 50 ,1 := 50 }; // 50% read, 50% write
  }
  constraint start_c {
    // Start should be mostly 1 (since it's needed for transactions)
    start dist {1 := 70, 0 := 30};  // 70% chance of start=1
  }
  


  function void display(string tag);
    $display("[%s] rst = %0d addr=%0h, master_in=%0h, slave_in=%0h, rw=%b, start=%b, more_data=%b, master_out=%0h, slave_out=%0h, error=%b",
             tag,rst, addr, master_data_in, slave_data_in, rw, start, more_data, master_data_out, slave_data_out, error_flag);
  endfunction
endclass