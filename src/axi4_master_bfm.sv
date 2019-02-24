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
	
	assign WDATA = u_core.WDATA;
	assign WSTRB = u_core.WSTRB;
	assign WLAST = u_core.WLAST;
	assign WVALID = u_core.WVALID;
	assign u_core.WREADY = WREADY;
	
	assign u_core.BID = BID;
	assign u_core.BRESP = BRESP;
	assign u_core.BVALID = BVALID;
	assign BREADY = u_core.BREADY;
	
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
	
endmodule

interface axi4_master_bfm_core(input clock, input reset);
	wire[31:0]							AXI4_ID_WIDTH;
	reg[63:0]							AWADDR = 0;
	reg[63:0]							AWADDR_r = 0;
	reg[31:0]							AWID = 0;
	reg[31:0]							AWID_r = 0;
	reg[7:0]							AWLEN = 0;
	reg[7:0]							AWLEN_r = 0;
	reg[2:0]							AWSIZE = 0;
	reg[2:0]							AWSIZE_r = 0;
	reg[1:0]							AWBURST = 0;
	reg[1:0]							AWBURST_r;
	reg									AWLOCK = 0;
	reg									AWLOCK_r = 0;
	reg[3:0]							AWCACHE = 0;
	reg[3:0]							AWCACHE_r = 0;
	reg[2:0]							AWPROT = 0;
	reg[2:0]							AWPROT_r = 0;
	reg[3:0]							AWQOS = 0;
	reg[3:0]							AWQOS_r = 0;
	reg[3:0]							AWREGION = 0;
	reg[3:0]							AWREGION_r = 0;
	reg									AWVALID = 0;
	reg									AWVALID_r = 0;
	wire								AWREADY;
	
	reg[63:0]							WDATA = 0;
	reg[63:0]							WDATA_r = 0;
	reg[7:0]							WSTRB = 0;
	reg[7:0]							WSTRB_r = 0;
	reg									WLAST = 0;
	reg									WLAST_r = 0;
	reg									WVALID = 0;
	reg									WVALID_r = 0;
	wire								WREADY;
	
	wire[31:0]							BID;
	wire[1:0]							BRESP;
	wire								BVALID;
	reg									BREADY = 1;
	
	reg[63:0]							ARADDR = 0;
	reg[63:0]							ARADDR_r = 0;
	reg[31:0]							ARID = 0;
	reg[31:0]							ARID_r = 0;
	reg[7:0]							ARLEN = 0;
	reg[7:0]							ARLEN_r = 0;
	reg[2:0]							ARSIZE = 0;
	reg[2:0]							ARSIZE_r = 0;
	reg[1:0]							ARBURST = 0;
	reg[1:0]							ARBURST_r = 0;
	reg[3:0]							ARCACHE = 0;
	reg[3:0]							ARCACHE_r = 0;
	reg[2:0]							ARPROT = 0;
	reg[2:0]							ARPROT_r = 0;
	reg[3:0]							ARREGION = 0;
	reg[3:0]							ARREGION_r = 0;
	reg									ARVALID = 0;
	reg									ARVALID_r = 0;
	wire								ARREADY;
	
	wire[15:0]							RID;
	wire[63:0]							RDATA;
	wire[1:0]							RRESP;
	wire								RLAST;
	wire								RVALID;
	reg									RREADY = 1;
	
	function void axi4_master_bfm_get_parameters(
		output int unsigned		id_width);
		id_width = AXI4_ID_WIDTH;
	endfunction
	
	
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

	task axi4_master_bfm_awreq(
		longint unsigned		awddr,
		int unsigned			awid,
		byte unsigned			awlen,
		byte unsigned			awsize,
		byte unsigned			awburst,
		byte unsigned			awcache,
		byte unsigned			awprot,
		byte unsigned			awregion);
		$display("awreq");
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
	
	task axi4_master_bfm_wdata(
		longint unsigned		wdata,
		int unsigned			wstrb,
		byte unsigned			wlast);
		WDATA_r = wdata;
		WSTRB_r = wstrb;
		WLAST_r = wlast;
		WVALID_r = 1;
	endtask
	
	always @(posedge clock) begin
		WDATA <= WDATA_r;
		WSTRB <= WSTRB_r;
		WLAST <= WLAST_r;
		WVALID <= WVALID_r;
		
		if (WVALID && WREADY) begin
			WVALID_r = 0;
			wdata_ack();
		end
	end
	
	always @(posedge clock) begin
		if (BVALID && BREADY) begin
			bresp(BID, BRESP);
		end
	end
	
	// TODO: detect reset
	reg in_reset = 0;
	always @(posedge clock) begin
		if (reset) begin
			in_reset <= 1;
		end else begin
			if (in_reset) begin
				reset_ev();
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
			awreq_ack();
			AWVALID_r = 0;
			AWVALID <= 0;
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
			arreq_ack();
			ARVALID_r = 0;
			ARVALID <= 0;
		end
		
	end

	always @(posedge clock) begin
		if (RREADY && RVALID) begin
			rresp(RID, RDATA, RRESP, RLAST);
		end
	end

`include "axi4_master_bfm_api.svh"
endinterface


