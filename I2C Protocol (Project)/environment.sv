class i2c_env;
  i2c_generator gen;
  i2c_driver drv;
  i2c_monitor mon;
  i2c_scoreboard scb;
  event done;
  mailbox gen2drv;
  mailbox mon2scb;
  virtual i2c_if vif;

  function new(virtual i2c_if vif);
    this.vif = vif;
    gen2drv = new();
    mon2scb = new();
    gen = new(gen2drv,done);
    drv = new(gen2drv, vif);
    mon = new(mon2scb, vif);
    scb = new(mon2scb,done);
  endfunction

  task run();
    
    fork
      gen.main();
      drv.main();
      mon.main();
      scb.main();
    join_any
    $display("\n====== FUNCTIONAL COVERAGE REPORT ======");
    $display("Coverage = %0.2f%%", mon.cg.get_coverage());
    wait(gen.finish.triggered) $finish;
  endtask
endclass