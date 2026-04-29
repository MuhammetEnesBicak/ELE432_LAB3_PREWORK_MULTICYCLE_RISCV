`timescale 1ns/1ps

module riscv(input  logic        clk, 
             input  logic        reset,
             input  logic [31:0] ReadData,
             output logic        MemWrite,
             output logic [31:0] Adr, WriteData);

  logic [6:0]  op;
  logic [2:0]  funct3;
  logic        funct7b5;
  logic        Zero;
  logic [1:0]  ImmSrc;
  logic [1:0]  ALUSrcA, ALUSrcB;
  logic [1:0]  ResultSrc;
  logic        AdrSrc;
  logic [2:0]  ALUControl;
  logic        IRWrite, PCWrite, RegWrite;

  controller c(
    .clk(clk), 
    .reset(reset),
    .op(op), 
    .funct3(funct3), 
    .funct7b5(funct7b5), 
    .zero(Zero),
    .immsrc(ImmSrc),
    .alusrca(ALUSrcA), 
    .alusrcb(ALUSrcB),
    .resultsrc(ResultSrc),
    .adrsrc(AdrSrc),
    .alucontrol(ALUControl),
    .irwrite(IRWrite), 
    .pcwrite(PCWrite),
    .regwrite(RegWrite), 
    .memwrite(MemWrite)
  );

  datapath dp(
    .clk(clk), 
    .reset(reset),
    .PCWrite(PCWrite), 
    .AdrSrc(AdrSrc),
    .IRWrite(IRWrite), 
    .RegWrite(RegWrite),
    .ALUSrcA(ALUSrcA), 
    .ALUSrcB(ALUSrcB), 
    .ResultSrc(ResultSrc),
    .ImmSrc(ImmSrc), 
    .ALUControl(ALUControl),
    .ReadData(ReadData),
    .Zero(Zero),
    .Adr(Adr), 
    .WriteData(WriteData),
    .op(op), 
    .funct3(funct3), 
    .funct7b5(funct7b5)
  );

endmodule
