module barrel_shifter_gate(in, shift, out);
input  [7:0] in;
input  [2:0] shift;
output [7:0] out;

/*Write your code here*/
wire [7:0] temp1,temp2;

level1 l1(.in(in),.shift(shift[0]),.out(temp1));
level2 l2(.in(temp1),.shift(shift[1]),.out(temp2));
level3 l3(.in(temp2),.shift(shift[2]),.out(out));

/*End of code*/
endmodule

module level3 (in,shift,out);
input [7:0] in;
input shift;
output [7:0] out;

wire [7:0] in_data;
assign in_data = {in[3:0],4'b0};

genvar i;
for(i=0;i<8;i=i+1) begin
    mux m1(.x(out[i]),.a(in[i]),.b(in_data[i]),.sel(shift));
end

endmodule

module level2 (in,shift,out);
input [7:0] in;
input shift;
output [7:0] out;

wire [7:0] in_data;
assign in_data = {in[5:0],2'b0};

genvar j;
for(j=0;j<8;j=j+1) begin
    mux m1(.x(out[j]),.a(in[j]),.b(in_data[j]),.sel(shift));
end

endmodule

module level1 (in,shift,out);
input [7:0] in;
input shift;
output [7:0] out;

wire [7:0] in_data;
assign in_data = {in[6:0],1'b0};

genvar k;
for(k=0;k<8;k=k+1) begin
    mux m1(.x(out[k]),.a(in[k]),.b(in_data[k]),.sel(shift));
end

endmodule

module mux (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not #1 n0(sel_i,sel);
and #1 a1(w1,a,sel_i);
and #1 a2(w2,b,sel);
or  #1 o1(x,w1,w2);

endmodule