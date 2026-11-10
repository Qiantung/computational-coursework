`timescale 1ns / 1ps

module tb_riscv_cpu;

    // 信号定义
    reg clk;
    reg rst_n;
    reg [31:0] count;
    

    single_cpu cpu (
        .clk(clk),
        .rst_n(rst_n)
    );

    // 时钟信号生成
    always begin
        #5 clk = ~clk;  // 10ns 时钟周期
    end

    always begin
        #10 count = count + 1;
    end

    initial begin
        // 初始化信号
        clk = 1;
        rst_n = 0;
        count = 0;
        
        // 复位信号的变化
        #10 rst_n = 1;

        // 等待一段时间，确保CPU稳定
        #10;
        
        // 模拟执行一段时间
        #2000;
        
        // 结束仿真
        $finish;
    end
    


endmodule
