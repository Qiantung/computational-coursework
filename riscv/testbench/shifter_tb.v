`timescale 1ns / 1ps

module shifter_tb;

    // 输入信号
    reg [31:0] SrcA;            // 被移位的数
    reg [4:0] shift_count;      // 移位的位数
    reg [1:0] shift_mode;       // 移位模式（00=逻辑左移, 01=逻辑右移, 10=算数右移）

    // 输出信号
    wire [31:0] ALU_Result;     // 移位结果

    // 实例化 shifter 模块
    shifter uut (
        .SrcA(SrcA),
        .shift_count(shift_count),
        .shift_mode(shift_mode),
        .ALU_Result(ALU_Result)
    );

    // 测试过程
    initial begin
        // 初始化信号
        SrcA = 32'b00000000000000000000000000010101;  // 32位数（十进制：21）
        shift_count = 5'b00001;    // 移位1位
        shift_mode = 2'b00;        // 逻辑左移

        // 输出初始状态
        $display("Testing Logical Left Shift:");
        $monitor("SrcA = %b, shift_count = %d, shift_mode = %b, ALU_Result = %b", SrcA, shift_count, shift_mode, ALU_Result);
        
        #10;  // 等待10ns

        // 逻辑左移
        shift_mode = 2'b00;        // 逻辑左移
        shift_count = 5'b00001;    // 移位1位
        #10;  // 等待10ns

        // 逻辑右移
        shift_mode = 2'b01;        // 逻辑右移
        shift_count = 5'b00001;    // 移位1位
        #10;  // 等待10ns

        // 算术右移
        shift_mode = 2'b10;        // 算术右移
        shift_count = 5'b00001;    // 移位1位
        #10;  // 等待10ns

        // 算术右移测试（负数）
        SrcA = 32'b11111111111111111111111111110101;  // 32位负数（十进制：-11）
        shift_mode = 2'b10;        // 算术右移
        shift_count = 5'b00001;    // 移位1位
        #10;  // 等待10ns

        // 结束仿真
        $finish;
    end

endmodule
