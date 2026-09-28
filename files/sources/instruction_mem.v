`timescale 1ns / 1ps

module instruction_mem (
    input  wire [15:0] pc,
    output wire [15:0] instr
);

    reg [15:0] rom [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            rom[i] = 16'h0000;
        end

        // 0. ADDI R1, R0, 10    -> R1 = 10
        rom[0] = 16'b0001_001_000_001010;

        // 1. ADDI R2, R0, 20    -> R2 = 20
        rom[1] = 16'b0001_010_000_010100;

        // 2. ADD  R3, R1, R2    -> R3 = 10 + 20 = 30
        rom[2] = 16'b0000_011_001_010_000;

        // 3. SW   R3, 4(R0)     -> Mem[4] = 30
        rom[3] = 16'b0011_011_000_000100;

        // 4. LW   R4, 4(R0)     -> R4 = 30
        rom[4] = 16'b0010_100_000_000100;

        // 5. SUB  R5, R4, R1    -> R5 = 30 - 10 = 20
        rom[5] = 16'b0000_101_100_001_001;

        // 6. BEQ  R5, R2, 1     -> R5 == R2 oldugundan PC = 6 + 1 + 1 = 8'e atlar (7'yi atlar)
        rom[6] = 16'b0100_101_010_000001;

        // 7. ADDI R6, R0, 1     -> Atlama BASARISIZ olursa calisir (Hata durumu)
        rom[7] = 16'b0001_110_000_000001;

        // 8. ADDI R6, R0, 25    -> Atlama BASARILI olursa calisir (Beklenen deger 25)
        rom[8] = 16'b0001_110_000_011001;

        // 9. JUMP 9            -> Kendi uzerinde sonsuz dongu (kilitlenme)
        rom[9] = 16'b0110_000000001001;
    end

    assign instr = rom[pc[7:0]];

endmodule