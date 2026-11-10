module adder (
    input [31:0] SrcA,
    input [31:0] SrcB, 
    input [3:0] ALU_Control,
    input cin,
    output add_overflow,
    output add_carry,
    output [31:0] ALU_Result
);

    assign {add_carry, ALU_Result} = SrcA + SrcB + cin;

    assign add_overflow = ((ALU_Control == 4'b0000) & ~SrcA[31] & ~SrcB[31] &  ALU_Result[31]) |
                          ((ALU_Control == 4'b0000) &  SrcA[31] &  SrcB[31] & ~ALU_Result[31]) |
                          ((ALU_Control == 4'b0011) &  SrcA[31] & ~SrcB[31] & ~ALU_Result[31]) |
					      ((ALU_Control == 4'b0011) & ~SrcA[31] &  SrcB[31] &  ALU_Result[31]);


endmodule