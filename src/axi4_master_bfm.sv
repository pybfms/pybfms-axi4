/****************************************************************************
 * axi4_master_bfm.sv
 ****************************************************************************/
`include "axi4_macros.svh"
/**
 * Module: axi4_master_bfm
 * 
 * TODO: Add module documentation
 */
module axi4_master_bfm #(
			parameter int AXI4_ADDRESS_WIDTH=32,
			parameter int AXI4_DATA_WIDTH=128,
			parameter int AXI4_ID_WIDTH=4,
			parameter int AXI4_MAX_BURST_LENGTH=16
		) (
			input			clock,
			input			reset,
			
			`AXI4_INITIATOR_PORT(,AXI4_ADDRESS_WIDTH,AXI4_DATA_WIDTH,AXI4_ID_WIDTH)
		);
`define BFM_NONBLOCK
	
	bit[AXI4_DATA_WIDTH-1:0]			wdata_buf[AXI4_MAX_BURST_LENGTH];
	reg									aw_req = 0;
	reg[(AXI4_ADDRESS_WIDTH-1):0]		AWADDR_r;
	reg[(AXI4_ADDRESS_WIDTH-1):0]		AWADDR_rs;
	reg[(AXI4_ID_WIDTH-1):0]			AWID_r;
	reg[(AXI4_ID_WIDTH-1):0]			AWID_rs;
	reg[7:0]							AWLEN_r;
	reg[7:0]							AWLEN_rs;
	reg[2:0]							AWSIZE_r;
	reg[2:0]							AWSIZE_rs;
	reg[1:0]							AWBURST_r;
	reg[1:0]							AWBURST_rs;
	reg[3:0]							AWCACHE_r;
	reg[3:0]							AWCACHE_rs;
	reg[2:0]							AWPROT_r;
	reg[2:0]							AWPROT_rs;
	reg[3:0]							AWQOS_r;
	reg[3:0]							AWQOS_rs;
	reg[3:0]							AWREGION_r;
	reg[3:0]							AWREGION_rs;
	reg									AWVALID_r;

	axi4_master_bfm_core u_core (
		.clock  (clock ), 
		.reset  (reset ));
	
	assign u_core.AXI4_ID_WIDTH = AXI4_ID_WIDTH;

	assign AWADDR	= u_core.AWADDR;
	assign AWID		= u_core.AWID;
	assign AWLEN	= u_core.AWLEN;
	assign AWSIZE	= u_core.AWSIZE;
	assign AWBURST	= u_core.AWBURST;
	assign AWLOCK	= u_core.AWLOCK;
	assign AWCACHE	= u_core.AWCACHE;
	assign AWPROT	= u_core.AWPROT;
	assign AWQOS	= u_core.AWQOS;
	assign AWREGION	= u_core.AWREGION;
	assign AWVALID	= u_core.AWVALID;
	assign u_core.AWREADY = AWREADY;
	
	assign ARVALID 	= u_core.ARVALID;
	assign u_core.ARREADY = ARREADY;
	assign ARADDR 	= u_core.ARADDR;
	assign ARID 	= u_core.ARID;
	assign ARLEN 	= u_core.ARLEN;
	assign ARSIZE 	= u_core.ARSIZE;
	assign ARBURST 	= u_core.ARBURST;
	assign ARCACHE 	= u_core.ARCACHE;
	assign ARPROT 	= u_core.ARPROT;
	assign ARREGION = u_core.ARREGION;
	
	assign u_core.RID = RID;
	assign u_core.RDATA = RDATA;
	assign u_core.RRESP = RRESP;
	assign u_core.RLAST = RLAST;
	assign u_core.RVALID = RVALID;
	assign RREADY = u_core.RREADY;
	
//	task axi4_master_bfm_get_parameters(
//			output int unsigned ADDRESS_WIDTH,
//			output int unsigned DATA_WIDTH,
//			output int unsigned ID_WIDTH);
//			ADDRESS_WIDTH = AXI4_ADDRESS_WIDTH;
//			DATA_WIDTH = AXI4_DATA_WIDTH;
//			ID_WIDTH = AXI4_ID_WIDTH;
//	endtask
//	export "DPI-C" task axi4_master_bfm_get_parameters;


endmodule

interface axi4_master_bfm_core(input clock, input reset);
//	bit[AXI4_DATA_WIDTH-1:0]			wdata_buf[AXI4_MAX_BURST_LENGTH];
//	reg									aw_req = 0;
//	reg[(AXI4_ADDRESS_WIDTH-1):0]		AWADDR_r;
//	reg[(AXI4_ADDRESS_WIDTH-1):0]		AWADDR_rs;
//	reg[(AXI4_ID_WIDTH-1):0]			AWID_r;
//	reg[(AXI4_ID_WIDTH-1):0]			AWID_rs;
//	reg[7:0]							AWLEN_r;
//	reg[7:0]							AWLEN_rs;
//	reg[2:0]							AWSIZE_r;
//	reg[2:0]							AWSIZE_rs;
//	reg[1:0]							AWBURST_r;
//	reg[1:0]							AWBURST_rs;
//	reg[3:0]							AWCACHE_r;
//	reg[3:0]							AWCACHE_rs;
//	reg[2:0]							AWPROT_r;
//	reg[2:0]							AWPROT_rs;
//	reg[3:0]							AWQOS_r;
//	reg[3:0]							AWQOS_rs;
//	reg[3:0]							AWREGION_r;
//	reg[3:0]							AWREGION_rs;
//	reg									AWVALID_r;

//	bit[AXI4_DATA_WIDTH-1:0]			rdata_buf[AXI4_MAX_BURST_LENGTH];
	wire[31:0]							AXI4_ID_WIDTH;
	reg[63:0]							AWADDR;
	reg[63:0]							AWADDR_r;
	reg[31:0]							AWID;
	reg[31:0]							AWID_r;
	reg[7:0]							AWLEN;
	reg[7:0]							AWLEN_r;
	reg[2:0]							AWSIZE;
	reg[2:0]							AWSIZE_r;
	reg[1:0]							AWBURST;
	reg[1:0]							AWBURST_r;
	reg									AWLOCK;
	reg									AWLOCK_r;
	reg[3:0]							AWCACHE;
	reg[3:0]							AWCACHE_r;
	reg[2:0]							AWPROT;
	reg[2:0]							AWPROT_r;
	reg[3:0]							AWQOS;
	reg[3:0]							AWQOS_r;
	reg[3:0]							AWREGION;
	reg[3:0]							AWREGION_r;
	reg									AWVALID;
	reg									AWVALID_r = 0;
	wire								AWREADY;
	
	reg[63:0]							ARADDR;
	reg[63:0]							ARADDR_r;
	reg[31:0]							ARID;
	reg[31:0]							ARID_r;
	reg[7:0]							ARLEN;
	reg[7:0]							ARLEN_r;
	reg[2:0]							ARSIZE;
	reg[2:0]							ARSIZE_r;
	reg[1:0]							ARBURST;
	reg[1:0]							ARBURST_r;
	reg[3:0]							ARCACHE;
	reg[3:0]							ARCACHE_r;
	reg[2:0]							ARPROT;
	reg[2:0]							ARPROT_r;
	reg[3:0]							ARREGION;
	reg[3:0]							ARREGION_r;
	reg									ARVALID;
	reg									ARVALID_r = 0;
	wire								ARREADY;
	
	wire[15:0]							RID;
	wire[63:0]							RDATA;
	wire[1:0]							RRESP;
	wire								RLAST;
	wire								RVALID;
	reg									RREADY = 1;
	
`ifdef HAVE_HDL_VIRTUAL_INTERFACE
		// TODO: API package
