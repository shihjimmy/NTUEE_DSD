`timescale 1ns/10ps
module GSIM ( clk, reset, in_en, b_in, out_valid, x_out);
    input   clk ;
    input   reset ;
    input   in_en;
    output  out_valid;
    input   [15:0]  b_in;
    output  [31:0]  x_out;
    
    // state parameters
    parameter IDLE = 0;
    parameter GET_B = 1;
    parameter CALC = 2;
    parameter OUT = 3;

    // wires and regs
    reg [1:0] state_r,state_w;
    reg [15:0] matrix_b [0:15];
    reg [15:0] matrix_b_w [0:15];
    reg [31:0] matrix_x[0:15];
    reg [31:0] matrix_x_w[0:15];
    
    reg [3:0] count_CALC_r,count_CALC_w;
    reg [6:0] count_iter_r,count_iter_w;
    reg [3:0] count_OUT_r,count_OUT_w;
    reg [3:0] count_GET_B_r,count_GET_B_w;
    
    reg  check_GETB,check_CALC,check_iter;

    wire [31:0] x_iter [0:5];
    reg [31:0] x0[0:5];
    reg [31:0] x0_w[0:5];
    reg [37:0] temp1[0:2],temp2[0:2],temp3[0:1],temp4,temp5,temp5a,temp5b,temp6,temp6a,temp6b,temp7,temp7a,temp7b,temp8,temp8a,temp8b,temp9,temp9a,temp9b;
    reg [31:0] temp10;

    //state transition
    always@ (*) begin
        case(state_r)
            IDLE: state_w = (in_en) ? GET_B : IDLE;
            GET_B: state_w = (&count_GET_B_r) ? CALC : GET_B;
            CALC: state_w = (count_iter_r==7'd72) ? OUT : CALC;
            OUT:  state_w = (&count_OUT_r) ? IDLE : OUT;
        endcase
    end
    
    //counters
    always@ (*) begin
        check_GETB = (state_r==GET_B);
        check_CALC = (state_r==CALC);

        count_GET_B_w = (in_en) ? (count_GET_B_r+1'b1) : 0;
        count_CALC_w = (check_CALC) ? (count_CALC_r + 1'b1) : 0;
        count_iter_w = (check_CALC && (&count_CALC_r)) ? (count_iter_r + 1'b1) : count_iter_r;
        count_OUT_w = (state_r==OUT) ? (count_OUT_r + 1'b1) : 0;
    end

    //get matrix b
    integer k;
    always@ (*) begin
        if (in_en) begin
            for (k=1; k<16; k=k+1) begin
                matrix_b_w[k-1] = matrix_b[k];
            end
            matrix_b_w[15] = b_in;
        end
        else begin
            for (k=0;k<16;k=k+1) matrix_b_w[k] = matrix_b[k];
        end
    end
    
    reg [31:0] x_temp[0:5];

    always @(*) begin
        if (check_CALC && &(~count_iter_r) && ~(&count_CALC_r)) begin
            x_temp[0] = 0;
            x_temp[1] = 0;
            x_temp[2] = 0;
            x_temp[3] = 0;
            x_temp[4] = 0;
            x_temp[5] = 0;
        end
        else if (check_CALC && (&count_CALC_r)) begin
            x_temp[0] = matrix_x[3];
            x_temp[1] = matrix_x[2];
            x_temp[2] = matrix_x[1];
            x_temp[3] = 0;
            x_temp[4] = 0;
            x_temp[5] = 0;
        end
        else if(check_CALC && count_CALC_r<12) begin
            x_temp[0] = matrix_x[count_CALC_r+4];
            x_temp[1] = x0[0];
            x_temp[2] = x0[1];
            x_temp[3] = temp10;
            x_temp[4] = x0[3];
            x_temp[5] = x0[4];
        end
        else if(check_CALC && count_CALC_r<15) begin
            x_temp[0] = 0;
            x_temp[1] = x0[0];
            x_temp[2] = x0[1];
            x_temp[3] = temp10;
            x_temp[4] = x0[3];
            x_temp[5] = x0[4];
        end
        else begin
            x_temp[0] = 0;
            x_temp[1] = 0;
            x_temp[2] = 0;
            x_temp[3] = 0;
            x_temp[4] = 0;
            x_temp[5] = 0;
        end
    end

    //iteration 
    integer q;
    always@ (*) begin
        if(check_CALC) begin
            x0_w[0] = x_temp[0];
            x0_w[1] = x_temp[1];
            x0_w[2] = x_temp[2];
            x0_w[3] = x_temp[3];
            x0_w[4] = x_temp[4];
            x0_w[5] = x_temp[5];
        end         
        else begin
            for(q=0;q<6;q=q+1) begin
                x0_w[q] = 0;
            end
        end
    end

    assign x_iter[0] = x0[0];
    assign x_iter[1] = x0[5];
    assign x_iter[2] = x0[1];
    assign x_iter[3] = x0[4];
    assign x_iter[4] = x0[2];
    assign x_iter[5] = x0[3];

    always@ (*) begin
        temp1[0] = ({{6{x_iter[0][31]}},x_iter[0]}) + ({{6{x_iter[1][31]}},x_iter[1]});
        temp1[1] = ({{6{x_iter[2][31]}},x_iter[2]}) + ({{6{x_iter[3][31]}},x_iter[3]});
        temp1[2] = ({{6{x_iter[4][31]}},x_iter[4]}) + ({{6{x_iter[5][31]}},x_iter[5]});
        temp2[0] = (({{6{matrix_b[count_CALC_r][15]}},matrix_b[count_CALC_r],16'b0}) + temp1[0]);
        temp2[1] = (temp1[1]<<1) + (temp1[1]<<2);
        temp2[2] = temp1[2] + (temp1[2]<<2);
        temp3[0] = ~temp2[1] + 1'b1 + temp2[0];
        temp3[1] = temp2[2] + (temp1[2]<<3);
        temp4 = temp3[0] + temp3[1];
        temp5a = temp4;
        temp5b = ($signed(temp4)>>>4);
        temp5 = temp5a + temp5b;
        temp6a = temp5;
        temp6b = ($signed(temp5)>>>8);
        temp6 = temp6a + temp6b;
        temp7a = temp6;
        temp7b = ($signed(temp6)>>>16);
        temp7 = temp7a + temp7b;
        temp8a = temp7;
        temp8b = ($signed(temp7)>>>32);
        temp8 = temp8a + temp8b;
        temp9a = temp8;
        temp9b = temp8 << 1;
        temp9 = temp9a + temp9b;
        temp10 = temp9[37:6];
    end

    integer p;
    always@ (*) begin
        if(state_r == CALC) begin
            for (p=0; p<16; p=p+1) begin
                matrix_x_w[p] = (count_CALC_r == p) ? temp10 : matrix_x[p];
            end
        end
        else if(state_r==OUT) begin
            for(p=0;p<15;p=p+1) begin
                matrix_x_w[p] = matrix_x[p+1];
            end
            matrix_x_w[15] = 0;
        end
        else begin
            for(p=0;p<16;p=p+1) begin
                matrix_x_w[p] = matrix_x[p];
            end
        end
    end

    assign x_out = matrix_x[0];
    assign out_valid = (state_r==OUT);

    integer i;
    always@ (posedge clk or posedge reset) begin
        if(reset) begin
            state_r <= IDLE;
            count_CALC_r <= 0;
            count_iter_r <= 0;
            count_OUT_r <= 0;
            count_GET_B_r <= 0;

            for(i=0;i<16;i=i+1) begin
                matrix_x[i] <= 0;
                matrix_b[i] <= 0;
            end

            for(i=0;i<6;i=i+1) begin
                x0[i] <= 0;
            end
        end
        else begin
            state_r <= state_w;
            count_CALC_r <= count_CALC_w;
            count_iter_r <= count_iter_w;
            count_OUT_r <= count_OUT_w;
            count_GET_B_r <= count_GET_B_w;

            for(i=0;i<16;i=i+1) begin
                matrix_x[i] <= matrix_x_w[i];
                matrix_b[i] <= matrix_b_w[i];
            end

            for(i=0;i<6;i=i+1) begin
                x0[i] <= x0_w[i];
            end
        end
    end

endmodule
