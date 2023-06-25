module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output reg     proc_stall;
    output reg [31:0] proc_rdata;
    // memory interface
    input  [127:0]     mem_rdata;
    input              mem_ready;
    output reg         mem_read, mem_write;
    output reg [27:0]  mem_addr;
    output reg [127:0] mem_wdata;
    
//==== wire/reg definition ================================
    parameter COMPARE = 0;
    parameter ALLOCATE = 1;
    parameter WRITE_BACK = 2;
    
    integer i;
    reg [1:0]   state_r,state_w;
    // valid, dirty, tag(25bits), data(32x4 bits)
    reg [154:0] data_r[0:7];   
    reg [154:0] data_w[0:7];
    wire [24:0] tag_i;
    wire [2:0]  index_i;
    wire [1:0]  offset_i;
    wire valid_i, dirty_i;
    wire hit_i;

//==== combinational circuit ==============================
    assign tag_i = proc_addr[29:5];
    assign index_i = proc_addr[4:2];
    assign offset_i = proc_addr[1:0];
    assign valid_i = data_r[index_i][154];
    assign dirty_i = data_r[index_i][153];
    assign hit_i = (data_r[index_i][152:128] == tag_i && valid_i); //when invalid or different tag

    always@ (*) begin
        case(state_r) 
            COMPARE: state_w = (!(proc_read ^ proc_write)) || (hit_i) ? COMPARE : (dirty_i) ? WRITE_BACK : ALLOCATE;
            ALLOCATE: state_w = (mem_ready) ? COMPARE : ALLOCATE;
            WRITE_BACK: state_w = (mem_ready) ? ALLOCATE : WRITE_BACK;
            default: state_w = state_r;
        endcase
    end

    always@ (*) begin
        proc_stall = 0;
        mem_read = 0;
        mem_write = 0;
        mem_addr = 0;
        mem_wdata = 0;

        case(state_r)
            COMPARE: begin
                if((proc_read ^ proc_write) && !hit_i)
                    proc_stall = 1;
            end
            WRITE_BACK: begin
                mem_write = !mem_ready;
                proc_stall = 1;
                mem_addr = {data_r[index_i][152:128],index_i};
                mem_wdata = data_r[index_i][127:0];
            end
            ALLOCATE: begin
                mem_read = !mem_ready;
                proc_stall = 1;
                mem_addr = proc_addr[29:2];
            end
        endcase
    end

    always@ (*) begin
        for(i=0;i<8;i=i+1) begin
            data_w[i] = data_r[i];
        end
        proc_rdata = 0;

        if(state_r == COMPARE) begin
            if(hit_i && proc_write && !proc_read) begin
                case(offset_i)
                    2'b00: data_w[index_i] = {2'b11,data_r[index_i][152:128],data_r[index_i][127:32],proc_wdata};
                    2'b01: data_w[index_i] = {2'b11,data_r[index_i][152:128],data_r[index_i][127:64],proc_wdata,data_r[index_i][31:0]};
                    2'b10: data_w[index_i] = {2'b11,data_r[index_i][152:128],data_r[index_i][127:96],proc_wdata,data_r[index_i][63:0]};
                    2'b11: data_w[index_i] = {2'b11,data_r[index_i][152:128],proc_wdata,data_r[index_i][95:0]};
                endcase
            end    
            else if(hit_i && !proc_write && proc_read) begin
                case(offset_i)
                    2'b00: proc_rdata = data_r[index_i][31:0];
                    2'b01: proc_rdata = data_r[index_i][63:32];
                    2'b10: proc_rdata = data_r[index_i][95:64];
                    2'b11: proc_rdata = data_r[index_i][127:96];
                endcase
            end
        end
        else if (state_r == ALLOCATE) begin
            if(mem_ready)
                data_w[index_i] = {2'b10,proc_addr[29:5],mem_rdata};
        end
    end

//==== sequential circuit =================================
    always@( posedge clk ) begin
        if( proc_reset ) begin
            state_r <= COMPARE;
            for(i=0;i<8;i=i+1) begin
                data_r[i] <= 0;
            end
        end
        else begin
            state_r <= state_w;
            for(i=0;i<8;i=i+1) begin
                data_r[i] <= data_w[i];
            end
        end
    end

endmodule
