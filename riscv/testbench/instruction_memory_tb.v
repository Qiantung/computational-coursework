`timescale 1ns / 1ps

module tb_instruction_memory;

    // 信号定义
    reg [7:0] addr;
    wire [31:0] instruction;
    
    // CPU模块的信号连接
    instruction_memory instruction_memory (
        .addr(addr),
        .instruction(instruction)
    );


    // 初始化测试环境
    initial begin
        // 初始化信号
        addr = 8'h00;
        // instruction = 32'h0000_0000;

        // 等待一段时间，确保CPU稳定
        #10;
        addr = 8'h01;
        #10;
        addr = 8'h02;
        #10;
        addr = 8'h03;
        #10;
        addr = 8'h04;
        
        // 模拟执行一段时间
        #200;
        
        // 结束仿真
        $finish;
    end
    


endmodule
