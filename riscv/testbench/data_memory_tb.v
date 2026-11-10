`timescale 1ns / 1ps

module data_memory_tb;

    // 输入信号声明
    reg clk;
    reg rst_n;
    reg w_en;
    reg [2:0] rw_type;
    reg [31:0] addr;
    reg [31:0] d_in;

    // 输出信号声明
    wire [31:0] d_out;

    // 实例化待测试模块
    data_memory uut (
        .clk(clk),
        .rst_n(rst_n),
        .w_en(w_en),
        .rw_type(rw_type),
        .addr(addr),
        .d_in(d_in),
        .d_out(d_out)
    );

    // 时钟产生
    always begin
        #5 clk = ~clk;  // 每5ns翻转一次，频率为100MHz
    end

    // 初始化信号
    initial begin
        // 初始化信号
        clk = 1;
        rst_n = 0;
        w_en = 0;
        rw_type = 3'b000; // 默认读取全字
        addr = 0;
        d_in = 32'h0;

        // 复位
        #10 rst_n = 1;

        // 测试开始
        #10;
        $display("### Start Write Operations ###");
        
        // 写入操作（字节写入）
        w_en = 1;
        addr = 32'h0000_0000;   // 地址0
        rw_type = 3'b000;       // 字节写入
        d_in = 32'hCD;          // 写入字节A5到内存
        #10;
        
        addr = 32'h0000_0001;   // 地址1
        d_in = 32'hAB;          // 写入字节5A到内存
        #10;

        // 写入操作（半字写入）
        addr = 32'h0000_0002;   // 地址0
        rw_type = 3'b001;       // 半字写入
        d_in = 32'h2222;        // 写入半字FFFF到内存
        #10;

        // 写入操作（全字写入）
        addr = 32'h0000_0004;   // 地址4
        rw_type = 3'b010;       // 全字写入
        d_in = 32'h1234_5678;    // 写入全字DEADBEEF到内存
        #10;
        
        // 读取操作
        w_en = 0;
        
        // 读取操作（字节读取）
        addr = 32'h0000_0000;   // 地址0
        rw_type = 3'b100;       // 字节读取
        #10;
        $display("Read Byte from 0x00000000: %h", d_out);
        
        addr = 32'h0000_0001;   // 地址1
        #10;
        $display("Read Byte from 0x00000001: %h", d_out);

        // 读取操作（半字读取）
        addr = 32'h0000_0002;   // 地址0
        rw_type = 3'b101;       // 半字读取
        #10;
        $display("Read Half Word from 0x00000000: %h", d_out);
        
        // 读取操作（全字读取）
        addr = 32'h0000_0004;   // 地址4
        rw_type = 3'b010;       // 全字读取
        #10;
        $display("Read Word from 0x00000004: %h", d_out);

        // 结束测试
        $stop;
    end

    // 显示信号变化（可选）
    initial begin
        $monitor("Time: %t | addr: %h | d_in: %h | d_out: %h | rw_type: %b | w_en: %b", 
                  $time, addr, d_in, d_out, rw_type, w_en);
    end

endmodule
