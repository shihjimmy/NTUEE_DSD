module barrel_shifter(in, shift, out);
input  [7:0] in;
input  [2:0] shift;
output [7:0] out;

/*Write your code here*/
assign out = (shift == 3'b000) ? in :
             (shift == 3'b001) ? {in[6:0],1'b0} :
             (shift == 3'b010) ? {in[5:0],2'b0} :
             (shift == 3'b011) ? {in[4:0],3'b0} :
             (shift == 3'b100) ? {in[3:0],4'b0} :
             (shift == 3'b101) ? {in[2:0],5'b0} :
             (shift == 3'b110) ? {in[1:0],6'b0} :
             (shift == 3'b111) ? {in[0],7'b0} : in;

/*End of code*/
endmodule