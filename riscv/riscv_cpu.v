module single_cpu
 (
    input              clk  ,
    input              rst_n,
    output wire  [7:0] seg,
    output wire  [3:0] sel,
    output wire [3:0] led
     
     
     
); 

    //****************** controller **********************
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire funct7;
    wire MEM_W_en;
    wire [2:0] MEM_RW_type;
    wire MEM_to_REG;
    wire REGFILE_W_en;
    wire Branch;
    wire BEQ;
    wire BNE;
    wire BLT;
    wire BGE;
    wire JAL;
    wire JALR;
    wire LUI;
    wire AUIPC;
    wire ALU_SrcB;
    wire [3:0] ALU_Control;
    wire [3:0] data1;
    wire [3:0] data2;
    wire [3:0] data3;
    
    
    
    Controler Controler (.funct7(funct7),
                         .funct3(funct3),
                         .opcode(opcode),
                         .MEM_W_en(MEM_W_en),
                         .MEM_RW_type(MEM_RW_type),
                         .MEM_to_REG(MEM_to_REG),
                         .REGFILE_W_en(REGFILE_W_en),
                         .Branch(Branch),
                         .BEQ(BEQ),
                         .BNE(BNE),
                         .BLT(BLT),
                         .BGE(BGE),
                         .JAL(JAL),
                         .JALR(JALR),
                         .LUI(LUI),
                         .AUIPC(AUIPC),
                         .ALU_SrcB(ALU_SrcB),
                         .ALU_Control(ALU_Control));

assign led = data1;
    //********************* pc ***************************
    wire [31:0] pc_in;
    wire [31:0] pc_out;
    wire [31:0] pc_no_branch;
    wire [31:0] pc_branch;
    wire [31:0] pc_plus4;
    wire Branch_chose;
    wire [31:0] reg_write_back_data;
    wire [31:0] imm;

    assign pc_in = Branch_chose ? pc_branch : pc_no_branch;
    assign pc_plus4 = pc_out + 4;
    assign pc_no_branch = ({JAL,JALR} == 2'b00) ? pc_plus4 : 
                          ({JAL,JALR} == 2'b01) ? {reg_write_back_data[31:1], 1'b0} :
                          ({JAL,JALR} == 2'b10) ?{reg_write_back_data[31:1], 1'b0} : 32'h0000_0000;
    assign pc_branch = imm + pc_out;

    PC PC ( .clk(clk),
            .rst_n(rst_n),
            .pc_new(pc_in),
            .pc_out(pc_out) );

    //************** instruction_memory ******************
    wire [31:0] instruction;
    instruction_memory insmem ( .addr(pc_out[9:2]),
                                .instruction(instruction));
    
    //******************* decoder ************************
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    decoder decoder (.instruction(instruction),
                     .rs1(rs1),
                     .rs2(rs2),
                     .rd(rd),
                     .opcode(opcode),
                     .funct3(funct3),
                     .funct7(funct7),
                     .imm(imm));

    //**************** register file *********************
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] w_data;
    wire [1:0] wdata_multi_temp_ctrl;

    assign wdata_multi_temp_ctrl = {(JAL | JALR), LUI};
    assign w_data = (wdata_multi_temp_ctrl == 2'b00) ? reg_write_back_data : 
                    (wdata_multi_temp_ctrl == 2'b01) ? imm : 
                    (wdata_multi_temp_ctrl == 2'b10) ? pc_plus4 : 32'h0000_0000;
                    
                 
                 
   
    register_file register_file (.clk  (clk  ),
                                 .rst_n(rst_n),
                                 .rs1(rs1),
                                 .rs2(rs2),
                                 .rd(rd),
                                 .w_data(w_data),
                                 .w_en(REGFILE_W_en),
                                 .rs1_data(rs1_data),
                                 .rs2_data(rs2_data),
                                 .data1(data1),
                                 .data2(data2),
                                 .data3(data3)
                                 
                                 );
                                 
                                 
    display inst( 
    .clk  (clk  ),    
    .rst_n(rst_n),   
    .data5(data1),  
    .data6(data2),
    .data7(data3),
    .seg  (seg),  
    .sel  (sel) 
  //  output
);                             
                                 
                                 

    //********************* ALU **************************
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] ALU_Result;
    wire Zero;
    
    assign Branch_chose = ((BEQ & Zero) | (BNE & ~Zero) | (BLT & ALU_Result[0]) | (BGE & ~ALU_Result[0])) & Branch;
    assign SrcA = (AUIPC || JAL)? pc_out : rs1_data;
    assign SrcB = ALU_SrcB ? imm : rs2_data;

    ALU ALU (.ALU_Control(ALU_Control),
             .SrcA(SrcA),
             .SrcB(SrcB),
             .Zero(Zero),
             .Overflow(),
             .ALU_Result(ALU_Result));
    
    //****************** Data Memory *********************
    wire [31:0] mem_data_out;

    assign reg_write_back_data = MEM_to_REG ? mem_data_out : ALU_Result;

    data_memory data_memory (.clk(clk),
                             .rst_n(rst_n),
                             .addr(ALU_Result),
                             .w_en(MEM_W_en),
                             .rw_type(MEM_RW_type),
                             .d_in(rs2_data),
                             .d_out(mem_data_out));


endmodule
