module alu(input  logic [31:0] a, b,
           input  logic [2:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);
  always_comb
    case (alucontrol)
      3'b000: result = a + b;       // add
      3'b001: result = a - b;       // sub
      3'b010: result = a & b;       // and
      3'b011: result = a | b;       // or
      3'b101: result = (a < b) ? 32'd1 : 32'd0; // slt
      default: result = 32'bx;
    endcase

  assign zero = (result == 32'd0);
endmodule
