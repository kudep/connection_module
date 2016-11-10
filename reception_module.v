
`include "timescale.v"

`include "connection_module_defines.v"

module reception_module(data_o, stb_o, clk_i, reset_i, en_i, sda_i, scl_i);

  parameter DATA_WIDTH = 8;
  parameter PRSCL_WIDTH = 8;

  output [DATA_WIDTH-1 : 0] data_o;
  output            stb_o;
  input            clk_i, reset_i;
  input            en_i, sda_i, scl_i;

  reg [DATA_WIDTH-1 : 0] data_o;
  reg            stb_o;
  wire            clk_i, reset_i;
  wire            en_i, sda_i, scl_i;


  //Filtration section
  reg [ 2:0] fEN, fSDA, fSCL;      // SCL and SDA filter inputs
  reg        sEN, sSDA, sSCL;      // filtered and synchronized SCL and SDA inputs
  reg        dEN, dSDA, dSCL;      // delayed versions of sSCL and sSDA
  // capture EN, SDA and SCL
  // reduce metastability risk
  always @(posedge clk_i or posedge reset_i)
    if (reset_i)
    begin
        fSCL <= #`DELAY 3'b000;
        fSDA <= #`DELAY 3'b000;
        fEN  <= #`DELAY 3'b000;
    end
    else
    begin
        fSCL <= #`DELAY {fSCL[1:0],scl_i};
        fSDA <= #`DELAY {fSDA[1:0],sda_i};
        fEN  <= #`DELAY {fEN[1:0],en_i};
    end


  // generate filtered EN, SCL and SDA signals
  always @(posedge clk_i or posedge reset_i)
    if (reset_i)
    begin
        sSCL <= #`DELAY 1'b0;
        sSDA <= #`DELAY 1'b0;
        sEN <=  #`DELAY 1'b0;

        dSCL <= #`DELAY 1'b0;
        dSDA <= #`DELAY 1'b0;
        dEN <=  #`DELAY 1'b0;
    end
    else
    begin
        sSCL <= #`DELAY &fSCL[2:1] | &fSCL[1:0];
        sSDA <= #`DELAY &fSDA[2:1] | &fSDA[1:0];
        sEN <= #`DELAY &fEN[2:1] | &fEN[1:0];

        dSCL <= #`DELAY sSCL;
        dSDA <= #`DELAY sSDA;
        dEN <= #`DELAY sEN;
    end


  //Data reception section
  reg [DATA_WIDTH-1 : 0] data;
  reg [4:0] bit_count;
  always @(posedge clk_i or posedge reset_i)
    if (reset_i)
    begin
      bit_count <= #`DELAY DATA_WIDTH;
      data<= #`DELAY 8'b0000_0000;
    end
    else
      if (sSCL & ~dSCL & dEN & sEN)
      begin
        data <= #`DELAY{data[DATA_WIDTH-2:0], dSDA};
        if (~|bit_count) bit_count <= #`DELAY DATA_WIDTH-1;
        else bit_count= #`DELAY bit_count-1;
      end
      else
        if (~dEN | ~sEN)
        begin
          bit_count <= #`DELAY DATA_WIDTH;
        end


  // generate fdata_o and stb_o signals
  reg shift_stb;
  always @(posedge clk_i or posedge reset_i)
    if (reset_i)
    begin
      data_o<= #`DELAY 8'b0000_0000;
      stb_o <= #`DELAY 1'b0;
      shift_stb <= #`DELAY 1'b0;
    end
    else
    begin
      stb_o<=shift_stb;
      if (~|bit_count)
      begin
        data_o<= #`DELAY data;
        shift_stb <= #`DELAY 1'b1;
      end
      else
      begin
        shift_stb <= #`DELAY 1'b0;
      end
    end


endmodule // connection_module
