//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

module alu_always_tb2;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;
    
    alu_always alu_always(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

    initial begin
        $fsdbDumpfile("alu_always.fsdb");
        $fsdbDumpvars();
    end

    integer err;
    integer err_count;

    initial begin
        err = 0;
        err_count = 0;

        #(`CYCLE);
        ctrl = 4'b0000;
        x    = 8'b11111110;
        y    = 8'b00000001;

        #(`HCYCLE);
        if( out != 8'b11111111 || carry != 1) err = err + 1;
        x    = 8'b00000001;

        #(`HCYCLE);
        if( out != 8'd2 || carry != 0) err = err + 1;
        x    = 8'b10001000;
        y    = 8'b10001000;

        #(`HCYCLE);
        if( out != 8'b00010000 || carry != 1) err = err + 1;
        if ( err == 0 ) $display( "PASS --- 0000 ADD");
        else begin
            $display( "FAIL --- 0000 ADD");
            err_count  = err_count + 1;
        end
        err = 0;

        #(`CYCLE);
        ctrl = 4'b0001;
        x    = 8'b11111110;
        y    = 8'b00000001;

        #(`HCYCLE);
        if( out != 8'b11111101 || carry != 1) err = err + 1;
        x    = 8'b00000010;

        #(`HCYCLE);
        if( out != 8'd1 || carry != 0) err = err + 1;
        x    = 8'b10001000;
        y    = 8'b10000111;

        #(`HCYCLE);
        if( out != 8'b00000001 || carry != 0) err = err + 1;
        x    = 8'd1;

        #(`HCYCLE);
        if( out != 8'b01111010 || carry != 0) err = err + 1;
        if ( err == 0 ) $display( "PASS --- 0001 Sub");
        else begin 
            $display("%d",err);
            $display( "FAIL --- 0001 Sub");
            err_count  = err_count + 1;
        end
        err = 0;

        #(`CYCLE);
        // 0010 and
        ctrl = 4'b0010;
        x    = 8'b10101010;
        y    = 8'b10011000;
        
        #(`HCYCLE);
        if( out == 8'b10001000 && carry == 0 ) $display( "PASS --- 0010 and" );
        else begin
            $display( "FAIL --- 0010 and" );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        // 0011 or
        ctrl = 4'b0011;
        
        #(`HCYCLE);
        if( out == 8'b10111010 && carry == 0) $display( "PASS --- 0011 or" );
        else begin
            $display( "FAIL --- 0011 or" );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        // 0100 boolean not
        ctrl = 4'b0100;
        x    = 8'd0;
        y    = 8'd0;
        
        #(`HCYCLE);
        if( out == 8'b1111_1111 && carry == 0) $display( "PASS --- 0100 boolean not" );
        else begin 
            $display( "FAIL --- 0100 boolean not" );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        // 0101 Xor
        ctrl = 4'b0101;
        x    = 8'b10101010;
        y    = 8'b10011000;
        
        #(`HCYCLE);
        if( out == 8'b00110010 && carry == 0) $display( "PASS --- 0101 Xor" );
        else begin 
            $display( "FAIL --- 0101 Xor" );
            err_count  = err_count + 1;
        end
        
        #(`CYCLE);
        // 0110 Nor
        ctrl = 4'b0110;
        
        #(`HCYCLE);
        if( out == 8'b01000101 && carry == 0) $display( "PASS --- 0110 Nor" );
        else  begin
            $display( "FAIL --- 0110 Nor" );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        // 0111 Shift left logical variable
        ctrl = 4'b0111;
        
        #(`HCYCLE);
        if( out == 8'b01100000 && carry == 0) $display( "PASS --- 0111 Shift left logical variable" );
        else begin 
            $display( "FAIL --- 0111 Shift left logical variable" );
        end

        #(`CYCLE);
        // 1000 Shift right logical variable
        ctrl = 4'b1000;
        
        #(`HCYCLE);
        if( out == 8'b00100110 && carry == 0) $display( "PASS --- 1000 Shift right logical variable" );
        else begin
            $display( "FAIL --- 1000 Shift right logical variable" );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        // 1001 Shift right arithmetic
        ctrl = 4'b1001;
        
        #(`HCYCLE);
        if( out == 8'b11010101 && carry == 0) $display( "PASS --- 1001 Shift right arithmetic" );
        else begin
            $display( "FAIL --- 1001 Shift right arithmetic" );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        // 1010 Rotate left
        ctrl = 4'b1010;
        
        #(`HCYCLE);
        if( out == 8'b01010101 && carry == 0) $display( "PASS --- 1010 Rotate left " );
        else begin 
            $display( "FAIL --- 1010 Rotate left " );
            err_count  = err_count + 1;
        end
        
        #(`CYCLE);
        // 1011 Rotate right
        ctrl = 4'b1011;
        
        #(`HCYCLE);
        if( out == 8'b01010101 && carry == 0) $display( "PASS --- 1011 Rotate right " );
        else begin 
            $display( "FAIL --- 1011 Rotate right " );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        // 1100 Equal
        ctrl = 4'b1100;
        
        #(`HCYCLE);
        if( out != 0 || carry != 0) err = err + 1;
        y = 8'b10101010;

        #(`HCYCLE);
        if( out != 1 || carry != 0) err = err + 1;
        if(err == 0) $display( "PASS --- 1100 Equal ");
        else  begin
            $display( "FAIL --- 1100 Equal ");
            err_count  = err_count + 1;
        end
        err = 0;

        #(`CYCLE);
        ctrl = 4'b1101;
        
        #(`HCYCLE);
        if( out == 0 && carry == 0) $display( "PASS --- NOP " );
        else begin 
            $display( "FAIL --- NOP " );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        ctrl = 4'b1110;
        
        #(`HCYCLE);
        if( out == 0 && carry == 0) $display( "PASS --- NOP " );
        else begin 
            $display( "FAIL --- NOP " );
            err_count  = err_count + 1;
        end

        #(`CYCLE);
        ctrl = 4'b1111;
        
        #(`HCYCLE);
        if( out == 0 && carry == 0) $display( "PASS --- NOP " );
        else begin 
            $display( "FAIL --- NOP " );
            err_count  = err_count + 1;
        end

       
        if(err_count == 0) $display("Congratulation! You pass!! . \n");
        else begin 
            $display("Fail! You should check your design! \n");
        end

        #(`CYCLE) $finish;
    end

endmodule