`endif
	
	
`ifdef HAVE_HDL_VIRTUAL_INTERFACE
		// TODO: API handle
`else
		int unsigned				m_id;
		
		import "DPI-C" context function int unsigned axi4_master_bfm_register(string path);
		
		task axi4_master_bfm_get_parameters(
			output int unsigned				id_width);
			id_width = AXI4_ID_WIDTH;
		endtask
		export "DPI-C" task axi4_master_bfm_get_parameters;
		
		initial begin
			m_id = axi4_master_bfm_register($sformatf("%m"));
		end
`endif
	
`ifndef HAVE_HDL_VIRTUAL_INTERFACE
	import "DPI-C" context task axi4_master_bfm_reset(int unsigned id);
`endif

	task axi4_master_bfm_arreq(
		longint unsigned		addr,
		int unsigned			arid,
		byte unsigned			arlen,
		byte unsigned			arsize,
		byte unsigned			arburst,
		byte unsigned			arcache,
		byte unsigned			arprot,
		byte unsigned			arregion);
		ARADDR_r = addr;
		ARID_r = arid;
		ARLEN_r = arlen;
		ARSIZE_r = arsize;
		ARBURST_r = arburst;
		ARCACHE_r = arcache;
		ARPROT_r = arprot;
		ARREGION_r = arregion;
		ARVALID_r = 1;
	endtask
