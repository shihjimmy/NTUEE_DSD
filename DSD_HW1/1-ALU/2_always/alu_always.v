//RT �Vlevel (event-driven) 
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output reg     carry;
    output reg [7:0] out;
    
    reg  temp_carry0, temp_carry1;
    reg  [7:0] temp0,temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8,temp9,temp10,temp11,temp12;

    always@(*) begin
        {temp_carry0,temp0} = {x[7],x[7:0]} + {y[7],y[7:0]};
        {temp_carry1,temp1} = {x[7],x[7:0]} - {y[7],y[7:0]};
        temp2 = x & y;
        temp3 = x | y;
        temp4 = ~x;
        temp5 = x ^ y;
        temp6 = ~temp3; 
        temp7 = (y << x[2:0]);
        temp8 = (y >> x[2:0]);
        temp9 = {x[7] , x[7:1]};
        temp10 = {x[6:0] , x[7]};
        temp11 = {x[0] , x[7:1]};
        temp12 = (x==y) ? 1 : 0;

        if(ctrl == 4'b000) carry = temp_carry0;
        else if(ctrl == 4'b001) carry = temp_carry1;
        else carry = 0;

        case(ctrl)
            4'b0000: out = temp0;
            4'b0001: out = temp1;
            4'b0010: out = temp2;
            4'b0011: out = temp3;
            4'b0100: out = temp4;
            4'b0101: out = temp5;
            4'b0110: out = temp6;
            4'b0111: out = temp7;
            4'b1000: out = temp8;
            4'b1001: out = temp9;
            4'b1010: out = temp10;
            4'b1011: out = temp11;
            4'b1100: out = temp12;
            default: out = 0;
        endcase
    end

endmodule