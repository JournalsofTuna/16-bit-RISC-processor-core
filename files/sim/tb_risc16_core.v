`timescale 1ns / 1ps

module tb_risc16_core ();

    reg         clk;
    reg         rst;
    wire [15:0] debug_pc;
    wire [15:0] debug_instr;
    wire [15:0] debug_alu_result;

    risc16_core u_core (
        .clk(clk),
        .rst(rst),
        .debug_pc(debug_pc),
        .debug_instr(debug_instr),
        .debug_alu_result(debug_alu_result)
    );

    // 50 MHz Saat
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #45;
        @(posedge clk);
        #1;
        rst = 0;

        $display("===== RISC-16 CEKIRDEK SIMULASYONU BASLADI =====");

        repeat (15) begin
            @(posedge clk);
            #1;
            $display("[T=%0t ns] PC = %0d | Instr = 0x%04h | ALU_Out = %0d", 
                     $time, debug_pc, debug_instr, debug_alu_result);
        end

        #20;
        // R6 kontrolu: BEQ basariyla 7. satiri atlayip 8. satira gectiyse R6 = 25 olmalidir
        if (u_core.u_rf.registers[6] === 16'd25) begin
            $display(">>> TEST BASARILI: BEQ ve JUMP beklendigi gibi calisti! R6 = 25 <<<");
        end else begin
            $display(">>> TEST BASARISIZ: R6 degeri %0d (Beklenen: 25) <<<", u_core.u_rf.registers[6]);
        end

        // Data Memory kontrolu: SW ve LW dogrulamasi (Mem[4] == 30)
        if (u_core.u_dmem.ram[4] === 16'd30) begin
            $display(">>> TEST BASARILI: SW ve LW bellek islemleri dogru! Mem[4] = 30 <<<");
        end else begin
            $display(">>> TEST BASARISIZ: Mem[4] degeri %0d (Beklenen: 30) <<<", u_core.u_dmem.ram[4]);
        end

        $finish;
    end

endmodule