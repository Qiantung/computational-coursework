module data_memory (
    input clk,
    input rst_n,
    input [31:0] addr,
    input w_en,
    input [2:0] rw_type,
    input [31:0] d_in,
    output [31:0] d_out
);

    reg [31:0] ram[0:32];

    // initial begin
    //     ram[0] <= 32'd23;
    //     ram[1] <= 32'd34;
    //     ram[2] <= 32'd56;
    //     ram[3] <= 32'd76;
    //     ram[4] <= 32'd12;
    // end

    wire [31:0] w_data; // 鍐欏叆鍚庣殑鏁版嵁
    wire [31:0] w_data_B; // 瀛楄妭鍐欏叆鍚庣殑鏁版嵁
    wire [31:0] w_data_H; // 鍗婂瓧鍐欏叆鍚庣殑鏁版嵁

    wire [31:0] r_data; // 璇诲嚭鐨勬暟鎹?
    wire [7:0]  r_data_B;
    wire [15:0] r_data_H;
    wire [31:0] r_data_B_ex; // 鎵╁睍锛堥浂鎵╁睍鎴栫鍙锋墿灞曪級
    wire [31:0] r_data_H_ex; // 鎵╁睍锛堥浂鎵╁睍鎴栫鍙锋墿灞曪級
    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            // 澶嶄綅鏃舵竻绌簉am
            ram[0] <= 32'd23;
            ram[1] <= 32'd17;
            ram[2] <= 32'd42;
            ram[3] <= 32'd8;
            ram[4] <= 32'd35;
        end
        else if(w_en) begin
            ram[addr[9:2]] <= w_data; // 鐢变簬鍦板潃鏄瓧鑺傚榻愮殑锛屾墍浠ヤ綆2浣嶈灞忚斀
        end
    end

    assign w_data_B = (addr[1:0] == 2'b00) ? {r_data[31:8], d_in[7:0]} :
                      (addr[1:0] == 2'b01) ? {r_data[31:16], d_in[7:0], r_data[7:0]} :
                      (addr[1:0] == 2'b10) ? {r_data[31:24], d_in[7:0], r_data[15:0]} : {d_in[7:0], r_data[23:0]};

    assign w_data_H = (addr[1] == 1'b0) ? {r_data[31:16], d_in[15:0]} : {d_in[15:0], r_data[15:0]};

    assign w_data = (rw_type[1:0] == 2'b00) ? w_data_B :
                    (rw_type[1:0] == 2'b01) ? w_data_H : d_in;

    assign r_data = ram[addr[9:2]]; // 璇诲嚭鏁版嵁

    assign r_data_B = (addr[1:0] == 2'b00) ? {r_data[7:0]} :
                      (addr[1:0] == 2'b01) ? {r_data[15:8]} :
                      (addr[1:0] == 2'b10) ? {r_data[23:16]} : {r_data[31:24]};
    
    assign r_data_H = (addr[1] == 1'b0) ? {r_data[15:0]} : {r_data[31:16]};

    // 鑻unct3鐨勯珮浣嶄负0锛屽垯浣跨敤闆舵墿灞曪紝楂樹綅涓?1浣跨敤绗﹀彿鎵╁睍
    assign r_data_B_ex = (rw_type[2] == 1'b0) ? {{24{r_data_B[7]}}, r_data_B[7:0]} : {{24{1'b0}}, r_data_B[7:0]};
    assign r_data_H_ex = (rw_type[2] == 1'b0) ? {{16{r_data_H[15]}}, r_data_H[15:0]} : {{16{1'b0}}, r_data_H[15:0]};

    assign d_out = (rw_type[1:0] == 2'b00) ? r_data_B_ex :
                   (rw_type[1:0] == 2'b01) ? r_data_H_ex : r_data;

endmodule