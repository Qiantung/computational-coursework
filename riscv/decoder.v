`include "headfile.vh"
module decoder (
    input [31:0] instruction,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [6:0] opcode,
    output [2:0] funct3,
    output funct7,
    output [31:0] imm
);

    assign funct7 = instruction[30];

    assign funct3 = instruction[14:12];

    assign rs1 = instruction[19:15];

    assign rs2 = instruction[24:20];

    assign rd = instruction[11:7];

    assign opcode = instruction[6:0];

    wire I_type;
    wire U_type;
    wire J_type;
    wire B_type;
    wire S_type;
    wire R_type;
    wire JALR_type;

    assign I_type = (opcode == `LOAD) | (opcode == `I_TYPE);
    assign U_type = (opcode == `LUI) | (opcode == `AUIPC);
    assign J_type = (opcode == `JAL);
    assign B_type = (opcode == `B_TYPE);
    assign S_type = (opcode == `S_TYPE);
    assign R_type = (opcode == `R_TYPE);
    assign JALR_type = (opcode == `JALR);

    wire [31:0] imm_u;
    wire [31:0] imm_i;
    wire [31:0] imm_j;
    wire [31:0] imm_b;
    wire [31:0] imm_s;
    wire [31:0] imm_jalr;

    assign imm_u = {instruction[31:12], {12{1'b0}}};
    assign imm_i = {{20{instruction[31]}}, instruction[31:20]};
    assign imm_j = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    assign imm_b = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    assign imm_jalr = imm_i;

    assign imm = I_type ? imm_i : 
                 U_type ? imm_u : 
                 J_type ? imm_j :
                 B_type ? imm_b :
                 S_type ? imm_s : 
                 JALR_type ? imm_jalr : 32'h0000_0000;
                 



endmodule
