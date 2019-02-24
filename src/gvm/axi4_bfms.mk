
AXI4_BFMS_GVM_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
AXI4_BFMS_DIR := $(abspath $(AXI4_BFMS_GVM_DIR)../..)

ifneq (1,$(RULES))

DPI_OBJS_LIBS += libaxi4_bfms.o
AXI4_BFMS_GVM_SRCS = \
	$(notdir $(wildcard $(AXI4_BFMS_GVM_DIR)/*.cpp)) \
	$(notdir $(wildcard $(AXI4_BFMS_DIR)/src-gen/gvm/*.cpp))
SRC_DIRS += $(AXI4_BFMS_GVM_DIR) $(AXI4_BFMS_DIR)/src-gen/gvm

else # Rules

libaxi4_bfms.o : $(AXI4_BFMS_GVM_SRCS:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(AXI4_BFMS_GVM_SRCS:.cpp=.o)

endif
