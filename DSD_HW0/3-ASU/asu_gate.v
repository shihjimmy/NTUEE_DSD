module asu_gate (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;

/*Write your code here*/
wire temp_carry;
wire [7:0] temp_out1,temp_out2;

barrel_shifter_gate BS1(.in(x),.shift(y[2:0]),.out(temp_out1));
adder_gate FA1(.x(x),.y(y),.carry(temp_carry),.out(temp_out2));

MUX m1(.x(carry),.a(0),.b(temp_carry),.sel(mode));

genvar i;
for(i=0;i<8;i=i+1) begin
    MUX m2 (.x(out[i]),.a(temp_out1[i]),.b(temp_out2[i]),.sel(mode));
end

/*End of code*/

endmodule

module MUX (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not n0(sel_i,sel);
and a1(w1,a,sel_i);
and a2(w2,b,sel);
or  #2.5 o1(x,w1,w2);

endmodule