module ALU (
    input [3:0] ALU_Control,
    input [31:0] SrcA,
    input [31:0] SrcB,
    output Zero,
    output Overflow,
    output [31:0] ALU_Result
);

    //*********************logic op***************************
    reg [31:0] logic_result;

    always@(*) begin
        case(ALU_Control)
        4'b0100:logic_result = SrcA & SrcB;
        4'b0101:logic_result = SrcA | SrcB;
        4'b0110:logic_result = SrcA ^ SrcB;
        4'b0111:logic_result = ~(SrcA | SrcB);
        endcase
    end 

    //************************shift op************************
    wire [31:0] shift_result;
    wire [1:0] shift_ctrl;

    assign shift_ctrl = (ALU_Control[3:2] == 2'b11) ? ALU_Control[1:0] : 2'b11;

    shifter shifter(.SrcA(SrcA),
                    .shift_count(SrcB[4:0]),
                    .shift_mode(shift_ctrl),
                    .ALU_Result(shift_result));

    
    //************************add sub op**********************
    wire [31:0] BIT_M;
    wire [31:0] XOR_M; // 加法操作时是原码，减法操作时是反码
    wire ADD_carry, ADD_OverFlow;
    wire [31:0] add_result;
    wire sub_ctrl;
    wire sub_cin; // 执行减法操作时加一将反码变为补码

    // assign sub_ctrl = (ALU_Control[3:0] == 4'b0011) ? 1'b1 :
    //                   (ALU_Control[3:1] == 3'b100)  ? 1'b1 : 1'b0;

    assign sub_ctrl = (ALU_Control[3:0] == 4'b0011) || (ALU_Control[3:0] == 4'b1000) || (ALU_Control[3:0] == 4'b1001);
    assign sub_cin = sub_ctrl ? 1'b1 : 1'b0;

    assign BIT_M = {32{sub_ctrl}};
    assign XOR_M = BIT_M ^ SrcB;

    adder adder(.SrcA(SrcA),
                .SrcB(XOR_M),
                .cin(sub_cin),
                .ALU_Control(ALU_Control),
                .add_carry(ADD_carry),
                .add_overflow(ADD_OverFlow),
                .ALU_Result(add_result));

    assign Overflow = ADD_OverFlow & (ALU_Control[3:2] == 2'b00);


    //**************************slt op************************
    wire [31:0] slt_result;
    wire LESS_M1; // 无符号小于
    wire LESS_M2; // 有符号小于
    wire LESS_S;
    wire SLT_M;

    assign LESS_M1 = ADD_carry ^ sub_cin;
    assign LESS_M2 = ADD_OverFlow ^ add_result[31];
    assign LESS_S = (ALU_Control[0] == 1'b0) ? LESS_M1 : LESS_M2;
    assign slt_result = LESS_S ? 32'h0000_0001 : 32'h0000_0000;


    //**************************ALU result********************
    assign ALU_Result = (ALU_Control[3:2] == 2'b00) ? add_result :
                        (ALU_Control[3:2] == 2'b01) ? logic_result :
                        (ALU_Control[3:2] == 2'b10) ? slt_result : shift_result;
    
    assign Zero = ~(|ALU_Result);


endmodule

/*  ALU_Control表
*
*   0000 - 加法
*   0011 - 减法
*   0100 - 逻辑与
*   0101 - 逻辑或
*   0110 - 逻辑异或
*   0111 - 逻辑或非
*   1000 - 无符号小于置1
*   1001 - 有符号小于置1
*   1100 - 逻辑左移
*   1101 - 逻辑右移
*   1110 - 算数右移
*
*/