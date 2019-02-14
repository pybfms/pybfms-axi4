/****************************************************************************
 * axi4_master_bfm_tb_hdl.h
 ****************************************************************************/

#ifndef INCLUDED_axi4_master_bfm_TB_HDL_H
#define INCLUDED_axi4_master_bfm_TB_HDL_H
#include "GoogletestVlEngine.h"
#include "Vaxi4_master_bfm_tb_hdl.h"

using namespace gtest_hdl;

class axi4_master_bfm_tb_hdl : public GoogletestVlEngine<Vaxi4_master_bfm_tb_hdl> {
public:
        axi4_master_bfm_tb_hdl();

        virtual ~axi4_master_bfm_tb_hdl();

        virtual void SetUp();

};


#endif /* INCLUDED_axi4_master_bfm_TB_HDL_H */
