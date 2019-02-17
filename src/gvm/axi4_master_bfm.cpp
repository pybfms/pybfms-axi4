/*
 * axi4_master_bfm.cpp
 *
 *  Created on: Feb 3, 2019
 *      Author: ballance
 */

#include "axi4_master_bfm.h"
#include "GoogletestHdl.h"

extern "C" {
// DPI-export functions

void axi4_master_bfm_get_parameters(
		uint32_t			*id_width);

void axi4_master_bfm_arreq(
		uint64_t			addr,
		uint32_t			arid,
		uint8_t				arlen,
		uint8_t				arsize,
		uint8_t				arburst,
		uint8_t				arcache,
		uint8_t				arprot,
		uint8_t				arregion);

void axi4_master_bfm_awreq(
		uint64_t			awaddr,
		uint32_t			awid,
		uint8_t				awlen,
		uint8_t				awsize,
		uint8_t				awburst,
		uint8_t				awcache,
		uint8_t				awprot,
		uint8_t				awregion);

void axi4_master_bfm_wdata(
		uint64_t			wdata,
		uint32_t			wstrb,
		uint8_t				wlast);

// DPI-import functions
uint32_t axi4_master_bfm_register(const char *path);

uint32_t axi4_master_bfm_reset(uint32_t id);

uint32_t axi4_master_bfm_arreq_ack(uint32_t id);

uint32_t axi4_master_bfm_awreq_ack(uint32_t id);

uint32_t axi4_master_bfm_wdata_ack(uint32_t id);

uint32_t axi4_master_bfm_bresp(uint32_t id, uint32_t bid, uint8_t resp);

uint32_t axi4_master_bfm_rresp(
		uint32_t			id,
		uint32_t			rid,
		uint64_t			rdata,
		uint8_t				rresp,
		uint8_t				rlast);

}

axi4_master_bfm::axi4_master_bfm() :
		GvmBfm(this),
		m_id_pool(0),
		m_rresp_notifiers(0),
		m_bresp_notifiers(0) {
	m_is_reset = false;
	m_recv_arreq = false;
	m_recv_awreq = false;
	m_recv_wdata = false;
}

axi4_master_bfm::~axi4_master_bfm() {
	if (m_id_pool) {
		delete [] m_id_pool;
	}
	if (m_rresp_notifiers) {
		delete [] m_rresp_notifiers;
	}
	if (m_bresp_notifiers) {
		delete [] m_bresp_notifiers;
	}
	// TODO Auto-generated destructor stub
}

void axi4_master_bfm::init(const std::string &path, void *ctxt) {
	uint32_t id_width;
	GvmBfm::init(path, ctxt);

	GoogletestHdl::setContext(getContext());
	axi4_master_bfm_get_parameters(&id_width);

	fprintf(stdout, "init: id_width=%d\n", id_width);

	uint32_t num_ids = 1 << id_width;
	m_id_pool = new bool[num_ids];
	for (int i=0; i<num_ids; i++) {
		m_id_pool[i] = true;
	}
	m_id_pool_sz = num_ids;

	m_rresp_notifiers = new rresp_data[num_ids];
	m_bresp_notifiers = new bresp_data[num_ids];
}

uint32_t axi4_master_bfm::read32(uint64_t addr) {
	uint64_t data;
	bool last;
	uint32_t arid = alloc_id();

	m_rresp_notifiers[arid].set_valid();
	arreq(addr, arid, 1, 1, 0, 0, 0, 0);

	// Wait for a response
	m_rresp_notifiers[arid].wait(data, last);

	fprintf(stdout, "last=%d\n", m_rresp_notifiers[arid].last());

	free_id(arid);

	return data;
}

void axi4_master_bfm::write32(
		uint64_t 			addr,
		uint32_t			data) {
	uint32_t awid = alloc_id();

	m_bresp_notifiers[awid].set_valid();
	awreq(addr, awid, 1, 1, 0, 0, 0, 0);

	// Send data
	GoogletestHdl::setContext(getContext());
	axi4_master_bfm_wdata(data, 0xF, 1);

	m_recv_wdata_mutex.lock();
	while (!m_recv_wdata) {
		m_recv_wdata_cond.wait(m_recv_wdata_mutex);
	}
	m_recv_wdata = false;
	m_recv_wdata_mutex.unlock();

	free_id(awid);

	// TODO: wait for bresp

}

void axi4_master_bfm::arreq(
			uint64_t			addr,
			uint32_t			arid,
			uint8_t				arlen,
			uint8_t				arsize,
			uint8_t				arburst,
			uint8_t				arcache,
			uint8_t				arprot,
			uint8_t				arregion) {
	wait_reset();

	m_recv_arreq_mutex.lock();
	m_recv_arreq = false;

	GoogletestHdl::setContext(getContext());
	axi4_master_bfm_arreq(addr, arid, arlen, arsize, arburst, arcache, arprot, arregion);

	// Wait for acknowledge
	do {
		m_recv_arreq_cond.wait(m_recv_arreq_mutex);
	} while (m_recv_arreq == false);

	m_recv_arreq_mutex.unlock();
}

