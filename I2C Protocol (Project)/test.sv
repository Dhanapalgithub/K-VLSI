class i2c_test;
  i2c_env e;
  function new(virtual i2c_if vif);
    e = new(vif);
  endfunction

  task run();
    e.gen.count = 500;
    e.run();
  endtask
endclass