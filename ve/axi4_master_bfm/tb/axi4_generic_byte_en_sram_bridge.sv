/****************************************************************************
 * axi4_generic_byte_en_sram_bridge.sv
 ****************************************************************************/
`include "axi4_macros.svh"
`include "generic_sram_byte_en_macros.svh"

/**
 * Module: axi4_generic_byte_en_sram_bridge
 * 
 * TODO: Add module documentation
 */
module axi4_generic_byte_en_sram_bridge #(
			parameter int MEM_ADDR_BITS=10,
			parameter int AXI_ADDRESS_WIDTH=32,
			parameter int AXI_DATA_WIDTH=1024,
			parameter int AXI_ID_WIDTH=4,
			parameter bit[MEM_ADDR_BITS-1:0]    MEM_ADDR_OFFSET=0
		) (
			input									clk,
			input									rst_n,
			`AXI4_TARGET_PORT(,AXI_ADDRESS_WIDTH,AXI_DATA_WIDTH,AXI_ID_WIDTH),
			`GENERIC_SRAM_BYTE_EN_INITIATOR_PORT(,MEM_ADDR_BITS,AXI_DATA_WIDTH)
		);
   
	parameter ADDR_WIDTH_OFF = $clog2(AXI_DATA_WIDTH/8);
	reg[2:0] 						write_state;
	reg[MEM_ADDR_BITS-1:4]			write_addr;
	wire[MEM_ADDR_BITS-1:0]			write_addr_w;
	reg[3:0]						write_offset;
	reg[3:0]						write_count;
	reg[AXI_ID_WIDTH-1:0]			write_id;
	reg[1:0]						write_burst;
	reg[3:0]						write_wrap_mask;
