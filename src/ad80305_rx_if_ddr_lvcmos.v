`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: comba
// Engineer: 
// 
// Create Date:     
// Design Name: 
// Module Name:    ad80305_rx_if 
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
module ad80305_rx_if_ddr_lvcmos(
    input               i_rx_clk                ,
    input               i_rx_frame              ,
    input   [11:0]      i_rx_data               ,
    input               i_fpga_clk_125p         ,
    input               i_fpga_rst_125p         ,
    output              o_iqdata_fp             ,
    output  [11:0]      o_idata                 ,
    output  [11:0]      o_qdata
    );

//--1,IDDR 输入
wire [12:0] w_adc_data;
assign w_adc_data = {i_rx_frame,i_rx_data};
    
wire [12:0] dataout_h; 
wire [12:0] dataout_l; 
        
ad80305_iddr ad80305_iddr_inst(
	.aclr           ( 1'b0      ),
	.datain         ( w_adc_data),
	.inclock        ( i_rx_clk  ),
	.dataout_h      ( dataout_h ),
	.dataout_l      ( dataout_l )
	);
	

reg [11:0] dataout_i;
reg [11:0] dataout_q;
always @ (posedge i_rx_clk)
begin
	if(dataout_h[12] == 1'b1)
        begin
        	dataout_i <= dataout_h[11:0];    
        	dataout_q <= dataout_l[11:0];
        end
    else
    	begin
        	dataout_i <= dataout_l[11:0];    
        	dataout_q <= dataout_h[11:0];    		
    	end
end



//--2,时钟域转换到FPGA时钟域


reg [3:0]	r_wr_addr;
always @ (posedge i_rx_clk or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_wr_addr <= 4'd0;
	else
		r_wr_addr <= r_wr_addr + 4'd1;
end

reg r_wr_en0 ;
always@(posedge i_rx_clk or negedge i_fpga_rst_125p)
	if(!i_fpga_rst_125p)
		r_wr_en0 <=1'd0;
	else if(r_wr_addr==3'd6 )
		r_wr_en0 <= 1'b1 ;
	else
		r_wr_en0 <=r_wr_en0;

reg r_rd_en;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_rd_en <= 1'b0;
	else
		r_rd_en <= !r_rd_en;
end

reg [3:0] r_rd_addr;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_rd_addr <= 4'd0;
	else if(!r_wr_en0)
		r_rd_addr <= 4'd0;
	else if(r_rd_en == 1'b1 && r_wr_en0)
		r_rd_addr <= r_rd_addr+4'd1;
	else
		r_rd_addr <= r_rd_addr;
end

/*wire [23:0] w_adc_iqdata;
ad_dpram_inf #(
  .BRAM_WIDTH (24),
  .BRAM_DEPTH (16),
  .ADDR_WIDTH (4 )
)u_ad_dpram_inf(
	.i_wr_clk (i_rx_clk		 			),
	.i_wr_en  (1'b1			 			),
	.i_wr_addr(r_wr_addr 				),
	.i_wr_data({dataout_q,dataout_i} 	),
	                    
	.i_rd_clk (i_fpga_clk_125p			),
	.i_rd_en  (1'b1      				),	
	.i_rd_addr(r_rd_addr 				),
	.o_rd_data(w_adc_iqdata 				)		
);*/

wire rdempty;
wire wrfull;

	reg r_wr_en1;
	reg r_rd_en1;

always@(posedge i_rx_clk or negedge i_fpga_rst_125p )
    if (!i_fpga_rst_125p ) 
        r_wr_en1 <= 1'b0;
    else if(wrfull == 1'b1 ) 
        r_wr_en1 <= 1'b0 ; 
    else
        r_wr_en1 <= 1'b1;

always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p )
    if (!i_fpga_rst_125p ) 
        r_rd_en1 <= 1'b0;
    else if(rdempty == 1'b1 ) 
        r_rd_en1 <= 1'b0 ;
    else
        r_rd_en1 <= r_rd_en;

wire [23:0] w_adc_iqdata;
dac_conver_fifo udac_conver_fifo (
	.aclr	 (!i_fpga_rst_125p   ),
	.data	 ({dataout_q,dataout_i}),
	.rdclk	 (i_fpga_clk_125p),
	.rdreq	 (r_rd_en1		),
	.wrclk	 (i_rx_clk     ),
	.wrreq	 (r_wr_en1		),
	.q		 (w_adc_iqdata	),
	.rdempty (rdempty		),
	.wrfull  (wrfull		)
	);

reg 		w_iqdata_fp;
reg [11:0] w_idata    ;
reg [11:0] w_qdata    ;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		begin
			w_iqdata_fp <= 1'b0;
			w_idata     <= 12'd0;
			w_qdata     <= 12'd0;
		end
	else if(r_rd_en1 == 1'b1)
		begin
			w_iqdata_fp <= 1'b1;
			w_idata     <= w_idata;
			w_qdata     <= w_qdata;
		end
	else
		begin
			w_iqdata_fp <= 1'b0;
			w_idata     <= w_adc_iqdata[11:0];
			w_qdata     <= w_adc_iqdata[23:12];
		end
end        
/*
//--3,IQ信号搬频，cos采用1 0 -1 0序列，sin采用0 1 0 -1序列
reg [2:0] cnt_8;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		cnt_8 <= 3'd0;
	else if(w_iqdata_fp == 1'b1&&cnt_8 == 3'd7)
		cnt_8 <= 3'd0;
	else if(cnt_8 == 3'd7)
		cnt_8 <= cnt_8;
	else
		cnt_8 <= cnt_8 + 3'd1;		
end

reg [11:0] cos_data;
reg [11:0] sin_data;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)  //I1 = I * COSW - Q * SIN W         Q1 =Q * COSW + I * SIN W 
begin
	if(!i_fpga_rst_125p)
		cos_data <= 12'd0;
	else 
		case(cnt_8)
            3'd0 : cos_data <= w_idata ;           //I
            3'd2 : cos_data <= ~w_qdata + 1'b1 ;   //-Q
            3'd4 : cos_data <= ~w_idata + 1'b1 ;   //-I
            3'd6 : cos_data <= w_qdata ;           // Q
            default:cos_data <= cos_data ;
        endcase
end
   
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		sin_data <= 12'd0;
	else 
		case(cnt_8)                               
            3'd0 : sin_data <= w_qdata;           //Q 
            3'd2 : sin_data <= w_idata ;          //I 
            3'd4 : sin_data <= ~w_qdata + 1'b1 ;  //-Q
            3'd6 : sin_data <= ~w_idata + 1'b1 ;  //-I
            default:sin_data <= sin_data ;
        endcase
end

reg cos_data_fp;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		cos_data_fp <= 1'b0;
	else
		cos_data_fp <= w_iqdata_fp;
end

assign o_iqdata_fp = cos_data_fp;
assign o_idata     = cos_data   ;
assign o_qdata     = sin_data   ;
*/
assign o_iqdata_fp = w_iqdata_fp;
assign o_idata     = w_idata    ;
assign o_qdata     = w_qdata    ;

endmodule                      
            
    	         	
	                 