-include ../trace-build-init.mk
############################################################################
# sources
LX4U_SOURCES := \
  system/extras/ext4_utils/ext4_utils.cpp \
  system/extras/ext4_utils/wipe.cpp \
  system/extras/ext4_utils/ext4_sb.cpp \
  system/extras/squashfs_utils/squashfs_utils.c

LX4U_SOURCES_CPP := $(filter %.cpp,$(LX4U_SOURCES))
LX4U_OBJECTS_CPP := $(LX4U_SOURCES_CPP:.cpp=.o)

LX4U_SOURCES_C   := $(filter %.c,$(LX4U_SOURCES))
LX4U_OBJECTS_C   := $(LX4U_SOURCES_C:.c=.o)

############################################################################
# flags
LX4U_CPPFLAGS := \
  -D_GNU_SOURCE \
  -D_LARGEFILE64_SOURCE \
  -DFEC_NO_KLOG \
  -DSQUASHFS_NO_KLOG \
  -I/usr/include/android \
  -I$(INCROOT)/system/core/libcutils/include \
  -I$(INCROOT)/system/core/libsparse/include \
  -I$(INCROOT)/system/extras/ext4_utils/include \
  -I$(INCROOT)/system/extras/libfec/include \
  -I$(INCROOT)/system/extras/squashfs_utils \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/external/squashfs-tools/squashfs-tools

############################################################################
# dependencies and build flags
o/system/libext4_utils.a: CFLAGS   := $(BASE_CFLAGS)   $(LX4U_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libext4_utils.a: CPPFLAGS := $(BASE_CPPFLAGS) $(LX4U_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libext4_utils.a: LDFLAGS  := $(BASE_LDFLAGS)  $(LX4U_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libext4_utils.a: CXXFLAGS := $(BASE_CXXFLAGS) $(LX4U_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libext4_utils.a: $(LX4U_OBJECTS_C) $(LX4U_OBJECTS_CPP)

OBJ_C   += $(LX4U_OBJECTS_C)
OBJ_CPP += $(LX4U_OBJECTS_CPP)
BUILT   += o/system/libext4_utils.a

############################################################################
# clean
clean-libext4_utils.a:
	@rm -vf $(LX4U_OBJECTS_C) $(LX4U_OBJECTS_CPP)
	@rm -vf o/system/libext4_utils.a

clean: clean-libext4_utils.a

############################################################################
-include ../trace-build-exit.mk
