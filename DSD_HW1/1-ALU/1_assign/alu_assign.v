//RTL (use continuous assignment)
module alu_assign(
    ctrl,
    x,
    y,
    carry,
    out  
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;
    
    wire   temp_carry0, temp_carry1;
    wire   [7:0] temp0,temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8,temp9,temp10,temp11,temp12;
    
    assign {temp_carry0,temp0} = {x[7],x} + {y[7],y};
    assign {temp_carry1,temp1} = {x[7],x} - {y[7],y};
    assign temp2 = x & y;
    assign temp3 = x | y;
    assign temp4 = ~x;
    assign temp5 = x ^ y;
    assign temp6 = ~temp3; 
    assign temp7 = (y << x[2:0]);
    assign temp8 = (y >> x[2:0]);
    assign temp9 = {x[7] , x[7:1]};
    assign temp10 = {x[6:0] , x[7]};
    assign temp11 = {x[0] , x[7:1]};
    assign temp12 = (x==y) ? 1 : 0;

    assign carry = (ctrl == 4'b0000) ? temp_carry0 :
                   (ctrl == 4'b0001) ? temp_carry1 : 0;

    assign out = (ctrl == 4'b0000) ? temp0 :
                 (ctrl == 4'b0001) ? temp1 :
                 (ctrl == 4'b0010) ? temp2 :
                 (ctrl == 4'b0011) ? temp3 :
                 (ctrl == 4'b0100) ? temp4 :
                 (ctrl == 4'b0101) ? temp5 :
                 (ctrl == 4'b0110) ? temp6 :
                 (ctrl == 4'b0111) ? temp7 :  
                 (ctrl == 4'b1000) ? temp8 :
                 (ctrl == 4'b1001) ? temp9 :
                 (ctrl == 4'b1010) ? temp10 :
                 (ctrl == 4'b1011) ? temp11 :
                 (ctrl == 4'b1100) ? temp12 : 0;

endmodule