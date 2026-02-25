module imem(
    input logic [31:0] A, // Address for instruction fetch (word-aligned)
    output logic [31:0] RD // Instruction read from memory
);
    logic [31:0] mem [127:0]; // Instruction memory with 128 words of 32 bits each

    // Load instruction memory from a file
    initial begin
        $readmemh("memfile.dat", mem);
    end

    // Read instruction from memory using the address A (word-aligned)
    always_comb begin
        RD = mem[A[8:2]];
    end
endmodule