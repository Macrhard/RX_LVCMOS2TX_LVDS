// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    ad80305_tx_if 
// Project Name: 
// Target Devices: 
// Tool versions:
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ad80305_tx_if_ddr_lvcmos_31p25(
    input              i_fpga_clk      ,
    input	           i_fpga_rst      ,    
    input              i_tx_iqdata_fp  ,
    input [11:0]       i_tx_idata      ,
    input [11:0]       i_tx_qdata      ,   
    input              i_tx_clk        , 
    output             o_tx_clk        ,
    output             o_tx_frame      ,
    output  [11:0]     o_tx_data
    );

reg [11:0] cos_data,sin_data ;
always @ (posedge i_fpga_clk) cos_data  <= i_tx_qdata ;   //i_tx_idata ;
always @ (posedge i_fpga_clk) sin_data  <= i_tx_idata ;   //i_tx_qdata ; 

reg cos_data_fp;
always @ (posedge i_fpga_clk or negedge i_fpga_rst)
begin
	if(!i_fpga_rst)
		cos_data_fp <= 1'b0;
	else
		cos_data_fp <= i_tx_iqdata_fp;
end

wire [23:0] w_dac_data;
assign w_dac_data = {cos_data,sin_data};

reg [1:0] cnt_4;
always@(posedge i_fpga_clk or negedge i_fpga_rst)
begin
	if(!i_fpga_rst)
		cnt_4 <= 2'd0;
	else if(cnt_4 == 2'd3)
		cnt_4 <= 2'd0;
	else
		cnt_4 <= cnt_4 + 2'd1;
end

reg r_wr_en;
always@(posedge i_fpga_clk or negedge i_fpga_rst)
begin
	if(!i_fpga_rst)
		r_wr_en <= 1'b0;
	else if(&cnt_4)
		r_wr_en <= 1'b1;
	else
		r_wr_en <= 1'b0;
end


wire rdempty;
wire wrfull;

	reg r_wr_en1;

always@(posedge i_fpga_clk or negedge i_fpga_rst )
    if (!i_fpga_rst ) 
        r_wr_en1 <= 1'b0;
    else if(wrfull == 1'b1 ) 
        r_wr_en1 <= 1'b0 ; 
    else
        r_wr_en1 <= r_wr_en;

		
wire [23:0] w_adc_iqdata; 
dac_conver_fifo udac_conver_fifo (
	.aclr	 (!i_fpga_rst   ),
	.data	 (w_dac_data	),
	.rdclk	 (i_tx_clk 		),
	.rdreq	 (1'b1		 	),
	.wrclk	 (i_fpga_clk	),
	.wrreq	 (r_wr_en1		),
	.q		 (w_adc_iqdata	),
	.rdempty (rdempty		),
	.wrfull  (wrfull		)
	);

wire [13:0] data_out;        
ad80305_oddr ad80305_oddr_inst(
	.datain_h       ({2'b11,w_adc_iqdata[11:0]}     ),            
	.datain_l       ({2'b00,w_adc_iqdata[23:12]}    ),           
	.outclock       ( i_tx_clk              		),
	.dataout        ( data_out              		)
	);   
	
    assign o_tx_clk   = data_out[13];
    assign o_tx_frame = data_out[12];
    assign o_tx_data  = data_out[11:0];	         

endmodule 