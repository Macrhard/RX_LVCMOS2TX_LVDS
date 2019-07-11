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
module ad80305_tx_if_ddr_dcs(
    input              i_fpga_clk               ,
    input	           i_fpga_rst               ,
    input			   i_tx_clk					,//fpga_62p5    
    input              i_tx_iqdata_fp           ,
    input [11:0]       i_tx_idata               ,
    input [11:0]       i_tx_qdata               ,    
    output             o_tx_clk                 ,
    output             o_tx_frame               ,
    output  [5:0]      o_tx_data
    );

//--1.时钟域转换到tx时钟域

wire [23:0] w_dac_data;
assign w_dac_data = {i_tx_qdata,i_tx_idata};

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

reg r_rd_en;
always @ (posedge i_tx_clk or negedge i_fpga_rst)
	if(!i_fpga_rst)
		r_rd_en <= 1'b0;
	else
		r_rd_en <= ~r_rd_en;

wire rdempty;
wire wrfull;

	reg r_wr_en1;
	reg r_rd_en1;

always@(posedge i_fpga_clk or negedge i_fpga_rst )
    if (!i_fpga_rst ) 
        r_wr_en1 <= 1'b0;
    else if(wrfull == 1'b1 ) 
        r_wr_en1 <= 1'b0 ; 
    else
        r_wr_en1 <= r_wr_en;

always@(posedge i_tx_clk or negedge i_fpga_rst )
    if (!i_fpga_rst ) 
        r_rd_en1 <= 1'b0;
    else if(rdempty == 1'b1 ) 
        r_rd_en1 <= 1'b0 ;
    else
        r_rd_en1 <= r_rd_en;

wire [23:0] w_adc_iqdata;
dac_conver_fifo udac_conver_fifo (
	.aclr	 (!i_fpga_rst   ),
	.data	(w_dac_data	 	),
	.rdclk	(i_tx_clk 		),
	.rdreq	(r_rd_en1		),
	.wrclk	(i_fpga_clk		),
	.wrreq	(r_wr_en1		),
	.q		(w_adc_iqdata	),
	.rdempty (rdempty		),
	.wrfull  (wrfull		)
	);
reg [6:0] idata_bit7;
reg [6:0] qdata_bit7;
always @ (posedge i_tx_clk or negedge i_fpga_rst)
begin
	if(!i_fpga_rst)
		begin
			idata_bit7 <= 7'd0;
			qdata_bit7 <= 7'd0;
		end
	else if(r_rd_en1 == 1'b0)
		begin
			idata_bit7 <= {1'b1,w_adc_iqdata[11:6]};
			qdata_bit7 <= {1'b1,w_adc_iqdata[23:18]};
		end
	else
		begin
			idata_bit7 <= {1'b0,w_adc_iqdata[5:0]};
			qdata_bit7 <= {1'b0,w_adc_iqdata[17:12]};		
		end
end


//暂时用于测试
wire [7:0] w_outdata;        
dac_ddio_out u0_dac_ddio_out(
	.datain_h	({1'b0,idata_bit7}			),
	.datain_l	({1'b1,qdata_bit7}			),
	.outclock	(i_tx_clk					),
	.dataout 	(w_outdata					)
	);      

assign  o_tx_clk   = w_outdata[7]  ;
assign  o_tx_frame = w_outdata[6]  ;
assign  o_tx_data  = w_outdata[5:0];

endmodule 