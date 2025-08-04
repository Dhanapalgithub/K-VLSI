class i2c_driver;
  mailbox gen2drv;
  virtual i2c_if vif;
  i2c_transaction tr;

  function new(mailbox gen2drv, virtual i2c_if vif);
    this.gen2drv = gen2drv;
    this.vif = vif;
  endfunction

  task main();
    forever begin
      gen2drv.get(tr);
      vif.rst <= 1'b1;
      repeat(5) @ (posedge vif.clk);
      vif.rst <= 1'b0;
      @(posedge vif.clk);
      $display("[DRV] : RESET DONE");
      vif.addr            <= tr.addr;
      vif.master_data_in  <= tr.master_data_in;
      vif.slave_data_in   <= tr.slave_data_in;
      vif.rw              <= tr.rw;
      vif.start           <= tr.start;
      vif.more_data       <= tr.more_data;
      tr.start <= 0;
      tr.display("DRV");
//       #165;
    end
  endtask
endclass