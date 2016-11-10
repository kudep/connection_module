`include "timescale.v"
module test;

  /* Make a reset that pulses once. */
  parameter DATA_WIDTH = 8;
  parameter PRSCL_WIDTH = 8;
/*
  //transmission_module
  reg [DATA_WIDTH-1 : 0] data_i;
  reg [PRSCL_WIDTH-1 : 0] prescl_i;
  reg            reset_i, start_i;
  wire            busy_o;
  wire            en_o, sda_o, scl_o;

  //reception_module
  wire [DATA_WIDTH-1 : 0] data_o;
  wire            stb_o;
  wire            en_i, sda_i, scl_i;

  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);
      data_i=144;
      prescl_i=8;
      reset_i = 0;
      start_i=0;
      # 10 reset_i = 1;
      # 40 reset_i = 0;
      start_i=1;
      # 20 start_i = 0;
      # 10130 start_i=0;
      data_i=129;
      # 40 start_i = 1;
      # 20 start_i = 0;
      # 51300 $finish;
  end

  reg clk_i = 0;
  always #10 clk_i = !clk_i;

  //transmission_module tm1 (data_i, prescl_i, clk_i, reset_i, start_i,busy_o, en_o, sda_o, scl_o);

  assign en_i = en_o;
  assign sda_i = sda_o;
  assign scl_i = scl_o;

  //reception_module rm1 (data_o, stb_o, clk_i, reset_i, en_i, sda_i, scl_i);

*/

  //reg
  reg [DATA_WIDTH-1 : 0] data_i;
  wire [DATA_WIDTH-1 : 0] data_o;
  reg [PRSCL_WIDTH-1 : 0] pre_reg_i;
  wire [PRSCL_WIDTH-1 : 0] status_reg_o;
  reg [PRSCL_WIDTH-1 : 0] cmd_reg_i;


  reg            reset_i, start_i;
  wire            en_o, sda_o, scl_o;

  //reception_module
  wire            en_i, sda_i, scl_i;

  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);
      data_i=144;
      pre_reg_i=8;
      cmd_reg_i=0;
      reset_i = 0;
      # 10 reset_i = 1;
      # 40 reset_i = 0;
      # 20 cmd_reg_i[0] = 0;
      cmd_reg_i[0] = 1;
      # 6130 cmd_reg_i[1]=1;
      # 4130 cmd_reg_i[1]=1;
      # 30 cmd_reg_i[1]=0;
      # 5130 cmd_reg_i[0]=0;
      data_i=129;
      # 40 cmd_reg_i[0] = 1;
      # 20 cmd_reg_i[0] = 0;
      # 51300 $finish;
  end

  reg clk_i = 0;
  always #10 clk_i = !clk_i;

  assign en_i = en_o;
  assign sda_i = sda_o;
  assign scl_i = scl_o;

connection_module cm1(clk_i, reset_i, pre_reg_i, status_reg_o, cmd_reg_i, data_i, data_o, en_o, sda_o, scl_o, en_i, sda_i, scl_i);


  initial
     $monitor("At time %t, value = %h (%0d)",
              $time, sda_o, sda_o);
endmodule // test