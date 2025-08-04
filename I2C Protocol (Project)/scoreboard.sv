class i2c_scoreboard;
  mailbox mon2scb;
  i2c_transaction tr;
  event done;
  int count;
	
  function new(mailbox mon2scb,event done );
    this.mon2scb = mon2scb;
    this.done= done ;

  endfunction
  task main();
    forever begin
//       #10;
      mon2scb.get(tr);
      count++;
//       cg.sample();
      
      
      tr.display("SCB");
      
      $display("[SCB] Verifying outputs...");
      if (tr.start ==0) $info("Start isn't asserted, passing to next iteration");
      else if (tr.rw == 1 ) begin
        if (tr.master_data_out == tr.slave_data_in)
          $display("PASSED test", $time);

        else $error("Read operation failed");
      end
      else if (tr.rw == 0) begin
        if (tr.master_data_in == tr.slave_data_out) 
          $display("PASSED test");
        else $error ("Write operation failed");
      end
      
//       if(count == 8) $finish;
//       else $error ("TEST have been failed completely")
      ->done;
    end
  endtask

endclass