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
    // valid, dirty, tag(26bits), data(32x4 bits)
    reg [155:0] data_r[0:7];   
    reg [155:0] data_w[0:7];
    wire [25:0] tag_i;
    wire [1:0]  index_i;
    wire [2:0]  index_even,index_odd;
    wire [1:0]  offset_i;
    wire valid_i_1, valid_i_2;
    wire dirty_i_1, dirty_i_2;
    wire hit_i_1,   hit_i_2;

    //LRU 
    reg [3:0] lru;
    reg [3:0] lru_next;
    reg [2:0] index_next_r,index_next_w;

//==== combinational circuit ==============================
    assign tag_i = proc_addr[29:4];
    assign index_i = proc_addr[3:2];
    assign offset_i = proc_addr[1:0];
    assign index_even = index_i << 1;
    assign index_odd = index_even + 1'b1;

    assign valid_i_1 = data_r[index_even][155];
    assign valid_i_2 = data_r[index_odd][155];
    assign dirty_i_1 = data_r[index_even][154];
    assign dirty_i_2 = data_r[index_odd][154];
    assign hit_i_1 = (data_r[index_even][153:128] == tag_i && valid_i_1); 
    assign hit_i_2 = (data_r[index_odd][153:128] == tag_i && valid_i_2); 

    always@ (*) begin
        case(state_r) 
            COMPARE: state_w = (!(proc_read ^ proc_write) || (hit_i_1)||(hit_i_2)) ? COMPARE : ((dirty_i_1)||(dirty_i_2)) ? WRITE_BACK : ALLOCATE;
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
                if((proc_read ^ proc_write) && !hit_i_1 && !hit_i_2)
                    proc_stall = 1;
            end
            WRITE_BACK: begin
                mem_write = !mem_ready;
                proc_stall = 1;

                if(dirty_i_1 && !lru[index_i]) begin
                    mem_wdata = data_r[index_even][127:0];
                    mem_addr = {data_r[index_even][153:128],index_i};
                end
                else if(dirty_i_2 && lru[index_i]) begin
                    mem_wdata = data_r[index_odd][127:0];
                    mem_addr = {data_r[index_odd][153:128],index_i};
                end
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
        lru_next = lru;
        index_next_w = index_next_r;

        if(state_r == COMPARE) begin
            if(proc_read) begin
                if((hit_i_1)) begin
                    case(offset_i)
                        2'b00: proc_rdata = data_r[index_even][31:0];
                        2'b01: proc_rdata = data_r[index_even][63:32];
                        2'b10: proc_rdata = data_r[index_even][95:64];
                        2'b11: proc_rdata = data_r[index_even][127:96];
                    endcase
                end 
                else if(hit_i_2) begin
                    case(offset_i)
                        2'b00: proc_rdata = data_r[index_odd][31:0];
                        2'b01: proc_rdata = data_r[index_odd][63:32];
                        2'b10: proc_rdata = data_r[index_odd][95:64];
                        2'b11: proc_rdata = data_r[index_odd][127:96];
                    endcase
                end
            end
            else if(proc_write) begin
                if((hit_i_1)) begin
                    case(offset_i)
                        2'b00: data_w[index_even] = {2'b11,data_r[index_even][153:128],data_r[index_even][127:32],proc_wdata};
                        2'b01: data_w[index_even] = {2'b11,data_r[index_even][153:128],data_r[index_even][127:64],proc_wdata,data_r[index_even][31:0]};
                        2'b10: data_w[index_even] = {2'b11,data_r[index_even][153:128],data_r[index_even][127:96],proc_wdata,data_r[index_even][63:0]};
                        2'b11: data_w[index_even] = {2'b11,data_r[index_even][153:128],proc_wdata,data_r[index_even][95:0]};
                    endcase
                end  
                else if((hit_i_2)) begin
                    case(offset_i)
                        2'b00: data_w[index_odd] = {2'b11,data_r[index_odd][153:128],data_r[index_odd][127:32],proc_wdata};
                        2'b01: data_w[index_odd] = {2'b11,data_r[index_odd][153:128],data_r[index_odd][127:64],proc_wdata,data_r[index_odd][31:0]};
                        2'b10: data_w[index_odd] = {2'b11,data_r[index_odd][153:128],data_r[index_odd][127:96],proc_wdata,data_r[index_odd][63:0]};
                        2'b11: data_w[index_odd] = {2'b11,data_r[index_odd][153:128],proc_wdata,data_r[index_odd][95:0]};
                    endcase
                end  
            end
        end
        else if (state_r == ALLOCATE) begin
            if(mem_ready) begin
                data_w[index_next_r] = {2'b10,proc_addr[29:4],mem_rdata};

                case(index_i)
                    2'b00: begin
                        if(lru[0]) lru_next[0] = 0;
                        else       lru_next[0] = 1;
                    end
                    2'b01: begin
                        if(lru[1]) lru_next[1] = 0;
                        else       lru_next[1] = 1;
                    end
                    2'b10: begin
                        if(lru[2]) lru_next[2] = 0;
                        else       lru_next[2] = 1;
                    end
                    2'b11: begin
                        if(lru[3]) lru_next[3] = 0;
                        else       lru_next[3] = 1;
                    end
                    default: lru_next = lru;
                endcase    
            end
            else begin
                case(index_i) 
                    2'b00: index_next_w = (lru[0]) ? 3'b000 : 3'b001;
                    2'b01: index_next_w = (lru[1]) ? 3'b010 : 3'b011;
                    2'b10: index_next_w = (lru[2]) ? 3'b100 : 3'b101;
                    2'b11: index_next_w = (lru[3]) ? 3'b110 : 3'b111;
                    default : index_next_w = index_next_r;
                endcase
            end
        end
    end

//==== sequential circuit =================================
    always@( posedge clk ) begin
        if( proc_reset ) begin
            state_r <= COMPARE;
            lru <= 0;
            index_next_r <= 0;
            
            for(i=0;i<8;i=i+1) begin
                data_r[i] <= 0;
            end
        end
        else begin
            state_r <= state_w;
            lru <= lru_next;
            index_next_r <= index_next_w;

            for(i=0;i<8;i=i+1) begin
                data_r[i] <= data_w[i];
            end
        end
    end

endmodule