//	reg[AXI_DATA_WIDTH-1:0]			write_data;
	reg[2:0] 						read_state;
	reg[MEM_ADDR_BITS-1:4]			read_addr;
	wire[MEM_ADDR_BITS-1:0]			read_addr_w;
	reg[3:0]						read_offset;
	reg[3:0]						read_count;
	reg[3:0]						read_length;
	reg[AXI_ID_WIDTH-1:0]			read_id;
	reg[1:0]						read_burst;
	reg[3:0]						read_wrap_mask;
	reg								read_lock;
	reg								write_lock;
	reg     						sram_owner_r = 0;
	reg     						sram_owner_w = 0;
	reg[1:0]						sram_owner_nxt = 0;
	wire[MEM_ADDR_BITS-1:0]			sram_addr;
	
	reg[MEM_ADDR_BITS-1:4]			exclusive_addr = 0;
	reg[AXI_ID_WIDTH-1:0]			exclusive_id = {AXI_ID_WIDTH{1'b1}};
	
	wire							exclusive_ok;
	
	assign exclusive_ok = (write_id == exclusive_id && 
				write_addr == exclusive_addr);
	
	assign RRESP = (read_lock)?2'b01:2'b00;
	assign BRESP = (write_lock && exclusive_ok)?1'b01:1'b00;
	wire write_exclusive_fail = (write_lock && !exclusive_ok);
	
	always @(posedge clk) begin
		if (write_lock && !exclusive_ok) begin
			$display("Failed Exclusive Write");
		end
	end


	// Arbitration logic for read vs write
	always @* begin
		if (rst_n == 0) begin
			sram_owner_nxt = 0;
		end else begin
			if (sram_owner_r == 0 && sram_owner_w == 0) begin
				if (read_state == 0 && ARVALID) begin
					sram_owner_nxt = 1;
				end else if (write_state == 0 && AWVALID) begin
					sram_owner_nxt = 2;
				end else begin
					sram_owner_nxt = 0;
				end
			end else begin
				sram_owner_nxt = {sram_owner_w, sram_owner_r};
			end
		end
	end

	always @(posedge clk)
	begin
		if (!rst_n) begin
			write_state <= 2'b00;
			write_offset <= 0;
			write_id <= 0;
			write_burst <= 0;
			write_wrap_mask <= 0;
			write_addr <= 0;
			write_count <= 4'b0000;
			write_lock <= 0;
		end else begin
			case (write_state) 
				2'b00: begin // Wait Address state
					if (AWVALID == 1'b1 && AWREADY == 1'b1 && 
							sram_owner_nxt != 1) begin
						write_addr <= AWADDR[MEM_ADDR_BITS+ADDR_WIDTH_OFF:ADDR_WIDTH_OFF+4];
						write_offset <= AWADDR[ADDR_WIDTH_OFF+4-1:ADDR_WIDTH_OFF];
    					
						write_id <= AWID;
						write_count <= 0;
						write_state <= 1;
						write_lock <= AWLOCK;
						sram_owner_w <= 1;
    				
						case (AWBURST)
							2: begin
								case (AWLEN)
									0,1: write_wrap_mask <= 1;
									2,3: write_wrap_mask <= 3;
									4,5,6,7: write_wrap_mask <= 7;
									default: write_wrap_mask <= 15;
								endcase
							end
	    					
							default: write_wrap_mask <= 'hf;
						endcase
					end else begin
						write_lock <= 0;
					end
				end
    			
				2'b01: begin // Wait for write data
					if (WVALID == 1'b1 && WREADY == 1'b1) begin
						if (WLAST == 1'b1) begin
							write_state <= 2;
						end else begin
							write_count <= write_count + 1;
						end
    				
						case (write_burst)
							2: begin
								write_offset <= (write_offset & ~write_wrap_mask) |
									((write_offset + 1) & write_wrap_mask);
							end
    						
							default: begin
								if (write_offset == 'hf && !WLAST) begin
									write_addr <= write_addr + 1;
								end
								write_offset <= write_offset + 1;
							end
						endcase
					end
				end
    			
				2'b10: begin  // Send write response
					if (BVALID == 1'b1 && BREADY == 1'b1) begin
						write_state <= 2'b00;
						sram_owner_w <= 0;
					end
				end
    			
				default: begin
				end
			endcase
		end
	end
	
	reg[AXI_DATA_WIDTH-1:0]			read_data_r = 0;
    		
	always @(posedge clk) begin
		if (rst_n == 0) begin
			read_state <= 0;
			read_lock <= 0;
			read_addr <= 0;
			read_offset <= 0;
			read_count <= 4'b0000;
			read_length <= 4'b0000;
			read_id <= 0;
			read_burst <= 0;
			read_wrap_mask <= 0;
			sram_owner_r <= 0;
			read_data_r <= 0;
		end else begin
			case (read_state)
				2'b00: begin // Wait address state
					if (ARVALID && ARREADY && sram_owner_nxt != 2) begin
						read_addr <= ARADDR[MEM_ADDR_BITS+ADDR_WIDTH_OFF:ADDR_WIDTH_OFF+4];
						read_offset <= ARADDR[ADDR_WIDTH_OFF+4-1:ADDR_WIDTH_OFF];
						read_length <= ARLEN;
						read_burst <= ARBURST;
						read_lock <= ARLOCK;
						read_count <= 0;
						read_state <= 1;
						read_id <= ARID;
						sram_owner_r <= 1;
						
						if (ARLOCK) begin
							exclusive_addr <= ARADDR[MEM_ADDR_BITS+ADDR_WIDTH_OFF:ADDR_WIDTH_OFF+4];
							exclusive_id <= ARID;
						end
    					
						case (ARBURST) 
							2: begin
								case (ARLEN) 
									0,1: read_wrap_mask <= 1;
									2,3: read_wrap_mask <= 3;
									4,5,6,7: read_wrap_mask <= 7;
									default: read_wrap_mask <= 15;
								endcase
							end
    						
							default: read_wrap_mask <= 'hf;
						endcase
					end else begin
						read_lock <= 0;
					end
				end
    		
				// Propagate address to data
				1: read_state <= 2;
    		
					// Propagate address to data
				2: begin
					// TODO:
//					read_data <= read_data_r;
					read_data_r <= read_data;
					read_state <= 3;
				end
    			
				3: begin 
					if (RVALID && RREADY) begin
						if (read_count == read_length) begin
							read_state <= 1'b0;
							sram_owner_r <= 0;
						end else begin
							read_count <= read_count + 1;
							read_state <= 4;
						end
    					
						case (read_burst) 
							2: begin
								read_offset <= (read_offset & ~read_wrap_mask) |
									((read_offset + 1) & read_wrap_mask);
							end
    						
							default: begin
								if (read_offset == 'hf) begin
									read_addr <= read_addr + 1;
								end
								read_offset <= read_offset + 1;
							end
						endcase
					end
				end
    			
				4: read_state <= 2;
    			
				default: begin
					read_state <= 0;
					sram_owner_r <= 0;
				end 
			endcase
		end
	end
    
	assign read_addr_w = {read_addr,read_offset};
	assign write_addr_w = {write_addr, write_offset};
	
	assign addr = sram_addr;
	assign write_en = (WVALID && WREADY &&
			(!write_lock || exclusive_ok));
	assign byte_en = WSTRB;
	assign write_data = WDATA;
	
	assign RDATA = read_data_r;
	
	assign read_en = 1;
    
	assign sram_addr = (sram_owner_w == 1)?
			(write_addr_w-MEM_ADDR_OFFSET):
			(read_addr_w-MEM_ADDR_OFFSET);
   
	assign AWREADY = (write_state == 0 && sram_owner_nxt != 1);
//	assign AWREADY = (sram_owner_nxt != 1);
	assign WREADY = (write_state == 1);
    
	assign BVALID = (write_state == 2);
	assign BID = (write_state == 2)?write_id:0;
    
	assign ARREADY = (read_state == 1'b0 && sram_owner_nxt != 2);
//	assign ARREADY = (sram_owner_nxt != 2);

	assign RVALID = (read_state == 3);
	assign RLAST = (read_state == 3 && read_count == read_length)?1'b1:1'b0;
	assign RID = (read_state == 3)?read_id:0;	

endmodule

