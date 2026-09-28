`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module control_unit(
    input wire [3:0] opcode,
    input wire [2:0] func,
    output reg      reg_write,
    output reg      alu_src,
    output reg      mem_read,
    output reg      mem_write,
    output reg      mem_to_reg,
    output reg      branch,
    output reg      branch_bne,
    output reg      jump,
    output reg [3:0] alu_ctrl
    
    );
    
     always @(*) begin
        // Varsayilan (default) guvenli degerler -Latch olusumunu engeller.
        reg_write = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        branch_bne = 1'b0;
        jump       = 1'b0;
        alu_ctrl   = 4'b0000;
        
        case (opcode)
            // ====================================
            // R-TYPE (ADD,SUB,AND,OR,XOR,SLT,SLL,SRL)
            // ====================================
        4'b0000: begin
            reg_write  = 1'b1;
            alu_src    = 1'b0; // Ikınci operand Register'dan gelir.
            mem_to_reg = 1'b0; // Yazmac dosyasina ALU Sonucu yazilir.
          case(func) 
              3'b000: alu_ctrl = 4'b0000; // ADD
              3'b001: alu_ctrl = 4'b0001; // SUB
              3'b010: alu_ctrl = 4'b0010; // AND
              3'b011: alu_ctrl = 4'b0011; // OR
              3'b100: alu_ctrl = 4'b0100; // XOR
              3'b101: alu_ctrl = 4'b0101; // SLT
              3'b110: alu_ctrl = 4'b0110; // SLL
              3'b111: alu_ctrl = 4'b0111; // SRL
              default: alu_ctrl = 4'b0000;
           endcase
         end
      // =======================================
      // I-TYPE: ADDI
      // =======================================
      
      4'b0001: begin
        reg_write = 1'b1;
        alu_src = 1'b1; // Ikinci operand Immediate
        mem_to_reg = 1'b0; 
        alu_ctrl = 4'b0000; // ALU Toplama yapar.
     end
    // =============================================
    // I-TYPE: LW (Load Wire)
    // =============================================
    4'b0010: begin
        reg_write = 1'b1;   // LW Hedef yazmaca yazar
        alu_src   = 1'b1; // Adres Hesabi: Base + Imm
        mem_read  = 1'b1; // Hafizada oku.
        mem_to_reg = 1'b1; // Yazmaca Hafiza verisini yonlendir.
        alu_ctrl = 4'b0000; // Adres hesabi icin ADD
      end
      
      // ===================================================
      // I-TYPE: SW (Store Word)
      // ==================================================
    4'b0011: begin
        alu_src = 1'b1; // Adres Hesabi: Base + Imm
        mem_write = 1'b1; // Hafizaya Yaz.   
        alu_ctrl = 4'b0000; // Adres hesabi icin ADD
      end
      
     // ==================================================
     // I-TYPE: BEQ (Branch if Equal) 
     // ==================================================
     
     4'b0100: begin
        branch = 1'b1;
        alu_src = 1'b0;
        alu_ctrl = 4'b0001; // Esitligi kontrol etmek icin SUB (Zero bayragi)
     end
     
    // ===================================================
    // I-TYPE BNE (Branch if Not Equal)
    // ===================================================
    
    4'b0101: begin
        branch = 1'b1;
        branch_bne = 1'b1;
        alu_src = 1'b0;
        alu_ctrl = 4'b0001; // Esitligi kontrol etmek icin SUB(~Zero)
    end
    
    // ====================================================
    // J-TYPE: JUMP 
    // ====================================================
    4'b0110: begin
        jump = 1'b1;
     end
     
         default: begin
        // Tanimsiz opcode gelirse guvenli sifir durumunda kal.
          end
       endcase
     end

endmodule
