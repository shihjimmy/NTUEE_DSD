module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;

/*Write your code here*/
wire [6:0] temp;

full_adder FA1(.a(x[0]),.b(y[0]),.cin(1'b0),.cout(temp[0]),.out(out[0]));
full_adder FA2(.a(x[1]),.b(y[1]),.cin(temp[0]),.cout(temp[1]),.out(out[1]));
full_adder FA3(.a(x[2]),.b(y[2]),.cin(temp[1]),.cout(temp[2]),.out(out[2]));
full_adder FA4(.a(x[3]),.b(y[3]),.cin(temp[2]),.cout(temp[3]),.out(out[3]));
full_adder FA5(.a(x[4]),.b(y[4]),.cin(temp[3]),.cout(temp[4]),.out(out[4]));
full_adder FA6(.a(x[5]),.b(y[5]),.cin(temp[4]),.cout(temp[5]),.out(out[5]));
full_adder FA7(.a(x[6]),.b(y[6]),.cin(temp[5]),.cout(temp[6]),.out(out[6]));
full_adder FA8(.a(x[7]),.b(y[7]),.cin(temp[6]),.cout(carry),.out(out[7]));

/*End of code*/

endmodule

module full_adder(a,b,cin,cout,out);
input a,b,cin;
output cout;
output out;

wire temp1,temp2,temp3;

and #1 AND1(temp1,cin,a);
and #1 AND2(temp2,a,b);
and #1 AND3(temp3,cin,b);
or  #1 OR1(cout,temp1,temp2,temp3);
xor #1 XOR1(out,a,b,cin);

endmodule