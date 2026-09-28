`timescale 1ns / 1ps


module tb_control_unit();
    reg [3:0] opcode;
    reg [2:0] func;
    wire      reg_write;
    wire      alu_src;
    wire      mem_read;
    wire      mem_to_reg;
    wire      branch;
    wire      branch_bne;
    wire      jump;
    wire [3:0] alu_ctrl;
    
    integer errors = 0;
    
    control_unit u_cu (
        .opcode(opcode),
        .func(func),
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

    initial begin
        opcode = 4'b0000;
        func = 3'b000;
        #10;
        
        // TEST 1: R-Type ADD (Opcode=0, Func=0)
        opcode = 4'b0000; func = 3'b000; #10;
        if (reg_write !== 1'b1 || alu_src !== 1'b0 || alu_ctrl !== 4'b0000) begin
            $display("[HATA] ADD komutu yanlis sinyal uretti!");
            errors = errors + 1;
        end else begin
            $display("[BASARILI] R-Type ADD sinyalleri dogru.");
        end

        // TEST 2: I-Type LW (Opcode=2)
        opcode = 4'b0010; func = 3'b000; #10;
        if (reg_write !== 1'b1 || mem_read !== 1'b1 || mem_to_reg !== 1'b1 || alu_src !== 1'b1) begin
            $display("[HATA] LW komutu yanlis sinyal uretti!");
            errors = errors + 1;
        end else begin
            $display("[BASARILI] I-Type LW sinyalleri dogru.");
        end

        // TEST 3: I-Type SW (Opcode=3)
        opcode = 4'b0011; func = 3'b000; #10;
        if (reg_write !== 1'b0 || mem_write !== 1'b1 || alu_src !== 1'b1) begin
            $display("[HATA] SW komutu yanlis sinyal uretti!");
            errors = errors + 1;
        end else begin
            $display("[BASARILI] I-Type SW sinyalleri dogru.");
        end

        // TEST 4: BEQ (Opcode=4)
        opcode = 4'b0100; func = 3'b000; #10;
        if (branch !== 1'b1 || reg_write !== 1'b0 || alu_ctrl !== 4'b0001) begin
            $display("[HATA] BEQ komutu yanlis sinyal uretti!");
            errors = errors + 1;
        end else begin
            $display("[BASARILI] BEQ sinyalleri dogru.");
        end

        #10;
        if (errors == 0)
            $display(">>> CONTROL UNIT TESTLERI KUSURSUZ GECTI <<<");
        else
            $display(">>> %0d HATA VAR <<<", errors);

        $finish;
    end

endmodule