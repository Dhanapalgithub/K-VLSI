// Covergroup definition (placed outside the class)
covergroup i2c_cg with function sample(bit start, bit rw, bit [6:0] addr);
  option.per_instance = 1; // Allows each instance to have its own coverage results

  coverpoint start { bins low = {0}; bins high = {1}; }
  coverpoint rw    { bins write = {0}; bins read  = {1}; }
  coverpoint addr {
    bins low_range[]  = {[0:31]};
    bins mid_range[]  = {[32:95]};
    bins high_range[] = {[96:127]};
    bins common       = {7'h50, 7'h68, 7'h27};
  }
  cross start, rw;
endgroup

class i2c_monitor;
  mailbox mon2scb;
  virtual i2c_if vif;
  i2c_transaction tr;

  i2c_cg cg; // Declare an instance of the covergroup type

  function new(mailbox mon2scb, virtual i2c_if vif);
    this.mon2scb = mon2scb;
    this.vif = vif;
    cg = new(); // Instantiate the covergroup
  endfunction

  task main();
    forever begin
      // Wait for signals to stabilize or a relevant event
      // For I2C, it's often best to sample at a specific point
      // where the transaction data is fully valid, e.g., after
      // an ACK, NACK, or STOP condition indicates end of transfer.
      // The #180 is an arbitrary delay; consider using an event
      // from the interface (like a 'ready' signal from the DUT).
      #180;

      tr = new();

      // Sample data from the virtual interface
      tr.addr           = vif.addr;
      tr.rw             = vif.rw;
      tr.master_data_in = vif.master_data_in;
      tr.slave_data_in  = vif.slave_data_in;
      tr.start          = vif.start;
      tr.more_data      = vif.more_data;
      tr.master_data_out = vif.master_data_out;
      tr.slave_data_out  = vif.slave_data_out;
      tr.error_flag      = vif.error_flag;
      
      mon2scb.put(tr);
      tr.display("MONITOR");

      // Sample coverage manually using the 'sample' function
      cg.sample(vif.start, vif.rw, vif.addr);
    end
  endtask
endclass