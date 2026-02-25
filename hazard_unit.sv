module hazard_unit(
    input logic [4:0] Rs1D, Rs2D,
    input logic [4:0] Rs1E, Rs2E,
    input logic [4:0] RdE,RdM,RdW,
    input logic RegWriteM, RegWriteW, RegWriteE,
    input logic Branch_occurredE,
    input logic [1:0] ResultSrcE,
    output logic StallF, StallD,
    output logic FlushE, FlushD,
    output logic[1:0] ForwardAE, ForwardBE
);
    logic lw_stall;
    // forward
    always_comb begin
        if(((Rs1E == RdM) && RegWriteM) & Rs1E != 0) begin
            ForwardAE = 2'b10;
        end
        else if(((Rs1E == RdW) && RegWriteW) & Rs1E != 0) begin
            ForwardAE = 2'b01;
        end
        else begin
            ForwardAE = 2'b00;
        end
    end

    always_comb begin
        if(((Rs2E == RdM) && RegWriteM) & Rs2E != 0) begin
            ForwardBE = 2'b10;
        end
        else if(((Rs2E == RdW) && RegWriteW) & Rs2E != 0) begin
            ForwardBE = 2'b01;
        end
        else begin
            ForwardBE = 2'b00;
        end
    end

    // stall
    assign lw_stall = (RegWriteE & (ResultSrcE == 2'b01) && ((RdE == Rs1D) || (RdE == Rs2D))) ? 1 : 0;
    assign StallF = lw_stall;   
    assign StallD = lw_stall;
    // flush
    assign FlushE = lw_stall | Branch_occurredE;
    assign FlushD = Branch_occurredE;

endmodule