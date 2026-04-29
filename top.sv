`timescale 1ns/1ps

module top(input  logic        clk, 
           input  logic        reset,
           output logic [31:0] WriteData, DataAdr,
           output logic        MemWrite);

  logic [31:0] ReadData;

  // RISC-V (Controller + Datapath)
  riscv rv(
    .clk(clk), 
    .reset(reset),
    .ReadData(ReadData),
    .MemWrite(MemWrite),
    .Adr(DataAdr),
    .WriteData(WriteData)
  );

  // Unified Memory
  mem memory(
    .clk(clk), 
    .we(MemWrite),
    .a(DataAdr), 
    .wd(WriteData),
    .rd(ReadData)
  );

endmodule
