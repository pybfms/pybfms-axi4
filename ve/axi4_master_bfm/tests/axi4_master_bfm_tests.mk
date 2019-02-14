

axi4_master_bfm_TESTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(axi4_master_bfm_TESTS_DIR)
# TODO: Add source directories for each relevant sub-directory

axi4_master_bfm_TESTS_SRC := $(notdir $(wildcard $(axi4_master_bfm_TESTS_DIR)/*.cpp))

else # Rules


libaxi4_master_bfm_tests.o : $(axi4_master_bfm_TESTS_SRC:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(axi4_master_bfm_TESTS_SRC:.cpp=.o)
        

endif