void axi4_master_bfm::awreq(
			uint64_t			awaddr,
			uint32_t			awid,
			uint8_t				awlen,
			uint8_t				awsize,
			uint8_t				awburst,
			uint8_t				awcache,
			uint8_t				awprot,
			uint8_t				awregion) {
	wait_reset();

	m_recv_awreq_mutex.lock();
	m_recv_awreq = false;

	GoogletestHdl::setContext(getContext());
	axi4_master_bfm_awreq(awaddr, awid, awlen, awsize, awburst, awcache, awprot, awregion);

	// Wait for acknowledge
	do {
		m_recv_awreq_cond.wait(m_recv_awreq_mutex);
	} while (m_recv_awreq == false);

	m_recv_awreq_mutex.unlock();
}

void axi4_master_bfm::arreq_ack() {
	fprintf(stdout, "--> arreq_ack\n");
	m_recv_arreq_mutex.lock();
	m_recv_arreq = true;
	m_recv_arreq_cond.notify();
	m_recv_arreq_mutex.unlock();
	fprintf(stdout, "<-- arreq_ack\n");
}

void axi4_master_bfm::awreq_ack() {
	fprintf(stdout, "--> awreq_ack\n");
	m_recv_awreq_mutex.lock();
	m_recv_awreq = true;
	m_recv_awreq_cond.notify();
	m_recv_awreq_mutex.unlock();
	fprintf(stdout, "<-- awreq_ack\n");
}

void axi4_master_bfm::wdata_ack() {
	m_recv_wdata_mutex.lock();
	m_recv_wdata = true;
	m_recv_wdata_cond.notify();
	m_recv_wdata_mutex.unlock();
}

void axi4_master_bfm::bresp(uint32_t bid, uint8_t resp) {
	fprintf(stdout, "bresp: bid=%d\n", bid);

	if (bid < m_id_pool_sz) {
		m_bresp_notifiers[bid].notify(resp);
	} else {
		fprintf(stdout, "INTERNAL ERROR: bid %d is outside legal limits\n", bid);
	}
}

void axi4_master_bfm::rresp(
		uint32_t				rid,
		uint64_t				rdata,
		uint8_t					rresp,
		uint8_t					rlast) {
	fprintf(stdout, "rresp: rid=%d rlast=%d\n", rid, rlast);

	if (rid < m_id_pool_sz) {
		m_rresp_notifiers[rid].notify(rdata, rlast);
	} else {
		fprintf(stdout, "INTERNAL ERROR: rid %0d is outside legal limits\n", rid);
	}
}

void axi4_master_bfm::reset() {
	fprintf(stdout, "--> reset\n");
	m_is_reset_mutex.lock();
	m_is_reset = true;
	m_is_reset_cond.notify();
	m_is_reset_mutex.unlock();
	fprintf(stdout, "<-- reset\n");
}

void axi4_master_bfm::wait_reset() {
	if (!m_is_reset) {
		m_is_reset_mutex.lock();
		while (!m_is_reset) {
			m_is_reset_cond.wait(m_is_reset_mutex);
		}
		m_is_reset_mutex.unlock();
	}
}

uint32_t axi4_master_bfm::alloc_id() {
	int32_t id = -1;
	m_id_pool_mutex.lock();
	do {
		// TODO: ideally would mix this up a bit
		for (int i=0; i<m_id_pool_sz; i++) {
			if (m_id_pool[i]) {
				id = i;
				m_id_pool[i] = false;
				break;
			}
		}

		if (id == -1) {
			m_id_pool_cond.wait(m_id_pool_mutex);
		}
	} while (id == -1);
	m_id_pool_mutex.unlock();

	return id;
}

void axi4_master_bfm::free_id(uint32_t id) {
	m_id_pool_mutex.lock();
	m_id_pool[id] = true; // now available
	m_id_pool_cond.notify();
	m_id_pool_mutex.unlock();
}

uint32_t axi4_master_bfm_arreq_ack(uint32_t id) {
	axi4_master_bfm_t::bfm(id)->arreq_ack();
	return 0;
}

uint32_t axi4_master_bfm_awreq_ack(uint32_t id) {
	axi4_master_bfm_t::bfm(id)->awreq_ack();
	return 0;
}

uint32_t axi4_master_bfm_wdata_ack(uint32_t id) {
	axi4_master_bfm_t::bfm(id)->wdata_ack();
	return 0;
}

uint32_t axi4_master_bfm_bresp(uint32_t id, uint32_t bid, uint8_t resp) {
	axi4_master_bfm_t::bfm(id)->bresp(bid, resp);
	return 0;
}

uint32_t axi4_master_bfm_rresp(
		uint32_t 		id,
		uint32_t		rid,
		uint64_t		rdata,
		uint8_t			rresp,
		uint8_t			rlast) {
	axi4_master_bfm_t::bfm(id)->rresp(rid, rdata, rresp, rlast);
	return 0;
}

uint32_t axi4_master_bfm_register(const char *path) {
	return axi4_master_bfm_t::register_bfm(path);
}

uint32_t axi4_master_bfm_reset(uint32_t id) {
	axi4_master_bfm_t::bfm(id)->reset();
	return 0;
}

// Not really fond of this...
axi4_master_bfm_t				bfm_type;