`ifndef HAVE_HDL_VIRTUAL_INTERFACE
	export "DPI-C" task axi4_master_bfm_arreq;
`endif

	task axi4_master_bfm_awreq(
		longint unsigned		awddr,
		int unsigned			awid,
		byte unsigned			awlen,
		byte unsigned			awsize,
		byte unsigned			awburst,
		byte unsigned			awcache,
		byte unsigned			awprot,
		byte unsigned			awregion);
		AWADDR_r = awddr;
		AWID_r = awid;
		AWLEN_r = awlen;
		AWSIZE_r = awsize;
		AWBURST_r = awburst;
		AWCACHE_r = awcache;
		AWPROT_r = awprot;
		AWREGION_r = awregion;
		AWVALID_r = 1;
	endtask
`ifndef HAVE_HDL_VIRTUAL_INTERFACE
	export "DPI-C" task axi4_master_bfm_awreq;
`endif
	
`ifndef HAVE_HDL_VIRTUAL_INTERFACE
	import "DPI-C" context task axi4_master_bfm_arreq_ack(int unsigned id);
	import "DPI-C" context task axi4_master_bfm_awreq_ack(int unsigned id);
`endif
	
	// TODO: detect reset
	reg in_reset = 0;
	always @(posedge clock) begin
		$display("clock: reset=%0d", reset);
		if (reset) begin
			in_reset <= 1;
		end else begin
			if (in_reset) begin
`ifdef HAVE_HDL_VIRTUAL_INTERFACE
`else
				axi4_master_bfm_reset(m_id);
`endif
				in_reset <= 0;
			end
		end
	end
	
	always @(posedge clock) begin
		AWVALID <= AWVALID_r;
		AWADDR <= AWADDR_r;
		AWID <= AWID_r;
		AWLEN <= AWLEN_r;
		AWSIZE <= AWSIZE_r;
		AWBURST <= AWBURST_r;
		AWLOCK <= AWLOCK_r;
		AWCACHE <= AWCACHE_r;
		AWPROT <= AWPROT_r;
		AWQOS <= AWQOS_r;
		AWREGION <= AWREGION_r;
		
		if (AWVALID && AWREADY) begin
`ifdef HAVE_HDL_VIRTUAL_INTERFACE
				// TODO:
`else
			axi4_master_bfm_awreq_ack(m_id);
`endif
			AWVALID_r = 0;
		end
	end
		
	always @(posedge clock) begin
		ARVALID <= ARVALID_r;
		ARADDR <= ARADDR_r;
		ARID <= ARID_r;
		ARLEN <= ARLEN_r;
		ARSIZE <= ARSIZE_r;
		ARBURST <= ARBURST_r;
		ARCACHE <= ARCACHE_r;
		ARPROT <= ARPROT_r;
		ARREGION <= ARREGION_r;
		
		
		if (ARVALID && ARREADY) begin
`ifdef HAVE_HDL_VIRTUAL_INTERFACE
`else
			axi4_master_bfm_arreq_ack(m_id);
`endif
			ARVALID_r = 0;
		end
		
	end

`ifndef HAVE_HDL_VIRTUAL_INTERFACE
	import "DPI-C" task axi4_master_bfm_rresp(
			int unsigned				id,
			int unsigned				rid,
			longint unsigned			rdata,
			byte unsigned				rresp,
			byte unsigned				rlast);
`endif
	
	always @(posedge clock) begin
		if (RREADY && RVALID) begin
`ifdef HAVE_HDL_VIRTUAL_INTERFACE
`else
			axi4_master_bfm_rresp(
					m_id,
					RID,
					RDATA,
					RRESP,
					RLAST);
`endif
	
			$display("rresp");
		end
	end
	
endinterface


