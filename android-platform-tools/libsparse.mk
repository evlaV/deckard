-include ../trace-build-init.mk
############################################################################
# sources
LSPARSE_SOURCES := \
  system/core/libsparse/backed_block.cpp \
  system/core/libsparse/output_file.cpp \
  system/core/libsparse/sparse.cpp \
  system/core/libsparse/sparse_crc32.cpp \
  system/core/libsparse/sparse_err.cpp \
  system/core/libsparse/sparse_read.cpp

LSPARSE_SOURCES_CPP := $(filter %.cpp,$(LSPARSE_SOURCES))
LSPARSE_OBJECTS_CPP := $(LSPARSE_SOURCES_CPP:.cpp=.o)

LSPARSE_SO_MAJOR    := 0

############################################################################
# flags
LSPARSE_CPPFLAGS := \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libsparse/include \
  -I$(INCROOT)/system/libbase/include \

LSPARSE_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -Wl,-soname,libsparse.so.$(LSPARSE_SO_MAJOR) \
  -lbase \
  -lz \
  -shared

############################################################################
# dependencies and build flags
o/system/libsparse.so: CFLAGS   := $(BASE_CFLAGS)   $(LSPARSE_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libsparse.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LSPARSE_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libsparse.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LSPARSE_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libsparse.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LSPARSE_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libsparse.so: SO_MAJOR := $(LSPARSE_SO_MAJOR)
o/system/libsparse.so: | o/system/libbase.so
o/system/libsparse.so: $(LSPARSE_OBJECTS_CC) $(LSPARSE_OBJECTS_CPP)

OBJ_CPP += $(LSPARSE_OBJECTS_CPP)
BUILT   += o/system/libsparse.so

############################################################################
# clean
clean-libsparse.so:
	@rm -vf $(LSPARSE_OBJECTS_CC) $(LSPARSE_OBJECTS_CPP)
	@rm -vf o/system/libsparse.so{,.$(LSPARSE_SO_MAJOR)}

clean: clean-libsparse.so

############################################################################
# install
INCLUDES  += $(INCROOT)/system/core/libsparse/include/sparse
LIBRARIES += o/system/libsparse.so
LIBRARIES += o/system/libsparse.so.$(LSPARSE_SO_MAJOR)
############################################################################
-include ../trace-build-exit.mk
