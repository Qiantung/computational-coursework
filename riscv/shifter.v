module shifter (
    input [31:0] SrcA, // 被移数为RS1
    input [4:0] shift_count, // 移数为RS2，且只取低五位
    input [1:0] shift_mode, // 位移模式：逻辑左移、逻辑右移、算数右移
    output reg [31:0] ALU_Result
);

    wire [5:0] complement;

    assign complement = 6'd32 - shift_count;

    always @(*) begin
        case(shift_mode)
        2'b00: ALU_Result = SrcA << shift_count; // 逻辑左移
        2'b01: ALU_Result = SrcA >> shift_count; // 逻辑右移
        2'b10: ALU_Result = {{32{SrcA[31]}} << complement} | {SrcA >> shift_count}; // 算数右移
        default: ALU_Result = SrcA;
        endcase
    end

endmodule