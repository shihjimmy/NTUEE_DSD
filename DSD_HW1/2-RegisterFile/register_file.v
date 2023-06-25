module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
input        Clk, WEN;
input  [2:0] RW, RX, RY;
input  [7:0] busW;
output reg [7:0] busX, busY;
    
// write your design here, you can delcare your own wires and regs. 
// The code below is just an eaxmple template
reg [7:0] r0_w, r1_w, r2_w, r3_w, r4_w, r5_w, r6_w, r7_w;
reg [7:0] r0_r, r1_r, r2_r, r3_r, r4_r, r5_r, r6_r, r7_r;

always@(*) begin
    r0_r = 0;
    
    if(WEN==1) begin
        case(RW)
            3'd0: begin
                r0_w = 0;
                r1_w = r1_r;
                r2_w = r2_r;
                r3_w = r3_r;
                r4_w = r4_r;
                r5_w = r5_r;
                r6_w = r6_r;
                r7_w = r7_r;
            end
            3'd1: begin
                r0_w = r0_r;
                r1_w = busW;
                r2_w = r2_r;
                r3_w = r3_r;
                r4_w = r4_r;
                r5_w = r5_r;
                r6_w = r6_r;
                r7_w = r7_r;
            end
            3'd2: begin
                r0_w = r0_r;
                r1_w = r1_r;
                r2_w = busW;
                r3_w = r3_r;
                r4_w = r4_r;
                r5_w = r5_r;
                r6_w = r6_r;
                r7_w = r7_r;
            end
            3'd3: begin
                r0_w = r0_r;
                r1_w = r1_r;
                r2_w = r2_r;
                r3_w = busW;
                r4_w = r4_r;
                r5_w = r5_r;
                r6_w = r6_r;
                r7_w = r7_r;
            end
            3'd4: begin
                r0_w = r0_r;
                r1_w = r1_r;
                r2_w = r2_r;
                r3_w = r3_r;
                r4_w = busW;
                r5_w = r5_r;
                r6_w = r6_r;
                r7_w = r7_r;
            end
            3'd5: begin
                r0_w = r0_r;
                r1_w = r1_r;
                r2_w = r2_r;
                r3_w = r3_r;
                r4_w = r4_r;
                r5_w = busW;
                r6_w = r6_r;
                r7_w = r7_r;
            end
            3'd6: begin
                r0_w = r0_r;
                r1_w = r1_r;
                r2_w = r2_r;
                r3_w = r3_r;
                r4_w = r4_r;
                r5_w = r5_r;
                r6_w = busW;
                r7_w = r7_r;
            end
            3'd7: begin
                r0_w = r0_r;
                r1_w = r1_r;
                r2_w = r2_r;
                r3_w = r3_r;
                r4_w = r4_r;
                r5_w = r5_r;
                r6_w = r6_r;
                r7_w = busW;
            end
            default: begin
                r0_w = r0_r;
                r1_w = r1_r;
                r2_w = r2_r;
                r3_w = r3_r;
                r4_w = r4_r;
                r5_w = r5_r;
                r6_w = r6_r;
                r7_w = r7_r;
            end
        endcase
    end
    else begin
        r0_w = r0_r;
        r1_w = r1_r;
        r2_w = r2_r;
        r3_w = r3_r;
        r4_w = r4_r;
        r5_w = r5_r;
        r6_w = r6_r;
        r7_w = r7_r;
    end

    case(RX)
        3'd0: busX = r0_r;
        3'd1: busX = r1_r;
        3'd2: busX = r2_r;
        3'd3: busX = r3_r;
        3'd4: busX = r4_r;
        3'd5: busX = r5_r;
        3'd6: busX = r6_r;
        3'd7: busX = r7_r;
        default: busX = 0;
    endcase

    case(RY)
        3'd0: busY = r0_r;
        3'd1: busY = r1_r;
        3'd2: busY = r2_r;
        3'd3: busY = r3_r;
        3'd4: busY = r4_r;
        3'd5: busY = r5_r;
        3'd6: busY = r6_r;
        3'd7: busY = r7_r;
        default: busY = 0;
    endcase
end

always@(posedge Clk) begin
    r0_r <= r0_w;
    r1_r <= r1_w;
    r2_r <= r2_w;
    r3_r <= r3_w;
    r4_r <= r4_w;
    r5_r <= r5_w;
    r6_r <= r6_w;
    r7_r <= r7_w;
end	

endmodule