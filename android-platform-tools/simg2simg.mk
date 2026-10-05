-include ../trace-build-init.mk
############################################################################
# sources
S2S_SOURCES := \
  system/core/libsparse/simg2simg.cpp \
  system/core/libsparse/sparse_crc32.cpp

S2S_SOURCES_CPP := $(filter %.cpp,$(S2S_SOURCES))
S2S_OBJECTS_CPP := $(S2S_SOURCES_CPP:.cpp=.o)

############################################################################
# flags
S2S_CXXFLAGS := -fpermissive

S2S_CPPFLAGS := -I$(INCROOT)/system/core/libsparse/include

S2S_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lbase \
  -llog \
  -lpthread \
  -lsparse \
  -pie

############################################################################
# dependencies and build flags
o/system/simg2simg: CFLAGS   := $(BASE_CFLAGS)   $(S2S_CFLAGS)   $(EXTRA_CFLAGS)
o/system/simg2simg: CPPFLAGS := $(BASE_CPPFLAGS) $(S2S_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/simg2simg: LDFLAGS  := $(BASE_LDFLAGS)  $(S2S_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/simg2simg: CXXFLAGS := $(BASE_CXXFLAGS) $(S2S_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/simg2simg: | o/system/libbase.so o/system/liblog.so o/system/libsparse.so
o/system/simg2simg: $(S2S_OBJECTS_CPP)

############################################################################
# built objects
OBJ_CPP += $(S2S_OBJECTS_CPP)
BUILT   += o/system/simg2simg
############################################################################
# clean
clean-simg2simg: OBJ := $(S2S_OBJECTS_CPP)
clean-simg2simg:
	@rm -vf $(OBJ)
	@rm -vf o/system/simg2simg
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-simg2simg

############################################################################
# install
USR_BINS += o/system/simg2simg

############################################################################
-include ../trace-build-exit.mk
