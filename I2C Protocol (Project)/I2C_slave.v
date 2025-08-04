module slave (
  input rst,
  input [6:0] slave_addr,
  input [7:0] data_in,
  input scl_posedge,

  output reg [7:0] data_out,

  inout sda, 
  inout scl
);
  parameter IDLE = 3'd0;
  parameter READ_ADDR = 3'd1;
  parameter ACK1 = 3'd2;
  parameter READ_DATA= 3'd3;
  parameter ACK2= 3'd4;
  parameter WRITE_DATA = 3'd5;

  reg [7:0] data_in_reg;
  //   reg [7:0] data_out_reg;
  reg [3:0] counter;
  reg [2:0] state ;
  reg [6:0] slv_addr;
  reg [7:0] check_addr;
  reg sda_out;
  reg scl_out;
  reg rw;
  reg wr_en;
  
  reg check=1'b0;

  assign sda = (wr_en)? sda_out : 'bz;

  
  always@(negedge sda) begin
    if( scl == 1 && state==IDLE) begin
      wr_en <= 0;
        counter <=7;
        slv_addr  <= slave_addr;
        data_in_reg <= data_in;
          state <= READ_ADDR;
    end
  end

  always @(posedge scl or posedge rst)
    if (rst) begin 
      wr_en     <= 0;
      state     <= IDLE;
      counter   <= 7;
      sda_out   <= 1;
      data_out  <= 8'd0;
      rw        <= 0;


    end
  else begin 
    case (state)
      IDLE : begin 
        wr_en <= 0;
        counter <=7;
        slv_addr  <= slave_addr;
        data_in_reg <= data_in;

      end 

      READ_ADDR : begin 
        if (counter == 0 ) begin 
          @(negedge scl_posedge) check_addr[0] = sda;
          rw <= sda;
//           wr_en <= 1;
          state <= ACK1;

        end
        else begin 
          @(negedge scl_posedge) check_addr[counter] = sda;
          counter <= counter -1;
        end
      end

      ACK1: begin 
        wr_en <= 1;
        counter <=7;
//         $strobe(check_addr,slv_addr);
        if (check_addr[7:1] == slv_addr)  begin 
//           check<=1'b1;
          sda_out <= 0;
          
          if (rw == 0) 
            state <= READ_DATA;
          else state <= WRITE_DATA;
        end
      end

      READ_DATA : begin 
        sda_out <= 1;
        wr_en <= 0;
        if (counter == 0 ) begin 
          @(negedge scl_posedge) data_out[counter] = sda;
          check=1'b1;
          state <= ACK2;
        end
        else begin 
          @(negedge scl_posedge) data_out[counter] <= sda;
          counter <= counter -1;
        end
      end

      ACK2 : begin
        wr_en <=1;
        sda_out <= 0;
        #4;state <= IDLE;
      end

      WRITE_DATA : begin 
        wr_en <= 1;
        if (counter == 0 ) begin 
          sda_out = data_in_reg [counter];

          state <= IDLE;
        end
        else begin 
          sda_out <= data_in_reg [counter];
          counter <= counter -1;
        end
      end
    endcase
  end
endmodule