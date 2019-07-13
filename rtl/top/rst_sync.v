//******************************************************************************
//  File    : rst_sync.v
//  Author  : Lyu Yang
//  Date    : 2019-07-12
//  Details :
//******************************************************************************
module rst_sync (
    input       clk     ,
    input       arst_i  ,
    output      srst_o
);

reg     [1:0]   rst_sync;

always @ (posedge clk or posedge arst_i)
    if(arst_i)
        rst_sync <= 2'b11;
    else
        rst_sync <= {rst_sync[0], 1'b0};

assign srst_o = rst_sync[1];

endmodule

