module pc(
    input logic clk, reset,
    input [31:0] PCF_next,
    input logic StallF,
    output logic [31:0] PCF
);
    always_ff @(posedge clk) begin
        if(reset) begin
            PCF <= 32'b0;
        end
        else if(StallF) begin
            PCF <= PCF;
        end
        else begin
            PCF <= PCF_next;
        end
    end
endmodule