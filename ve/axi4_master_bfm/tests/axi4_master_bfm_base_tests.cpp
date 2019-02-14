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
		bfm->read32(i);
	}
//	bfm->wait_reset();

	fprintf(stdout, "SMOKETEST\n");
	run();
}
