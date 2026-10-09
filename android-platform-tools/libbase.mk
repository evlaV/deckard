-include ../trace-build-init.mk
############################################################################
# sources
LBASE_SOURCES := \
  system/libbase/abi_compatibility.cpp \
  system/libbase/chrono_utils.cpp \
  system/libbase/cmsg.cpp \
  system/libbase/file.cpp \
  system/libbase/hex.cpp \
  system/libbase/logging.cpp \
  system/libbase/mapped_file.cpp \
  system/libbase/parsebool.cpp \
  system/libbase/parsenetaddress.cpp \
  system/libbase/posix_strerror_r.cpp \
  system/libbase/process.cpp \
  system/libbase/properties.cpp \
  system/libbase/stringprintf.cpp \
  system/libbase/strings.cpp \
  system/libbase/threads.cpp \
  system/libbase/test_utils.cpp \
  system/libbase/errors_unix.cpp \
  external/fmtlib/src/format.cc

LBASE_SOURCES_CPP := $(filter %.cpp,$(LBASE_SOURCES))
LBASE_OBJECTS_CPP := $(LBASE_SOURCES_CPP:.cpp=.o)

LBASE_SOURCES_CC  := $(filter %.cc,$(LBASE_SOURCES))
LBASE_OBJECTS_CC  := $(LBASE_SOURCES_CC:.cc=.o)

LBASE_SO_MAJOR    := 0

############################################################################
# flags
LBASE_CPPFLAGS := \
  -D_FILE_OFFSET_BITS=64 \
  -I$(INCROOT)/external/fmtlib/include \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/logging/liblog/include \

LBASE_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -Wl,-soname,libbase.so.$(LBASE_SO_MAJOR) \
  -llog \
  -lpthread \
  -shared

############################################################################
# dependencies and build flags
o/system/libbase.so: CFLAGS   := $(BASE_CFLAGS)   $(LBASE_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libbase.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LBASE_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libbase.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LBASE_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libbase.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LBASE_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libbase.so: SO_MAJOR := $(LBASE_SO_MAJOR)
o/system/libbase.so: | o/system/liblog.so
o/system/libbase.so: $(LBASE_OBJECTS_CC) $(LBASE_OBJECTS_CPP)

OBJ_CC  += $(LBASE_OBJECTS_CC)
OBJ_CPP += $(LBASE_OBJECTS_CPP)
BUILT   += o/system/libbase.so

###########################################################################
# clean
clean-libbase.so:
	@rm -vf $(LBASE_OBJECTS_CC) $(LBASE_OBJECTS_CPP)
	@rm -vf o/system/libbase.so{,.$(LBASE_SO_MAJOR)}

clean: clean-libbase.so

############################################################################
# install
INCLUDES  += $(INCROOT)/system/libbase/include/android-base
INCLUDES  += $(INCROOT)/external/fmtlib/include/fmt
LIBRARIES += o/system/libbase.so
LIBRARIES += o/system/libbase.so.$(LBASE_SO_MAJOR)
############################################################################
-include ../trace-build-exit.mk
