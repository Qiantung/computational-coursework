`include "headfile.vh"
module Controler (
    input funct7,
    input [2:0] funct3,
    input [6:0] opcode,

    output reg MEM_W_en,
    output reg [2:0] MEM_RW_type,
    output reg MEM_to_REG,
    output reg REGFILE_W_en,
    output reg Branch,
    output reg BEQ,
    output reg BNE,
    output reg BLT,
    output reg BGE,
    output reg JAL,
    output reg JALR,
    output reg LUI,
    output reg AUIPC,
    output reg ALU_SrcB,
    output reg [3:0] ALU_Control
);

    always @(*) begin
        case(opcode)
        `R_TYPE: begin
            // R-type 通用设置
            MEM_W_en = 1'b0;
            MEM_RW_type = 3'b000;
            MEM_to_REG = 1'b0;
            REGFILE_W_en = 1'b1;
            Branch = 1'b0;
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b0;
            JALR = 1'b0;
            LUI = 1'b0;
            AUIPC = 1'b0;
            ALU_SrcB = 1'b0;

            case(funct3)
            3'b000: ALU_Control = funct7 ? 4'b0011 : 4'b0000; // funct7 = 1:SUB指令, 0:ADD指令
            3'b001: ALU_Control = 4'b1100; // SLL指令  逻辑左移
            3'b010: ALU_Control = 4'b1001; // SLT指令  小于置位（有符号）
            3'b011: ALU_Control = 4'b1000; // SLTU指令 小于置位（无符号）
            3'b100: ALU_Control = 4'b0110; // XOR指令  异或
            3'b101: ALU_Control = funct7 ? 4'b1110 : 4'b1101; // SRL指令 1:算数右移 0:逻辑右移
            3'b110: ALU_Control = 4'b0101; // OR指令   或
            3'b111: ALU_Control = 4'b0100; // AND指令  与
            endcase
        end
        `I_TYPE: begin
            // I-type 通用设置
            MEM_W_en = 1'b0;
            MEM_RW_type = 3'b000;
            MEM_to_REG = 1'b0;
            REGFILE_W_en = 1'b1;
            Branch = 1'b0;
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b0;
            JALR = 1'b0;
            LUI = 1'b0;
            AUIPC = 1'b0;
            ALU_SrcB = 1'b1;

            case(funct3)
            3'b000: ALU_Control = 4'b0000; // ADDI指令
            3'b010: ALU_Control = 4'b1001; // SLTI指令  小于置位（有符号）
            3'b011: ALU_Control = 4'b1000; // SLTIU指令 小于置位（无符号）
            3'b100: ALU_Control = 4'b0110; // XORI指令  异或
            3'b110: ALU_Control = 4'b0101; // ORI指令   或
            3'b111: ALU_Control = 4'b0100; // ANDI指令  与
            3'b001: ALU_Control = 4'b1100; // SLLI指令  逻辑左移
            3'b101: ALU_Control = funct7 ? 4'b1110 : 4'b1101; // SRLI指令 1:算数右移 0:逻辑右移
            endcase
        end
        `LOAD: begin
            // Load 通用设置
            MEM_W_en = 1'b0;
            MEM_to_REG = 1'b1; // 读取mem写回reg
            MEM_RW_type = funct3;
            REGFILE_W_en = 1'b1; // reg写使能
            Branch = 1'b0;
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b0;
            JALR = 1'b0;
            LUI = 1'b0;
            AUIPC = 1'b0;
            ALU_SrcB = 1'b1; // 接收立即数
            ALU_Control = 4'b0000; // 执行加法操作
        end
        `S_TYPE: begin
            // S_TYPE 通用设置
            MEM_W_en = 1'b1;  // mem写入使能
            MEM_to_REG = 1'b1; // 读取mem写回
            MEM_RW_type = funct3;
            REGFILE_W_en = 1'b0; // 关闭reg写使能
            Branch = 1'b0;
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b0;
            JALR = 1'b0;
            LUI = 1'b0;
            AUIPC = 1'b0;
            ALU_SrcB = 1'b1; // 接收立即数
            ALU_Control = 4'b0000; // 执行加法操作
        end
        `B_TYPE: begin
            // B_TYPE 通用设置
            MEM_W_en = 1'b0;  // 关闭mem写入使能
            MEM_to_REG = 1'b0; // 读取ALU写回
            MEM_RW_type = 3'b000;
            REGFILE_W_en = 1'b0; // 关闭reg写使能
            Branch = 1'b1; // 开启分支总控
            JAL = 1'b0;
            JALR = 1'b0;
            LUI = 1'b0;
            AUIPC = 1'b0;
            ALU_SrcB = 1'b0; // 接收寄存器

            case(funct3)
            3'b000: begin // BEQ指令
                BEQ = 1'b1;
                BNE = 1'b0;
                BLT = 1'b0;
                BGE = 1'b0;
                ALU_Control = 4'b0011; // 执行减法操作
            end
            3'b001: begin // BNE指令
                BEQ = 1'b0;
                BNE = 1'b1;
                BLT = 1'b0;
                BGE = 1'b0;
                ALU_Control = 4'b0011; // 执行减法操作
            end
            3'b100: begin // BLT指令（有符号）
                BEQ = 1'b0;
                BNE = 1'b0;
                BLT = 1'b1;
                BGE = 1'b0;
                ALU_Control = 4'b1001; // 执行SLT小于置位操作
            end
            3'b101: begin // BGE指令（有符号）
                BEQ = 1'b0;
                BNE = 1'b0;
                BLT = 1'b0;
                BGE = 1'b1;
                ALU_Control = 4'b1001; // 执行SLT小于置位操作
            end
            3'b110: begin // BLTU指令（无符号）
                BEQ = 1'b0;
                BNE = 1'b0;
                BLT = 1'b1;
                BGE = 1'b0;
                ALU_Control = 4'b1000; // 执行SLTU小于置位操作（无符号）
            end
            3'b111: begin // BGEU指令（无符号）
                BEQ = 1'b0;
                BNE = 1'b0;
                BLT = 1'b0;
                BGE = 1'b1;
                ALU_Control = 4'b1000; // 执行SLTU小于置位操作（无符号）
            end
            endcase
        end
        `JAL: begin
            // JAL 设置
            MEM_W_en = 1'b0;  // 关闭mem写入使能
            MEM_to_REG = 1'b0; // 读取ALU写回
            MEM_RW_type = 3'b000;
            REGFILE_W_en = 1'b1; // reg写使能
            Branch = 1'b0; // 关闭分支
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b1; // 开启JAL
            JALR = 1'b0;
            LUI = 1'b0;
            AUIPC = 1'b0;
            ALU_SrcB = 1'b1; // 接收立即数
            ALU_Control = 4'b0000; // 执行加法操作
        end
        `JALR: begin
            // JALR 设置
            MEM_W_en = 1'b0;  // 关闭mem写入使能
            MEM_to_REG = 1'b0; // 读取ALU写回
            MEM_RW_type = 3'b000;
            REGFILE_W_en = 1'b1; // reg写使能
            Branch = 1'b0; // 关闭分支
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b0; 
            JALR = 1'b1; // 开启JALR
            LUI = 1'b0;
            AUIPC = 1'b0;
            ALU_SrcB = 1'b1; // 接收立即数
            ALU_Control = 4'b0000; // 执行加法操作
        end
        `LUI: begin
            // LUI 设置
            MEM_W_en = 1'b0;  // 关闭mem写入使能
            MEM_to_REG = 1'b0; // 读取ALU写回
            MEM_RW_type = 3'b000;
            REGFILE_W_en = 1'b1; // reg写使能
            Branch = 1'b0; // 关闭分支
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b0; 
            JALR = 1'b0;
            LUI = 1'b1; // 将立即数写入寄存器文件
            AUIPC = 1'b0;
            ALU_SrcB = 1'b1; // 接收立即数
            ALU_Control = 4'b0000; // 执行加法操作
        end
        `AUIPC: begin
            // AUIPC 设置
            MEM_W_en = 1'b0;  // 关闭mem写入使能
            MEM_to_REG = 1'b0; // 读取ALU写回
            MEM_RW_type = 3'b000;
            REGFILE_W_en = 1'b1; // reg写使能
            Branch = 1'b0; // 关闭分支
            BEQ = 1'b0;
            BNE = 1'b0;
            BLT = 1'b0;
            BGE = 1'b0;
            JAL = 1'b0; 
            JALR = 1'b0;
            LUI = 1'b0;  // 将ALU写回的数据写入寄存器文件
            AUIPC = 1'b1; // 将PC输入ALU
            ALU_SrcB = 1'b1; // 接收立即数
            ALU_Control = 4'b0000; // 执行加法操作
        end
        endcase
    end


endmodule