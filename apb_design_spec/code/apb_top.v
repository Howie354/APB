module apb_top #(
    parameter DATA_WD = 8,
    parameter ADDR_WD = 8 
) (
    input                         clk,
    input                         rst_n,
    input [DATA_WD + ADDR_WD : 0] cmd_in,
    input                         cmd_vld,
    output                        cmd_rdy,
    output                        read_vld,
    output [DATA_WD - 1 : 0]      read_data
);

    wire psel,penable,pwrite,pready;
    wire [DATA_WD - 1 : 0] pwdata;
    wire [ADDR_WD - 1 : 0] paddr;
    wire [DATA_WD - 1 : 0] prdata;

   apb_master  #(
              .DATA_WD(DATA_WD),
              .ADDR_WD(ADDR_WD)
            )u_apb_master(
              .clk(clk),
              .rst_n(rst_n),
              .cmd_in(cmd_in),
              .cmd_vld(cmd_vld),
              .prdata(prdata),
              .pready(pready),
              .cmd_rdy(cmd_rdy),
              .psel(psel),
              .penable(penable),
              .pwrite(pwrite),
              .paddr(paddr),
              .pwdata(pwdata),
              .read_vld(read_vld),
              .read_data(read_data)
            );

   apb_slave  #(
             .DATA_WD(DATA_WD),
             .ADDR_WD(ADDR_WD)
           )u_apb_slave(
             .clk(clk),
             .rst_n(rst_n),
             .psel(psel),
             .penable(penable),
             .pwrite(pwrite),
             .paddr(paddr),
             .pwdata(pwdata),
             .prdata(prdata),
             .pready(pready)
           );

                          
endmodule
