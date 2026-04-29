`timescale 1ns/1ps

module mainfsm(input  logic        clk,
               input  logic        reset,
               input  logic [6:0]  op,
               output logic        Branch, PCUpdate,
               output logic        RegWrite, MemWrite, IRWrite,
               output logic [1:0]  ResultSrc, ALUSrcB, ALUSrcA,
               output logic        AdrSrc,
               output logic [1:0]  ALUOp);

  typedef enum logic [3:0] {
    S0_FETCH, S1_DECODE, S2_MEMADR, S3_MEMREAD, S4_MEMWB,
    S5_MEMWRITE, S6_EXECUTER, S7_ALUWB, S8_EXECUTEI, S9_JAL, S10_BEQ
  } statetype;

  statetype state, nextstate;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) state <= S0_FETCH;
    else       state <= nextstate;
  end

  always_comb begin
    case(state)
      S0_FETCH:   nextstate = S1_DECODE;
      S1_DECODE:  case(op)
                    7'b0000011: nextstate = S2_MEMADR;   // lw
                    7'b0100011: nextstate = S2_MEMADR;   // sw
                    7'b0110011: nextstate = S6_EXECUTER; // R-type
                    7'b0010011: nextstate = S8_EXECUTEI; // I-type ALU
                    7'b1101111: nextstate = S9_JAL;      // jal
                    7'b1100011: nextstate = S10_BEQ;     // beq
                    default:    nextstate = S0_FETCH;
                  endcase
      S2_MEMADR:  case(op)
                    7'b0000011: nextstate = S3_MEMREAD;  // lw
                    7'b0100011: nextstate = S5_MEMWRITE; // sw
                    default:    nextstate = S0_FETCH;
                  endcase
      S3_MEMREAD: nextstate = S4_MEMWB;
      S4_MEMWB:   nextstate = S0_FETCH;
      S5_MEMWRITE:nextstate = S0_FETCH;
      S6_EXECUTER:nextstate = S7_ALUWB;
      S7_ALUWB:   nextstate = S0_FETCH;
      S8_EXECUTEI:nextstate = S7_ALUWB;
      S9_JAL:     nextstate = S7_ALUWB;
      S10_BEQ:    nextstate = S0_FETCH;
      default:    nextstate = S0_FETCH;
    endcase
  end

  always_comb begin
    // Assigning 0 for don't care determinism
    Branch    = 1'b0;
    PCUpdate  = 1'b0;
    RegWrite  = 1'b0;
    MemWrite  = 1'b0;
    IRWrite   = 1'b0;
    ResultSrc = 2'b00;
    ALUSrcB   = 2'b00;
    ALUSrcA   = 2'b00;
    AdrSrc    = 1'b0;
    ALUOp     = 2'b00;

    case(state)
      S0_FETCH: begin
        AdrSrc    = 1'b0;
        IRWrite   = 1'b1;
        ALUSrcA   = 2'b00;
        ALUSrcB   = 2'b01; // PC + 4 için ALUSrcB 01 olmalı
        ALUOp     = 2'b00;
        ResultSrc = 2'b10;
        PCUpdate  = 1'b1;
      end
      S1_DECODE: begin
        ALUSrcA   = 2'b01;
        ALUSrcB   = 2'b10; // OldPC + ImmExt dallanma hesabı için 10 olmalı
        ALUOp     = 2'b00;
      end
      S2_MEMADR: begin
        ALUSrcA   = 2'b10;
        ALUSrcB   = 2'b10; // Base Address + ImmExt için 10 olmalı
        ALUOp     = 2'b00;
      end
      S3_MEMREAD: begin
        ResultSrc = 2'b00;
        AdrSrc    = 1'b1;
      end
      S4_MEMWB: begin
        ResultSrc = 2'b01;
        RegWrite  = 1'b1;
      end
      S5_MEMWRITE: begin
        ResultSrc = 2'b00;
        AdrSrc    = 1'b1;
        MemWrite  = 1'b1;
      end
      S6_EXECUTER: begin
        ALUSrcA   = 2'b10;
        ALUSrcB   = 2'b00;
        ALUOp     = 2'b10;
      end
      S7_ALUWB: begin
        ResultSrc = 2'b00;
        RegWrite  = 1'b1;
      end
      S8_EXECUTEI: begin
        ALUSrcA   = 2'b10;
        ALUSrcB   = 2'b10; // rs1 + ImmExt (I-Type) icin 10 
        ALUOp     = 2'b10;
      end
		
		S9_JAL: begin
        ALUSrcA   = 2'b01;       // OldPC
        ALUSrcB   = 2'b01;       // 01 (Sabit 4) olmalı
        ALUOp     = 2'b00;       // ALU = OldPC + 4 işlemini yapar
        ResultSrc = 2'b00;       // S1'den gelen hedef adres PC'ye yazılır
        PCUpdate  = 1'b1;
      end
		
      S10_BEQ: begin
        ALUSrcA   = 2'b10;
        ALUSrcB   = 2'b00;
        ALUOp     = 2'b01;
        ResultSrc = 2'b00;
        Branch    = 1'b1;
      end
    endcase
  end
endmodule
