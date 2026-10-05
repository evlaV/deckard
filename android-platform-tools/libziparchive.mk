-include ../trace-build-init.mk
############################################################################
# sources
LZA_SOURCES := \
  system/libziparchive/zip_archive.cc \
  system/libziparchive/zip_archive_stream_entry.cc \
  system/libziparchive/zip_cd_entry_map.cc \
  system/libziparchive/zip_error.cpp \
  system/libziparchive/zip_writer.cc \

LZA_SOURCES_CPP := $(filter %.cpp,$(LZA_SOURCES))
LZA_OBJECTS_CPP := $(LZA_SOURCES_CPP:.cpp=.o)

LZA_SOURCES_CC  := $(filter %.cc,$(LZA_SOURCES))
LZA_OBJECTS_CC  := $(LZA_SOURCES_CC:.cc=.o)

LZA_SO_MAJOR    := 0

############################################################################
# flags
LZA_CPPFLAGS := \
  -DINCFS_SUPPORT_DISABLED=1 \
  -DZLIB_CONST \
  -D_FILE_OFFSET_BITS=64 \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/libziparchive/incfs_support/include \
  -I$(INCROOT)/system/libziparchive/include \
  -I$(INCROOT)/system/logging/liblog/include \

LZA_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -Wl,-soname,libziparchive.so.$(LZA_SO_MAJOR) \
  -lbase \
  -llog \
  -lpthread \
  -lz \
  -shared

############################################################################
# dependencies and build flags
o/system/libziparchive.so: CFLAGS   := $(BASE_CFLAGS)   $(LZA_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libziparchive.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LZA_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libziparchive.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LZA_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libziparchive.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LZA_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libziparchive.so: SO_MAJOR := $(LZA_SO_MAJOR)
o/system/libziparchive.so: | o/system/libbase.so o/system/liblog.so
o/system/libziparchive.so: $(LZA_OBJECTS_CC) $(LZA_OBJECTS_CPP)

OBJ_CC  += $(LZA_OBJECTS_CC)
OBJ_CPP += $(LZA_OBJECTS_CPP)
BUILT   += o/system/libziparchive.so
############################################################################
# clean
clean-libziparchive.so:
	@rm -vf $(LZA_OBJECTS_CC) $(LZA_OBJECTS_CPP)
	@rm -vf o/system/libziparchive.so{,.$(LZA_SO_MAJOR)}

clean: clean-libziparchive.so

############################################################################
# install
INCLUDES  += $(INCROOT)/system/libziparchive/include/ziparchive
LIBRARIES += o/system/libziparchive.so
LIBRARIES += o/system/libziparchive.so.$(LZA_SO_MAJOR)

############################################################################
-include ../trace-build-exit.mk
