module control_unit(
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct75,
    output logic RegWriteD,
    output logic MemWriteD,
    output logic [1:0] ImmSrcD,
    output logic ALUSrcD,
    output logic [2:0] ALUControlD,
    output logic BranchD,
    output logic JumpD,
    output logic[1:0] ResultSrcD
);
    logic [1:0] ALUOpD;

    always_comb begin
        // Default values for control signals
        RegWriteD = 0;
        MemWriteD = 0;
        ImmSrcD = 2'b00;
        ALUSrcD = 2'b00;
        ALUControlD = 3'b000;
        BranchD = 0;
        JumpD = 0;
        ResultSrcD = 2'b00;
        ALUOpD = 2'b00;

        case (op)
            7'd51: begin // R-type
                RegWriteD = 1;
                ALUSrcD = 2'b00; // Register source
                ALUOpD = 2'b10; // ALU control determined by funct3 and funct7

            end
            7'd19: begin // I-type (e.g., ADDI)
                RegWriteD = 1;
                ALUSrcD = 1; // Immediate source
                ImmSrcD = 2'b00; // I-type immediate
                ALUOpD = 2'b10; // ALU control determined by funct3
            end
            7'd3: begin // Load (e.g., LW)
                RegWriteD = 1;
                MemWriteD = 0;
                ALUSrcD = 1; // Immediate source for address calculation
                ImmSrcD = 2'b00; // I-type immediate for load address
                ResultSrcD = 2'b01; // Load data from memory
                ALUOpD = 2'b00; // ALU performs address calculation (ADD)
            end
            7'd35: begin // Store (e.g., SW)
                RegWriteD = 0;
                MemWriteD = 1;
                ALUSrcD = 1; // Immediate source for address calculation
                ImmSrcD = 2'b01; // S-type immediate for store address
                ALUOpD = 2'b00; // ALU performs address calculation (ADD)
            end
            7'd99: begin // Branch (e.g., BEQ)
                RegWriteD = 0;
                BranchD = 1;
                ALUSrcD = 0; // Register source for comparison
                ImmSrcD = 2'b10; // B-type immediate for branch offset
                ALUOpD = 2'b01; // ALU performs subtraction for comparison
            end
            7'd111: begin // Jump (e.g., JAL)
                RegWriteD = 1;
                JumpD = 1;
                ALUSrcD = 0; 
                ImmSrcD = 2'b11; // J-type immediate for jump offset
                ResultSrcD = 2'b10; // PC + 4 as the result to write back
            end
            default: ;
        endcase
        case(ALUOpD)
            2'b00: ALUControlD = 3'b000; // ADD for load/store address calculation
            2'b01: ALUControlD = 3'b001; // SUB for branch comparison
            2'b10: begin // R-type or I-type ALU operations
                casez({funct3, op[5], funct75})
                    5'b00011: ALUControlD = 3'b001;
                    5'b000??: ALUControlD = 3'b000; // ADD
                    5'b010??: ALUControlD = 3'b101; // SLT
                    5'b110??: ALUControlD = 3'b010; // OR
                    5'b111??: ALUControlD = 3'b011; // AND
                    default: ALUControlD = 3'b000; // Default case
                endcase
            end
            default: ALUControlD = 3'b000; // Default case
        endcase

    end
endmodule