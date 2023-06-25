// Your SingleCycle RISC-V code
module CHIP(clk,
            rst_n,
            // for mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // for mem_I
            mem_addr_I,
            mem_rdata_I
    );

    input         clk, rst_n ;
    // for mem_D
    output        mem_wen_D  ;  // mem_wen_D is high, CHIP writes data to D-mem; else, CHIP reads data from D-mem
    output [31:0] mem_addr_D ;  // the specific address to fetch/store data 
    output [31:0] mem_wdata_D;  // data writing to D-mem 
    input  [31:0] mem_rdata_D;  // data reading from D-mem
    // for mem_I
    output [31:0] mem_addr_I ;  // the fetching address of next instruction
    input  [31:0] mem_rdata_I;  // instruction reading from I-mem

    //PC counter
    reg    [31:0] addr_r;
    wire   [31:0] addr_w,addr_temp;
    wire   [31:0] Jalr_addr;
    wire   [31:0] PC_add4;
    wire   [31:0] Branch_addr;

    //immediate generator
    wire   [31:0] immediate;
    reg    [31:0] immGen;
    
    //Control
    reg           Jalr, Jal, memWrite, aluSrc, regWrite, memRead, Branch, memtoReg;
    reg    [3:0]  Aluop;

    //register file
    wire     [31:0] data_temp;
    wire     [31:0] data_to_reg;
    wire    [4:0]  rs1, rs2, rw;
    wire    [31:0] rdata_2;
   
    //ALU
    reg           zero;
    wire   [31:0] alu_data1,alu_data2;
    reg    [31:0] alu_result;
    wire   [6:0]  opcode;
    wire   [2:0]  funct3;
    wire   [6:0]  funct7;
    
    //assignment
    //next address
    assign PC_add4 = mem_addr_I + 4;
    assign Branch_addr = mem_addr_I + immGen;
    assign Jalr_addr = alu_data1 + immGen;
    assign addr_temp = ((Branch & zero) | Jal) ? Branch_addr : PC_add4;
    assign addr_w = (Jalr == 1) ? Jalr_addr : addr_temp;

    //alu
    assign alu_data2 = (aluSrc == 1) ? immGen : rdata_2;

    //immGen
    assign immediate = {mem_rdata_I[7:0],mem_rdata_I[15:8],mem_rdata_I[23:16],mem_rdata_I[31:24]};
    assign opcode = immediate[6:0];
    assign funct3 = immediate[14:12];
    assign funct7 = immediate[31:25];
    
    //data to reg
    assign data_temp = (memtoReg == 1) ? {mem_rdata_D[7:0],mem_rdata_D[15:8],mem_rdata_D[23:16],mem_rdata_D[31:24]} : alu_result;
    assign data_to_reg = (Jal | Jalr) ? PC_add4 : data_temp;

    //register file
    assign rs1 = immediate[19:15];
    assign rs2 = immediate[24:20];
    assign rw  = immediate[11:7];
    reg_file rf1(.clk(clk),.rst_n(rst_n),.wen(regWrite),.a1(rs1),.a2(rs2),.aw(rw),.d(data_to_reg),.q1(alu_data1),.q2(rdata_2));
    
    //output
    assign mem_wen_D = memWrite;
    assign mem_wdata_D = {rdata_2[7:0],rdata_2[15:8],rdata_2[23:16],rdata_2[31:24]};
    assign mem_addr_D = alu_result;
    assign mem_addr_I = addr_r;

    //immediate generator
    always@ (*) begin
        case(opcode)
            7'b0110011:begin
                //R-type: and add sub or slt
                immGen = 0;
            end
            7'b0000011:begin
                //I-type: lw 
                immGen = {{21{immediate[31]}},immediate[30:25],immediate[24:21],immediate[20]};
            end
            7'b1100111:begin
                //I-type: jalr
                immGen = {{21{immediate[31]}},immediate[30:25],immediate[24:21],immediate[20]};
            end
            7'b0100011:begin
                //S-type: sw 
                immGen = {{21{immediate[31]}},immediate[30:25],immediate[11:8],immediate[7]};
            end
            7'b1100011:begin
                //B-type: beq
                immGen = {{20{immediate[31]}},immediate[7],immediate[30:25],immediate[11:8],1'b0};
            end
            7'b1101111:begin
                //J-type: jal
                immGen = {{12{immediate[31]}},immediate[19:12],immediate[20],immediate[30:25],immediate[24:21],1'b0};
            end
            default:begin
                immGen = 0;
            end
        endcase
    end

    //Control unit but try not to use mux to minimize area
    always@ (*) begin
        Jalr = opcode[6]&opcode[5]&(!opcode[4])&(!opcode[3])&opcode[2]&opcode[1]&opcode[0];
        Jal  = opcode[6]&opcode[5]&(!opcode[4])&opcode[3]&opcode[2]&opcode[1]&opcode[0];
        Branch = opcode[6]&opcode[5]&(!opcode[4])&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0];
        memWrite = (!opcode[6])&opcode[5]&(!opcode[4])&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0];
        memtoReg = (!opcode[6])&(!opcode[5])&(!opcode[4])&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0];
        regWrite = (opcode[6]&opcode[5]&(!opcode[4])&(!opcode[3])&opcode[2]&opcode[1]&opcode[0]) | (opcode[6]&opcode[5]&(!opcode[4])&opcode[3]&opcode[2]&opcode[1]&opcode[0]) | ((!opcode[6])&(!opcode[5])&(!opcode[4])&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0]) | ((!opcode[6])&opcode[5]&opcode[4]&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0]);
        aluSrc = ((!opcode[6])&(!opcode[5])&(!opcode[4])&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0]) | ((!opcode[6])&opcode[5]&(!opcode[4])&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0]);
        memRead = (!opcode[6])&(!opcode[5])&(!opcode[4])&(!opcode[3])&(!opcode[2])&opcode[1]&opcode[0];
    end

    //ALU control
    always@ (*) begin
        Aluop[0] = opcode[4] & funct3[2] & funct3[1] & (!funct3[0]);
        Aluop[1] = !(opcode[4] & (!opcode[3]) & funct3[1]);
        Aluop[2] = ( (!opcode[4]) & (!funct3[1])) | (funct7[5] & opcode[4]);
        Aluop[3] = opcode[4] & (!funct3[2]) & funct3[1];
    end

    //ALU unit
    always@ (*) begin
        zero = 0;
        case(Aluop) 
            4'b0000: begin
                //and
                alu_result = alu_data1 & alu_data2;
            end
            4'b0001: begin
                //or
                alu_result = alu_data1 | alu_data2;
            end
            4'b0010: begin
                //add
                alu_result = alu_data1 + alu_data2;
            end
            4'b0110: begin
                //subtract
                alu_result = alu_data1 - alu_data2;
                zero = !alu_result;
            end
            4'b1000: begin
                //slt
                alu_result = ($signed(alu_data1) < $signed(alu_data2)) ? 1 : 0 ;
            end
            default: alu_result = 0;
        endcase
    end

    always@(posedge clk) begin
        if(!rst_n) begin
            addr_r <= 0;
        end
        else begin
            addr_r <= addr_w;
        end
    end
    
endmodule

module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);

    // constants
    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth

    input clk, rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a1, a2, aw;

    output [BITS-1:0] q1, q2;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (aw == i)) ? d : mem[i];
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            mem[0] <= 32'b0;
            for (i=1; i<word_depth; i=i+1) begin
                mem[i] <= 32'h0;
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end
    end

endmodule
