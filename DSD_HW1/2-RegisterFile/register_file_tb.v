`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5
`define PATTERN_NUM 100

module register_file_tb;
    // port declaration for design-under-test
    reg Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;
    
    // instantiate the design-under-test
    register_file rf(
        Clk  ,
        WEN  ,
        RW   ,
        busW ,
        RX   ,
        RY   ,
        busX ,
        busY
    );

    // write your test pattern here
    // waveform dump
    initial begin
       $fsdbDumpfile("register_file.fsdb");
       $fsdbDumpvars(0,rf,"+mda");
    end

    always begin 
        #(`HCYCLE) Clk = ~Clk;
    end

    integer i;
    integer count;
    integer err_count;
    reg stop;
    reg [7:0] input_pattern [0:500];
    reg [7:0] output_pattern [0:200];

    initial begin
        $readmemb("input.pattern",input_pattern);
        $readmemb("output_golden.pattern",output_pattern);
        Clk = 0;
        count = 0;
        err_count = 0;
        stop = 0;
        RX = 0;
        RY = 0;
        RW = 0;
        WEN = 0;
        busW = 0;

        for(i=0;i<500;i=i+5)begin
            #(0.3*`CYCLE) begin
                RX = input_pattern[i][2:0];
                RY = input_pattern[i+1][2:0];
                RW = input_pattern[i+2][2:0];
                WEN = input_pattern[i+3][0];
                busW = input_pattern[i+4][7:0];
            end
            #(0.2*`CYCLE);
            #(`HCYCLE);
        end
    end

    always@(posedge Clk) begin
        #(0.2*`CYCLE);

        if(busX != output_pattern[2*(i/5)][7:0]) begin
            err_count = err_count + 1;
            $display("Wrong!");
            $display("Answer should be: %d", output_pattern[2*(i/5)][7:0]);
            $display("Your busX: %d", busX);
            $display("\n");
        end
        else begin
            $display("Correct!");
            $display("\n");
        end

        if(busY != output_pattern[2*(i/5) + 1][7:0]) begin
            err_count = err_count + 1;
            $display("Wrong!");
            $display("Answer should be: %d", output_pattern[2*(i/5) + 1][7:0]);
            $display("Your busY: %d", busY);
            $display("\n");
        end
        else begin
            $display("Correct!");
            $display("\n");
        end
    end
   
    always@(posedge Clk) begin
        count <= count + 1;
        if(count >= (`PATTERN_NUM))
            stop <= 1;
    end

    always@(posedge stop)begin
        if(err_count == 0) begin
            $display("==========================================\n");
            $display("======  Congratulation! You Pass!  =======\n");
            $display("==========================================\n");
        end
        else begin
            $display("===============================\n");
            $display("There are %d errors.", err_count);
            $display("===============================\n");
        end
        $finish;
    end

endmodule
