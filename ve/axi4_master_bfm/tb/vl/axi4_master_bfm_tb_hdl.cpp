/****************************************************************************
 * axi4_master_bfm_tb_hdl.cpp
 ****************************************************************************/

#include "axi4_master_bfm_tb_hdl.h"
#include <stdio.h>


axi4_master_bfm_tb_hdl::axi4_master_bfm_tb_hdl() {
        addClock(top()->clock, 10);
}

axi4_master_bfm_tb_hdl::~axi4_master_bfm_tb_hdl() {

}

void axi4_master_bfm_tb_hdl::SetUp() {
}

// Register this top-level with the GoogletestVl system
static GoogletestVlEngineFactory<axi4_master_bfm_tb_hdl>         prv_factory;
