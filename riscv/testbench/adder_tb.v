module adder_tb;

    // 声明输入信号
    reg [31:0] SrcA;
    reg [31:0] SrcB;
    reg [3:0] ALU_Control;
    reg cin;

    // 声明输出信号
    wire add_overflow;
    wire add_carry;
    wire add_zero;
    wire [31:0] ALU_Result;

    // 实例化 adder 模块
    adder uut (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALU_Control(ALU_Control),
        .cin(cin),
        .add_overflow(add_overflow),
        .add_carry(add_carry),
        .add_zero(add_zero),
        .ALU_Result(ALU_Result)
    );

    // 初始化输入信号
    initial begin
        // 初始化信号
        SrcA = 32'b0;
        SrcB = 32'b0;
        ALU_Control = 4'b0000;  // 默认加法操作
        cin = 1'b0;

        // 打印信号值
        $monitor("At time %t, SrcA = %h, SrcB = %h, ALU_Control = %b, cin = %b, ALU_Result = %h, add_overflow = %b, add_carry = %b, add_zero = %b", 
                 $time, SrcA, SrcB, ALU_Control, cin, ALU_Result, add_overflow, add_carry, add_zero);
        
        // 测试 1: 加法操作，SrcA = 5, SrcB = 3, ALU_Control = 4'b0000, cin = 0
        #10 SrcA = 32'd5; SrcB = 32'd3; ALU_Control = 4'b0000; cin = 1'b0;
        
        // 测试 2: 加法溢出，SrcA = 31, SrcB = 31, ALU_Control = 4'b0000, cin = 0
        #10 SrcA = 32'd31; SrcB = 32'd31; ALU_Control = 4'b0000; cin = 1'b0;
        
        // 测试 3: 带进位的加法，SrcA = -5, SrcB = 5, ALU_Control = 4'b0000, cin = 1
        #10 SrcA = 32'hFFFF_FFFB; SrcB = 32'd5; ALU_Control = 4'b0000; cin = 1'b1;
        
        // 测试 4: 加法溢出，SrcA = 32'h80000000, SrcB = 32'h80000000, ALU_Control = 4'b0000, cin = 0
        #10 SrcA = 32'h80000000; SrcB = 32'h80000000; ALU_Control = 4'b0000; cin = 1'b0;
        
        // 测试 5: 零加法，SrcA = 0, SrcB = 0, ALU_Control = 4'b0000, cin = 0
        #10 SrcA = 32'd0; SrcB = 32'd0; ALU_Control = 4'b0000; cin = 1'b0;

        // 测试 6: 减法操作，SrcA = 10, SrcB = -5, ALU_Control = 4'b0011, cin = 0
        // 注意：SrcB 需要转换为补码形式 (-5) 来进行减法
        #10 SrcA = 32'd10; SrcB = 32'hFFFF_FFFB; ALU_Control = 4'b0011; cin = 1'b0;
        
        // 测试 7: 减法操作，SrcA = 5, SrcB = -10, ALU_Control = 4'b0011, cin = 0
        #10 SrcA = 32'd5; SrcB = 32'hFFFF_FFF6; ALU_Control = 4'b0011; cin = 1'b0;

        // 测试 8: 减法溢出，SrcA = 32'h20000000, SrcB = -32'h50000000, ALU_Control = 4'b0011, cin = 0
        #10 SrcA = 32'h20000000; SrcB = 32'hB0000000; ALU_Control = 4'b0011; cin = 1'b0;

        // 结束仿真
        #10 $finish;
    end

endmodule
