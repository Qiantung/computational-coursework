`timescale 1ns / 1ps

module ALU_tb;

    // Testbench signals
    reg [3:0] ALU_Control;
    reg [31:0] SrcA;
    reg [31:0] SrcB;
    wire Zero;
    wire Overflow;
    wire [31:0] ALU_Result;

    // Instantiate the ALU
    ALU uut (
        .ALU_Control(ALU_Control),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Zero(Zero),
        .Overflow(Overflow),
        .ALU_Result(ALU_Result)
    );

    // Apply test vectors
    initial begin
        // Test 1: 加法操作 (ALU_Control = 0000)
        ALU_Control = 4'b0000; // Add
        SrcA = 32'h80000000;   // 5
        SrcB = 32'h80000000;   // 3
        #10;  // Wait for 10 time units
        $display("Add: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 2: 减法操作 (ALU_Control = 0011)
        ALU_Control = 4'b0011; // Subtract
        SrcA = 32'h00000005;   // 5
        SrcB = 32'ha0000003;   // 3
        #10;
        $display("Sub: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 3: 逻辑与操作 (ALU_Control = 0100)
        ALU_Control = 4'b0100; // AND
        SrcA = 32'h000000FF;   // 0000000011111111
        SrcB = 32'h0000F0F0;   // 1111000001110000
        #10;
        $display("AND: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 4: 逻辑或操作 (ALU_Control = 0101)
        ALU_Control = 4'b0101; // OR
        SrcA = 32'h0000000F;   // 00000000000000000000000000001111
        SrcB = 32'h000000F0;   // 00000000000000000000000011110000
        #10;
        $display("OR: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 5: 逻辑异或操作 (ALU_Control = 0110)
        ALU_Control = 4'b0110; // XOR
        SrcA = 32'h000000FF;   // 0000000011111111
        SrcB = 32'h0000F0F0;   // 1111000001110000
        #10;
        $display("XOR: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 6: 逻辑或非操作 (ALU_Control = 0111)
        ALU_Control = 4'b0111; // NOR
        SrcA = 32'h000000F0;   // 11110000
        SrcB = 32'h0000000F;   // 00001111
        #10;
        $display("NOR: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 7: 无符号小于 (ALU_Control = 1000)
        ALU_Control = 4'b1000; // Unsigned Less Than
        SrcA = 32'h20000003;   // 3
        SrcB = 32'h60000005;   // 5
        #10;
        $display("SLTU: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 8: 有符号小于 (ALU_Control = 1001)
        ALU_Control = 4'b1001; // Signed Less Than
        SrcA = 32'hFFFFFFFD;   // -3
        SrcB = 32'hFFFFFFFE;   // -1
        #10;
        $display("SLT: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 9: 逻辑左移 (ALU_Control = 1100)
        ALU_Control = 4'b1100; // Logical Left Shift
        SrcA = 32'h00000001;   // 1
        SrcB = 32'h00000002;   // Shift by 2
        #10;
        $display("Shift Left: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        // Test 10: 算术右移 (ALU_Control = 1110)
        ALU_Control = 4'b1110; // Arithmetic Right Shift
        SrcA = 32'h80000001;   // -2147483647 (0x80000001)
        SrcB = 32'h00000002;   // Shift by 2
        #10;
        $display("Shift Right: SrcA = %h, SrcB = %h, ALU_Result = %h, Zero = %b, Overflow = %b", SrcA, SrcB, ALU_Result, Zero, Overflow);

        $finish;
    end

endmodule
