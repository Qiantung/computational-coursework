module PC (
    input clk,
    input rst_n,
    input [31:0] pc_new,
    output reg [31:0] pc_out
);

    always@(posedge clk) begin
		if(!rst_n)
			pc_out <= 32'h0000_0000;
		else
			pc_out <= pc_new;
	end	

endmodule