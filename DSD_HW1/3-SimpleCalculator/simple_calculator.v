`include "../1-ALU/2_always/alu_always.v"
`include "../2-RegisterFile/register_file.v"

module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

// declaration of wire/reg
    wire [7:0] data_out;
    wire [7:0] data_x;
    wire [7:0] data_y;
    wire [7:0] alu_out;

    assign data_x = (Sel==0) ? DataIn : data_out;
    assign busY = data_y;
   
// submodule instantiation
    register_file reg_file(.Clk(Clk),.WEN(WEN),.RW(RW),.RX(RX),.RY(RY),.busW(alu_out),.busX(data_out),.busY(data_y));
    alu_always alu(.ctrl(Ctrl),.x(data_x),.y(data_y),.carry(Carry),.out(alu_out));

endmodule
