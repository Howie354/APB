module apb_slave #(
    parameter DATA_WD = 8,
    parameter ADDR_WD = 8 
) (
    input                    clk,
    input                    rst_n,
    input                    psel,
    input                    penable,
    input                    pwrite,
    input  [ADDR_WD - 1 : 0] paddr,
    input  [DATA_WD - 1 : 0] pwdata,
    output [DATA_WD - 1 : 0] prdata,
    output                   pready
);

localparam ADDR_MAX = (1 << ADDR_WD);

reg [DATA_WD - 1 : 0] mem [ADDR_MAX - 1 : 0];

localparam [1:0] IDLE = 2'b00;
localparam [1:0] SETUP = 2'b01;
localparam [1:0] ACCESS = 2'b11; 

reg [1:0] state,next_state;

// assign pready = 1'b1;
//control path
wire apb_fire;
assign apb_fire = psel && penable && pready;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state) 
        IDLE: begin
            if(psel) begin
                next_state = SETUP;
            end
            else begin
                next_state = IDLE;
            end
        end
        SETUP: begin
            next_state = ACCESS;
        end
        ACCESS: begin
            if(!pready) begin
                next_state = ACCESS;
            end
            else if(psel) begin
                next_state = SETUP;
            end
            else begin
                next_state = IDLE;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

reg r_pready;
assign pready = r_pready;
always @(*) begin
    case(state)
        IDLE: begin
            r_pready = 1'b0;            
        end 
        SETUP: begin
            r_pready = 1'b0;            
        end
        ACCESS: begin
            if(psel && penable) begin
                r_pready = 1'b1;
            end
            else begin
                r_pready = 1'b0;
            end
        end
        default: begin
        end
    endcase
end

//data path

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    end
    else if(apb_fire) begin
        mem[paddr] <= pwdata;
    end
end

assign prdata = mem[paddr];

endmodule