/****************************************************************************
 * axi4_master_bfm_tb_hdl.sv
 ***************************************************************************/
`include "axi4_macros.svh"
`include "generic_sram_byte_en_macros.svh"

module axi4_master_bfm_tb_hdl(input clock);

`ifdef HAVE_HDL_CLKGEN
	reg clk_r = 0;

	initial begin
		forever begin
			#10ns;
			clk_r <= ~clk_r;
		end
	end

	assign clock = clk_r;
`endif

	reg reset = 1;
	reg [7:0] reset_cnt = 0;

	always @(posedge clock) begin
		if (reset_cnt == 10) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end

	parameter AXI4_ADDRESS_WIDTH = 32;
	parameter AXI4_DATA_WIDTH = 32;
	parameter AXI4_ID_WIDTH = 4;

	`AXI4_WIRES(bfm2bridge_,AXI4_ADDRESS_WIDTH,AXI4_DATA_WIDTH,AXI4_ID_WIDTH);
	`GENERIC_SRAM_BYTE_EN_WIRES(bridge2mem_, 10, AXI4_DATA_WIDTH);
	
	axi4_master_bfm #(
		.AXI4_ADDRESS_WIDTH     (AXI4_ADDRESS_WIDTH    ), 
		.AXI4_DATA_WIDTH        (AXI4_DATA_WIDTH       ), 
		.AXI4_ID_WIDTH          (AXI4_ID_WIDTH         )
		) u_bfm (
		.clock                  (clock                 ), 
		.reset                  (reset                 ),
		`AXI4_CONNECT(, bfm2bridge_)
		);
	
	axi4_generic_byte_en_sram_bridge #(
			.MEM_ADDR_BITS(10),
			.AXI_ADDRESS_WIDTH(AXI4_ADDRESS_WIDTH),
			.AXI_DATA_WIDTH(AXI4_DATA_WIDTH),
			.AXI_ID_WIDTH(AXI4_ID_WIDTH)
		) u_bridge (
			.clk(clock),
			.rst_n(~reset),
			`AXI4_CONNECT(,bfm2bridge_),
			`GENERIC_SRAM_BYTE_EN_CONNECT(,bridge2mem_)
		);
	
endmodule