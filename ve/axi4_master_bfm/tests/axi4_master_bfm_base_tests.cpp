/****************************************************************************
 * axi4_master_bfm_base_tests.cpp
 ****************************************************************************/

#include "axi4_master_bfm_base_tests.h"
#include "axi4_master_bfm.h"
#include <stdio.h>

void axi4_master_bfm_base_tests::SetUp() {
}

void axi4_master_bfm_base_tests::TearDown() {
}

void axi4_master_bfm_base_tests::run() {
	GoogletestHdl::run();
}

/**
 * smoke test
 */
TEST_F(axi4_master_bfm_base_tests,smoke) {
	const CmdlineProcessor &clp = GoogletestHdl::clp();

	axi4_master_bfm *bfm = axi4_master_bfm_t::bfm("*.u_bfm");

	for (int i=0; i<16; i+=4) {
		bfm->write32(i, (i+1));
	}

	for (int i=0; i<16; i+=4) {
		uint32_t data = bfm->read32(i);
		fprintf(stdout, "data=0x%08x\n", data);
		EXPECT_EQ(data, i+1);
	}

//	bfm->wait_reset();

	fprintf(stdout, "SMOKETEST\n");
	run();
}
