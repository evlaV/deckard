-include ../trace-build-init.mk
############################################################################
# sources
S2I_SOURCES := \
  system/core/libsparse/simg2img.cpp \
  system/core/libsparse/sparse_crc32.cpp

S2I_SOURCES_CPP := $(filter %.cpp,$(S2I_SOURCES))
S2I_OBJECTS_CPP := $(S2I_SOURCES_CPP:.cpp=.o)

############################################################################
# flags
S2I_CPPFLAGS := -I$(INCROOT)/system/core/libsparse/include

S2I_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lbase \
  -llog \
  -lpthread \
  -lsparse \
  -pie

############################################################################
# dependencies and build flags
o/system/simg2img: CFLAGS   := $(BASE_CFLAGS)   $(S2I_CFLAGS)   $(EXTRA_CFLAGS)
o/system/simg2img: CPPFLAGS := $(BASE_CPPFLAGS) $(S2I_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/simg2img: LDFLAGS  := $(BASE_LDFLAGS)  $(S2I_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/simg2img: CXXFLAGS := $(BASE_CXXFLAGS) $(S2I_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/simg2img: | o/system/libbase.so o/system/liblog.so o/system/libsparse.so
o/system/simg2img: $(S2I_OBJECTS_CPP)

############################################################################
# built objects
OBJ_CPP += $(S2I_OBJECTS_CPP)
BUILT   += o/system/simg2img

############################################################################
# clean
clean-simg2img: OBJ := $(S2I_OBJECTS_CPP)
clean-simg2img:
	@rm -vf $(OBJ)
	@rm -vf o/system/simg2img
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-simg2img

############################################################################
# install
USR_BINS += o/system/simg2img

############################################################################
-include ../trace-build-exit.mk
