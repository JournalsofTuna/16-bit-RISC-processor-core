`timescale 1ns / 1ps

module risc16_core (
    input  wire        clk,
    input  wire        rst,
    output reg  [15:0] debug_pc,
    output wire [15:0] debug_instr,
    output wire [15:0] debug_alu_result,
    // MMIO icin gereken yeni cikislar:
    output wire        dmem_we,
    output wire [15:0] dmem_wdata
);


    // --- PC Mantığı ---
    reg  [15:0] pc;
    wire [15:0] pc_plus_one;
    wire [15:0] pc_branch;
    wire [15:0] pc_next;
    wire [15:0] instr;

    // --- Kontrol Sinyalleri ---
    wire       reg_write;
    wire       alu_src;
    wire       mem_read;
    wire       mem_write;
    wire       mem_to_reg;
    wire       branch;
    wire       branch_bne;
    wire       jump;
    wire [3:0] alu_ctrl;

    // --- Veri Yolu Sinyalleri ---
    wire [15:0] rdata1, rdata2;
    wire [15:0] alu_in_b;
    wire [15:0] alu_result;
    wire        zero, negative, carry;
    wire [15:0] mem_rdata;
    wire [15:0] reg_wdata;
    wire [15:0] sign_ext_imm;
    wire [2:0]  rf_waddr;

    // 1. Program Counter
    assign pc_plus_one  = pc + 16'd1;
    assign sign_ext_imm = {{10{instr[5]}}, instr[5:0]};
    assign pc_branch    = pc_plus_one + sign_ext_imm;

    wire take_branch = branch & (branch_bne ? ~zero : zero);
    wire [15:0] pc_after_branch = (take_branch) ? pc_branch : pc_plus_one;
    assign pc_next = (jump) ? {pc[15:12], instr[11:0]} : pc_after_branch;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc       <= 16'h0000;
            debug_pc <= 16'h0000;
        end else begin
            pc       <= pc_next;
            debug_pc <= pc_next;
        end
    end

    // 2. Komut Belleği
    instruction_mem u_imem (
        .pc(pc),
        .instr(instr)
    );

    // 3. Kontrol Birimi
    control_unit u_cu (
        .opcode(instr[15:12]),
        .func(instr[2:0]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .branch_bne(branch_bne),
        .jump(jump),
        .alu_ctrl(alu_ctrl)
    );

    // 4. Register File
    assign rf_waddr = instr[11:9];

    // SW, BEQ ve BNE için raddr2 hedef alanından okunmalıdır
    wire is_store_or_branch = (instr[15:12] == 4'b0011) || 
                              (instr[15:12] == 4'b0100) || 
                              (instr[15:12] == 4'b0101);

    wire [2:0] rf_raddr2 = (is_store_or_branch) ? instr[11:9] : instr[5:3];
    assign reg_wdata = (mem_to_reg) ? mem_rdata : alu_result;

    register_file u_rf (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .raddr1(instr[8:6]),
        .raddr2(rf_raddr2),
        .waddr(rf_waddr),
        .wdata(reg_wdata),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // 5. ALU
    assign alu_in_b = (alu_src) ? sign_ext_imm : rdata2;

    alu u_alu (
        .a(rdata1),
        .b(alu_in_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero),
        .negative(negative),
        .carry(carry)
    );

    // 6. Veri Belleği
    data_mem u_dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result),
        .wdata(rdata2),
        .rdata(mem_rdata)
    );

    // 7. Debug
    assign debug_instr      = instr;
    assign debug_alu_result = alu_result;
    assign dmem_we    = mem_write;
    assign dmem_wdata = rdata2;

endmodule