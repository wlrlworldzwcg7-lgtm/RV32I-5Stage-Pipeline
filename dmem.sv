module dmem(
    input logic WE, // Control signal to enable memory write
    input logic clk, // Clock signal for synchronizing memory operations
    input logic [31:0] WD, // Data to be written to memory
    input logic [31:0] A, // Address for memory access (word-aligned)
    output logic [31:0] RD // Data read from memory
);
    // Memory array
    logic [31:0] mem [127:0]; 

    // Write data to memory
    always_ff @(posedge clk) begin
        if (WE) begin
            mem[A[8:2]] <= WD;
        end
    end

    // Read data from memory
    always_comb begin
        RD = mem[A[8:2]];
    end
endmodule