module asu (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;

/*Write your code here*/
wire temp_carry;
wire [7:0] temp_out1,temp_out2;

barrel_shifter BS1(.in(x),.shift(y[2:0]),.out(temp_out1));
adder FA1(.x(x),.y(y),.carry(temp_carry),.out(temp_out2));

assign carry = mode ? temp_carry : 0;
assign out = mode ? temp_out2 : temp_out1;

/*End of code*/

endmodule