
module dino_demo(

	//////////// CLOCK //////////
	//input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	//input 		          		MAX10_CLK2_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS
);
   assign DRAM_UDQM = DRAM_LDQM;
   
	wire reset_n = KEY[0];
   wire button  = !KEY[1];

	dino_system u0 (
		.clk_clk                     (MAX10_CLK1_50),              //              clk.clk
		.reset_reset_n               (reset_n),                    //              reset.reset_n
      .sdram_clk_clk               (DRAM_CLK),
		.sdram_addr                  (DRAM_ADDR),                  //              sdram.addr
		.sdram_ba                    (DRAM_BA),                    //              .ba
		.sdram_cas_n                 (DRAM_CAS_N),                 //              .cas_n
		.sdram_cke                   (DRAM_CKE),                   //              .cke
		.sdram_cs_n                  (DRAM_CS_N),                  //              .cs_n
		.sdram_dq                    (DRAM_DQ),                    //              .dq
		.sdram_dqm                   (DRAM_LDQM),                  //              .dqm
		.sdram_ras_n                 (DRAM_RAS_N),                 //              .ras_n
		.sdram_we_n                  (DRAM_WE_N),                  //              .we_n
		.button_export					  (button),
		.seg7_display_digits			  ({HEX5, HEX4, HEX3, HEX2, HEX1, HEX0}),

		.vga_connector_vga_hs        (VGA_HS), // vga_connector.vga_hs_signal
		.vga_connector_vga_vs        (VGA_VS), //              .vga_vs_signal
		.vga_connector_vga_r         (VGA_R),  //              .vga_r_signal
		.vga_connector_vga_g         (VGA_G),  //              .vga_g_signal
		.vga_connector_vga_b         (VGA_B)   //              .vga_b_signal
	);

endmodule
