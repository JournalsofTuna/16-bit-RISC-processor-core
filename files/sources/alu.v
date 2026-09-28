`timescale 1ns / 1ps

module alu(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [3:0] alu_ctrl,
    output reg [15:0] result,
    output wire     zero,
    output wire     negative,
    output reg      carry

    );
    wire [16:0] sum_ext;
    wire [16:0] sub_ext;
    
    // Elde ve Borc durumlarini yakalamk icin 17-bit genisletme
    assign sum_ext = {1'b0, a} + {1'b0, b};
    assign sub_ext = {1'b0, a} - {1'b0, b};

    always @(*) begin 
        carry =  1'b0;
        case(alu_ctrl)
            4'b0000: begin // ADD
            result = sum_ext[15:0];
            carry  = sum_ext [16];
         end
       4'b0001: begin // SUB
            result =  sub_ext[15:0];
            carry  = sub_ext[16];
         end
         4'b0010: result = a & b;
         4'b0011: result = a | b;
         4'b0100: result = a ^ b;
         4'b0101: result = ($signed(a) < $signed(b)) ? 16'h0001 : 16'h0000;
         4'b0110: result = a << b[3:0];
         4'b0111: result = a >> b[3:0];
         4'b1000: result = $signed(a) >>> b[3:0];
         default: result = 16'h0000;
       endcase
    end
    
    assign zero = (result ==16'h0000);
    assign negative = result[15];

endmodule
