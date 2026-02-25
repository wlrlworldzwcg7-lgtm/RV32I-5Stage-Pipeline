module top(
    input logic clk, reset
);

    // IF
    logic [31:0] PCF, InstrF, PCF_next, PCPlus4F;
    logic StallF;
    // ID
    logic [31:0] InstrD, ExtImmD, PCD, PCPlus4D;
    logic [4:0] Rs1D, Rs2D, RdD, RD1D, RD2D;
    logic RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
    logic [1:0] ResultSrcD;
    logic [2:0] ALUControlD;
    logic [1:0] ImmSrcD;
    logic FlushD, StallD;
    // EXE
    logic [31:0] SrcAE, SrcBE, WriteDataE, ExtImmE, PCE, PCTargetE, SrcBE_alterE, PCPlus4E, ALUResultE;
    logic [4:0] Rs1E, Rs2E, RdE, RD1E, RD2E;
    logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE;
    logic [1:0] ResultSrcE, ForwardAE, ForwardBE;
    logic [2:0] ALUControlE;
    logic PCSrcE, ZeroE, FlushE, Branch_occurredE;
    // MEM
    logic [31:0] ALUResultM, WriteDataM, PCPlus4M, ReadDataM;
    logic [4:0] RdM;
    logic RegWriteM, MemWriteM;
    logic [1:0] ResultSrcM;
    // WB
    logic [31:0] ALUResultW, ReadDataW, PCPlus4W, ResultW;
    logic [4:0] RdW;
    logic RegWriteW;
    logic [1:0] ResultSrcW;

    // modules
    pc my_pc(
        .clk(clk), .reset(reset),
        .PCF_next(PCF_next),
        .StallF(StallF),
        .PCF(PCF)
    );

    imem my_imem(
        .A(PCF),
        .RD(InstrF)
    );
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];
    regfile my_regfile(
        .clk(clk),
        .RegWriteW(RegWriteW),
        .A1(Rs1D), .A2(Rs2D), .A3(RdW),
        .WD3(ResultW),
        .RD1(RD1D), .RD2(RD2D)
    );

    extend my_extend(
        .ImmSrcD(ImmSrcD),
        .InstrD(InstrD[31:7]),
        .ImmExtD(ExtImmD)
    );

    control_unit my_control(
        .op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct75(InstrD[30]),
        .RegWriteD(RegWriteD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUSrcD(ALUSrcD),
        .ResultSrcD(ResultSrcD),
        .ALUControlD(ALUControlD),
        .ImmSrcD(ImmSrcD)
    );

    alu my_alu(
        .SrcAE(SrcAE),
        .SrcBE(SrcBE),
        .ALUControlE(ALUControlE),
        .ALUResultE(ALUResultE),
        .ZeroE(ZeroE)
    );

    dmem my_dmem(
        .clk(clk),
        .A(ALUResultM),
        .WD(WriteDataM),
        .WE(MemWriteM),
        .RD(ReadDataM)
    );

    hazard_unit my_hazard_unit(
        .Rs1D(Rs1D), .Rs2D(Rs2D), .RdE(RdE), .RdM(RdM), .RdW(RdW),
        .Rs1E(Rs1E), .Rs2E(Rs2E),
        .RegWriteE(RegWriteE), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
        .Branch_occurredE(Branch_occurredE), .ResultSrcE(ResultSrcE),
        .StallF(StallF), .StallD(StallD), .FlushD(FlushD), .FlushE(FlushE),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );

    assign PCPlus4F = PCF + 4;
    assign PCF_next = PCSrcE ? PCTargetE : PCPlus4F;
    always_comb begin
        case(ForwardAE)
            2'b00: SrcAE = RD1E;
            2'b01: SrcAE = ResultW;
            2'b10: SrcAE = ALUResultM;
            default: SrcAE = RD1E;
        endcase
        case(ForwardBE)
            2'b00: SrcBE_alterE = RD2E;
            2'b01: SrcBE_alterE = ResultW;
            2'b10: SrcBE_alterE = ALUResultM;
            default: SrcBE_alterE = RD2E;
        endcase
    end
    
    assign SrcBE = ALUSrcE ? ExtImmE : SrcBE_alterE;
    assign PCTargetE = PCE + ExtImmE; //extend的时候已经把00补齐了
    assign Branch_occurredE = BranchE & ZeroE;
    assign PCSrcE = JumpE | Branch_occurredE;
    assign WriteDataE = SrcBE_alterE;
    always_comb begin
        case(ResultSrcW)
            2'b00: ResultW = ALUResultW;
            2'b01: ResultW = ReadDataW;
            2'b10: ResultW = PCPlus4W;
            default: ResultW = ALUResultW;
        endcase
    end

    always_ff @(posedge clk)begin
        if(FlushD) begin
            InstrD <= 32'h00000000;
            PCD <= 32'h00000000;
            PCPlus4D <= 32'h00000000;
        end
        else if(!StallD) begin
            InstrD <= InstrF;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end

    always_ff @(posedge clk)begin
        if(FlushE) begin
            RegWriteE <= 0;
            MemWriteE <= 0;
            JumpE <= 0;
            BranchE <= 0;
            ALUSrcE <= 0;
            ResultSrcE <= 0;
            ALUControlE <= 0;
            Rs1E <= 0;
            Rs2E <= 0;
            RdE <= 0;
            RD1E <= 0;
            RD2E <= 0;
            ExtImmE <= 0;
            PCE <= 0;
            PCPlus4E <= 0;
        end
        else begin
            RegWriteE <= RegWriteD;
            MemWriteE <= MemWriteD;
            JumpE <= JumpD;
            BranchE <= BranchD;
            ALUSrcE <= ALUSrcD;
            ResultSrcE <= ResultSrcD;
            ALUControlE <= ALUControlD;
            Rs1E <= Rs1D;
            Rs2E <= Rs2D;
            RdE <= RdD;
            RD1E <= RD1D;
            RD2E <= RD2D;
            ExtImmE <= ExtImmD;
            PCE <= PCD; 
            PCPlus4E <= PCPlus4D;
        end
    end

    always_ff @(posedge clk)begin
        RegWriteM <= RegWriteE;
        MemWriteM <= MemWriteE;
        ResultSrcM <= ResultSrcE;
        RdM <= RdE;
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        PCPlus4M <= PCPlus4E;
    end

    always_ff @(posedge clk)begin
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        RdW <= RdM;
        ALUResultW <= ALUResultM;
        ReadDataW <= ReadDataM;
        PCPlus4W <= PCPlus4M;
    end

endmodule