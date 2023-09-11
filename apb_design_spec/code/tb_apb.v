module tb_apb();

localparam DATA_WD = 4;
localparam ADDR_WD = 4;
localparam HALF_CYCLE = 5;

reg                         clk;
reg                         rst_n;
reg [DATA_WD + ADDR_WD : 0] cmd_in;
reg                         cmd_vld;
wire                        cmd_rdy;
wire                        read_vld;
wire [DATA_WD - 1 : 0]      read_data;


apb_top #(
       .DATA_WD(DATA_WD),
       .ADDR_WD(ADDR_WD)
     )u_apb_top (
       .clk(clk),
       .rst_n(rst_n),
       .cmd_in(cmd_in),
       .cmd_vld(cmd_vld),
       .cmd_rdy(cmd_rdy),
       .read_vld(read_vld),
       .read_data(read_data)
     );


reg [ADDR_WD : 0] addr_cnt;

wire cmd_fire;
assign cmd_fire = cmd_vld && cmd_rdy;

wire                   write;
wire [ADDR_WD - 1 : 0] cmd_data;
wire [ADDR_WD - 1 : 0] cmd_addr;

assign write = !addr_cnt[ADDR_WD];
assign cmd_data = addr_cnt[ADDR_WD - 1 : 0];
assign cmd_addr = addr_cnt[ADDR_WD - 1 : 0];

initial begin
    clk = 0;
    forever #HALF_CYCLE clk = ~clk;
end

initial begin
     rst_n = 0;
     #50
     rst_n = 1;
     #1950 $finish();
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_cnt <= 'b0;
    end
    else if(cmd_fire) begin
        addr_cnt <= addr_cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cmd_vld <= 'b0;
        cmd_in <= 'b0;
    end
    else begin
        cmd_vld <= 1'b1;
        cmd_in <= {write,cmd_addr,cmd_data};
    end
end

initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

endmodule