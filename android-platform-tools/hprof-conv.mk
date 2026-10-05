-include ../trace-build-init.mk
############################################################################
# sources
HPC_SOURCES := dalvik/tools/hprof-conv/HprofConv.c

HPC_SOURCES_C := $(filter %.c,$(HPC_SOURCES))
HPC_OBJECTS_C := $(HPC_SOURCES_C:.c=.o)

############################################################################
# flags
HPC_LDFLAGS := -pie

############################################################################
# dependencies and build flags
o/dalvik/hprof-conv: CFLAGS   := $(BASE_CFLAGS)   $(HPC_CFLAGS)   $(EXTRA_CFLAGS)
o/dalvik/hprof-conv: CPPFLAGS := $(BASE_CPPFLAGS) $(HPC_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/dalvik/hprof-conv: LDFLAGS  := $(BASE_LDFLAGS)  $(HPC_LDFLAGS)  $(EXTRA_LDFLAGS)
o/dalvik/hprof-conv: CXXFLAGS := $(BASE_CXXFLAGS) $(HPC_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/dalvik/hprof-conv: $(HPC_OBJECTS_C) 

############################################################################
# built objects
OBJ_C   += $(HPC_OBJECTS_C)
BUILT   += o/dalvik/hprof-conv

############################################################################
# clean
clean-hprof-conv: OBJ := $(HPC_OBJECTS_C)
clean-hprof-conv:
	@rm -vf $(OBJ)
	@rm -vf o/dalvik/hprof-conv
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-hprof-conv
############################################################################
# install
USR_BINS += o/dalvik/hprof-conv

############################################################################
-include ../trace-build-exit.mk
