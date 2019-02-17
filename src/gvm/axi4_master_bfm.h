/*
 * axi4_master_bfm.h
 *
 *  Created on: Feb 3, 2019
 *      Author: ballance
 */
#pragma once
#include "GvmBfm.h"
#include "GvmBfmType.h"
#include "GvmMutex.h"
#include "GvmCond.h"
#include "axi4_master_bfm_rsp_if.h"



class axi4_master_bfm :
		public GvmBfm<axi4_master_bfm_rsp_if>,
		public virtual axi4_master_bfm_rsp_if {
public:
	axi4_master_bfm();

	virtual ~axi4_master_bfm();

	virtual void init(const std::string &path, void *ctxt);

	virtual uint32_t read32(uint64_t addr);

	virtual void write32(
			uint64_t 	addr,
			uint32_t	data);

	virtual void arreq(
			uint64_t			addr,
			uint32_t			arid,
			uint8_t				arlen,
			uint8_t				arsize,
			uint8_t				arburst,
			uint8_t				arcache,
			uint8_t				arprot,
			uint8_t				arregion
			);

	virtual void awreq(
			uint64_t			addr,
			uint32_t			arid,
			uint8_t				arlen,
			uint8_t				arsize,
			uint8_t				arburst,
			uint8_t				arcache,
			uint8_t				arprot,
			uint8_t				arregion
			);

	// Notifies the C++ side of the BFM that the read-request has been accepted
	virtual void arreq_ack();

	// Notifies the C++ side of the BFM that the write-request has been accepted
	virtual void awreq_ack();

	virtual void wdata_ack();

	virtual void bresp(uint32_t bid, uint8_t resp);

	// Notifies that a read-response has been received
	virtual void rresp(
			uint32_t			rid,
			uint64_t			rdata,
			uint8_t				rresp,
			uint8_t				rlast
			);

	virtual void reset();

	void wait_reset();

protected:

	uint32_t alloc_id();

	void free_id(uint32_t id);

	class notifier {
	public:
		bool					m_valid;
		bool					m_ready;
		GvmMutex				m_ready_mutex;
		GvmCond					m_ready_cond;

		notifier() : m_valid(false), m_ready(false) { }

		void set_valid() { m_valid = true; }

		virtual void wait() {
			m_ready_mutex.lock();
			while (!m_ready) {
				m_ready_cond.wait(m_ready_mutex);
			}
			m_ready = false;
			m_ready_mutex.unlock();
		}

		virtual void notify() {
			m_ready_mutex.lock();
			m_ready = true;
			m_ready_cond.notify();
			m_ready_mutex.unlock();
		}
	};

	class rresp_data : public notifier {
	public:
		uint64_t				m_data[16]; // size for 1024-width bus
		bool					m_last;

		void init() {
			m_last = false;
			set_valid();
		}

		bool last() const { return m_last; }

		void set_data(uint32_t idx, uint64_t data) {
			m_data[idx] = data;
		}

		uint64_t get_data(uint32_t idx) {
			return m_data[idx];
		}

		void wait(uint64_t &data, bool &last) {
			notifier::wait();
			data = m_data[0];
			last = m_last;
		}

		void notify(uint64_t data, bool last) {
			m_last = last;
			m_data[0] = data;
			notifier::notify();
		}
	};

	class bresp_data : public notifier {
	public:
		uint8_t					m_bresp;

		void notify(uint8_t resp) {
			m_bresp = resp;
			notifier::notify();
		}
	};

private:
	bool						m_is_reset;
	GvmMutex					m_is_reset_mutex;
	GvmCond						m_is_reset_cond;

	bool						*m_id_pool;
	uint32_t					m_id_pool_sz;
	GvmMutex					m_id_pool_mutex;
	GvmCond						m_id_pool_cond;

	GvmMutex					m_read_mutex;

	bool						m_recv_arreq;
	GvmMutex					m_recv_arreq_mutex;
	GvmCond						m_recv_arreq_cond;

	bool						m_recv_awreq;
	GvmMutex					m_recv_awreq_mutex;
	GvmCond						m_recv_awreq_cond;

	bool						m_recv_wdata;
	GvmMutex					m_recv_wdata_mutex;
	GvmCond						m_recv_wdata_cond;

	rresp_data					*m_rresp_notifiers;
	bresp_data					*m_bresp_notifiers;
};

typedef GvmBfmType<axi4_master_bfm>				axi4_master_bfm_t;

