`timescale 1ns/1ps

module datapath(input  logic        clk, reset,
                input  logic        PCWrite, AdrSrc, IRWrite, RegWrite,
                input  logic [1:0]  ALUSrcA, ALUSrcB, ResultSrc,
                input  logic [1:0]  ImmSrc,
                input  logic [2:0]  ALUControl,
                input  logic [31:0] ReadData,
                output logic        Zero,
                output logic [31:0] Adr, WriteData,
                output logic [6:0]  op,
                output logic [2:0]  funct3,
                output logic        funct7b5);

  logic [31:0] PC, OldPC, Instr, Data;
  logic [31:0] RD1, RD2, A;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] ALUResult, ALUOut, Result;

  assign op       = Instr[6:0];
  assign funct3   = Instr[14:12];
  assign funct7b5 = Instr[30];

  flopenr #(32) pcreg(clk, reset, PCWrite, Result, PC);
  mux2    #(32) adrmux(PC, Result, AdrSrc, Adr);

  flopenr #(32) oldpcreg(clk, reset, IRWrite, PC, OldPC);
  flopenr #(32) instrreg(clk, reset, IRWrite, ReadData, Instr);
  flopr   #(32) datareg(clk, reset, ReadData, Data);

  // Instr[19:15]=rs1, Instr[24:20]=rs2, Instr[11:7]=rd
  regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, RD1, RD2);
  extend  ext(Instr[31:7], ImmSrc, ImmExt);

  flopr   #(32) areg(clk, reset, RD1, A);
  flopr   #(32) breg(clk, reset, RD2, WriteData); // B register'ının çıkışı doğrudan WriteData'dır

  mux3    #(32) srcamux(PC, OldPC, A, ALUSrcA, SrcA);
  mux3    #(32) srcbmux(WriteData, 32'd4, ImmExt, ALUSrcB, SrcB);

  alu     alunit(SrcA, SrcB, ALUControl, ALUResult, Zero);
  flopr   #(32) aluoutreg(clk, reset, ALUResult, ALUOut);
  
  mux3    #(32) resultmux(ALUOut, Data, ALUResult, ResultSrc, Result);

endmodule
