module regfile(
    input logic clk,
    input logic [4:0] A1, // Address of the first register to read
    input logic [4:0] A2, // Address of the second register to read
    input logic [4:0] A3, // Address of the register to write
    input logic [31:0] WD3, // Data to write to the register specified by A3
    input logic RegWriteW, // Control signal to enable register write
    output logic [31:0] RD1, // Data read from the first register
    output logic [31:0] RD2 // Data read from the second register
);
    logic [31:0] rf [31:0]; // Register file with 32 registers of 32 bits each
    assign RD1 = A1 == 0 ? 0 : rf[A1]; // Read data from the first register
    assign RD2 = A2 == 0 ? 0 : rf[A2]; // Read data from the second register
    always_ff @(posedge clk) begin
        if (RegWriteW && A3 != 0) begin
            rf[A3] <= WD3; // Write data to the register specified by A3 if RegWriteD is enabled
        end
    end
endmodule