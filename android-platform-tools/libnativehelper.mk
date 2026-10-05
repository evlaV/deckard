-include ../trace-build-init.mk
############################################################################
# sources
LNH_SOURCES := \
  libnativehelper/DlHelp.c \
  libnativehelper/ExpandableString.c \
  libnativehelper/JNIHelp.c \
  libnativehelper/JNIPlatformHelp.c \
  libnativehelper/JniConstants.c \
  libnativehelper/JniInvocation.c \
  libnativehelper/file_descriptor_jni.c

LNH_SOURCES_C := $(filter %.c,$(LNH_SOURCES))
LNH_OBJECTS_C := $(LNH_SOURCES_C:.c=.o)

LNH_SO_MAJOR  := 0

############################################################################
# flags
LNH_CPPFLAGS := \
  -I/usr/include/android \
  -I$(INCROOT)/libnativehelper/header_only_include \
  -I$(INCROOT)/libnativehelper/include \
  -I$(INCROOT)/libnativehelper/include_jni \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/logging/liblog/include

LNH_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -Wl,-soname,libnativehelper.so.$(LNH_SO_MAJOR) \
  -ldl \
  -llog \
  -lpthread \
  -shared

############################################################################
# dependencies and build flags
o/libnativehelper/libnativehelper.so: CFLAGS   := $(BASE_CFLAGS)   $(LNH_CFLAGS)   $(EXTRA_CFLAGS)
o/libnativehelper/libnativehelper.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LNH_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/libnativehelper/libnativehelper.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LNH_LDFLAGS)  $(EXTRA_LDFLAGS)
o/libnativehelper/libnativehelper.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LNH_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/libnativehelper/libnativehelper.so: SO_MAJOR := $(LNH_SO_MAJOR)
o/libnativehelper/libnativehelper.so: | o/system/liblog.so
o/libnativehelper/libnativehelper.so: $(LNH_OBJECTS_C)

OBJ_C += $(LNH_OBJECTS_C)
BUILT += o/libnativehelper/libnativehelper.so

############################################################################
# clean
clean-libnativehelper.so:
	@rm -vf $(LNH_OBJECTS_C)
	@rm -vf o/libnativehelper/libnativehelper.so{,.$(LNH_SO_MAJOR)}

clean: clean-libnativehelper.so

############################################################################
# install
LNH_INC   := $(INCROOT)/libnativehelper
INCLUDES  += $(wildcard $(LNH_INC)/include_jni/*)
INCLUDES  += $(wildcard $(LNH_INC)/include_platform/*)
INCLUDES  += $(wildcard $(LNH_INC)/include_platform_header_only/*)
INCLUDES  += $(LNH_INC)/include/nativehelper
INCLUDES  += $(LNH_INC)/header_only_include/nativehelper
LIBRARIES += o/libnativehelper/libnativehelper.so
LIBRARIES += o/libnativehelper/libnativehelper.so.$(LLOG_SO_MAJOR)

############################################################################
-include ../trace-build-exit.mk
