`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module data_mem(
    
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [15:0] addr,
    input wire [15:0] wdata,
    input wire [15:0] rdata
    
    );
    
    reg [15:0] ram [0:255];
    integer i;
    
    initial begin 
        for (i = 0; i < 256 ; i = i + 1) begin
            ram[i] = 16'h0000; 
          end
       end
       
       
       // Senkron Yazma (SW)
       always @(posedge clk) begin
            if(mem_write) begin
                ram[addr[7:0]] <=wdata;
            end
         end
      // Aseenkron Okuma (LW)
      assign rdata = (mem_read) ? ram[addr[7:0]] : 16'h0000;
      
    
endmodule
