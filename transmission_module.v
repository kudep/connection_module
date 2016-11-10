
`include "timescale.v"

`include "connection_module_defines.v"

module transmission_module( clk_i, reset_i, prescl_i, data_i, start_i, busy_o, en_o, sda_o, scl_o);

  parameter DATA_WIDTH = 8;
  parameter PRSCL_WIDTH = 8;

  input [DATA_WIDTH-1 : 0] data_i;
  input [PRSCL_WIDTH-1 : 0] prescl_i;
  input            clk_i, reset_i, start_i;
  output            busy_o;
  output            en_o, sda_o, scl_o;

  
  wire [DATA_WIDTH-1 : 0] data_i;
  wire [PRSCL_WIDTH-1 : 0] prescl_i;
  wire            clk_i, reset_i, start_i;
  wire            busy_o;
  reg            en_o, sda_o, scl_o;
assign busy_o = en_o;

  //Prescaler section
  reg [PRSCL_WIDTH-1 : 0] prescl_count;
  reg clk;
  always @(posedge clk_i or posedge reset_i)
    if(reset_i)
      prescl_count<=#`DELAY 0;
    else
      if(~|prescl_count) 
        prescl_count<=#`DELAY prescl_i>>2;//for 4 stage of transmission
      else 
        prescl_count<=#`DELAY prescl_count-1;

  always @(posedge clk_i or posedge reset_i)
    if(reset_i)
    begin
      prescl_count<=#`DELAY 0;
      clk<=#`DELAY 0;
    end
    else
      if(~|prescl_count) 
        clk<=#`DELAY ~clk;


  //Data transmission section


  // cmd_state machine variable
  reg cmd_state; // synopsys enum_cmd_state

  parameter cmd_state_idle = 1'b0;
  parameter cmd_state_a    = 1'b1;

  reg [4:0] bit_count;
  reg transmite;
  reg start;

  always @(posedge clk_i or posedge reset_i)
    if(reset_i)
    begin
      cmd_state<=#`DELAY cmd_state_idle;
      transmite<=#`DELAY 1'b0;
      start<=#`DELAY 1'b0;
    end
    else
    begin
      start<=#`DELAY 1'b0;
      case(cmd_state)
        cmd_state_idle:
          begin
            if(start_i) 
            begin
              cmd_state<=#`DELAY cmd_state_a;
              transmite<=#`DELAY 1'b1;
              start<=#`DELAY 1'b1;
            end
            else
            begin
              cmd_state<=#`DELAY cmd_state_idle;
            end
          end
        cmd_state_a:
          begin
            if(!start_i)
            begin
              cmd_state<=#`DELAY cmd_state_idle;
            end
            else
            begin
              cmd_state<=#`DELAY cmd_state_a;
            end
          end
        default:
          begin
            cmd_state<=#`DELAY cmd_state_idle;
            start<=#`DELAY 1'b0;
          end
      endcase
      if(~|bit_count) transmite<=#`DELAY 1'b0;
    end

  // transmission_state machine variable
  reg [3:0] transmission_state; // synopsys enum_transmission_state

  parameter [3:0] transmission_state_idle = 4'b0000;
  parameter [3:0] transmission_state_a    = 4'b0001;
  parameter [3:0] transmission_state_b    = 4'b0010;
  parameter [3:0] transmission_state_c    = 4'b0100;
  parameter [3:0] transmission_state_d    = 4'b1000;

  
  reg [DATA_WIDTH-1 : 0] data;

  always @(posedge clk or posedge reset_i)
    if(reset_i)
    begin
      transmission_state<=#`DELAY transmission_state_idle;
      en_o<=#`DELAY 1'b0;
      data <=#`DELAY data_i;
      sda_o<=#`DELAY 1'b0;
      scl_o<=#`DELAY 1'b0;
      bit_count<=#`DELAY DATA_WIDTH;
    end
    else
    begin
      en_o<=#`DELAY 1'b1;
      sda_o<=#`DELAY data[DATA_WIDTH-1];
      scl_o<=#`DELAY 1'b0;
      case(transmission_state)
        transmission_state_idle:
          begin
            if(transmite) 
            begin 
              transmission_state<=#`DELAY transmission_state_a;
              if(start) data <=#`DELAY data_i;
            end
            else
            begin
              transmission_state<=#`DELAY transmission_state_idle;
              en_o<=#`DELAY 1'b0;
              bit_count<=#`DELAY DATA_WIDTH;
              sda_o<=#`DELAY 1'b0;
            end
          end
        transmission_state_a:
          begin
            transmission_state<=#`DELAY transmission_state_b;
          end
        transmission_state_b:
          begin
            transmission_state<=#`DELAY transmission_state_c;
            scl_o<=#`DELAY 1'b1;
          end
        transmission_state_c:
          begin
            transmission_state<=#`DELAY transmission_state_d;
            scl_o<=#`DELAY 1'b1;
          end
        transmission_state_d:
          begin
            transmission_state<=#`DELAY transmission_state_idle;
            data<=#`DELAY {data[DATA_WIDTH-2 : 0],1'b0};
            bit_count<=bit_count-1;
          end
        default:
          begin
            transmission_state<=#`DELAY transmission_state_idle;
            en_o<=#`DELAY 1'b0;
          end
      endcase
    end


endmodule // connection_module
