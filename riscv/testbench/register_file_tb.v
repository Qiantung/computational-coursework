`timescale 1ns / 1ps

module register_file_tb;

    // Testbench signals
    reg clk;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] w_data;
    reg w_en;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    // Instantiate the register_file module
    register_file uut (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .w_data(w_data),
        .w_en(w_en),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Clock generation
    always begin
        clk = ~clk;
        #5;  // Clock period: 10ns (50MHz)
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 1;
        rs1 = 5'd0;
        rs2 = 5'd0;
        rd = 5'd0;
        w_data = 32'd0;
        w_en = 0;

        // Apply reset (if needed)
        #10;

        // Test Case 1: Write to register 1 and read from register 1
        w_en = 1;
        rd = 5'd1;
        w_data = 32'h12345678;  // Data to write
        #10;  // Wait for one clock cycle

        // Read from register 1
        rs1 = 5'd1;
        #10;  // Wait for one clock cycle
        $display("Read from rs1 (Reg 1): %h", rs1_data); // Expect 0x12345678

        // Test Case 2: Write to register 2 and read from rs1 and rs2
        rd = 5'd2;
        w_data = 32'hA5A5A5A5;  // Data to write
        #10;

        rs1 = 5'd1;  // Read from register 1 (should be 0x12345678)
        rs2 = 5'd2;  // Read from register 2 (should be 0xA5A5A5A5)
        #10;

        $display("Read from rs1 (Reg 1): %h", rs1_data); // Expect 0x12345678
        $display("Read from rs2 (Reg 2): %h", rs2_data); // Expect 0xA5A5A5A5

        // Test Case 3: Write to register 0 (should not be written to)
        rd = 5'd0;
        w_data = 32'hDEADBEEF;
        #10;  // Register 0 is hardwired to 0

        rs1 = 5'd0;  // Read from register 0 (should be 0)
        rs2 = 5'd0;  // Read from register 0 (should be 0)
        #10;

        $display("Read from rs1 (Reg 0): %h", rs1_data); // Expect 0x00000000
        $display("Read from rs2 (Reg 0): %h", rs2_data); // Expect 0x00000000

        // Test Case 4: Write to another register and verify the write
        rd = 5'd3;
        w_data = 32'hDEADBEEF;
        #10;
        rs1 = 5'd3;
        #10;
        $display("Read from rs1 (Reg 3): %h", rs1_data); // Expect 0xDEADBEEF

        // Test Case 5: Disable write enable and check no write occurs
        w_en = 0;
        rd = 5'd1;
        w_data = 32'hC0FFEE00;
        #10; // No write should happen
        rs1 = 5'd1;
        #10;
        $display("Read from rs1 (Reg 1) after disabling write: %h", rs1_data); // Expect 0x12345678, as no write occurs

        $finish;
    end
endmodule
