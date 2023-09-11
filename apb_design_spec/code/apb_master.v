module apb_master #(
    parameter DATA_WD = 8,
    parameter ADDR_WD = 8
) (
    input                         clk,
    input                         rst_n,
    input [DATA_WD + ADDR_WD : 0] cmd_in,
    input                         cmd_vld,
    input [DATA_WD - 1 : 0]       prdata,
    input                         pready,
    output                        cmd_rdy,
    output                        psel,
    output                        penable,
    output                        pwrite,
    output [ADDR_WD - 1 : 0]      paddr,
    output [DATA_WD - 1 : 0]      pwdata,
    output                        read_vld,
    output [DATA_WD - 1 : 0]      read_data
);

//----------------------------tx----------------------------------------------

localparam [1:0] IDLE = 2'b00;
localparam [1:0] SETUP = 2'b01;
localparam [1:0] ACCESS = 2'b11;

reg [1:0] state,next_state;

reg r_psel,r_penable;
assign psel = r_psel;
assign penable = r_penable;

reg [DATA_WD + ADDR_WD : 0] r_cmd_in;

//control path
wire cmd_fire;
assign cmd_fire = cmd_vld && cmd_rdy;
assign cmd_rdy = state == IDLE;

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
            if(cmd_fire) begin
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
            if(pready) begin
                next_state = IDLE;
            end
            else begin
                next_state = ACCESS;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(*) begin
    r_psel = 'b0;
    r_penable = 'b0;
    case(state)
        IDLE: begin
        end
        SETUP: begin
            r_psel = 1'b1;
        end
        ACCESS: begin
            r_psel = 1'b1;
            r_penable = 1'b1;
        end
        default: begin
        end
    endcase
end


//data path
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_cmd_in <= 'b0;
    end
    else if(cmd_fire) begin
        r_cmd_in <= cmd_in;
    end
end

assign paddr  = r_cmd_in[DATA_WD + ADDR_WD - 1 : DATA_WD];
assign pwdata = r_cmd_in[DATA_WD - 1 : 0];
assign pwrite = r_cmd_in[DATA_WD + ADDR_WD];

//---------------------------------------------rx----------------------------------

assign read_data = prdata;
assign read_vld = ~pwrite && pready;

endmodule