class i2c_generator;
  mailbox gen2drv;
  event done;
  event finish;
  int count;
  rand i2c_transaction tr;
  function new(mailbox gen2drv, event done);
    this.gen2drv = gen2drv;
    this.done = done;

  endfunction

  task main();

    repeat (count) begin
      tr = new();
      assert(tr.randomize());
      // Force start=1 for at least one transaction
      //       if ( tr.start == 0) tr.start = 1;

      gen2drv.put(tr);
      tr.display("GEN");

      @(done);
    end
    ->finish;
  endtask

endclass