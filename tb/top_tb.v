//FileName 	  : top_tb.v
//Author      : Mahdi
//Description : My Testbench Templatefile

module top_tb();
    reg         clk;
    reg         rst_n;
    reg  [3:0]  r_address;
    reg         i_rx_clk;
  	reg         i_tx_clk;
    wire [11:0] w_rx_rom_iqdata;
    wire        w_iqdata_fp;
    wire [11:0] w_idata;    
    wire [11:0] w_qdata;  
    wire        o_tx_clk ; 
    wire        o_tx_frame;
    wire [5:0] o_tx_data ;


  	`define RESET_TIME    100
    `define CLOCK_FREQ    125e6  //时钟频率
  	localparam CLOCK_PERIOD = 1e9/`CLOCK_FREQ;
	initial begin
    	clk = 0;
   		forever begin
        	#(CLOCK_PERIOD/2) clk = ~clk ;
    	end 
	end 
  	initial begin
    	rst_n = 1'b0;
    	#(`RESET_TIME);
    	@(posedge clk);
    	rst_n = 1'b1;
    end

//==================rx clk==========================
    `define RX_CLK_FREQ    31.25e6  //时钟频率
  	localparam RX_CLK_PERIOD = 1e9/`RX_CLK_FREQ;
	initial begin
    	i_rx_clk = 0;
   		forever begin
        	#(RX_CLK_PERIOD/2) i_rx_clk = ~i_rx_clk ;
    	end 
	end 

//==================tx clk==========================
    `define TX_CLK_FREQ    62.5e6  //时钟频率
  	localparam TX_CLK_PERIOD = 1e9/`TX_CLK_FREQ;
	initial begin
    	i_tx_clk = 0;
   		forever begin
        	#(TX_CLK_PERIOD/2) i_tx_clk = ~i_tx_clk ;
    	end 
	end 


//=================================
//rom
always @(posedge i_rx_clk or negedge rst_n)
begin
	if(!rst_n)
		r_address <= 12'd0;
	else
	begin
		if(r_address == 4'd9)
			r_address <= 4'd0;
		else
			r_address <= r_address + 4'd1;
	end
end

rom iqdata_ins_outside(
	.address  (r_address),          //input
	.clock    (i_rx_clk),       //input
	.q        (w_rx_rom_iqdata)       //output
	);  

ad80305_rx_if_ddr_lvcmos_31p25  u_ad80305_rx_if_ddr_lvcmos_31p25 (
    .i_rx_clk                ( i_rx_clk          ),
    .i_rx_frame              ( 1'b1              ),
    .i_rx_data               ( w_rx_rom_iqdata   ),
    .i_fpga_clk_125p         ( clk               ),
    .i_fpga_rst_125p         ( rst_n             ),

    .o_iqdata_fp             ( w_iqdata_fp       ),
    .o_idata                 ( w_idata           ),
    .o_qdata                 ( w_qdata           )
);

ad80305_tx_if_ddr_dcs  u_ad80305_tx_if_ddr_dcs (
    .i_fpga_clk              ( clk              ),
    .i_fpga_rst              ( rst_n            ),
    .i_tx_clk                ( i_tx_clk         ),
    .i_tx_iqdata_fp          ( w_iqdata_fp      ),
    .i_tx_idata              ( w_idata          ),
    .i_tx_qdata              ( w_qdata          ),

    .o_tx_clk                ( o_tx_clk         ),
    .o_tx_frame              ( o_tx_frame       ),
    .o_tx_data               ( o_tx_data        )
);   
    
endmodule