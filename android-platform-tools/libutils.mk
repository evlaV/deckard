-include ../trace-build-init.mk
############################################################################
# sources
LUTILS_SOURCES := \
  system/core/libutils/FileMap.cpp \
  system/core/libutils/JenkinsHash.cpp \
  system/core/libutils/LightRefBase.cpp \
  system/core/libutils/NativeHandle.cpp \
  system/core/libutils/Printer.cpp \
  system/core/libutils/RefBase.cpp \
  system/core/libutils/SharedBuffer.cpp \
  system/core/libutils/StopWatch.cpp \
  system/core/libutils/String8.cpp \
  system/core/libutils/String16.cpp \
  system/core/libutils/StrongPointer.cpp \
  system/core/libutils/SystemClock.cpp \
  system/core/libutils/Threads.cpp \
  system/core/libutils/Timers.cpp \
  system/core/libutils/Tokenizer.cpp \
  system/core/libutils/Unicode.cpp \
  system/core/libutils/VectorImpl.cpp \
  system/core/libutils/misc.cpp \
  system/core/libutils/Looper.cpp

LUTILS_SOURCES_CPP := $(filter %.cpp,$(LUTILS_SOURCES))
LUTILS_OBJECTS_CPP := $(LUTILS_SOURCES_CPP:.cpp=.o)

LUTILS_SO_MAJOR    := 0

############################################################################
# flags
LUTILS_CPPFLAGS := \
  -I$(INCROOT)/system/core/cutils/include \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libcutils/include \
  -I$(INCROOT)/system/core/libprocessgroup/include \
  -I$(INCROOT)/system/incremental_delivery/incfs/util/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/logging/liblog/include

LUTILS_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -Wl,-soname,libutils.so.$(LUTILS_SO_MAJOR) \
  -lbacktrace \
  -lcutils \
  -llog \
  -lpthread \
  -shared

############################################################################
# dependencies and build flags
o/system/libutils.so: CFLAGS   := $(BASE_CFLAGS)   $(LUTILS_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libutils.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LUTILS_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libutils.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LUTILS_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libutils.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LUTILS_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libutils.so: SO_MAJOR := $(LUTILS_SO_MAJOR)
o/system/libutils.so: | o/system/libbacktrace.so o/system/libcutils.so o/system/liblog.so
o/system/libutils.so: $(LUTILS_OBJECTS_CPP)

OBJ_CPP += $(LUTILS_OBJECTS_CPP)
BUILT   += o/system/libutils.so

############################################################################
# clean
clean-libutils.so:
	@rm -vf $(LUTILS_OBJECTS_CPP)
	@rm -vf o/system/libutils.so{,.$(LUTILS_SO_MAJOR)}

clean: clean-libutils.so

############################################################################
# install
INCLUDES  += $(INCROOT)/system/core/libutils/include/utils
INCLUDES  += $(INCROOT)/system/incremental_delivery/incfs/util/include/util
LIBRARIES += o/system/libutils.so
LIBRARIES += o/system/libutils.so.$(LUTILS_SO_MAJOR)

############################################################################
-include ../trace-build-exit.mk
