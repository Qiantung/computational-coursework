module register_file (
    input clk,
    input rst_n,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] w_data,
    input w_en,
    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [3:0]  data1   ,
    output [3:0]  data2   ,
    output [3:0]  data3   
);


    reg [31:0] registers[31:0]; // 瀹氫箟32涓?32浣嶅瘎瀛樺櫒
    
    
 assign  data1  = registers[1][3:0];
assign  data2  = registers[2][3:0];
assign  data3  = registers[3][3:0];

    always @(posedge clk) begin
        if(!rst_n) begin
            registers[0]  <= 32'h0000_0000;
            registers[1]  <= 32'h0000_0000;
            registers[2]  <= 32'h0000_0000;
            registers[3]  <= 32'h0000_0000;
            registers[4]  <= 32'h0000_0000;
            registers[5]  <= 32'h0000_0000;
            registers[6]  <= 32'h0000_0000;
            registers[7]  <= 32'h0000_0000;
            registers[8]  <= 32'h0000_0000;
            registers[9]  <= 32'h0000_0000;
            registers[10] <= 32'h0000_0000;
            registers[11] <= 32'h0000_0000;
            registers[12] <= 32'h0000_0000;
            registers[13] <= 32'h0000_0000;
            registers[14] <= 32'h0000_0000;
            registers[15] <= 32'h0000_0000;
            registers[16] <= 32'h0000_0000;
            registers[17] <= 32'h0000_0000;
            registers[18] <= 32'h0000_0000;
            registers[19] <= 32'h0000_0000;
            registers[20] <= 32'h0000_0000;
            registers[21] <= 32'h0000_0000;
            registers[22] <= 32'h0000_0000;
            registers[23] <= 32'h0000_0000;
            registers[24] <= 32'h0000_0000;
            registers[25] <= 32'h0000_0000;
            registers[26] <= 32'h0000_0000;
            registers[27] <= 32'h0000_0000;
            registers[28] <= 32'h0000_0000;
            registers[29] <= 32'h0000_0000;
            registers[30] <= 32'h0000_0000;
            registers[31] <= 32'h0000_0000;
        end
        else if(w_en & (rd != 5'd0)) begin // 闆跺瘎瀛樺櫒鍙涓嶅啓姘镐负0
            registers[rd] <= w_data;
        end
    end
    
    assign rs1_data = (rs1 == 5'd0) ? 32'h0000_0000 : registers[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'h0000_0000 : registers[rs2];

    // 杩欓噷寰堢枒鎯戜负浠?涔堜娇鐢ㄥ紓姝ユ洿鏂帮紵

endmodule