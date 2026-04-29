`timescale 1ns/1ps

module controller(input  logic       clk,
                  input  logic       reset,
                  input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic       zero,
                  output logic [1:0] immsrc,
                  output logic [1:0] alusrca, alusrcb,
                  output logic [1:0] resultsrc,
                  output logic       adrsrc,
                  output logic [2:0] alucontrol,
                  output logic       irwrite, pcwrite,
                  output logic       regwrite, memwrite);

  logic [1:0] aluop;
  logic       branch;
  logic       pcupdate;

  mainfsm fsm (
    .clk(clk),
    .reset(reset),
    .op(op),
    .Branch(branch),
    .PCUpdate(pcupdate),
    .RegWrite(regwrite),
    .MemWrite(memwrite),
    .IRWrite(irwrite),
    .ResultSrc(resultsrc),
    .ALUSrcB(alusrcb),
    .ALUSrcA(alusrca),
    .AdrSrc(adrsrc),
    .ALUOp(aluop)
  );

  aludec ad (
    .opb5(op[5]),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .ALUOp(aluop),
    .ALUControl(alucontrol)
  );
  
  instrdec id (
    .op(op),
    .ImmSrc(immsrc)
  );

  assign pcwrite = (branch & zero) | pcupdate;

endmodule
