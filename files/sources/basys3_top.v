`timescale 1ns / 1ps

module basys3_top (
    input  wire        clk,       // 100 MHz Basys 3 saati (W5)
    input  wire        btnC,      // Orta buton: Reset (U18)
    input  wire [15:0] sw,        // 16 Switch
    output reg  [15:0] led,       // 16 LED
    output wire [3:0]  an,        // 7-Segment Anotlar
    output wire [6:0]  seg        // 7-Segment Katotlar
);

    wire cpu_clk;
    wire [15:0] debug_pc;
    wire [15:0] debug_instr;
    wire [15:0] debug_alu_result;
    wire        dmem_we;
    wire [15:0] dmem_wdata;

    // Saat Bolucu (sw[15]: 0 ise 5 Hz, 1 ise 5 MHz)
    clk_divider u_clk_div (
        .clk_100m(clk),
        .rst(btnC),
        .speed_sel(sw[15]),
        .cpu_clk(cpu_clk)
    );

    // RISC-16 Cekirdegi (Resmi portlarla baglandi)
    risc16_core u_cpu (
        .clk(cpu_clk),
        .rst(btnC),
        .debug_pc(debug_pc),
        .debug_instr(debug_instr),
        .debug_alu_result(debug_alu_result),
        .dmem_we(dmem_we),
        .dmem_wdata(dmem_wdata)
    );

    // MMIO: LED Yazma Mantigi
    always @(posedge cpu_clk or posedge btnC) begin
        if (btnC) begin
            led <= 16'h0000;
        end else if (dmem_we && (debug_alu_result == 16'h2000)) begin
            led <= dmem_wdata;
        end else if (!dmem_we) begin
            led[7:0]   <= debug_pc[7:0];
            led[15:8]  <= debug_alu_result[7:0];
        end
    end

    // 7-Segment Ekran Gostergesi
    wire [15:0] display_data = {debug_pc[7:0], debug_alu_result[7:0]};

    seven_seg_controller u_display (
        .clk_100m(clk),
        .rst(btnC),
        .val(display_data),
        .an(an),
        .seg(seg)
    );

endmodule