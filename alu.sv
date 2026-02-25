module alu(
    input logic [31:0] SrcAE,
    input logic [31:0] SrcBE,
    input logic [2:0] ALUControlE,
    output logic [31:0] ALUResultE,
    output logic ZeroE
);
    always_comb begin
        case(ALUControlE)
            3'b000: ALUResultE = SrcAE + SrcBE; // ADD
            3'b001: ALUResultE = SrcAE - SrcBE; // SUB
            3'b010: ALUResultE = SrcAE | SrcBE; // OR
            3'b011: ALUResultE = SrcAE & SrcBE; // AND
            3'b101: ALUResultE = ($signed(SrcAE) < $signed(SrcBE) ? 1 : 0); // SLT
            default: ALUResultE = 32'h00000000; // Default case
        endcase
        ZeroE = (ALUResultE == 32'h00000000);
    end
endmodule