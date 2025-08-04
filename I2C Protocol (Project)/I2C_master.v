module I2C_master (
  input [6:0] addr,
  input clk,
  input rst,
  input rw,
  input [7:0] data_in,
  input start,
  input more_data,
  output reg [7:0] data_out,
  output ready,
  output reg error_flag,
  output scl_posedge,

  inout sda,
  inout scl );

  localparam IDLE = 4'd0;
  localparam START = 4'd1;
  localparam SEND_SLAVE_ADDR = 4'd2;
  localparam ACK_WAIT = 4'd3;
  localparam WRITE_DATA = 4'd4;
  localparam WRITE_ACK_WAIT = 4'd5;
  localparam READ_DATA = 4'd6;
  localparam READ_ACK_WAIT = 4'd7;
  localparam STOP = 4'd8;
  localparam DONE = 4'd9;
  localparam ERROR = 4'd10;
  localparam WAIT_STOP = 4'd11;
  localparam WAIT_WRITE_ACK = 4'd12;
  localparam WAIT_ACK_DELAY = 4'd13;



  parameter CLK_DIV = 2; 

  reg [3:0] state, next_state;
  reg [7:0] data_reg;
  reg [7:0] addr_reg;
  reg [3:0] bit_counter;
  reg [10:0] scl_counter;
  reg wr_en;
  reg sda_state;
  reg scl_state;
  reg i2c_clk = 0;
  reg scl_en = 0;
  reg [7:0]data;

//   wire scl_posedge;
  wire scl_negedge;
  reg scl_d;
  reg mas=1'b0;

  always @(posedge clk) begin
    scl_d <= scl;
  end

  assign scl_posedge = (scl == 1 && scl_d == 0);
  assign scl_negedge = (scl == 0 && scl_d == 1);

  always @(posedge clk) begin
    if (scl_counter == CLK_DIV-1) begin
      i2c_clk <= ~i2c_clk;
      scl_counter <= 0;
    end else begin
      scl_counter <= scl_counter + 1;
    end
  end

  assign scl = (scl_en) ? i2c_clk : 1'b1;
  assign sda = (wr_en)? sda_state : 1'bz;

  always @(posedge i2c_clk or posedge rst) begin 
    if (rst) begin
      scl_counter <= 0;
      scl_en <= 0;
      data_out <= 0;
      state <= IDLE; 
      error_flag <= 0;
      wr_en <= 1;
      sda_state <= 1;
    end else begin
      case (state)


        IDLE: begin
          wr_en <= 1;
          sda_state <= 1;
          if (start && ready) begin
            addr_reg <= {addr, rw};
            data_reg <= data_in;
            bit_counter <= 7;
            scl_en <= 0;
            state <= START;
          end
        end

        START: begin
          wr_en <= 1;
          sda_state <= 0; // SDA falls while SCL is high
          scl_en <= 1;
          state <= SEND_SLAVE_ADDR;
        end

        SEND_SLAVE_ADDR: begin
          wr_en <= 1;
          scl_en <= 1;
          sda_state <= addr_reg[bit_counter];
          if (bit_counter == 0)begin

            state <= ACK_WAIT;end
          else
            bit_counter <= bit_counter - 1;
        end



//         WAIT_ACK_DELAY: begin
//           bit_counter <= 7;
          
//             state <= ACK_WAIT;
          
//         end

        ACK_WAIT: begin
          wr_en <= 0;
          @(negedge scl_posedge) if ( sda == 0) begin
            bit_counter <= 7;
            if (addr_reg[0] == 0)
              state <= WRITE_DATA;
            else if (rw == 1) // changed
              state <= READ_DATA;
          end else if ( sda == 1) begin
            state <= ERROR;
          end
        end

        WRITE_DATA: begin
          wr_en <= 1;
          sda_state <= data_reg[bit_counter];
          if (bit_counter == 0) begin
            state <= WAIT_WRITE_ACK;
          end
          else
            bit_counter <= bit_counter - 1;
        end
        WAIT_WRITE_ACK: begin
          wr_en <= 0;
          // wait for full SCL cycle before sampling
          if (clk)
            state <= WRITE_ACK_WAIT;
        end


        WRITE_ACK_WAIT: begin
          wr_en <= 0;
          if (sda == 0) begin
              if (more_data) begin
                bit_counter <= 7;
                state <= WRITE_DATA;
              end else begin
                wr_en <= 1;
                state <= STOP;
              end
            end else begin
              state <= ERROR;
            end
        end


        READ_DATA: begin
          wr_en <= 0;
            
            
          if (bit_counter == 0) begin
            @(negedge scl_posedge)data_out[bit_counter] <= sda;
            data[bit_counter]<=sda;
              state <= READ_ACK_WAIT;
          end
            else begin
              @(negedge scl_posedge) data_out[bit_counter] <= sda;
              data[bit_counter]<=sda;
              bit_counter <= bit_counter - 1;
              mas<=~mas;
            end
        

        end

        READ_ACK_WAIT: begin
          wr_en <= 1;
          sda_state <= 0;
          if (scl_posedge) begin
            if (more_data) begin
              bit_counter <= 7;
              state <= READ_DATA;
            end else begin
              state <= STOP;
            end
          end
        end

        STOP: begin
          
          sda_state <= 1;
          scl_en <= 0;
          state <= WAIT_STOP;
        end

        WAIT_STOP: begin
          state <= IDLE;
        end

        ERROR: begin
          error_flag <= 1;
        end
      endcase
    end
  end

  assign ready = (!rst && (state == IDLE));
endmodule