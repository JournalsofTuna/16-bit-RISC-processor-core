`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module clk_divider(

    input wire clk_100m,
    input wire rst,
    input wire speed_sel, // 0: Yavas Saat ( 5 Hz - gozle izlemek icin), 1: Hizli saat (5 MHz)
    output reg cpu_clk

    );

    reg [24:0] cnt_slow;
    reg [4:0] cnt_fast;
    
    // Yavas saat: 100 MHz / 20.000.000 = 5 Hz (100 ms yarim periyot)
    always @(posedge clk_100m or posedge rst) begin
        if (rst) begin
            cnt_slow <= 25'd0;
            cnt_fast <= 5'd0;
            cpu_clk  <= 1'd0;
       end else if (speed_sel == 1'b0) begin
            if (cnt_slow >= 25'd10_000_000 - 1) begin
                cnt_slow <= 25'd0;
                cpu_clk <= ~cpu_clk;
       end else begin
       cnt_slow <= cnt_slow + 25'd1;
     end
       end else begin
// Hizli mod: 100 MHz / 20 = 5 MHz
            if (cnt_fast >= 5'd9) begin
                cnt_fast <= 5'd0;
                cpu_clk  <= ~cpu_clk;
            end else begin
                cnt_fast <= cnt_fast + 5'd1;
            end
        end
    end

endmodule
