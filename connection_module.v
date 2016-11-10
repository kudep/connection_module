
`include "timescale.v"

`include "connection_module_defines.v"

module connection_module(clk_i, reset_i, pre_reg_i, status_reg_o, cmd_reg_i, data_i, data_o, en_o, sda_o, scl_o, en_i, sda_i, scl_i);

  parameter DATA_WIDTH = 8;
  parameter REG_WIDTH = 8;

  input            clk_i, reset_i;
  input [REG_WIDTH-1 : 0] pre_reg_i;
  output [REG_WIDTH-1 : 0] status_reg_o;
  input [REG_WIDTH-1 : 0] cmd_reg_i;
  input [DATA_WIDTH-1 : 0] data_i;
  output [DATA_WIDTH-1 : 0] data_o;

  output            en_o, sda_o, scl_o;
  input            en_i, sda_i, scl_i;


  reg [DATA_WIDTH-1 : 0] data_o;
  reg [DATA_WIDTH-1 : 0] status_reg_o;
  wire            en_o, sda_o, scl_o;

  //set data update bit of status register and set data_o
  wire [DATA_WIDTH-1 : 0] data;
  always @(posedge reset_i or posedge stb_o or posedge cmd_reg_i[1])
  begin
    if (reset_i)
    begin
      status_reg_o[1]<=#`DELAY 1'b0;
      data_o<=#`DELAY 8'b0000_0000;
    end
    else
      if (stb_o)
      begin
        status_reg_o[1]<=#`DELAY 1'b1;
        data_o<=#`DELAY data;
      end
        else if (cmd_reg_i[1])
          status_reg_o[1]<=#`DELAY 1'b0;
  end

  //set busy bit of status register
  wire busy;
  always @(posedge reset_i or posedge clk_i)
  begin
    if (reset_i)
    begin
      status_reg_o[0]<=#`DELAY 1'b0;
      data_o<=#`DELAY 8'b0000_0000;
    end
    else
      status_reg_o[0]<=#`DELAY busy;
  end

  always @(posedge reset_i)
  begin
    if (reset_i)
    begin
      status_reg_o[7:2]<=#`DELAY 6'b00_0000;
    end
  end

  //reception_module 
  reception_module rm
  (
    .data_o     (data           ),
    .stb_o      (stb_o            ),
    .clk_i      (clk_i            ),
    .reset_i    (reset_i          ),
    .en_i       (en_i             ),
    .sda_i      (sda_i            ),
    .scl_i      (scl_i            )
  );
  
  //transmission_module
  transmission_module tm
  (
    .clk_i     (clk_i             ),
    .reset_i   (reset_i           ),
    .start_i   (cmd_reg_i[0]      ),
    .data_i    (data_i            ),
    .prescl_i  (pre_reg_i         ),
    .busy_o    (busy              ),
    .en_o      (en_o              ),
    .sda_o     (sda_o             ),
    .scl_o     (scl_o             )
  );


endmodule // connection_module
