module extend(
    input [1:0] ImmSrcD,
    input [31:7] InstrD,
    output logic [31:0] ImmExtD
);

    always_comb begin
        case (ImmSrcD)
            2'b00: ImmExtD = {{20{InstrD[31]}}, InstrD[31:20]}; // I-type
            2'b01: ImmExtD = {{20{InstrD[31]}}, InstrD[31:25], InstrD[11:7]}; // S-type
            2'b10: ImmExtD = {{19{InstrD[31]}}, InstrD[31], InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0}; // B-type
            2'b11: ImmExtD = {{12{InstrD[31]}}, InstrD[19:12], InstrD[20], InstrD[31:21], 1'b0}; // J-type
            default: ImmExtD = 32'h00000000; // Default case
        endcase
    end
endmodule