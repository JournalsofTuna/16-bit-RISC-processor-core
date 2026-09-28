`timescale 1ns / 1ps

module register_file(
    input wire clk,
    input wire rst,
    input wire reg_write,
    input wire [2:0] raddr1,
    input wire [2:0] raddr2,
    input wire [2:0] waddr,
    input wire [15:0] wdata,
    output wire [15:0] rdata1,
    output wire [15:0] rdata2

    );
    reg[15:0] registers [7:0];
    integer i;
    
    // Senkron Yazma (Clock'un yukselen kenarinda)
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for (i = 0; i < 8; i = i+1) begin
                registers[i] <=16'h0000;
             end
          end else if (reg_write && (waddr != 3'b000)) begin
          // R0 donanimsal olarak her zaman sifir kalir (MIPS/RISC-V Standardi)
            registers[waddr] <= wdata;
          end
       end
       
       // Asenkron Okuma (Combinational)
       assign rdata1 = (raddr1 == 3'b000) ? 16'h0000 : registers[raddr1];
       assign rdata2 = (raddr2 == 3'b000) ? 16'h0000 : registers[raddr2];
endmodule
