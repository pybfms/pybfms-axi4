
AXI4_BFMS_MKFILES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifneq (1,$(RULES))

AXI4_BFMS := $(abspath $(AXI4_BFMS_MKFILES_DIR)/..)
export AXI4_BFMS

else # Rules

endif
