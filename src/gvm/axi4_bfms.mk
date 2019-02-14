
AXI4_BFMS_GVM_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

DPI_OBJS_LIBS += libaxi4_bfms.o
AXI4_BFMS_GVM_SRCS = $(notdir $(wildcard $(AXI4_BFMS_GVM_DIR)/*.cpp))
SRC_DIRS += $(AXI4_BFMS_GVM_DIR)

else # Rules

libaxi4_bfms.o : $(AXI4_BFMS_GVM_SRCS:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(AXI4_BFMS_GVM_SRCS:.cpp=.o)

endif
