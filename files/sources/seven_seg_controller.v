`timescale 1ns / 1ps

module seven_seg_controller (
    input  wire        clk_100m,  // 100 MHz Basys 3 osilatörü
    input  wire        rst,       // btnC reset girişi
    input  wire [15:0] val,       // Ekrana basılacak 16-bit değer
    output reg  [3:0]  an,        // Anot seçicileri (Active Low)
    output reg  [6:0]  seg        // Katot segmentleri (Active Low: {g,f,e,d,c,b,a})
);

    // 100 MHz'i ~1 kHz tarama frekansına bölmek için 18-bit sayaç.
    // Tarama sayacı resette kilitlenmez, sürekli sayarak tüm haneleri çoklamaya devam eder.
    reg [17:0] refresh_counter = 18'd0;
    always @(posedge clk_100m) begin
        refresh_counter <= refresh_counter + 18'd1;
    end

    // Sayacın en üst 2 biti hangi hanenin aktif olduğunu seçer
    wire [1:0] active_digit = refresh_counter[17:16];

    // Aktif haneye göre görüntülenecek 4-bitlik hex değerini seç
    reg [3:0] digit_val;
    always @(*) begin
        if (rst) begin
            // Reset basılı tutulduğunda tüm hanelere 0 yönlendirilir
            digit_val = 4'h0;
            case (active_digit)
                2'b00: an = 4'b1110; // En sağdaki hane
                2'b01: an = 4'b1101; // Sağdan ikinci
                2'b10: an = 4'b1011; // Soldan ikinci
                2'b11: an = 4'b0111; // En soldaki hane
            endcase
        end else begin
            case (active_digit)
                2'b00: begin
                    an = 4'b1110;
                    digit_val = val[3:0];
                end
                2'b01: begin
                    an = 4'b1101;
                    digit_val = val[7:4];
                end
                2'b10: begin
                    an = 4'b1011;
                    digit_val = val[11:8];
                end
                2'b11: begin
                    an = 4'b0111;
                    digit_val = val[15:12];
                end
            endcase
        end
    end

    // 4-bit HEX değeri 7-segment (Active Low) koduna dönüştürme
    // Segment dizilimi: {g, f, e, d, c, b, a}
    always @(*) begin
        case (digit_val)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end

endmodule