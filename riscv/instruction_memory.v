module instruction_memory (
    input [7:0] addr,
    output [31:0] instruction 
);

    reg [31:0] rom[255:0];

    initial begin
rom[0] =32'h00000293;
rom[1] =32'h00500313;
rom[2] =32'hfff30393;
rom[3] =32'h02038863;
rom[4] =32'h00000e13;
rom[5] =32'h00038e93;
rom[6] =32'hfe0e88e3;
rom[7] =32'h000e2f03;
rom[8] =32'h004e2f83;
rom[9] =32'h01ff4663;
rom[10]=32'h01fe2023;
rom[11]=32'h01ee2223;
rom[12]=32'h004e0e13;
rom[13]=32'hfff38393;
rom[14]=32'hfddff06f;
rom[15]=32'h0000006f;
    end
    
    
    

    assign instruction = rom[addr]; // 鏈?澶氬彲淇濆瓨256涓寚浠?

endmodule