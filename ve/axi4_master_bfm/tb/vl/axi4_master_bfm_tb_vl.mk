

axi4_master_bfm_TB_VL_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

ifeq (vl,$(SIM))
SRC_DIRS += $(axi4_master_bfm_TB_VL_DIR)
endif

axi4_master_bfm_TB_VL_SRC_FILES=$(wildcard $(axi4_master_bfm_TB_VL_DIR)/*.cpp)
axi4_master_bfm_TB_VL_SRC=$(notdir $(axi4_master_bfm_TB_VL_SRC_FILES))

else # Rules

# Compilation of the testbench wrapper requires the
# translated header files produced by vl_translate.d
libaxi4_master_bfm_tb_vl.o : axi4_master_bfm_tb_hdl.cpp vl_translate.d
	$(Q)$(CXX) -c -o $@ $(CXXFLAGS) $(filter %.cpp,$(^))

endif
