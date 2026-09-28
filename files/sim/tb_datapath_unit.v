`timescale 1ns / 1ps

module tb_datapath_unit();
    reg clk;
    reg rst;
    reg reg_write;
    reg [2:0] raddr1,raddr2,waddr;
    reg [15:0] wdata;
    wire [15:0] rdata1,rdata2;
    
    reg [3:0] alu_ctrl;
    wire [15:0] alu_result;
    wire    zero,negative,carry;
    
        // Register File Instance
     register_file u_rf (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .wdata(wdata),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );
    


    // ALU Instance (RF Cikislari dogrudan ALU operandlarina bagli)
    alu u_alu(
    .a(rdata1),
    .b(rdata2),
    .alu_ctrl(alu_ctrl),
    .result(alu_result),
    .zero(zero),
    .negative(negative),
    .carry(carry)
    );  

    // 50 MHz Clock (20 ns periyot)
    always #10 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        reg_write = 0;
        raddr1 = 0;
        raddr2 = 0;
        waddr = 0;
        wdata = 0;
        alu_ctrl = 4'b0000;
        
        #25;
        rst = 0;
        
        // 1.R1'e 42 yaz
        @(posedge clk);
        reg_write = 1;
        waddr = 3'd1;
        wdata = 16'd42;
        
        // 2. R2'ye 5 yaz.
        @(posedge clk);
        waddr = 3'd2;
        wdata = 16'd5;
        
        // 3. R0'a 99  yazmayi dene(donanimsal sifir testi)
        @ (posedge clk);
        waddr = 3'd0;
        wdata = 16'd99;
        
        @(posedge clk);
        reg_write  = 0;
        
        // 4.R1 ve R2'yi ALU'da topla (ADD: 4'b0000)
          raddr1 = 3'd1;
          raddr2 = 3'd2;
          alu_ctrl = 4'b0000;
          #5;
         $display("--- TEST 1. TOPLAMA ---");
         $display("R1 (%0d) + R2(%0d) =  %0d | Zero = %b", rdata1,rdata2,alu_result,zero);
         
         // SONUCU R3'e yaz.
         @(posedge clk);
         reg_write = 1;
         waddr = 3'd3;
         wdata = alu_result;
         
         // 5. R1 ve R2'yi ALU'da cikar (SUB: 4'b0001)
         @(posedge clk);
         reg_write = 0;
         alu_ctrl = 4'b0001;
         #5;
         $display("--- TEST 2: CIKARMA ---");
         $display("R1 (%0d) - R2(%0d) = %0d", rdata1,rdata2,alu_result);
         
         // 6. R0 Kontrolu (0 kalmali.)
         raddr1 = 3'd0;
         #5;
         $display("--- TEST 3: R0 DEGERI---");
         $display("R0: %0d (Beklenen: 0)",rdata1);
         
         #40;
         $finish;
end
endmodule
        