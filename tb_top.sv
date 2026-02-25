module tb_top();
    logic clk;
    logic reset;

    top dut(
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk; // Generate a clock signal with a period of 10 time units

    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, tb_top); // Dump all variables in the testbench for waveform analysis

        clk = 0; // Initialize clock to 0
        reset = 1; // Assert reset at the beginning

        #18 reset = 0; // Deassert reset after 18 time units

        #2000; // Run the simulation for 2000 time units to observe the behavior of the CPU
        $finish; // End the simulation
    end

endmodule