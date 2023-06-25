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
    reg [3:0] count_stage_r,count_stage_w;
    reg [6:0] count_iter_r,count_iter_w;
    reg [3:0] count_OUT_r,count_OUT_w;
    reg [3:0] count_GET_B_r,count_GET_B_w;
    
    reg  check_GETB,check_CALC,check_iter;

    reg [31:0] x_iter [0:5];
    reg [38:0] w [0:5];
    reg [38:0] r [0:5];
    wire [38:0] out [0:2];
    wire [38:0] out_plus[0:2];

    //state transition
    always@ (*) begin
        case(state_r)
            IDLE: state_w = (in_en) ? GET_B : IDLE;
            GET_B: state_w = (&count_GET_B_r) ? CALC : GET_B;
            CALC: state_w = (count_iter_r==7'd71) ? OUT : CALC;
            OUT:  state_w = (&count_OUT_r) ? IDLE : OUT;
        endcase
    end
    
    //counters
    always@ (*) begin
        check_GETB = (state_r==GET_B);
        check_CALC = (state_r==CALC);
        check_iter = count_stage_r[3] && !count_stage_r[2] && !count_stage_r[1] && count_stage_r[0];

        count_GET_B_w = (in_en) ? (count_GET_B_r+1'b1) : 0;
        count_CALC_w = (check_CALC && check_iter) ? (count_CALC_r + 1'b1) : count_CALC_r;
        count_iter_w = (check_CALC && (&count_CALC_r) && check_iter) ? (count_iter_r + 1'b1) : count_iter_r;
        count_stage_w = (check_CALC && !check_iter) ? (count_stage_r + 1'b1) : 0;
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
    
    //iteration stage1
    integer q;
    always@ (*) begin
        if(state_r==CALC) begin
            case(count_CALC_r)
                4'd0: begin
                    x_iter[0] = 0;
                    x_iter[2] = 0;
                    x_iter[4] = 0;
                    x_iter[5] = matrix_x[1];
                    x_iter[3] = matrix_x[2];
                    x_iter[1] = matrix_x[3];
                end
                4'd1: begin
                    x_iter[0] = 0;
                    x_iter[2] = 0;
                    x_iter[4] = matrix_x[0];
                    x_iter[5] = matrix_x[2];
                    x_iter[3] = matrix_x[3];
                    x_iter[1] = matrix_x[4];
                end
                4'd2: begin
                    x_iter[0] = 0;
                    x_iter[2] = matrix_x[0];
                    x_iter[4] = matrix_x[1];
                    x_iter[5] = matrix_x[3];
                    x_iter[3] = matrix_x[4];
                    x_iter[1] = matrix_x[5];
                end
                4'd3: begin
                    x_iter[0] = matrix_x[0];
                    x_iter[2] = matrix_x[1];
                    x_iter[4] = matrix_x[2];
                    x_iter[5] = matrix_x[4];
                    x_iter[3] = matrix_x[5];
                    x_iter[1] = matrix_x[6];
                end
                4'd4: begin
                    x_iter[0] = matrix_x[1];
                    x_iter[2] = matrix_x[2];
                    x_iter[4] = matrix_x[3];
                    x_iter[5] = matrix_x[5];
                    x_iter[3] = matrix_x[6];
                    x_iter[1] = matrix_x[7];
                end
                4'd5: begin
                    x_iter[0] = matrix_x[2];
                    x_iter[2] = matrix_x[3];
                    x_iter[4] = matrix_x[4];
                    x_iter[5] = matrix_x[6];
                    x_iter[3] = matrix_x[7];
                    x_iter[1] = matrix_x[8];
                end
                4'd6: begin
                    x_iter[0] = matrix_x[3];
                    x_iter[2] = matrix_x[4];
                    x_iter[4] = matrix_x[5];
                    x_iter[5] = matrix_x[7];
                    x_iter[3] = matrix_x[8];
                    x_iter[1] = matrix_x[9];
                end
                4'd7: begin
                    x_iter[0] = matrix_x[4];
                    x_iter[2] = matrix_x[5];
                    x_iter[4] = matrix_x[6];
                    x_iter[5] = matrix_x[8];
                    x_iter[3] = matrix_x[9];
                    x_iter[1] = matrix_x[10];
                end
                4'd8: begin
                    x_iter[0] = matrix_x[5];
                    x_iter[2] = matrix_x[6];
                    x_iter[4] = matrix_x[7];
                    x_iter[5] = matrix_x[9];
                    x_iter[3] = matrix_x[10];
                    x_iter[1] = matrix_x[11];
                end
                4'd9: begin
                    x_iter[0] = matrix_x[6];
                    x_iter[2] = matrix_x[7];
                    x_iter[4] = matrix_x[8];
                    x_iter[5] = matrix_x[10];
                    x_iter[3] = matrix_x[11];
                    x_iter[1] = matrix_x[12];
                end
                4'd10: begin
                    x_iter[0] = matrix_x[7];
                    x_iter[2] = matrix_x[8];
                    x_iter[4] = matrix_x[9];
                    x_iter[5] = matrix_x[11];
                    x_iter[3] = matrix_x[12];
                    x_iter[1] = matrix_x[13];
                end
                4'd11: begin
                    x_iter[0] = matrix_x[8];
                    x_iter[2] = matrix_x[9];
                    x_iter[4] = matrix_x[10];
                    x_iter[5] = matrix_x[12];
                    x_iter[3] = matrix_x[13];
                    x_iter[1] = matrix_x[14];
                end
                4'd12: begin
                    x_iter[0] = matrix_x[9];
                    x_iter[2] = matrix_x[10];
                    x_iter[4] = matrix_x[11];
                    x_iter[5] = matrix_x[13];
                    x_iter[3] = matrix_x[14];
                    x_iter[1] = matrix_x[15];
                end
                4'd13: begin
                    x_iter[0] = matrix_x[10];
                    x_iter[2] = matrix_x[11];
                    x_iter[4] = matrix_x[12];
                    x_iter[5] = matrix_x[14];
                    x_iter[3] = matrix_x[15];
                    x_iter[1] = 0;
                end
                4'd14: begin
                    x_iter[0] = matrix_x[11];
                    x_iter[2] = matrix_x[12];
                    x_iter[4] = matrix_x[13];
                    x_iter[5] = matrix_x[15];
                    x_iter[3] = 0;
                    x_iter[1] = 0;
                end
                4'd15: begin
                    x_iter[0] = matrix_x[12];
                    x_iter[2] = matrix_x[13];
                    x_iter[4] = matrix_x[14];
                    x_iter[5] = 0;
                    x_iter[3] = 0;
                    x_iter[1] = 0;
                end
                default: begin
                    for(q=0;q<6;q=q+1) begin
                        x_iter[q] = 0;
                    end
                end
            endcase
        end            
        else begin
            for(q=0;q<6;q=q+1) begin
                x_iter[q] = 0;
            end
        end
    end

    assign out_plus[0] = r[0] + r[1];
    assign out_plus[1] = r[2] + r[3];
    assign out_plus[2] = r[4] + r[5];

    always @(*) begin
        case(count_stage_r)
            0: begin
                w[0] = {{6{x_iter[0][31]}}, x_iter[0], 1'b0};
                w[1] = {{6{x_iter[1][31]}}, x_iter[1], 1'b0};
                w[2] = {{6{x_iter[2][31]}}, x_iter[2], 1'b0};
                w[3] = {{6{x_iter[3][31]}}, x_iter[3], 1'b0};
                w[4] = {{6{x_iter[4][31]}}, x_iter[4], 1'b0};
                w[5] = {{6{x_iter[5][31]}}, x_iter[5], 1'b0};
            end
            1: begin
                w[0] = {{6{matrix_b[count_CALC_r][15]}}, matrix_b[count_CALC_r],17'b0};
                w[1] = out_plus[0];
                w[2] = out_plus[1]<<1;
                w[3] = out_plus[1]<<2;
                w[4] = out_plus[2];
                w[5] = out_plus[2]<<2;
            end
            2: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = out_plus[0];
                w[3] = ~out_plus[1]+1'b1;
                w[4] = out_plus[2];
                w[5] = r[5]<<1;
            end
            3: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = out_plus[1];
                w[5] = out_plus[2];
            end
            4: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = $signed(out_plus[2])>>>4;
                w[5] = out_plus[2];
            end
            5: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = $signed(out_plus[2])>>>8;
                w[5] = out_plus[2];
            end
            6: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = $signed(out_plus[2])>>>16;
                w[5] = out_plus[2];
            end
            7: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = $signed(out_plus[2])>>>32;
                w[5] = out_plus[2];
            end
            8: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = out_plus[2]<<1;
                w[5] = out_plus[2];
            end
            9: begin
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = 0;
                w[5] = out_plus[2];
            end
            default: begin   
                w[0] = 0;
                w[1] = 0;
                w[2] = 0;
                w[3] = 0;
                w[4] = 0;
                w[5] = 0;   
            end
        endcase
    end

    integer t;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (t=0; t<6; t=t+1) r[t] <= 0;
        end
        else begin
            for (t=0; t<6; t=t+1) r[t] <= w[t];
        end
    end

    integer p;
    always@ (*) begin
        if(state_r == CALC && check_iter) begin
            for (p=0; p<16; p=p+1) begin
                matrix_x_w[p] = (count_CALC_r == p) ? w[5][38:7] : matrix_x[p];
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
            count_stage_r <= 0;
            count_OUT_r <= 0;
            count_GET_B_r <= 0;

            for(i=0;i<16;i=i+1) begin
                matrix_x[i] <= 0;
                matrix_b[i] <= 0;
            end
        end
        else begin
            state_r <= state_w;
            count_CALC_r <= count_CALC_w;
            count_iter_r <= count_iter_w;
            count_stage_r <= count_stage_w;
            count_OUT_r <= count_OUT_w;
            count_GET_B_r <= count_GET_B_w;

            for(i=0;i<16;i=i+1) begin
                matrix_x[i] <= matrix_x_w[i];
                matrix_b[i] <= matrix_b_w[i];
            end
        end
    end

endmodule
